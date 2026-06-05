# EMS 数据入库与交互方案（会话决策记录 V1）

> 本文档基于《局域网下传感器数据采集入库架构对比与选型报告》更新。V1 明确选型为 **EMQX + MQTT**：前置机只负责采集、格式化和上送；EMS 统一消费 EMQX 消息、映射设备与测点、执行实时与历史入库；PostgreSQL 保存配置和业务关系；TDengine 同时承载实时最新值与全部历史数据。

## 1. 系统边界与职责

- 传感器 / PLC：提供现场测点原始数据。
- 前置机（C）：负责 Modbus / IEC104 / IEC61850 等协议采集、基础解析、轻量校验、MQTT 上送和控制指令执行。
- EMQX：作为局域网内 MQTT Broker，承接前置机到 EMS 的消息转发、QoS、会话保持、共享订阅和消费者负载分发。
- EMS：负责订阅 EMQX、解析 Topic、校验消息、映射设备与测点、维护进程内 latest 缓存、写入 TDengine、生成 YX 历史与 SOE。
- PostgreSQL：保存电站、前置机、设备、父子设备、测点配置、TDengine 表路由、控制指令、回执和审计。
- TDengine：保存 YC / YX / BU 的实时最新值、周期历史、变位历史和 SOE 事件流水。
- V1 不使用 Redis。
- 前置机不感知 EMS 内部 `devId`，不感知 PostgreSQL 主键，不感知 TDengine 表结构或入库路由。

## 2. 规模与部署

- 站级规模：50MWh ~ 2000MWh。
- 设备规模参考：约 3000 台设备，约 5 ~ 8 类设备类型。
- 单设备测点：约 50 ~ 200 个。
- 总测点：30 万 ~ 200 万。
  - YC 约 70%。
  - YX 约 30%。
- 网络环境：前置机、EMQX、EMS、PostgreSQL、TDengine 均在 100Mbps 工业局域网内。
- EMQX：V1 部署 1 套局域网 Broker；生产环境建议至少准备主备或集群能力，避免 Broker 单点故障。
- PostgreSQL：主备部署，承担配置与业务关系存储。
- TDengine：历史与实时数据唯一持久化存储，建议按站点规模规划副本、vgroup 和保留周期。

## 3. 架构选型与数据流

V1 采用报告中的 EMS 转发架构，并在前置机与 EMS 之间引入 EMQX：

```text
传感器/PLC
  -> 前置机（C）
  -> EMQX（MQTT Broker）
  -> EMS Ingestion
       -> TDengine realtime/history
       -> PostgreSQL config/audit
```

核心决策：

- 前置机只发布标准 MQTT 消息，不直接连接 PostgreSQL 或 TDengine。
- EMQX 只负责消息传递和缓冲，不承载业务表路由逻辑。
- EMS 是唯一的入库治理层，负责设备映射、测点映射、质量判断、YX 变位补偿、SOE 派生、TDengine 表管理和历史入库。
- PostgreSQL 保存现场编号到 EMS 内部设备 ID、父子关系、测点配置、历史启用和 SOE 启用等规则。
- TDengine 采用“一设备一子表、同类型设备共用超级表”的模型；子表创建、标签填充、列映射均由 EMS 管控。
- TDengine 的实时数据通过最新值超级表保存，查询时使用 `LAST_ROW` 获取最新状态；EMS 可使用进程内 latest 缓存提升写入和比对效率，重启后从 TDengine 最新值恢复。

## 4. 标识体系

### 4.1 前置机侧使用的标识

前置机只使用现场天然标识：

- `psId`：电站编号。
- `clientId`：前置机编号，即 MQTT client 逻辑编号。
- `devType`：设备类型，例如 `pcs`、`bms`、`air_conditioner`、`fire`、`liquid_cooling`、`battery_cluster`、`pcs_module`。
- `devNo`：设备现场编号。主设备编号在 `psId + clientId + devType` 下唯一；子设备编号通常只在父设备下唯一。
- `parentType`：父设备类型，仅子设备 Topic 使用。
- `parentNo`：父设备现场编号，仅子设备 Topic 使用。

