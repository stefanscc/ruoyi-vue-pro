# EMQX 本地 Webhook 与 Rule 配置说明

## 1. 目的

当前本地 IoT 联调已经切换为 `EMQX Server + IoT Gateway(EMQX 协议)` 模式。

在这个模式下：

- 设备连接的是 EMQX `1883`
- 网关不再直接接收设备 MQTT 心跳包
- 网关通过两种方式感知设备状态
  - 订阅业务主题 `/sys/#`
  - 接收 EMQX 回调的客户端在线/离线事件

因此，如果需要在本地继续看到设备上线/下线日志，必须为 EMQX 额外配置 Webhook 与 Rule。

## 2. 本地链路

本地已验证通过的链路如下：

- EMQX Broker：`127.0.0.1:1883`
- EMQX Dashboard：`http://127.0.0.1:18083`
- Dashboard 用户名：`admin`
- Dashboard 密码：`public`
- IoT Gateway HTTP Hook：`http://172.29.156.241:8090`

说明：

- `172.29.156.241` 是当前 WSL/Ubuntu 网卡地址
- 在 Docker Desktop + WSL 场景下，EMQX 容器回调网关时，实测使用该地址可达
- `127.0.0.1` 不能直接作为容器内回调宿主机网关的目标地址

## 3. 网关 Hook 接口

网关在 EMQX 协议模式下暴露如下接口：

- `/mqtt/auth`
- `/mqtt/acl`
- `/mqtt/event`

本次本地联调已经实际使用的是：

- `POST http://172.29.156.241:8090/mqtt/event`

它当前处理的事件类型主要有：

- `client.connected`
- `client.disconnected`

## 4. 为什么切到 EMQX 后看不到原来的“心跳日志”

`mqtt-json` 模式下，网关自己就是 MQTT Server，所以能直接收到设备的 `PINGREQ`，日志会打印“收到客户端心跳”。

切到 EMQX 后：

- 设备心跳发生在 `设备 <-> EMQX`
- 网关只能看到 EMQX 转发的业务消息和事件回调
- 因此不会再出现原来那种协议层心跳日志

如果需要感知设备活跃情况，建议使用：

- EMQX 的 `client.connected / client.disconnected`
- 或设备自己定时上报业务心跳消息

## 5. 本地已使用的 EMQX 运行态配置

### 5.1 Webhook Bridge

名称：

- `iot_event_hook`

作用：

- 将 EMQX 规则命中的在线/离线事件回调给 IoT Gateway

目标地址：

- `http://172.29.156.241:8090/mqtt/event`

### 5.2 Rules

已使用两条规则：

- `iot_client_connected_rule`
- `iot_client_disconnected_rule`

对应事件源：

- `$events/client_connected`
- `$events/client_disconnected`

这两条规则会把 EMQX 事件转换为网关可识别的结构，例如：

```json
{
  "event": "client.connected",
  "username": "small&4aymZgOTOOCrDKRT",
  "clientid": "4aymZgOTOOCrDKRT.small",
  "peername": "172.17.0.1:xxxxx",
  "keepalive": 60,
  "connected_at": 1781230990000
}
```

```json
{
  "event": "client.disconnected",
  "username": "small&4aymZgOTOOCrDKRT",
  "clientid": "4aymZgOTOOCrDKRT.small",
  "peername": "172.17.0.1:xxxxx",
  "reason": "normal",
  "disconnected_at": 1781230990000
}
```

## 6. 通过 API 重建本地配置

如果 EMQX 容器被删除、数据卷被清空，或者需要重新初始化本地运行态配置，可通过 Dashboard OpenAPI 重建。

### 6.1 登录获取 Token

```bash
curl -X POST 'http://127.0.0.1:18083/api/v5/login' \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"public"}'
```

返回值中的 `token` 用于后续请求：

```text
Authorization: Bearer <token>
```

### 6.2 创建 Webhook Bridge

```bash
curl -X POST 'http://127.0.0.1:18083/api/v5/bridges' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{
    "name": "iot_event_hook",
    "type": "webhook",
    "enable": true,
    "url": "http://172.29.156.241:8090/mqtt/event",
    "method": "post",
    "headers": {
      "content-type": "application/json"
    },
    "body": "${.}",
    "pool_type": "random",
    "pool_size": 4,
    "connect_timeout": "15s",
    "request_timeout": "15s",
    "max_retries": 2,
    "resource_opts": {
      "query_mode": "async",
      "worker_pool_size": 1,
      "health_check_interval": 15000
    }
  }'
```

### 6.3 创建上线事件 Rule

```bash
curl -X POST 'http://127.0.0.1:18083/api/v5/rules' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{
    "name": "iot_client_connected_rule",
    "sql": "SELECT '\''client.connected'\'' as event, username, clientid, peername, keepalive, connected_at FROM \"$events/client_connected\"",
    "actions": ["http:iot_event_hook"],
    "enable": true,
    "description": "Forward client connected events to iot gateway"
  }'
```

### 6.4 创建下线事件 Rule

```bash
curl -X POST 'http://127.0.0.1:18083/api/v5/rules' \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer <token>' \
  -d '{
    "name": "iot_client_disconnected_rule",
    "sql": "SELECT '\''client.disconnected'\'' as event, username, clientid, peername, reason, disconnected_at FROM \"$events/client_disconnected\"",
    "actions": ["http:iot_event_hook"],
    "enable": true,
    "description": "Forward client disconnected events to iot gateway"
  }'
```

## 7. 验证方式

### 7.1 验证在线/离线事件

设备连接、断开后，网关日志中应出现：

```text
[handleClientConnected][设备上线: small&4aymZgOTOOCrDKRT]
[handleClientDisconnected][设备下线: small&4aymZgOTOOCrDKRT (normal)]
```

### 7.2 验证业务消息

设备向 EMQX 发布：

- `/sys/{productKey}/{deviceName}/thing/event/post`
- `/sys/{productKey}/{deviceName}/thing/property/post`

网关日志中应出现：

```text
[handle][收到 MQTT 消息, topic: /sys/.../thing/event/post, payload: ...]
```

## 8. 当前限制

当前仓库内保存的是：

- 网关本地配置
- 联调文档

当前没有落到仓库内的内容是：

- EMQX 容器内部的运行态 rule/bridge 数据

因此，EMQX 容器被重建后，需要按本文重新执行 OpenAPI 配置，或者后续补成自动化初始化方案。

## 9. 后续建议

如果后续希望进一步固化，可继续做两件事：

1. 增加一个仓库内的本地初始化脚本，在 EMQX 启动后自动调用 OpenAPI 创建 bridge/rule
2. 为 EMQX 规则增加更细的过滤条件，减少短连接测试时的重复上线/下线噪音
