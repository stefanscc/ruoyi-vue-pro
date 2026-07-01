package ingestion

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"sort"
	"strings"
	"time"

	"ems-ingestion/internal/config"
)

type TDengineClient struct {
	cfg    config.Config
	client *http.Client
}

func NewTDengineClient(cfg config.Config) *TDengineClient {
	return &TDengineClient{
		cfg:    cfg,
		client: &http.Client{Timeout: 15 * time.Second},
	}
}

func (c *TDengineClient) Exec(ctx context.Context, sql string) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.cfg.TDengineURL+"/rest/sql", bytes.NewBufferString(sql))
	if err != nil {
		return err
	}
	req.SetBasicAuth(c.cfg.TDengineUser, c.cfg.TDenginePassword)
	resp, err := c.client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return fmt.Errorf("tdengine status=%d body=%s", resp.StatusCode, strings.TrimSpace(string(body)))
	}
	var result struct {
		Code int    `json:"code"`
		Desc string `json:"desc"`
	}
	if err := json.Unmarshal(body, &result); err == nil && result.Code != 0 {
		return fmt.Errorf("tdengine code=%d desc=%s body=%s", result.Code, result.Desc, strings.TrimSpace(string(body)))
	}
	return nil
}

func (c *TDengineClient) EnsureMessageStable(ctx context.Context) error {
	db := ident(c.cfg.TDengineDatabase)
	sql := fmt.Sprintf(`CREATE STABLE IF NOT EXISTS %s.device_message (
		ts TIMESTAMP,
		id NCHAR(50),
		report_time TIMESTAMP,
		server_id NCHAR(50),
		upstream BOOL,
		reply BOOL,
		identifier NCHAR(100),
		request_id NCHAR(50),
		method NCHAR(100),
		params VARCHAR(8192),
		data VARCHAR(8192),
		code INT,
		msg NCHAR(256)
	) TAGS (device_id BIGINT)`, db)
	return c.Exec(ctx, sql)
}

func (c *TDengineClient) EnsureProductPropertyTables(ctx context.Context, snapshot CacheSnapshot) error {
	for productID, models := range snapshot.ThingModels {
		if err := c.ensureProductPropertyTable(ctx, productID, models); err != nil {
			return err
		}
	}
	return nil
}

func (c *TDengineClient) ensureProductPropertyTable(ctx context.Context, productID int64, models map[string]ThingModel) error {
	db := ident(c.cfg.TDengineDatabase)
	table := fmt.Sprintf("%s.product_property_%d", db, productID)
	columns := make([]string, 0, len(models))
	for _, model := range models {
		if model.Type != 1 {
			continue
		}
		columns = append(columns, fmt.Sprintf("%s %s", ident(toUnderline(model.Identifier)), tdType(model)))
	}
	sort.Strings(columns)
	body := "ts TIMESTAMP, report_time TIMESTAMP"
	if len(columns) > 0 {
		body += ", " + strings.Join(columns, ", ")
	}
	if err := c.Exec(ctx, fmt.Sprintf("CREATE STABLE IF NOT EXISTS %s (%s) TAGS (device_id BIGINT)", table, body)); err != nil {
		return err
	}
	for _, model := range models {
		if model.Type != 1 {
			continue
		}
		sql := fmt.Sprintf("ALTER STABLE %s ADD COLUMN %s %s", table, ident(toUnderline(model.Identifier)), tdType(model))
		if err := c.Exec(ctx, sql); err != nil {
			if !strings.Contains(strings.ToLower(err.Error()), "exist") {
				return err
			}
		}
	}
	return nil
}

func (c *TDengineClient) InsertMessage(ctx context.Context, msg DeviceMessage, identifier string) error {
	db := ident(c.cfg.TDengineDatabase)
	params := jsonCompact(msg.Params)
	data := jsonCompact(msg.Data)
	code := "NULL"
	if msg.Code != nil {
		code = fmt.Sprintf("%d", *msg.Code)
	}
	sql := fmt.Sprintf(`INSERT INTO %s.device_message_%d (
		ts, id, report_time, server_id, upstream, reply, identifier, request_id, method, params, data, code, msg
	) USING %s.device_message TAGS (%d) VALUES (
		%d, '%s', %d, '%s', %t, %t, '%s', '%s', '%s', '%s', '%s', %s, '%s'
	)`,
		db, msg.DeviceID, db, msg.DeviceID,
		time.Now().UnixMilli(), esc(msg.ID), msg.ReportTime.UnixMilli(), esc(msg.ServerID),
		msg.IsUpstream(), msg.IsReply(), esc(identifier), esc(msg.RequestID), esc(msg.Method), esc(params), esc(data), code, esc(msg.Msg))
	return c.Exec(ctx, sql)
}

func (c *TDengineClient) InsertProperties(ctx context.Context, device Device, reportTime time.Time, properties map[string]any, models map[string]ThingModel) error {
	if len(properties) == 0 {
		return nil
	}
	db := ident(c.cfg.TDengineDatabase)
	keys := make([]string, 0, len(properties))
	for key := range properties {
		if _, ok := models[strings.ToLower(key)]; ok {
			keys = append(keys, key)
		}
	}
	sort.Strings(keys)
	if len(keys) == 0 {
		return nil
	}
	columns := []string{"ts", "report_time"}
	values := []string{fmt.Sprintf("%d", time.Now().UnixMilli()), fmt.Sprintf("%d", reportTime.UnixMilli())}
	for _, key := range keys {
		model := models[strings.ToLower(key)]
		columns = append(columns, ident(toUnderline(model.Identifier)))
		values = append(values, tdValue(properties[key], model))
	}
	sql := fmt.Sprintf("INSERT INTO %s.device_property_%d USING %s.product_property_%d TAGS (%d) (%s) VALUES (%s)",
		db, device.ID, db, device.ProductID, device.ID, strings.Join(columns, ", "), strings.Join(values, ", "))
	return c.Exec(ctx, sql)
}

func tdType(model ThingModel) string {
	switch strings.ToLower(model.DataType) {
	case "int":
		return "BIGINT"
	case "float":
		return "FLOAT"
	case "double":
		return "DOUBLE"
	case "bool":
		return "BOOL"
	case "array", "struct":
		return "VARCHAR(4096)"
	case "text":
		if model.Length > 0 {
			return fmt.Sprintf("NCHAR(%d)", model.Length)
		}
		return "NCHAR(512)"
	default:
		return "NCHAR(512)"
	}
}

func tdValue(value any, model ThingModel) string {
	switch strings.ToLower(model.DataType) {
	case "int", "float", "double":
		return fmt.Sprintf("%v", value)
	case "bool":
		if b, ok := value.(bool); ok {
			if b {
				return "true"
			}
			return "false"
		}
		return fmt.Sprintf("%v", value)
	case "array", "struct":
		return "'" + esc(jsonCompact(value)) + "'"
	default:
		return "'" + esc(fmt.Sprintf("%v", value)) + "'"
	}
}

var safeIdent = regexp.MustCompile(`[^a-zA-Z0-9_]`)

func ident(value string) string {
	return safeIdent.ReplaceAllString(value, "_")
}

func esc(value string) string {
	return strings.ReplaceAll(value, "'", "''")
}

func toUnderline(value string) string {
	var out strings.Builder
	for i, r := range value {
		if i > 0 && r >= 'A' && r <= 'Z' {
			out.WriteByte('_')
		}
		out.WriteRune(r)
	}
	return strings.ToLower(out.String())
}