前置机不上送 EMS 内部 `devId`。EMS 根据 Topic 中的现场标识查询 PostgreSQL，映射为内部设备 ID 和 TDengine 子表。

### 4.2 PostgreSQL 设备映射唯一键

主设备唯一键：

```text
psId + clientId + scope=main + devType + devNo
```

子设备唯一键：

```text
psId + clientId + scope=sub + parentType + parentNo + devType + devNo
```

示例：

```text
电池簇 1 下模块 1：
psId=PS001, clientId=FEP01, scope=sub, parentType=battery_cluster, parentNo=1, devType=module, devNo=1

电池簇 100 下模块 1：
psId=PS001, clientId=FEP01, scope=sub, parentType=battery_cluster, parentNo=100, devType=module, devNo=1
```

这两条记录的 `devNo` 都是 `1`，但父设备不同，因此可以唯一定位不同子设备。

## 5. 采集与上送节拍

- T1（前置机 -> EMQX）默认 15s，可按设备类型、通道或站点配置。
- YC 上送策略（V1）：越死区变化上送 + 5 分钟总召兜底上送。
- YC 历史入库策略：EMS 不把每条 MQTT YC 消息都作为趋势历史；默认每 30s 从 EMS latest 缓存取窗口最后值写入 TDengine 历史超级表。
- YC 实时入库策略：EMS 收到 YC 后写入 TDengine 实时超级表，查询实时值使用 `LAST_ROW`。
- YX 上送策略：变位事件上送 + 全量快照总召。
- YX 全量快照周期：默认 60s。
- YX 变位事件写入实时值、变位历史；`soeEnabled = true` 的精确变位事件额外生成 SOE。
- YX 快照用于刷新实时值和发现漏变位；当快照与当前 latest 不一致时，EMS 写入一条补偿变位历史。
- BU 温度、电压独立 Topic、独立消费、独立 TDengine 超级表，按电池簇整包上送。
- 前置机心跳周期：默认 5s。

## 6. 时间语义

- 上行消息体中的 `ts` 使用 Unix 秒级时间戳，示例 `1740000000`。
- EMS 接收后统一转换为毫秒时间戳：

```text
ct = ts * 1000
```

- 同时保留：
  - `ct`：前置机采集时间，来自消息体 `ts`。
  - `rt`：EMS 接收时间，由 EMS 本机生成。
- 业务计算以前置机采集时间 `ct` 为主。
- YC 历史主时间戳使用 EMS 30s 采样窗口时间，例如 `10:00:00`、`10:00:30`；同时保留 `ct` 作为前置机原始采集时间。
- YX 精确变位事件的历史和 SOE 主时间戳使用 `ct`。
- YX 快照补偿事件使用快照采集时间 `ct`，并标记为推断事件。
- EMS 应监控 `abs(rt - ct)`；当时间偏差超过 10s 时记录告警或诊断日志。

## 7. MQTT Topic 与连接约定

### 7.1 普通主设备上行 Topic

```text
ems/v1/up/{psId}/{clientId}/{dataType}/main/{devType}/{devNo}
```

其中 `dataType` 可取：

```text
yc
yx-event
yx-snapshot
```

示例：

```text
ems/v1/up/PS001/FEP01/yc/main/pcs/PCS01
ems/v1/up/PS001/FEP01/yx-event/main/bms/BMS01
ems/v1/up/PS001/FEP01/yx-snapshot/main/fire/FIRE01
```

### 7.2 父设备下子设备上行 Topic

```text
ems/v1/up/{psId}/{clientId}/{dataType}/sub/{parentType}/{parentNo}/{devType}/{devNo}
```

示例：

```text
ems/v1/up/PS001/FEP01/yc/sub/pcs/PCS01/pcs_module/1
ems/v1/up/PS001/FEP01/yx-event/sub/battery_cluster/100/fire/3
ems/v1/up/PS001/FEP01/yc/sub/battery_cluster/100/liquid_cooling/2
```

