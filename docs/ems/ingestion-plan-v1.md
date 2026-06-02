# EMS 数据入库与交互方案（会话决策记录 V1）

> 本文档整理了当前会话中已确认的架构决策，作为后续接口协议与实现的基线。

## 1. 系统边界与职责

- 前置机（C）负责采集（Modbus / IEC104 / IEC61850）并写入 Redis。
- EMS 负责消费、实时处理、历史入库与控制指令下发。
- 不涉及前置机内部实现。

## 2. 规模与部署

- 站级规模：50MWh ~ 2000MWh。
- 总测点：30万 ~ 200万。
  - YC 约 70%。
  - YX 约 30%。
- Redis：不做集群，主备两台服务器。

## 3. 采集与上送节拍

- T1（前置机 -> Redis）默认 15s，可按设备类型、通道或站点配置。
- YC 上送策略（V1）：前置机按越死区变化批量写入 Redis latest，不做周期全量上送。
- YX 上送策略：变位上送 + 全量心跳。
- YX 全量心跳周期：60s。
- YX 变位需要保存历史；YC 单次越死区变化仅更新实时 latest，不直接作为历史入库事件。

## 4. 时间语义

- 同时保留：
  - 前置机采集时间。
  - EMS 接收时间。
- 业务计算以前置机采集时间为主。
- 时间精度：毫秒（ms）。

## 5. 控制链路策略

- 遥控（YK）：两步制（select + execute）。
- 遥调（YT）：同时支持定值下发 + 步长调节。
- 指令超时：3s 判失败。
- 超时/失败默认策略：不自动重发，由 EMS 告警并等待人工处理。

## 6. SOE 与质量位

- YX 需要 SOE。
- SOE（Sequence of Events）定义：需要保留为事件流水的 YX 变位记录，用于按现场发生时间追溯事故顺序。
- V1 不要求前置机判断测点是否为 SOE；前置机只负责写入 YX 变位流。
- EMS 根据测点配置中的 `soeEnabled` 判断某条 YX 变位是否生成 SOE 事件。
- SOE 按时序逐条记录，每条仅记录变位后状态（0/1），不在单条记录中同时存前/后状态。
- quality 字段保留。
- quality 编码：bitmask。
- quality 语义：0 = Good，非 0 = 异常。

## 7. 数据格式与消息通道

- 消息体格式：JSON + Protobuf 均支持。
- V1 先落地 JSON，后续可扩 Protobuf。
- Redis 数据通道：
  - YC 实时 latest：Redis Hash。
  - YX 变位：Redis Stream。
  - SOE 不由前置机单独写 Stream，而是 EMS 消费 YX 变位流后根据 `soeEnabled` 派生生成。
  - V1 不引入 YC Stream；如后续需要调试、审计或回放，再单独评估。

## 8. Redis 实时 YC 命名规范

- Redis key：

```text
rt:yc:{psId}:{frontId}:{deviceType}:{bucket}
```

- Hash field：

```text
{deviceNo}_{pointCode}
```

- 默认 bucket：

```text
bucket = 0
```

- 示例：

```text
key   = rt:yc:PS001:FEP01:PCS:0
field = PCS01_Ua
value = {"v":10.23,"q":0,"ct":1716969600000,"wt":1716969600100}
```

- 字段语义：
  - `psId`：电站 ID。
  - `frontId`：逻辑前置机 ID。主备前置机仅 IP 不同，逻辑 `frontId` 保持一致，Redis key 不因主备切换变化。
  - `deviceType`：设备类型，V1 预计约 5 ~ 8 类。
  - `bucket`：应用层桶编号，V1 固定为 `0`，暂不定义 bucket 计算逻辑；后续如需扩展为 `0..N-1`，需另行定义前置机与 EMS 共同遵守的计算与迁移规则。
  - `deviceNo`：设备编号。
  - `pointCode`：EMS 与前置机共同使用的测点编码。
  - `deviceNo` 与 `pointCode` 均不得包含 `_`，避免 Hash field 解析歧义。
  - `v`：遥测值。
  - `q`：质量位，`0 = Good`，非 `0 = 异常`。
  - `ct`：前置机采集时间，毫秒时间戳。
  - `wt`：前置机写入 Redis 时间，毫秒时间戳，仅作为诊断字段，不参与 V1 历史入库有效性判断。

