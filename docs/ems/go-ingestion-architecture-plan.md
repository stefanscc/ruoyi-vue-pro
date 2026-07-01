# 站级 EMS Go Ingestion + Java 管理后台重构方案

## 目标架构

将 IoT 热路径从 Java 拆出：

- Go ingestion：只接入 EMQX/MQTT，负责上行消费、解析、入库、在线状态、下行发布、规则执行和当前 Database Sink。
- Java east-server：保留后台管理、配置维护、权限、查询展示和 Go 健康状态查看。
- EMQX：继续作为 MQTT Broker。
- TDengine：保存设备消息日志和属性历史。
- PostgreSQL：保存业务配置、设备状态、规则、告警和 Database Sink 目标表。
- Redis：保存最新值缓存、在线路由缓存、幂等键和失败重试队列。

Go 第一版不做 HTTP/TCP/WebSocket/CoAP/Modbus 等设备接入协议。

## 工程结构

- Go 服务目录：`go-services/ems-ingestion`
- Go 版本：1.26.x
- Java Gateway：从 Maven modules 移除，不再作为主链路启动。
- Java IoT 消费者：删除设备消息、数据规则、场景规则三个消息消费者，避免和 Go 双写或重复触发。

## Go ingestion 职责

Go 订阅 `/sys/#`，QoS 1，固定 clientId，`clean session=false`，单实例持久订阅。

上行消息必须携带 `requestId`，幂等键为：

```text
deviceId + method + requestId
```

支持当前 `/sys` 方法：

- `thing.state.update`
- `thing.device.state.pack.post`
- `thing.topo.add`
- `thing.topo.delete`
- `thing.topo.get`
- `thing.auth.register`
- `thing.auth.register.sub`
- `thing.property.post`
- `thing.event.post`
- `thing.event.property.pack.post`
- `thing.config.push`
- `thing.service.invoke`
- `thing.ota.progress`

当前实现说明：

- 属性、事件、批量包、状态、子设备状态、拓扑和下行已接入核心处理。
- 动态注册方法暂返回未实现错误，保留入口。
- OTA 进度当前只记录消息日志，业务进度更新后续按实际 OTA 表结构补齐。

## 入库与缓存

Go 写入现有 TDengine 结构：

- `device_message_${deviceId}`
- `product_property_${productId}`
- `device_property_${deviceId}`

Go 启动和配置刷新时维护：

- `device_message` 超级表
- `product_property_${productId}` 超级表
- 物模型属性对应 TDengine 字段

Go 同步 Redis 运行态缓存：

- `iot:device_property:${deviceId}`
- `iot:device_report_times`
- `iot:device_server_id`

## EMQX Hook 与下行

Go 复用 `8090` 端口：

- `POST /mqtt/auth`
- `POST /mqtt/acl`
- `POST /mqtt/event`
- `GET /internal/health`
- `POST /internal/reload`
- `POST /internal/downlink`

内部 API 使用 `X-Internal-Token` 或 `Authorization: Bearer <token>`。

下行链路：

```text
east-server
  -> POST /internal/downlink
  -> Go 发布 MQTT 到 EMQX
  -> 设备订阅 /sys/{productKey}/{deviceName}/...
```

## 规则与 Database Sink

第一版只实现当前系统已使用的 Database Sink：

- 仅支持 PostgreSQL。
- 沿用固定表结构：`id, device_id, method, report_time, data, create_time`。
- `data` 写入整条设备消息 JSON。
- 不自动建目标表，目标表不存在则进入 Redis Stream 重试/死信。

暂不支持：

- HTTP Sink
- TCP Sink
- WebSocket Sink
- MQTT Sink
- Redis Sink
- Kafka Sink
- RabbitMQ Sink
- RocketMQ Sink

## 配置刷新

Go 直连 PostgreSQL 读取：

- 产品
- 设备
- 物模型
- 数据规则
- Database Sink

刷新策略：

- Go 周期性全量 reload，默认 30 秒。
- east-server 可调用 `POST /internal/reload` 主动刷新。
- Go 内存缓存为主，Redis 仅保存运行态和重试队列。

## 失败重试

Database Sink 写入失败：

- 写入 Redis Stream：`iot:go_ingestion:retry`
- 使用 consumer group：`ems-ingestion`
- 成功后 ack
- pending 消息超过 30 秒可 reclaim
- 超过最大重试次数进入：`iot:go_ingestion:retry:dead`

## systemd 部署

模板文件：

- `script/systemd/ems-ingestion.service`
- `script/systemd/ems-ingestion.env`

Go 服务依赖：

- PostgreSQL
- TDengine
- Redis
- EMQX

`east-server` 可独立重启，不影响 Go MQTT 消费和入库。

## 验收标准

- EMQX 上行 MQTT 消息可被 Go 消费。
- 缺失 `requestId` 的上行消息被拒绝或记录错误。
- 属性历史写入 TDengine，后台历史查询可用。
- 消息日志写入 TDengine，后台消息页面可用。
- 设备在线状态、最后上报时间、serverId 缓存正确。
- 当前 `alarm` 事件规则可写入 PostgreSQL `iot_test_event_log`。
- `east-server` 重启期间 Go 入库不中断。
- Java 后台下行可通过 Go 发布到 EMQX。
- Database Sink 写失败进入 Redis Stream 重试/死信。
- Java Maven 编译通过。