### 7.3 BU 专用上行 Topic

BU 温度、电压独立 Topic、独立消费、独立超级表。V1 按电池簇整包上送，不按单个电芯拆 Topic。

```text
ems/v1/up/{psId}/{clientId}/bu/temp/snapshot/{clusterNo}
ems/v1/up/{psId}/{clientId}/bu/volt/snapshot/{clusterNo}
```

示例：

```text
ems/v1/up/PS001/FEP01/bu/temp/snapshot/CLUSTER001
ems/v1/up/PS001/FEP01/bu/volt/snapshot/CLUSTER001
```

如果电池簇编号不是电站或前置机内唯一，V2 可扩展为：

```text
ems/v1/up/{psId}/{clientId}/bu/temp/snapshot/{stackNo}/{clusterNo}
ems/v1/up/{psId}/{clientId}/bu/volt/snapshot/{stackNo}/{clusterNo}
```

### 7.4 心跳与控制 Topic

前置机心跳：

```text
ems/v1/up/{psId}/{clientId}/heartbeat
```

主设备 YK / YT 下行：

```text
ems/v1/down/{psId}/{clientId}/cmd/yk/select/main/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yk/execute/main/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yt/set/main/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yt/adjust/main/{devType}/{devNo}
```

子设备 YK / YT 下行：

```text
ems/v1/down/{psId}/{clientId}/cmd/yk/select/sub/{parentType}/{parentNo}/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yk/execute/sub/{parentType}/{parentNo}/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yt/set/sub/{parentType}/{parentNo}/{devType}/{devNo}
ems/v1/down/{psId}/{clientId}/cmd/yt/adjust/sub/{parentType}/{parentNo}/{devType}/{devNo}
```

控制回执上行：

```text
ems/v1/up/{psId}/{clientId}/ack/yk/main/{devType}/{devNo}
ems/v1/up/{psId}/{clientId}/ack/yt/main/{devType}/{devNo}
ems/v1/up/{psId}/{clientId}/ack/yk/sub/{parentType}/{parentNo}/{devType}/{devNo}
ems/v1/up/{psId}/{clientId}/ack/yt/sub/{parentType}/{parentNo}/{devType}/{devNo}
```

### 7.5 MQTT 参数

- MQTT 版本：优先 MQTT 5.0；前置机实现成本受限时可使用 MQTT 3.1.1。
- 前置机 Client ID：

```text
front-{psId}-{clientId}
```

- Telemetry QoS：`1`，保证至少送达一次。
- Telemetry retained：`false`，实时采集数据不使用保留消息。
- Heartbeat QoS：`1`。
- Heartbeat retained：`true`，便于 EMS 启动后快速获知前置机最近状态。

EMS 多节点订阅使用共享订阅：

```text
$share/ems-yc/ems/v1/up/+/+/yc/#
$share/ems-yx-event/ems/v1/up/+/+/yx-event/#
$share/ems-yx-snapshot/ems/v1/up/+/+/yx-snapshot/#
$share/ems-bu-temp/ems/v1/up/+/+/bu/temp/snapshot/+
$share/ems-bu-volt/ems/v1/up/+/+/bu/volt/snapshot/+
$share/ems-heartbeat/ems/v1/up/+/+/heartbeat
$share/ems-ack/ems/v1/up/+/+/ack/#
```

ACL（访问控制）约定：

- 前置机只允许发布本 `psId + clientId` 的上行 Topic。
- 前置机只允许订阅本 `psId + clientId` 的下行 Topic。
- EMS 允许订阅全部上行 Topic，允许发布下行控制 Topic。

## 8. 普通设备消息体（JSON V1）

V1 先落地 JSON；后续如需要压缩带宽或降低前置机 CPU，可扩展 Protobuf。

示例：

```json
{
  "ts": 1740000000,
  "data": {
    "p": 25.6,
    "q": 120.0,
    "voltage": 1.85
  }
}
```

