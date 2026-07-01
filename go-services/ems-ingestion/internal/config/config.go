package config

import (
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	ServerID string

	HTTPAddr      string
	InternalToken string

	PostgresDSN string

	DatabaseSinkHostOverride string

	RedisAddr     string
	RedisPassword string
	RedisDB       int

	TDengineURL      string
	TDengineUser     string
	TDenginePassword string
	TDengineDatabase string

	MQTTBroker       string
	MQTTUsername     string
	MQTTPassword     string
	MQTTClientID     string
	MQTTTopics       []string
	MQTTQoS          byte
	MQTTCleanSession bool

	CacheReloadInterval time.Duration
	DedupeTTL           time.Duration

	RetryStream     string
	RetryGroup      string
	RetryConsumer   string
	RetryMaxAttempt int
}

func Load() Config {
	return Config{
		ServerID: env("EMS_INGESTION_SERVER_ID", "go-ingestion-8090"),

		HTTPAddr:      env("EMS_INGESTION_HTTP_ADDR", ":8090"),
		InternalToken: env("EMS_INGESTION_INTERNAL_TOKEN", "change-me"),

		PostgresDSN:              env("EMS_INGESTION_POSTGRES_DSN", "postgres://iot:iot123456@127.0.0.1:5432/ruoyi_vue_pro?sslmode=disable"),
		DatabaseSinkHostOverride: env("EMS_INGESTION_DATABASE_SINK_HOST_OVERRIDE", ""),

		RedisAddr:     env("EMS_INGESTION_REDIS_ADDR", "127.0.0.1:6379"),
		RedisPassword: env("EMS_INGESTION_REDIS_PASSWORD", ""),
		RedisDB:       envInt("EMS_INGESTION_REDIS_DB", 0),

		TDengineURL:      strings.TrimRight(env("EMS_INGESTION_TDENGINE_URL", "http://127.0.0.1:6041"), "/"),
		TDengineUser:     env("EMS_INGESTION_TDENGINE_USER", "root"),
		TDenginePassword: env("EMS_INGESTION_TDENGINE_PASSWORD", "taosdata"),
		TDengineDatabase: env("EMS_INGESTION_TDENGINE_DATABASE", "iot"),

		MQTTBroker:       env("EMS_INGESTION_MQTT_BROKER", "tcp://127.0.0.1:1883"),
		MQTTUsername:     env("EMS_INGESTION_MQTT_USERNAME", "admin"),
		MQTTPassword:     env("EMS_INGESTION_MQTT_PASSWORD", "public"),
		MQTTClientID:     env("EMS_INGESTION_MQTT_CLIENT_ID", "ems-ingestion"),
		MQTTTopics:       envList("EMS_INGESTION_MQTT_TOPICS", []string{"/sys/#"}),
		MQTTQoS:          byte(envInt("EMS_INGESTION_MQTT_QOS", 1)),
		MQTTCleanSession: envBool("EMS_INGESTION_MQTT_CLEAN_SESSION", false),

		CacheReloadInterval: envDuration("EMS_INGESTION_CACHE_RELOAD_INTERVAL", 30*time.Second),
		DedupeTTL:           envDuration("EMS_INGESTION_DEDUPE_TTL", 24*time.Hour),

		RetryStream:     env("EMS_INGESTION_RETRY_STREAM", "iot:go_ingestion:retry"),
		RetryGroup:      env("EMS_INGESTION_RETRY_GROUP", "ems-ingestion"),
		RetryConsumer:   env("EMS_INGESTION_RETRY_CONSUMER", "ems-ingestion-1"),
		RetryMaxAttempt: envInt("EMS_INGESTION_RETRY_MAX_ATTEMPT", 5),
	}
}

func env(key string, fallback string) string {
	if value := strings.TrimSpace(os.Getenv(key)); value != "" {
		return value
	}
	return fallback
}

func envInt(key string, fallback int) int {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func envBool(key string, fallback bool) bool {
	value := strings.ToLower(strings.TrimSpace(os.Getenv(key)))
	switch value {
	case "1", "true", "yes", "y", "on":
		return true
	case "0", "false", "no", "n", "off":
		return false
	default:
		return fallback
	}
}

func envDuration(key string, fallback time.Duration) time.Duration {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	parsed, err := time.ParseDuration(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func envList(key string, fallback []string) []string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	parts := strings.Split(value, ",")
	result := make([]string, 0, len(parts))
	for _, part := range parts {
		part = strings.TrimSpace(part)
		if part != "" {
			result = append(result, part)
		}
	}
	if len(result) == 0 {
		return fallback
	}
	return result
}
