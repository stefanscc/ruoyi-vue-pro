# IoT 本地启动与 MQTT 联调验证手册

## 1. 目标

本文档用于本地验证以下链路：

1. `east-server` 启动成功
2. `iot-gateway` 启动成功并监听 MQTT 1883 端口
3. 模拟设备通过 MQTT 发送属性、事件消息
4. 属性历史写入 TDengine
5. 事件消息写入 PostgreSQL 事件表

当前文档基于以下本地联调数据：

- 产品 `productKey`: `4aymZgOTOOCrDKRT`
- 设备 `deviceName`: `small`
- 设备密钥 `deviceSecret`: `0baa4c2ecc104ae1a26b4070c218bdf3`
- 设备 ID: `2001`
- 产品 ID: `1001`

## 2. 前置准备

确认以下基础设施已经可用：

1. PostgreSQL: `127.0.0.1:5432`
2. Redis: `127.0.0.1:6379`
3. TDengine REST/服务: `127.0.0.1:6041`

可先执行：

```bash
docker ps
```

建议至少能看到类似容器：

```text
east-postgres
east-redis
east-tdengine
```

## 3. 初始化数据库

### 3.1 初始化 PostgreSQL

导入 RuoYi 基础表：

```bash
docker exec -i east-postgres psql -U iot -d ruoyi_vue_pro < sql/postgresql/ruoyi-vue-pro.sql
```

导入 IoT 本地联调最小数据：

```bash
docker exec -i east-postgres psql -U iot -d ruoyi_vue_pro < sql/postgresql/iot-local-bootstrap.sql
```

### 3.2 初始化 TDengine

导入 IoT 本地联调所需的属性超级表：

```bash
docker exec -i east-tdengine taos < sql/tdengine/iot-local-bootstrap.sql
```

## 4. 编译项目

编译主服务：

```bash
mvn -pl east-server -am -Dmaven.test.skip=true package
```

编译网关：

```bash
mvn -pl east-module-iot/east-module-iot-gateway -am -Dmaven.test.skip=true package
```

如果只想快速确认依赖是否齐全，也可以先执行：

```bash
mvn -pl east-server -am -DskipTests compile
mvn -pl east-module-iot/east-module-iot-gateway -am -DskipTests compile
```

## 5. 启动服务

### 5.1 启动主服务

在项目根目录执行：

```bash
java -jar east-server/target/east-server.jar --spring.profiles.active=local
```

预期关键日志：

```text
Started EastServerApplication
[iotRedisMessageBus][创建 IoT Redis 消息总线]
Tomcat started on port 48080
```

### 5.2 启动 IoT Gateway

新开一个终端，在项目根目录执行：

```bash
java -jar east-module-iot/east-module-iot-gateway/target/east-module-iot-gateway.jar --spring.profiles.active=local
```

预期关键日志：

```text
[iotRedisMessageBus][创建 IoT Redis 消息总线]
[start][IoT MQTT 协议 mqtt-json 启动成功，端口：1883]
Started IotGatewayServerApplication
```

## 6. 发送 MQTT 消息

当前仓库已经按本地 profile 打开 MQTT：

- 端口：`1883`
- 序列化：`json`

### 6.1 鉴权规则

连接参数如下：

1. `clientId = 4aymZgOTOOCrDKRT.small`
2. `username = small&4aymZgOTOOCrDKRT`
3. `password` 为 HMAC-SHA256 签名

签名原文：

```text
clientId4aymZgOTOOCrDKRT.smalldeviceNamesmalldeviceSecret0baa4c2ecc104ae1a26b4070c218bdf3productKey4aymZgOTOOCrDKRT
```

本次联调中计算出的 `password` 为：

```text
509e2b08f7598eb139d276388c600435913ba4c94cd0d50aebc5c0d1855bcb75
```

### 6.2 属性上报

发布主题：

```text
/sys/4aymZgOTOOCrDKRT/small/thing/property/post
```

订阅回复主题：

```text
/sys/4aymZgOTOOCrDKRT/small/thing/property/post_reply
```

示例报文：

```json
{
  "requestId": "f795f0e4-851a-49b8-ac1f-a847873151a5",
  "method": "thing.property.post",
  "params": {
    "temperature": 27.8
  }
}
```

预期回复：

```json
{
  "deviceId": 2001,
  "requestId": "f795f0e4-851a-49b8-ac1f-a847873151a5",
  "method": "thing.property.post",
  "code": 0,
  "msg": "成功"
}
```

### 6.3 事件上报

发布主题：

```text
/sys/4aymZgOTOOCrDKRT/small/thing/event/post
```

订阅回复主题：

```text
/sys/4aymZgOTOOCrDKRT/small/thing/event/post_reply
```

示例报文：

```json
{
  "requestId": "871d2d8d-4445-4cae-8bff-f2e19a6d07cd",
  "method": "thing.event.post",
  "params": {
    "identifier": "alarm",
    "value": {
      "level": "critical",
      "temperature": 97
    },
    "time": 1780937444933
  }
}
```

预期回复：

```json
{
  "deviceId": 2001,
  "requestId": "871d2d8d-4445-4cae-8bff-f2e19a6d07cd",
  "method": "thing.event.post",
  "code": 0,
  "msg": "成功"
}
```

## 7. 验证入库

### 7.1 验证 TDengine 设备消息历史

```bash
docker exec east-tdengine taos -s "USE iot; SELECT tbname,id,method,identifier,upstream,reply FROM device_message ORDER BY ts DESC LIMIT 8;"
```

预期可以看到：

1. `thing.property.post` 上行消息
2. `thing.property.post` reply 消息
3. `thing.event.post` 上行消息
4. `thing.event.post` reply 消息
5. 设备上下线的 `thing.state.update` 消息

### 7.2 验证 TDengine 属性历史

```bash
docker exec east-tdengine taos -s "USE iot; SELECT ts,report_time,temperature FROM device_property_2001 ORDER BY ts DESC LIMIT 5;"
```

预期示例：

```text
2026-06-09 00:50:45.024 | 2026-06-09 00:50:44.935 | 27.8
```

### 7.3 验证 PostgreSQL 事件表

```bash
docker exec -i east-postgres psql -U iot -d ruoyi_vue_pro -c "SELECT id, device_id, method, report_time, create_time FROM iot_test_event_log ORDER BY create_time DESC LIMIT 5;"
```

预期至少有一条 `thing.event.post`：

```text
device_id = 2001
method = thing.event.post
```

### 7.4 验证设备在线离线状态

```bash
docker exec -i east-postgres psql -U iot -d ruoyi_vue_pro -c "SELECT id, state, online_time, offline_time, update_time FROM iot_device WHERE id = 2001;"
```

预期现象：

1. 连接成功后设备会变成在线
2. MQTT 客户端断开后设备会变成离线

## 8. 本次联调结论

当前本地链路已经验证通过：

1. `east-server` 本地 profile 可启动
2. `iot-gateway` 本地 profile 可启动
3. MQTT 鉴权成功
4. 属性上报成功并写入 TDengine 属性表
5. 事件上报成功并写入 PostgreSQL 事件表
6. 设备消息历史写入 TDengine 消息表

## 9. 相关文件

本次联调主要依赖以下文件：

1. `east-server/src/main/resources/application-local.yaml`
2. `east-module-iot/east-module-iot-gateway/src/main/resources/application-local.yaml`
3. `sql/postgresql/iot-local-bootstrap.sql`
4. `sql/tdengine/iot-local-bootstrap.sql`