字段语义：

- `ts`：前置机采集时间，Unix 秒级时间戳。
- `data`：测点集合，key 为 `pointCode`，value 为测点值。
- `data.p`、`data.q`、`data.voltage` 均为测点编码示例；其中 `data.q` 是测点名，不表示质量位。
- V1 消息体不强制携带质量位；没有质量位时，EMS 默认该批 data 的质量为 `0 = Good`。
- 如后续前置机需要上送质量位，使用独立字段名 `quality`，避免与测点 `q` 冲突。
- 前置机不在 payload 中传 `devId`，EMS 通过 Topic 中的设备定位信息映射内部设备 ID。

V1 校验规则：

- Topic 必须能映射到 PostgreSQL 中唯一设备。
- `ts` 必填，必须为正整数秒级时间戳。
- `data` 必填，必须至少包含 1 个测点。
- `data` 中未知测点不自动入库；EMS 记录异常并丢弃该未知测点，已知测点继续处理。
- 数值型测点必须可转换为 `double`；YX 测点必须可转换为 `0/1`。

## 9. BU 温度 / 电压消息体（JSON V1）

BU 数据按电池簇整包上送，payload 使用数组表达电芯序号对应值。

示例：

```json
{
  "ts": 1740000000,
  "data": [3.321, 3.318, 3.319]
}
```

字段语义：

- `ts`：前置机采集时间，Unix 秒级时间戳。
- `data`：电池簇内 BU 值数组。
- `data[0]` 对应 1 号 BU，`data[1]` 对应 2 号 BU，以此类推。
- 温度 Topic 中的 `data` 表示温度数组；电压 Topic 中的 `data` 表示电压数组。
- EMS 根据 PostgreSQL 中的电池簇配置校验数组长度、缺失值、NaN 和明显越界值。

## 10. EMS 接入处理流程

EMS 订阅 EMQX 后按以下顺序处理每条普通设备上行消息：

1. 解析 Topic，获得 `psId`、`clientId`、`dataType`、`scope`、`devType`、`devNo`，子设备还需获得 `parentType`、`parentNo`。
2. 根据 Topic 设备定位信息查询 PostgreSQL，确认设备归属、父子关系、内部 `devId`、点表配置和 TDengine 表路由。
3. 解析 JSON，校验 `ts`、`data`。
4. 将 `ts` 转换为 `ct`，生成 EMS 接收时间 `rt`。
5. 按测点配置将 `data` 拆分为 YC、YX 或其他业务测点。
6. 写入 TDengine 实时超级表。
7. 对 YC 按 30s 采样窗口写入 TDengine 历史超级表。
8. 对 YX event 写入变位历史，并按 `soeEnabled` 生成 SOE。
9. 对 YX snapshot 执行 latest 对比；如发现状态不同，写入补偿变位历史。

EMS 处理 BU 消息时，按 `psId + clientId + clusterNo` 映射电池簇，写入 `bu_temperature` 或 `bu_voltage` 超级表。

## 11. 前置机心跳（V1）

- MQTT Topic：

```text
ems/v1/up/{psId}/{clientId}/heartbeat
```

- Payload 示例：

```json
{
  "state": 1,
  "ts": 1740000000,
  "ip": "10.0.0.11",
  "ver": "1.0.0"
}
```

字段语义：

- `state`：前置机状态，`1 = 在线`，`0 = 离线`。
- `ts`：前置机生成心跳时间，秒级时间戳。
- `ip`：当前前置机 IP。
- `ver`：前置机程序版本。

EMS 处理规则：

- EMS 将心跳状态写入 PostgreSQL 或 TDengine 前置机状态表，供页面和告警查询。
- 超过 15s 未收到心跳，EMS 判定该逻辑前置机离线。
- EMQX 客户端上下线事件作为辅助诊断信号，不替代业务心跳。

## 12. YX、SOE 与质量位

