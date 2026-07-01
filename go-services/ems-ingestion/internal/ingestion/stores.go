package ingestion

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
)

func UpdateDeviceReportState(ctx context.Context, pg *pgxpool.Pool, deviceID int64, state int, reportTime time.Time) error {
	if state == DeviceStateOnline {
		_, err := pg.Exec(ctx, `UPDATE iot_device
			SET state = $1, online_time = $2, active_time = COALESCE(active_time, $2), update_time = CURRENT_TIMESTAMP
			WHERE id = $3`, state, reportTime, deviceID)
		return err
	}
	_, err := pg.Exec(ctx, `UPDATE iot_device
		SET state = $1, offline_time = $2, update_time = CURRENT_TIMESTAMP
		WHERE id = $3`, state, reportTime, deviceID)
	return err
}

func UpdateDeviceGateway(ctx context.Context, pg *pgxpool.Pool, deviceID int64, gatewayID *int64) error {
	_, err := pg.Exec(ctx, `UPDATE iot_device SET gateway_id = $1, update_time = CURRENT_TIMESTAMP WHERE id = $2`, gatewayID, deviceID)
	return err
}

func FindDeviceByIdentity(ctx context.Context, pg *pgxpool.Pool, productKey, deviceName string) (Device, bool, error) {
	var d Device
	err := pg.QueryRow(ctx, `SELECT id, device_name, product_id, product_key, device_type,
			gateway_id, state, device_secret
		FROM iot_device
		WHERE deleted = 0 AND product_key = $1 AND device_name = $2
		LIMIT 1`, productKey, deviceName).
		Scan(&d.ID, &d.DeviceName, &d.ProductID, &d.ProductKey, &d.DeviceType, &d.GatewayID, &d.State, &d.DeviceSecret)
	if err == nil {
		return d, true, nil
	}
	if err == pgx.ErrNoRows {
		return Device{}, false, nil
	}
	return Device{}, false, err
}

func RegisterDevice(ctx context.Context, pg *pgxpool.Pool, product Product, deviceName, sign string) (Device, map[string]any, error) {
	if !product.RegisterEnabled {
		return Device{}, nil, fmt.Errorf("product %s dynamic register is disabled", product.ProductKey)
	}
	if !validateProductSign(product, deviceName, sign) {
		return Device{}, nil, fmt.Errorf("product %s register sign is invalid", product.ProductKey)
	}
	if device, ok, err := FindDeviceByIdentity(ctx, pg, product.ProductKey, deviceName); err != nil {
		return Device{}, nil, err
	} else if ok {
		return device, registerResponse(device), nil
	}

	secret := newDeviceSecret()
	device := Device{
		DeviceName:   deviceName,
		ProductID:    product.ID,
		ProductKey:   product.ProductKey,
		DeviceType:   product.DeviceType,
		State:        DeviceStateInactive,
		DeviceSecret: secret,
	}
	err := pg.QueryRow(ctx, `INSERT INTO iot_device (
			id, device_name, nickname, product_id, product_key, device_type, state, device_secret,
			creator, updater, deleted
		) VALUES (
			nextval('iot_device_seq'), $1, $1, $2, $3, $4, $5, $6, 'go-ingestion', 'go-ingestion', 0
		) RETURNING id`,
		deviceName, product.ID, product.ProductKey, product.DeviceType, DeviceStateInactive, secret).
		Scan(&device.ID)
	if err != nil {
		if existing, ok, findErr := FindDeviceByIdentity(ctx, pg, product.ProductKey, deviceName); findErr != nil {
			return Device{}, nil, findErr
		} else if ok {
			return existing, registerResponse(existing), nil
		}
		return Device{}, nil, err
	}
	return device, registerResponse(device), nil
}

func registerResponse(device Device) map[string]any {
	return map[string]any{
		"productKey":   device.ProductKey,
		"deviceName":   device.DeviceName,
		"deviceSecret": device.DeviceSecret,
	}
}

func UpdateRedisRuntime(ctx context.Context, rdb *redis.Client, device Device, serverID string, reportTime time.Time, properties map[string]any) error {
	pipe := rdb.Pipeline()
	pipe.ZAdd(ctx, "iot:device_report_times", redis.Z{Score: float64(reportTime.UnixMilli()), Member: device.ID})
	if serverID != "" {
		pipe.HSet(ctx, "iot:device_server_id", fmt.Sprintf("%d", device.ID), serverID)
	}
	if len(properties) > 0 {
		hash := fmt.Sprintf("iot:device_property:%d", device.ID)
		for key, value := range properties {
			body, _ := json.Marshal(map[string]any{"value": value, "updateTime": reportTime})
			pipe.HSet(ctx, hash, key, string(body))
		}
	}
	_, err := pipe.Exec(ctx)
	return err
}

func Dedupe(ctx context.Context, rdb *redis.Client, ttl time.Duration, msg DeviceMessage) (bool, error) {
	key := fmt.Sprintf("iot:go_ingestion:dedupe:%d:%s:%s", msg.DeviceID, msg.Method, msg.RequestID)
	return rdb.SetNX(ctx, key, "1", ttl).Result()
}

type DatabaseSinkExecutor struct {
	mu           sync.Mutex
	hostOverride string
	pools        map[int64]*pgxpool.Pool
}

func NewDatabaseSinkExecutor(hostOverride string) *DatabaseSinkExecutor {
	return &DatabaseSinkExecutor{hostOverride: hostOverride, pools: map[int64]*pgxpool.Pool{}}
}

func (e *DatabaseSinkExecutor) Execute(ctx context.Context, sink DataSink, msg DeviceMessage) error {
	if sink.Type != DataSinkDatabase {
		return fmt.Errorf("unsupported data sink type %d", sink.Type)
	}
	if sink.Config.TableName == "" {
		return fmt.Errorf("database sink %d tableName is empty", sink.ID)
	}
	tableName := ident(sink.Config.TableName)
	if tableName != sink.Config.TableName {
		return fmt.Errorf("database sink %d tableName must contain only letters, numbers and underscore", sink.ID)
	}
	pool, err := e.pool(ctx, sink)
	if err != nil {
		return err
	}
	body, _ := json.Marshal(msg)
	_, err = pool.Exec(ctx,
		fmt.Sprintf("INSERT INTO %s (id, device_id, method, report_time, data, create_time) VALUES ($1, $2, $3, $4, $5, NOW())", tableName),
		msg.ID, msg.DeviceID, msg.Method, msg.ReportTime, string(body))
	return err
}

func (e *DatabaseSinkExecutor) pool(ctx context.Context, sink DataSink) (*pgxpool.Pool, error) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if pool := e.pools[sink.ID]; pool != nil {
		return pool, nil
	}
	dsn := normalizeJDBCPostgresDSN(sink.Config.JDBCURL, sink.Config.Username, sink.Config.Password, e.hostOverride)
	if dsn == "" {
		return nil, fmt.Errorf("database sink %d only supports jdbc:postgresql URLs", sink.ID)
	}
	pool, err := pgxpool.New(ctx, dsn)
	if err != nil {
		return nil, err
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}
	e.pools[sink.ID] = pool
	return pool, nil
}

func (e *DatabaseSinkExecutor) Close() {
	e.mu.Lock()
	defer e.mu.Unlock()
	for _, pool := range e.pools {
		pool.Close()
	}
	e.pools = map[int64]*pgxpool.Pool{}
}