- 查询约定：
  - 按设备类型查询时，EMS 先定位 `rt:yc:{psId}:{frontId}:{deviceType}:0`。
  - 按设备编号查询时，EMS 根据设备配置拼接 `{deviceNo}_{pointCode}`，使用 `HMGET` 批量读取。
  - 30s 历史入库任务按 `psId + frontId + deviceType + bucket` 遍历 Hash，使用 `HSCAN` 分批读取，避免大 Hash 阻塞 Redis。

## 9. 前置机心跳（V1）

- V1 仅定义最简单的前置机心跳，用于判断逻辑前置机是否在线。
- 心跳周期：默认 5s。
- 离线判定：超过 15s 未更新心跳，EMS 判定该前置机离线。
- Redis key：

```text
hb:front:{psId}:{frontId}
```

- Value 示例：

```json
{"state":1,"ts":1716969600000,"ip":"10.0.0.11","ver":"1.0.0"}
```

- 字段语义：
  - `state`：前置机状态，`1 = 在线`，`0 = 离线`。
  - `ts`：前置机写入心跳时间，毫秒时间戳。
  - `ip`：当前主用前置机 IP。
  - `ver`：前置机程序版本。

- V1 不单独定义通道心跳、设备心跳与 Redis 写入水位；如后续需要更精细的数据可信度判断，再在 V2 增加。

## 10. Redis YX 变位流命名规范

- Redis Stream key：

```text
stream:yx:{psId}:{frontId}:{deviceType}
```

- Message 字段：
  - `deviceNo`：设备编号。
  - `pointCode`：测点编码。
  - `v`：遥信变位后的状态，`0/1`。
  - `q`：质量位，`0 = Good`，非 `0 = 异常`。
  - `ct`：前置机采集到变位的时间，毫秒时间戳。
  - `seq`：前置机侧事件序号，用于辅助排序、排查与去重。

- EMS 消费规则：
  - 所有 YX 变位均更新 YX latest。
  - `historyEnabled = true` 的 YX 变位写入 YX 变位历史。
  - `soeEnabled = true` 的 YX 变位额外生成 SOE 事件流水。

## 11. 存储分工

- Redis：实时库（唯一实时值存储）。
- TDengine：历史库，固定周期批量写入，周期可配置。
  - YC 默认周期：30s。
  - YC 历史入库口径：每 30s 对全部遥测 latest 取当前窗口最后值，仅保存前置机心跳正常且 `quality = 0` 的数据。
  - YC 历史主时间戳使用 EMS 30s 采样窗口时间，例如 `10:00:00`、`10:00:30`；同时保留 latest 中的 `ct` 作为前置机原始采集时间。
  - YC `quality != 0` 的实时值可保留在 Redis latest，但 V1 暂不写入 TDengine 历史。
  - YC 历史查询遇到 `quality != 0` 导致的缺点时，趋势展示与统计口径暂按前值延续处理。
  - 电芯级 YC 历史采用电池簇级宽表，不按单电芯测点逐行存储：
    - `cell_voltage`：每个电池簇每 30s 写 1 行，416 个电芯电压作为 416 个字段。
    - `cell_temperature`：每个电池簇每 30s 写 1 行，416 个电芯温度作为 416 个字段。
    - 电芯温度与电压历史不存单电芯 `quality` 字段。
    - EMS 入库前对电芯温度、电压执行基础合法性校验，例如缺失、NaN、明显越界值不直接写入有效历史。
    - 每行保留 `ct`，用于记录前置机原始采集时间。
  - YX 历史入库口径：保存遥信变位记录。
  - SOE 独立保存事件原始流水。
- PostgreSQL：业务关系库（指令、回执、审计、测点配置等），不存实时 latest。
  - 测点配置需包含 `historyEnabled` 与 `soeEnabled`，用于 EMS 判断 YX 变位是否入历史、是否生成 SOE。

## 12. 保留周期

- SOE 保留时长：3 年。
- TDengine 历史数据保留时长：3 年。

## 13. SOE ACK 范围（V1）

- V1 暂不引入 SOE 的“事件确认/消警（ACK）”字段。
- V1 的 SOE 仅保留事件原始流水（按时间顺序记录变位后状态）。
- 后续如需告警闭环流程，再在 V2 增加 ACK 状态、ACK 人、ACK 时间等字段。