- YX 需要 SOE。
- SOE（Sequence of Events）定义：需要保留为事件流水的 YX 变位记录，用于按现场发生时间追溯事故顺序。
- V1 不要求前置机判断测点是否为 SOE；前置机只负责在 `data` 中上送状态值。
- EMS 根据测点配置中的 `historyEnabled` 判断 YX 变位是否写入历史。
- EMS 根据测点配置中的 `soeEnabled` 判断 YX event 是否生成 SOE。
- SOE 按时序逐条记录，每条仅记录变位后状态（0/1），不在单条记录中同时存前 / 后状态。
- V1 内部质量位字段统一命名为 `quality`。
- quality 编码：bitmask。
- quality 语义：`0 = Good`，非 `0 = 异常`。

YX event 处理规则：

- 写入 TDengine YX 实时超级表。
- 写入 TDengine YX 变位历史。
- `historyEnabled = true` 的 YX 变位写入 YX 变位历史。
- `soeEnabled = true` 的 YX event 额外生成 SOE 事件流水。
- `source = event`，`inferred = false`，时间可信。

YX snapshot 处理规则：

- 写入 TDengine YX 实时超级表。
- 和 EMS latest 缓存或 TDengine `LAST_ROW` 最新值对比。
- 状态相同：只刷新实时值，不写变位历史，不生成 SOE。
- 状态不同：写入一条补偿变位历史。
- 补偿历史字段：`source = snapshot`，`inferred = true`，`reason = snapshot_mismatch`。
- 默认不生成正式 SOE；如业务后续要求推断 SOE，必须在 SOE 中显式标记 `inferred = true`。

## 13. TDengine 落表与实时查询

### 13.1 表模型

- EMS 完全接管 TDengine 表定义、表路由和标签治理。
- 每类普通设备创建实时超级表和历史超级表。
- 每个超级表下按设备创建子表。TDengine 同库内表名需要全局避免冲突，建议子表名使用“业务前缀 + EMS 内部 devId”：

```text
yc_rt_d_{devId}
yc_hist_d_{devId}
yx_rt_d_{devId}
```

- 子表标签建议包含：
  - `psId`：电站编号。
  - `clientId`：逻辑前置机编号。
  - `scope`：`main` 或 `sub`。
  - `parentType`：父设备类型，主设备为空。
  - `parentNo`：父设备编号，主设备为空。
  - `devType`：设备类型。
  - `devNo`：设备现场编号。

### 13.2 YC 表

建议超级表：

```text
yc_rt_{devType}
yc_hist_{devType}
```

写入规则：

- `yc_rt_{devType}`：EMS 每次收到 YC 消息后写入，用于实时最新值查询。
- `yc_hist_{devType}`：EMS 默认每 30s 对 latest 缓存取窗口最后值写入，用于趋势和统计。
- `quality != 0` 的实时值可写入 `yc_rt_{devType}`，但 V1 暂不写入 `yc_hist_{devType}`。

实时查询：

```sql
SELECT LAST_ROW(*) FROM yc_rt_d_10001;
```

趋势查询：

```sql
SELECT * FROM yc_hist_d_10001 WHERE ts >= ? AND ts < ? ORDER BY ts;
```

### 13.3 YX 表

建议超级表：

```text
yx_rt_{devType}
yx_event_history
soe_event_history
```

写入规则：

- `yx_rt_{devType}`：event 和 snapshot 都写入，用于查询最新遥信状态。
- `yx_event_history`：event 必写；snapshot 发现状态不一致时写补偿历史。
- `soe_event_history`：默认只由精确 event 生成。

YX 实时查询：

```sql
SELECT LAST_ROW(*) FROM yx_rt_d_10001;
```

YX 历史查询：

```sql
SELECT *
FROM yx_event_history
WHERE dev_id = ?
  AND point_code = ?
  AND event_time >= ?
  AND event_time < ?
ORDER BY event_time;
```

YX 历史建议字段：

