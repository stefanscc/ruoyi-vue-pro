package ingestion

import (
	"context"
	"encoding/json"
	"log"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

type ConfigCache struct {
	pg *pgxpool.Pool
	mu sync.RWMutex
	s  CacheSnapshot
}

type CacheSnapshot struct {
	DevicesByKey  map[string]Device
	DevicesByID   map[int64]Device
	ProductsByID  map[int64]Product
	ProductsByKey map[string]Product
	ThingModels   map[int64]map[string]ThingModel
	DataRules     []DataRule
	DataSinks     map[int64]DataSink
	LoadedAt      time.Time
}

func NewConfigCache(pg *pgxpool.Pool) *ConfigCache {
	return &ConfigCache{pg: pg}
}

func (c *ConfigCache) StartAutoReload(ctx context.Context, interval time.Duration, td *TDengineClient) {
	if interval <= 0 {
		return
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := c.Reload(ctx); err != nil {
				log.Printf("cache reload failed: %v", err)
				continue
			}
			if err := td.EnsureProductPropertyTables(ctx, c.Snapshot()); err != nil {
				log.Printf("TDengine property table sync failed: %v", err)
			}
		}
	}
}

func (c *ConfigCache) Snapshot() CacheSnapshot {
	c.mu.RLock()
	defer c.mu.RUnlock()
	return c.s
}

func (c *ConfigCache) Reload(ctx context.Context) error {
	s := CacheSnapshot{
		DevicesByKey:  map[string]Device{},
		DevicesByID:   map[int64]Device{},
		ProductsByID:  map[int64]Product{},
		ProductsByKey: map[string]Product{},
		ThingModels:   map[int64]map[string]ThingModel{},
		DataSinks:     map[int64]DataSink{},
	}
	if err := c.loadProducts(ctx, &s); err != nil {
		return err
	}
	if err := c.loadDevices(ctx, &s); err != nil {
		return err
	}
	if err := c.loadThingModels(ctx, &s); err != nil {
		return err
	}
	if err := c.loadDataSinks(ctx, &s); err != nil {
		return err
	}
	if err := c.loadDataRules(ctx, &s); err != nil {
		return err
	}
	s.LoadedAt = time.Now()
	c.mu.Lock()
	c.s = s
	c.mu.Unlock()
	log.Printf("cache loaded: devices=%d products=%d thingProducts=%d dataRules=%d dataSinks=%d",
		len(s.DevicesByID), len(s.ProductsByID), len(s.ThingModels), len(s.DataRules), len(s.DataSinks))
	return nil
}

func (c *ConfigCache) loadProducts(ctx context.Context, s *CacheSnapshot) error {
	rows, err := c.pg.Query(ctx, `SELECT id, product_key, COALESCE(product_secret, ''), COALESCE(register_enabled, false), device_type
		FROM iot_product WHERE deleted = 0`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var p Product
		if err := rows.Scan(&p.ID, &p.ProductKey, &p.ProductSecret, &p.RegisterEnabled, &p.DeviceType); err != nil {
			return err
		}
		s.ProductsByID[p.ID] = p
		s.ProductsByKey[p.ProductKey] = p
	}
	return rows.Err()
}

func (c *ConfigCache) loadDevices(ctx context.Context, s *CacheSnapshot) error {
	rows, err := c.pg.Query(ctx, `SELECT id, device_name, product_id, product_key, device_type,
			gateway_id, state, device_secret
		FROM iot_device WHERE deleted = 0`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var d Device
		if err := rows.Scan(&d.ID, &d.DeviceName, &d.ProductID, &d.ProductKey, &d.DeviceType, &d.GatewayID, &d.State, &d.DeviceSecret); err != nil {
			return err
		}
		s.DevicesByID[d.ID] = d
		s.DevicesByKey[deviceKey(d.ProductKey, d.DeviceName)] = d
	}
	return rows.Err()
}

func (c *ConfigCache) loadThingModels(ctx context.Context, s *CacheSnapshot) error {
	rows, err := c.pg.Query(ctx, `SELECT id, product_id, product_key, identifier, type, property
		FROM iot_thing_model WHERE deleted = 0`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var m ThingModel
		var propertyJSON *string
		if err := rows.Scan(&m.ID, &m.ProductID, &m.ProductKey, &m.Identifier, &m.Type, &propertyJSON); err != nil {
			return err
		}
		if propertyJSON != nil {
			m.DataType, m.Length = parsePropertyType(*propertyJSON)
		}
		if s.ThingModels[m.ProductID] == nil {
			s.ThingModels[m.ProductID] = map[string]ThingModel{}
		}
		s.ThingModels[m.ProductID][strings.ToLower(m.Identifier)] = m
	}
	return rows.Err()
}

func (c *ConfigCache) loadDataSinks(ctx context.Context, s *CacheSnapshot) error {
	rows, err := c.pg.Query(ctx, `SELECT id, status, type, config FROM iot_data_sink WHERE deleted = 0`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var sink DataSink
		var configJSON string
		if err := rows.Scan(&sink.ID, &sink.Status, &sink.Type, &configJSON); err != nil {
			return err
		}
		if sink.Type == DataSinkDatabase {
			_ = json.Unmarshal([]byte(configJSON), &sink.Config)
		}
		s.DataSinks[sink.ID] = sink
	}
	return rows.Err()
}

func (c *ConfigCache) loadDataRules(ctx context.Context, s *CacheSnapshot) error {
	rows, err := c.pg.Query(ctx, `SELECT id, status, source_configs, sink_ids FROM iot_data_rule WHERE deleted = 0`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var rule DataRule
		var sourceJSON string
		var sinkIDs string
		if err := rows.Scan(&rule.ID, &rule.Status, &sourceJSON, &sinkIDs); err != nil {
			return err
		}
		_ = json.Unmarshal([]byte(sourceJSON), &rule.Sources)
		rule.SinkIDs = parseIDList(sinkIDs)
		s.DataRules = append(s.DataRules, rule)
	}
	return rows.Err()
}

func (s CacheSnapshot) DeviceByIdentity(productKey, deviceName string) (Device, bool) {
	device, ok := s.DevicesByKey[deviceKey(productKey, deviceName)]
	return device, ok
}

func (s CacheSnapshot) DeviceByID(id int64) (Device, bool) {
	device, ok := s.DevicesByID[id]
	return device, ok
}

func (s CacheSnapshot) ThingModel(productID int64, identifier string) (ThingModel, bool) {
	models := s.ThingModels[productID]
	if models == nil {
		return ThingModel{}, false
	}
	model, ok := models[strings.ToLower(identifier)]
	return model, ok
}

func deviceKey(productKey, deviceName string) string {
	return productKey + "/" + deviceName
}

func parseIDList(value string) []int64 {
	parts := strings.Split(value, ",")
	result := make([]int64, 0, len(parts))
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part == "" {
			continue
		}
		id, err := strconv.ParseInt(part, 10, 64)
		if err == nil {
			result = append(result, id)
		}
	}
	return result
}

func parsePropertyType(propertyJSON string) (string, int) {
	var body struct {
		DataType  string `json:"dataType"`
		DataSpecs struct {
			Length int `json:"length"`
		} `json:"dataSpecs"`
	}
	if err := json.Unmarshal([]byte(propertyJSON), &body); err != nil {
		return "text", 0
	}
	return body.DataType, body.DataSpecs.Length
}
