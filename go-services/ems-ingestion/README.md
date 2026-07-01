# EMS Go Ingestion

Go service for the EMS MQTT hot path.

## Responsibilities

- Subscribe EMQX `/sys/#` with QoS 1.
- Provide EMQX HTTP hooks on `:8090`.
- Write device message logs and property history to TDengine.
- Update PostgreSQL device state/topology and Redis runtime cache.
- Execute current Database Sink rules.
- Publish downlink messages to EMQX for `east-server`.

## Run

Install Go 1.26.x, then:

```bash
cd go-services/ems-ingestion
go mod download
go build ./cmd/ems-ingestion
./ems-ingestion
```

Configuration is read from environment variables. See `script/systemd/ems-ingestion.env`.

## Docker smoke run

When dependencies are exposed from Docker Desktop, run the service in a container and let EMQX call it through a shared Docker network:

```bash
docker network create ems_ingestion_net || true
docker network connect ems_ingestion_net xcao-emqx || true

docker run -d --name ems-ingestion-dev \
  --network ems_ingestion_net \
  --add-host=host.docker.internal:host-gateway \
  -v "$PWD:/workspace" \
  -v ems-go-mod-cache:/go/pkg/mod \
  -v ems-go-build-cache:/root/.cache/go-build \
  -w /workspace/go-services/ems-ingestion \
  -e EMS_INGESTION_POSTGRES_DSN="postgres://iot:iot123456@host.docker.internal:5432/ruoyi_vue_pro?sslmode=disable" \
  -e EMS_INGESTION_DATABASE_SINK_HOST_OVERRIDE="host.docker.internal" \
  -e EMS_INGESTION_REDIS_ADDR="host.docker.internal:6379" \
  -e EMS_INGESTION_TDENGINE_URL="http://host.docker.internal:6041" \
  -e EMS_INGESTION_MQTT_BROKER="tcp://xcao-emqx:1883" \
  golang:1.26 \
  bash -c 'export PATH=/usr/local/go/bin:/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin; go run ./cmd/ems-ingestion'
```

`EMS_INGESTION_DATABASE_SINK_HOST_OVERRIDE` only rewrites Database Sink JDBC URLs whose host is `127.0.0.1` or `localhost`. It is useful for local Docker runs where the sink config was authored for bare-metal Java.