```text
ts
event_time
receive_time
ps_id
client_id
dev_id
scope
parent_type
parent_no
dev_type
dev_no
point_code
old_value
new_value
quality
source        -- event / snapshot
inferred      -- false / true
reason        -- event / snapshot_mismatch
```

### 13.4 BU 温度 / 电压表

BU 温度、电压采用电池簇级宽表，不按单个 BU 逐行存储：

```text
bu_voltage
bu_temperature
```

每个电池簇一张子表，每次上送写 1 行，BU 值作为宽字段：

```text
ts, ct, bu001, bu002, ..., bu416
```

标签建议包含：

```text
psId, clientId, stackNo, clusterNo
```

写入规则：

- `bu_voltage`：电池簇每次电压 snapshot 写 1 行。
- `bu_temperature`：电池簇每次温度 snapshot 写 1 行。
- EMS 入库前对 BU 温度、电压执行基础合法性校验，例如缺失、NaN、明显越界值不直接写入有效历史。
- 每行保留 `ct`，用于记录前置机原始采集时间。

实时查询：

```sql
SELECT LAST_ROW(*) FROM bu_voltage_cluster_30001;
SELECT LAST_ROW(*) FROM bu_temperature_cluster_30001;
```

## 14. 可靠性与异常处理

- EMQX Telemetry 使用 QoS 1，EMS 按至少一次投递语义设计幂等处理。
- EMS 使用进程内 latest 缓存进行窗口采样、YX snapshot 比对和写入合并；该缓存不是持久化存储。
- EMS 重启后，从 TDengine 实时超级表 `LAST_ROW` 恢复 latest 缓存。
- TDengine 实时超级表采用 last-write-wins 查询口径：
  - 新消息 `ct` 大于旧值时作为最新值。
  - 新消息 `ct` 小于旧值时写入可保留，但 EMS 记录乱序诊断；查询最新时仍以最大时间为准。
  - 新消息 `ct` 等于旧值时，以最新 `rt` 作为冲突诊断依据。
- YC 历史通过 30s 窗口采样降低重复消息影响。
- YX / SOE 通过 `devId + pointCode + ct + value + source` 去重。
- 前置机侧应保留 YX event 本地事件队列，断线后继续补发未确认事件。
- TDengine 短时不可用时，EMS 将待写数据进入本地内存队列；队列超过阈值时转入磁盘补写队列。
- 达到最大重试次数后，EMS 记录失败批次、失败原因、设备定位信息、测点编码和时间范围，便于人工补写。
- EMQX、EMS、TDengine 均需要采集运行指标：连接数、堆积消息数、消费延迟、写入耗时、失败重试次数、丢弃点数。

## 15. 控制链路策略

- 遥控（YK）：两步制（select + execute）。
- 遥调（YT）：同时支持定值下发 + 步长调节。
- 指令下行通过 EMQX command Topic，由前置机订阅。
- 指令回执通过 ack Topic 上送。
- 指令超时：3s 判失败。
- 超时 / 失败默认策略：不自动重发，由 EMS 告警并等待人工处理。
- PostgreSQL 保存控制指令、回执、失败原因和审计流水。

## 16. 保留周期

- SOE 保留时长：3 年。
- TDengine 历史数据保留时长：3 年。
- TDengine 实时超级表如数据量可控，建议与历史同保留周期；如后续数据量压力过大，可独立设置较短保留周期，但仍需保证最新值可查。
- PostgreSQL 指令、回执、审计按业务审计策略保留，V1 建议不短于 3 年。

## 17. V1 明确不做的事项

- V1 不使用 Redis。
- 前置机不直接写 PostgreSQL。
- 前置机不直接写 TDengine。
- 前置机不上传 EMS 内部 `devId`。
- 前置机不维护 TDengine 表名、超级表、子表、标签或列映射。
- EMQX 不做业务规则判断，不做 TDengine 表路由。
- V1 不要求前置机判断 `historyEnabled` 或 `soeEnabled`。
- V1 不在普通设备消息体中强制携带质量位；默认按 `quality = 0` 处理。
