# 设备网关层与平台侧 MQTT 消息全量清单

## 1. 说明

本文基于当前仓库代码实现整理，范围覆盖：

- 设备 / 网关通过 MQTT 发给平台的全部消息类型
- 平台通过 MQTT 发给设备 / 网关的全部消息类型
- 各类型对应的 `method`
- 各类型对应的 MQTT `topic`
- 典型 JSON 报文样例
- 哪些消息会自动回复、哪些不会回复
- 当前实现里已经有业务发送入口的下行消息，以及仅定义了协议模型但暂未看到业务发送入口的消息

本文以 MQTT JSON 序列化为准。当前 JSON 序列化器是直接把 `IotDeviceMessage` 序列化为 JSON，不额外包裹 Alink 的 `version` 等字段。

## 1.1 站级 EMS 架构前提

对于你们当前站级项目，需要明确一个前提：

- EMS 不直接和下层子设备通信
- EMS 只和站控层网关通信
- 子设备的属性上报、事件上报、状态上报、启停控制、OTA 升级都应由网关代理

因此，本文后续所有内容需要区分两层含义：

- 当前仓库代码已经支持的实现方式
- 你们站级项目目标架构下，建议采用的网关代理方式

对于站级项目，建议遵循这个总原则：

- 上行时：优先由网关汇总后代子设备上报，或者网关代子设备转发
- 下行时：平台消息应先下发给网关，再由网关转给具体子设备
- 如果当前仓库某些下行能力还是“按子设备自身 topic 直接发”，那说明它和你们的站级目标架构还没有完全对齐，需要二次改造

## 2. Topic 规则

### 2.1 通用规则

- 基础前缀：`/sys/{productKey}/{deviceName}/`
- `method` 到 topic 的转换规则：把 `.` 替换成 `/`
- 回复 topic：在 topic 末尾追加 `_reply`

示例：

- `thing.property.post` -> `/sys/{productKey}/{deviceName}/thing/property/post`
- `thing.property.post` 的回复 topic -> `/sys/{productKey}/{deviceName}/thing/property/post_reply`

### 2.2 回复消息规则

- 平台回复设备上行请求时：topic 带 `_reply`，payload 里的 `method` 仍然是基础 method
- 设备回复平台下行请求时：推荐 topic 带 `_reply`，payload 里的 `method` 也带 `_reply`
- MQTT 网关侧会把设备回复报文里的 `method` 后缀 `_reply` 自动剥离，内部统一按基础 method 处理

### 2.3 公共报文结构

请求报文常见结构：

```json
{
  "id": "req-001",
  "requestId": null,
  "method": "thing.property.post",
  "params": {},
  "data": null,
  "code": null,
  "msg": null
}
```

响应报文常见结构：

```json
{
  "id": "resp-001",
  "requestId": "req-001",
  "method": "thing.property.post",
  "params": null,
  "data": null,
  "code": 0,
  "msg": "成功"
}
```

说明：

- 实际序列化内容可能还会带 `reportTime`、`deviceId`、`serverId` 等字段
- 样例里只保留对对接最关键的字段
- `code != null` 即表示这是回复消息

## 3. 设备 / 网关 -> 平台：上行消息

## 3.1 设备状态更新 `thing.state.update`

- 方向：设备 / 网关 -> 平台
- method：`thing.state.update`
- topic：`/sys/{productKey}/{deviceName}/thing/state/update`
- 是否自动回复：否
- 备注：
  - MQTT 协议里该 method 存在
  - 但当前 MQTT 实现中，设备上线 / 下线通常不是设备自己 publish 这个 topic，而是由连接建立 / 断开自动在平台内部生成该消息

样例：
## xcao: 缺少time
## codex：当前代码里 `thing.state.update` 的 DTO 只有 `state`，没有 `time` 字段，平台侧时间使用的是消息对象的 `reportTime`。而在 MQTT 场景下，这类在线/离线状态通常不是设备主动上报，而是由平台在连接建立/断开时内部生成，所以示例里没写 `time`。如果你们业务上要求“以前置机采集时间为准”，那需要扩展协议，例如改成 `{ "state": 1, "time": 1750665600000 }`，并同步改 `IotDeviceStateUpdateReqDTO` 与消费逻辑。
```json
{
  "id": "req-state-001",
  "method": "thing.state.update",
  "params": {
    "state": 1
  }
}
```

## 3.2 网关批量上报子设备状态 `thing.device.state.pack.post`

- 方向：网关 -> 平台
- method：`thing.device.state.pack.post`
- topic：`/sys/{productKey}/{deviceName}/thing/device/state/pack/post`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/device/state/pack/post_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao: subDevices中的time需要和前置机确认，变位上送还是总召（或者单个变位用3.1，总召用3.2）
## codex：这个判断非常对。当前代码只把 `time` 设计成“单个子设备状态记录自己的时间戳”，但没有强制语义。按站级前置机场景，建议这样约定更清晰：1）单个子设备状态变位，优先用 `3.2 thing.device.state.pack.post` 也可以，只传 1 条 `subDevices` 记录，这样网关侧实现统一；2）批量总召/批量状态刷新，也用 `3.2`，一包多条；3）`subDevices[].time` 建议定义为“该子设备状态在前置机侧确认变位/采集到的时间”；4）如果网关拿不到单点时间，则允许不传，由平台落库时间兜底。`3.1 thing.state.update` 更适合“网关设备自身在线/离线”，不太适合子设备批量状态。
## codex：结合你们“EMS 只和网关通信”的站级架构，`3.2` 其实就是最适合直接采用的一条现成上行协议，因为它本来就是“网关 topic + 子设备列表”的模式。站级项目里，建议把子设备状态上报主协议统一收口到这一条。
```json
{
  "id": "req-state-pack-001",
  "method": "thing.device.state.pack.post",
  "params": {
    "subDevices": [
      {
        "identity": {
          "productKey": "subProductA",
          "deviceName": "subDevice001"
        },
        "state": 1,
        "time": 1750665600000
      },
      {
        "identity": {
          "productKey": "subProductA",
          "deviceName": "subDevice002"
        },
        "state": 0,
        "time": 1750665605000
      }
    ]
  }
}
```

响应样例：

```json
{
  "requestId": "req-state-pack-001",
  "method": "thing.device.state.pack.post",
  "data": null,
  "code": 0,
  "msg": "成功"
}
```

## 3.3 添加拓扑关系 `thing.topo.add`

- 方向：网关 -> 平台
- method：`thing.topo.add`
- topic：`/sys/{productKey}/{deviceName}/thing/topo/add`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/topo/add_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao：本地局域网内是否需要password和username？网关测如何知道要给平台侧发送增加设备，什么时候触发？
## codex：按当前代码实现，`thing.topo.add` 里是需要带 `username/password/clientId` 的，因为平台在处理时会对每个子设备做一次认证校验，确认“这个子设备确实存在且认证信息正确”后才允许绑定。如果你们是本地局域网且前置机完全可信，也可以后续改协议，只传 `productKey + deviceName`，不做认证校验，但那属于协议简化改造，不是当前实现。至于什么时候触发，当前语义是“网关发现有新子设备需要纳入平台管理时触发”，常见时机有：前置机扫描到新设备、现场配置新增回路、站控系统下发‘纳管某设备’指令、或者网关本地导入点表完成后首次上线同步。
```json
{
  "id": "req-topo-add-001",
  "method": "thing.topo.add",
  "params": {
    "subDevices": [
      {
        "clientId": "subClient001",
        "username": "subDevice001&subProductA",
        "password": "sub-device-sign"
      }
    ]
  }
}
```

响应样例：
## xcao：本地局域网内是否需要password和username？返回为什么还要加productKey和deviceName？网关增加设备，平台会自动给设备表增加么？
## codex：分 3 件事：1）`password/username` 是否需要：当前实现需要；如果改成本地信任模式，可以去掉，但那要改后端 `handleTopoAddMessage` 的认证逻辑。2）响应里返回 `productKey/deviceName`，是为了明确告诉网关“哪些子设备绑定成功了”；因为请求可能一批多个，且其中部分可能失败，所以响应要回显成功清单。3）网关执行 `topo.add` 时，平台**不会**自动创建普通子设备记录；当前代码要求子设备本身已经存在于平台设备表，只是把它的 `gateway_id` 绑定到当前网关。真正“自动创建设备表记录”的是 `3.6 thing.auth.register` 这一型一密直连注册，不是 `topo.add`。
```json
{
  "requestId": "req-topo-add-001",
  "method": "thing.topo.add",
  "data": [
    {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    }
  ],
  "code": 0,
  "msg": "成功"
}
```

## 3.4 删除拓扑关系 `thing.topo.delete`

- 方向：网关 -> 平台
- method：`thing.topo.delete`
- topic：`/sys/{productKey}/{deviceName}/thing/topo/delete`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/topo/delete_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao: 网关删除设备，平台会自动给设备表删除么？网关测如何知道要给平台侧发送删除设备，什么时候触发？
## codex：当前实现里，`thing.topo.delete` 只会“解绑网关和子设备的拓扑关系”，不会删除平台里的设备表记录。代码实际动作是把子设备的 `gatewayId` 置空，并在需要时把该子设备状态改成离线。什么时候触发，语义上是“网关确认某个子设备不再归自己代理”时触发，常见时机有：前置机配置删除设备、现场设备拆除、设备迁移到其他网关、或者本地扫描发现该设备长期不存在并经人工确认移除。它表达的是‘解除代理关系’，不是‘物理删除设备档案’。
```json
{
  "id": "req-topo-del-001",
  "method": "thing.topo.delete",
  "params": {
    "subDevices": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      }
    ]
  }
}
```

响应样例：

```json
{
  "requestId": "req-topo-del-001",
  "method": "thing.topo.delete",
  "data": [
    {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    }
  ],
  "code": 0,
  "msg": "成功"
}
```

## 3.5 获取拓扑关系 `thing.topo.get`

- 方向：网关 -> 平台
- method：`thing.topo.get`
- topic：`/sys/{productKey}/{deviceName}/thing/topo/get`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/topo/get_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao: 什么时候触发获取拓扑关系
## codex：`thing.topo.get` 一般不是周期高频消息，而是“网关需要和平台对账”时触发。常见场景有：1）网关启动后想拉一次平台登记的子设备列表；2）前置机本地配置和平台配置可能不一致时做校验；3）人工诊断联调时查询当前已绑定关系；4）网关收到 `topo.change` 通知后想主动再拉一次全量确认。站级项目里，通常把它作为低频同步/诊断接口，而不是采集链路主流程。
```json
{
  "id": "req-topo-get-001",
  "method": "thing.topo.get",
  "params": {}
}
```

响应样例：

```json
{
  "requestId": "req-topo-get-001",
  "method": "thing.topo.get",
  "data": {
    "subDevices": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      },
      {
        "productKey": "subProductA",
        "deviceName": "subDevice002"
      }
    ]
  },
  "code": 0,
  "msg": "成功"
}
```

## 3.6 直连设备 / 网关一型一密动态注册 `thing.auth.register`

- 方向：设备 / 网关 -> 平台
- method：`thing.auth.register`
- 请求触发方式：不是普通 publish，而是 MQTT `CONNECT`
- reply topic：`/sys/{productKey}/{deviceName}/thing/auth/register_reply`
- 是否自动回复：是
- 适用对象：直连设备、网关设备

连接参数样例：

- `clientId`：`{normalClientId}|authType=register|`
- `username`：`{deviceName}&{productKey}`
- `password`：使用 `productSecret` 计算出的注册签名

注册成功响应样例：
## xcao: 请求触发方式为CONNECT,那哪来的method？平台侧如何知道method？
## codex：这个 `method` 不是设备在 MQTT payload 里传上来的，而是平台在处理 `CONNECT` 时“内部补出来”的。当前代码里，只要 `clientId` 带了 `|authType=register|` 后缀，平台就进入“动态注册流程”，并在返回响应时固定使用 `thing.auth.register` 作为响应 method。所以这里的 `method` 是平台侧流程语义，不是 CONNECT 报文原生字段。
```json
{
  "requestId": null,
  "method": "thing.auth.register",
  "data": {
    "productKey": "gatewayProductA",
    "deviceName": "gateway001",
    "deviceSecret": "new-device-secret"
  },
  "code": 0,
  "msg": "成功"
}
```

## 3.7 子设备动态注册 `thing.auth.register.sub`

- 方向：网关 -> 平台
- method：`thing.auth.register.sub`
- topic：`/sys/{productKey}/{deviceName}/thing/auth/sub-device/register`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/auth/sub-device/register_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao: 3.7适用的网关设备，3.6也适用网关设备，有什么区别？应用场景是什么？
## codex：两者虽然都可能和“网关”有关，但不是一回事。`3.6 thing.auth.register` 是“网关设备自己注册自己”，用于平台还没有这台网关记录时，靠 `productSecret` 自动创建设备并下发 `deviceSecret`。`3.7 thing.auth.register.sub` 是“网关替它下面的子设备注册”，前提是网关自己已经能正常连平台。应用场景上，`3.6` 解决‘这台网关第一次入网怎么在平台落档’，`3.7` 解决‘网关下面挂了很多子设备，子设备不想提前烧录独立密钥，怎么由网关代办注册’。
```json
{
  "id": "req-sub-reg-001",
  "method": "thing.auth.register.sub",
  "params": [
    {
      "productKey": "subProductA",
      "deviceName": "subDeviceNew001"
    }
  ]
}
```

响应样例：
## xcao: 平台侧怎么生成的deviceSecret，deviceSecret在设备测用来干什么？
## codex：当前代码里 `deviceSecret` 是平台通过 `IdUtil.fastSimpleUUID()` 生成的一串随机字符串，本质上就是设备密钥。它在设备侧的作用是“后续正式认证登录 MQTT/HTTP/TCP/UDP/WebSocket 时参与签名”，也就是从“一型一密/代注册”切换到“一机一密”的凭证。换句话说，注册接口只是为了拿到 `deviceSecret`，后面真正长期通信靠的是这个密钥。
```json
{
  "requestId": "req-sub-reg-001",
  "method": "thing.auth.register.sub",
  "data": [
    {
      "productKey": "subProductA",
      "deviceName": "subDeviceNew001",
      "deviceSecret": "allocated-sub-device-secret"
    }
  ],
  "code": 0,
  "msg": "成功"
}
```

## 3.8 属性上报 `thing.property.post`

- 方向：设备 / 子设备 / 网关 -> 平台
- method：`thing.property.post`
- topic：`/sys/{productKey}/{deviceName}/thing/property/post`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/property/post_reply`
- 是否自动回复：是

请求样例：
## xcao: 各设备单独上报我理解，但是网关是上报什么？网关自己的属性还是它下面各设备的属性呢？
## codex：在 `3.8 thing.property.post` 里，topic 上是谁，就表示“谁在上报自己的属性”。所以如果 topic 是网关自己的 `/sys/{gatewayPk}/{gatewayDn}/thing/property/post`，那语义上报的是“网关自身属性”，例如通信状态、CPU、缓存数、站地址、采集周期等；如果 topic 是某个子设备的 `/sys/{subPk}/{subDn}/thing/property/post`，那上报的是“该子设备属性”。当前实现里，子设备也可以单独按自己的身份上报，哪怕物理上是被网关代理转发的。若要“网关一包同时带自己和多个子设备属性”，那应该走 `3.9 pack.post`。
## codex：但按你们站级架构，EMS 不应该直接面向子设备接收 `thing.property.post`。更合适的站级建议协议是：topic 始终走网关 topic，消息体里显式带目标子设备。例如“单个子设备单条属性上报”可以约定成：
```json
{
  "id": "up-prop-gateway-001",
  "method": "thing.property.post",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "properties": {
      "temperature": 36.5,
      "switch": 1
    },
    "time": 1750665600000
  }
}
```
## codex：对应 topic 建议为：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/property/post`
## codex：需要明确：这类“网关 topic + `subDevice` 的单子设备属性上报”是**站级建议协议**，当前仓库代码**还未实现**。如果你们一次上送多个子设备属性，优先建议直接走 `3.9 thing.event.property.pack.post`，因为那条当前代码已经支持 `subDevices` 结构。
```json
{
  "id": "req-prop-001",
  "method": "thing.property.post",
  "params": {
    "temperature": 36.5,
    "power": 100,
    "status": "online"
  }
}
```

响应样例：

```json
{
  "requestId": "req-prop-001",
  "method": "thing.property.post",
  "data": null,
  "code": 0,
  "msg": "成功"
}
```

## 3.9 批量上报属性 / 事件 / 子设备数据 `thing.event.property.pack.post`

- 方向：网关 -> 平台
- method：`thing.event.property.pack.post`
- topic：`/sys/{productKey}/{deviceName}/thing/event/property/pack/post`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/event/property/pack/post_reply`
- 是否自动回复：是
- 适用对象：网关设备

请求样例：
## xcao: 3.9和3.8对于网关上报属性来说有什么区别？
## codex：核心区别是“单体上报”还是“网关聚合批量上报”。`3.8 thing.property.post` 只表达一个设备自己的属性上报，topic 上是谁就算谁；`3.9 thing.event.property.pack.post` 是专门给网关准备的聚合包，可以同时带：1）网关自身属性；2）网关自身事件；3）多个子设备属性；4）多个子设备事件。站级前置机场景如果你们是一次采集周期拿到很多子设备点位，优先用 `3.9` 更合适；如果只是某个单设备变位、单设备单点刷新，用 `3.8` 更轻。
## codex：再结合你们的站级架构，可以直接下结论：如果 EMS 只和网关通信，那 `3.9` 应该成为“子设备属性/事件批量上报”的主协议，尤其适合总召、周期采集、批量点位刷新。它本身就是网关 topic + `subDevices` 结构，和你们目标架构基本一致，属于当前文档里最适合站级项目直接沿用的一条现成协议。
```json
{
  "id": "req-pack-001",
  "method": "thing.event.property.pack.post",
  "params": {
    "properties": {
      "temperature": 25.5
    },
    "events": {
      "statusReport": {
        "value": {
          "message": "gateway started"
        },
        "time": 1750665600000
      }
    },
    "subDevices": [
      {
        "identity": {
          "productKey": "subProductA",
          "deviceName": "subDevice001"
        },
        "properties": {
          "power": 100
        },
        "events": {
          "healthCheck": {
            "value": {
              "errorCode": 0
            },
            "time": 1750665601000
          }
        }
      }
    ]
  }
}
```

响应样例：

```json
{
  "requestId": "req-pack-001",
  "method": "thing.event.property.pack.post",
  "data": null,
  "code": 0,
  "msg": "成功"
}
```

## 3.10 事件上报 `thing.event.post`

- 方向：设备 / 子设备 / 网关 -> 平台
- method：`thing.event.post`
- topic：`/sys/{productKey}/{deviceName}/thing/event/post`
- 回复 topic：`/sys/{productKey}/{deviceName}/thing/event/post_reply`
- 是否自动回复：是

请求样例：
## xcao: 事件上报似乎没有pack.post？ 如果网关像想上报某个子设备，消息体似乎没有子设备相关的？topic上的设备是指网关的还是子设备的？消息体怎么还有level、message、threshold等，不应该是遥信告警的状态么比如IGBTOverTemp：1之类？
## codex：这里分开看：1）“事件 pack.post” 在当前实现里不是独立 method，而是并入 `3.9 thing.event.property.pack.post` 里，通过 `events` 字段一起批量上报，所以你会看到没有单独的 `thing.event.pack.post`。2）如果网关想上报某个子设备的单条事件，有两种方式：要么直接用该子设备身份发 `3.10 thing.event.post`，此时 topic 上就是子设备；要么走 `3.9`，在 `subDevices[].events` 里带该子设备事件。3）`3.10` 的 topic 上设备是谁，就表示事件归属谁，不是固定只能是网关。4）示例里的 `level/message/threshold/current` 只是举例，表示 `value` 可以是结构体，不是协议强制。对于站级遥信告警，完全可以按你说的风格定义成比如 `identifier=IGBTOverTemp`，`value=1`，或者 `value={"status":1}`。事件体的具体字段应该由你们物模型/告警模型来约定，不是写死的。
## codex：如果完全按你们站级架构收敛，建议把“单个子设备单条事件上报”也改成网关 topic，例如：
```json
{
  "id": "up-event-gateway-001",
  "method": "thing.event.post",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "identifier": "IGBTOverTemp",
    "value": 1,
    "time": 1750665600000
  }
}
```
## codex：对应 topic 建议为：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/event/post`
## codex：如果是多个子设备事件一起上报，优先建议仍然走 `3.9` 的 `subDevices[].events`，因为这比单独扩一个“事件批量专用 method”更省改造量。
## codex：需要明确：上面这个“网关 topic + `subDevice` 的单子设备事件上报”是**站级建议协议**，当前仓库代码**还未实现**；而 `3.9` 中的批量事件上报结构，当前代码是支持的。
```json
{
  "id": "req-event-001",
  "method": "thing.event.post",
  "params": {
    "identifier": "alarm",
    "value": {
      "level": "warning",
      "message": "temperature too high",
      "threshold": 40,
      "current": 42
    },
    "time": 1750665600000
  }
}
```

响应样例：

```json
{
  "requestId": "req-event-001",
  "method": "thing.event.post",
  "data": null,
  "code": 0,
  "msg": "成功"
}
```

## 3.11 OTA 升级进度上报 `thing.ota.progress`

- 方向：设备 / 网关 -> 平台
- method：`thing.ota.progress`
- topic：`/sys/{productKey}/{deviceName}/thing/ota/progress`
- 是否自动回复：否

请求样例：
## xcao: 有没有具体的status对应的描述？站级暂定不需要ems做ota升级
## codex：当前代码里 OTA `status` 枚举是固定的：`0=PENDING(待推送)`、`10=PUSHED(已推送)`、`20=UPGRADING(升级中)`、`30=SUCCESS(升级成功)`、`40=FAILURE(升级失败)`、`50=CANCELED(升级取消)`。如果你们站级项目暂时不需要 EMS 做 OTA，可以把 `3.11` 和 `4.5` 视为“平台预留能力”，对接时先不实现即可，不影响属性、事件、拓扑、状态这些主链路。
## codex：如果以后你们仍想保留“站级网关代理 OTA 进度上报”的协议一致性，建议把 OTA 进度也收口到网关 topic，例如：
```json
{
  "id": "up-ota-progress-gateway-001",
  "method": "thing.ota.progress",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "version": "1.0.2",
    "status": 20,
    "description": "upgrading",
    "progress": 45
  }
}
```
## codex：对应 topic 建议为：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/ota/progress`
## codex：但也要明确：这类“网关代理子设备 OTA 进度上报”在当前仓库代码里**还未实现**，属于你们站级架构下建议扩展的协议。
```json
{
  "id": "req-ota-progress-001",
  "method": "thing.ota.progress",
  "params": {
    "version": "1.0.2",
    "status": 20,
    "description": "download finished",
    "progress": 100
  }
}
```

## 4. 平台 -> 设备 / 网关：下行消息

## 4.1 拓扑关系变更通知 `thing.topo.change`

- 方向：平台 -> 网关
- method：`thing.topo.change`
- topic：`/sys/{productKey}/{deviceName}/thing/topo/change`
- 设备回复 topic：`/sys/{productKey}/{deviceName}/thing/topo/change_reply`
- 当前仓库是否有明确发送入口：有
- 发送场景：后台绑定 / 解绑子设备到网关时自动下发

下行样例：
## xcao: 解绑是什么意思？这个status为0代表什么？
## codex：这里的“解绑”是指“平台认为某个子设备不再挂在这个网关下面代理”，不是删除设备档案。当前代码里 `status=0` 代表 `STATUS_CREATE`，也就是“新增/建立拓扑关系”；`status=1` 代表 `STATUS_DELETE`，也就是“删除/解除拓扑关系”。所以这个通知是发给网关做本地拓扑同步用的。
```json
{
  "id": "down-topo-change-001",
  "requestId": "down-topo-change-001",
  "method": "thing.topo.change",
  "params": {
    "status": 0,
    "subList": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      }
    ]
  }
}
```

设备回复样例：

```json
{
  "requestId": "down-topo-change-001",
  "method": "thing.topo.change_reply",
  "code": 0,
  "msg": "success",
  "data": null
}
```

## 4.2 属性设置 `thing.property.set`

- 方向：平台 -> 设备 / 网关
- method：`thing.property.set`
- topic：`/sys/{productKey}/{deviceName}/thing/property/set`
- 设备回复 topic：`/sys/{productKey}/{deviceName}/thing/property/set_reply`
- 当前仓库是否有明确发送入口：有
- 发送场景：场景联动规则可下发属性设置

下行样例：
## xcao: 属性设置时设置什么属性？和thing.property.post刚好相反？
## codex：这里设置的是“可写属性 / 控制属性”，通常来自产品物模型里允许平台下发的那部分属性，例如 `switch`、`mode`、`targetTemp`、`alarmThreshold`、`sampleInterval` 等。不是所有上报属性都一定允许设置，通常只有具备控制意义、配置意义的属性才适合放在 `thing.property.set`。
## codex：它和 `thing.property.post` 可以理解成“方向相反”，但不是严格一一对应的镜像关系。`thing.property.set` 表示平台下发“希望设备改成什么值”，`thing.property.post` 表示设备上报“设备当前实际是什么值”。比较推荐的交互习惯是：平台先发 `thing.property.set`，设备执行成功后，再主动回一条 `thing.property.post`，把执行后的真实值上报回来。
## codex：但结合你们站级架构，这里还要补一句更关键的话：**平台不应该直接给子设备发 `thing.property.set`，而应该发给网关，由网关再转给目标子设备。**
## codex：也就是说，站级模式下更合适的下行 topic 应该是网关 topic，例如：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/property/set`
## codex：而消息体里需要显式带上目标子设备标识，例如：
```json
{
  "id": "down-prop-set-gateway-001",
  "requestId": "down-prop-set-gateway-001",
  "method": "thing.property.set",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "properties": {
      "switch": 1
    }
  }
}
```
## codex：如果是“多个子设备执行同一条属性设置命令、同一组属性值”，建议扩成 `subDevices` 数组，例如：
```json
{
  "id": "down-prop-set-gateway-batch-001",
  "requestId": "down-prop-set-gateway-batch-001",
  "method": "thing.property.set",
  "params": {
    "subDevices": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      },
      {
        "productKey": "subProductA",
        "deviceName": "subDevice002"
      }
    ],
    "properties": {
      "switch": 1
    }
  }
}
```
## codex：需要特别说明：上面这两种“网关 topic + `subDevice/subDevices`”写法，都是**你们站级代理架构建议协议**，当前仓库代码**还未实现**，不能直接拿现有代码联调通过。
## codex：上面这个“网关 topic + `subDevice` 标识”的写法是**站级网关代理架构建议写法**，不是当前仓库已经现成支持的标准格式。当前仓库代码里 `thing.property.set` 还是更偏向“直接发给目标设备自身”。
```json
{
  "id": "down-prop-set-001",
  "requestId": "down-prop-set-001",
  "method": "thing.property.set",
  "params": {
    "properties": {
      "switch": 1
    }
  }
}
```

设备回复样例：

```json
{
  "requestId": "down-prop-set-001",
  "method": "thing.property.set_reply",
  "code": 0,
  "msg": "success",
  "data": null
}
```

说明：

- 虽然属性设置 DTO 本身是“扁平 Map”
- 但当前场景规则发送实现实际发的是 `params.properties.{identifier}=value`
- 设备侧建议优先兼容当前实现

## 4.3 服务调用 `thing.service.invoke`

- 方向：平台 -> 设备 / 网关
- method：`thing.service.invoke`
- topic：`/sys/{productKey}/{deviceName}/thing/service/invoke`
- 设备回复 topic：`/sys/{productKey}/{deviceName}/thing/service/invoke_reply`
- 当前仓库是否有明确发送入口：有
- 发送场景：场景联动规则可下发服务调用

下行样例：
## xcao: 服务调用都包含哪些服务？
## codex：当前代码没有写死“有哪些服务”，服务列表来自每个产品自己的物模型 `ThingModelService` 定义。也就是说，不同产品可以有不同的服务标识符，比如 `reboot`、`resetAlarm`、`syncTime`、`startCharge`、`stopCharge`、`readArchive` 等。平台下发时只负责按 `identifier + params` 发送，真正有哪些服务、每个服务有哪些入参，要以该产品的物模型配置为准。
## codex：如果按你们站级架构，服务调用也应该走“先发网关，再由网关转发到子设备”的模式。建议形态和 `4.2` 一样，topic 用网关 topic，`params` 里额外带目标子设备标识。例如：
```json
{
  "id": "down-service-gateway-001",
  "requestId": "down-service-gateway-001",
  "method": "thing.service.invoke",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "identifier": "start",
    "params": {
      "mode": "remote"
    }
  }
}
```
## codex：如果是“多个子设备执行同一条服务调用、同一组入参”，建议扩成 `subDevices` 数组，例如：
```json
{
  "id": "down-service-gateway-batch-001",
  "requestId": "down-service-gateway-batch-001",
  "method": "thing.service.invoke",
  "params": {
    "subDevices": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      },
      {
        "productKey": "subProductA",
        "deviceName": "subDevice002"
      }
    ],
    "identifier": "start",
    "params": {
      "mode": "remote"
    }
  }
}
```
## codex：同样需要强调：这类“网关批量代理服务调用”是**站级建议协议**，当前仓库代码**还未实现**。
## codex：这同样是站级代理建议格式；当前仓库现有实现还没有把“子设备标识封装在服务调用下行消息里”做成统一能力。
```json
{
  "id": "down-service-001",
  "requestId": "down-service-001",
  "method": "thing.service.invoke",
  "params": {
    "identifier": "reboot",
    "params": {
      "delaySeconds": 5
    }
  }
}
```

设备回复样例：

```json
{
  "requestId": "down-service-001",
  "method": "thing.service.invoke_reply",
  "code": 0,
  "msg": "success",
  "data": {
    "result": "accepted"
  }
}
```

说明：

- DTO 注释里是 `inputParams`
- 但当前场景规则发送实现实际使用的是 `params`
- 设备侧如果按当前平台报文兼容，建议同时兼容 `params` 和 `inputParams`

## 4.4 配置推送 `thing.config.push`

- 方向：平台 -> 设备 / 网关
- method：`thing.config.push`
- topic：`/sys/{productKey}/{deviceName}/thing/config/push`
- 设备回复 topic：`/sys/{productKey}/{deviceName}/thing/config/push_reply`
- 当前仓库是否有明确发送入口：未看到
- 说明：协议模型和 MQTT 下发能力已经具备，但当前仓库里没有看到明确业务侧发送代码

下行样例：
## xcao: 推送配置主要包含什么配置？
## codex：从当前 DTO 看，`thing.config.push` 更偏向“推送一个配置文件或配置内容的下载信息”，而不是把具体业务配置字段写死在协议里。它主要包含：配置编号、配置大小、签名算法、签名值、下载地址、获取方式。至于这个配置文件里面放什么，当前代码没有限定，业务上通常会放设备运行参数，比如采样周期、通信地址、告警阈值、点表版本、上送策略、时间同步策略等。
```json
{
  "id": "down-config-001",
  "requestId": "down-config-001",
  "method": "thing.config.push",
  "params": {
    "configId": "cfg-20260623-001",
    "configSize": 2048,
    "signMethod": "SHA256",
    "sign": "abcdef1234567890",
    "url": "https://example.com/config/device-001.json",
    "getType": "file"
  }
}
```

设备回复样例：

```json
{
  "requestId": "down-config-001",
  "method": "thing.config.push_reply",
  "code": 0,
  "msg": "success",
  "data": null
}
```

## 4.5 OTA 升级推送 `thing.ota.upgrade`

- 方向：平台 -> 设备 / 网关
- method：`thing.ota.upgrade`
- topic：`/sys/{productKey}/{deviceName}/thing/ota/upgrade`
- 设备回复 topic：`/sys/{productKey}/{deviceName}/thing/ota/upgrade_reply`
- 当前仓库是否有明确发送入口：有
- 发送场景：OTA 任务推送时下发

下行样例：
## xcao: 通过网关给某些子设备升级，在哪里指定子设备？
## codex：在当前实现里，不是在 `params` 里再额外指定子设备，而是“这条下行消息本身就是发给某个具体设备的”。也就是说，平台先选中要升级的目标设备记录，然后按该设备自己的 `deviceId` 发 `thing.ota.upgrade`；如果这个目标设备是子设备，平台会根据它当前记录的 `serverId/网关路由` 把消息发到对应网关侧，再由网关转给该子设备。所以“升级哪个子设备”是在平台建 OTA 任务、选择目标设备时决定的，不是在这里的 MQTT 报文体里再放一个子设备列表。
## codex：如果落实到 MQTT topic 和消息体，给某个子设备下发 OTA 时，topic 用的是**该子设备自己的 topic**，不是网关自己的 topic。也就是：
## codex：`/sys/{subProductKey}/{subDeviceName}/thing/ota/upgrade`
## codex：一个具体样例如下：
```json
{
  "id": "down-ota-sub-001",
  "requestId": "down-ota-sub-001",
  "method": "thing.ota.upgrade",
  "params": {
    "version": "1.0.2",
    "fileUrl": "https://example.com/fw/sub-device-1.0.2.bin",
    "fileSize": 1048576,
    "fileDigestAlgorithm": "SHA256",
    "fileDigestValue": "9f86d081884c7d659a2feaa0c55ad015"
  }
}
```
## codex：对应地，这个子设备后续回升级进度时，应该按它自己的身份上报到：
## codex：`/sys/{subProductKey}/{subDeviceName}/thing/ota/progress`
## codex：不过这里要特别提醒一层实现前提：按当前仓库 MQTT 代码，我看到的平台下行是按“目标设备自己的 MQTT 会话 / deviceId 映射”直接发的，我**没有看到**“只保留网关一条 MQTT 连接，再由网关内部代收所有子设备下行 OTA”的专门代理实现。所以如果你们现场方案是“子设备不和平台保持独立逻辑会话，所有下行都必须经同一条网关 MQTT 连接转发”，那当前代码大概率还需要补一层网关代理路由；如果你们是“子设备虽然挂在网关下，但协议身份上仍按自己的 `productKey + deviceName` 和平台通信”，那上面的 topic 和消息体就是当前实现对应的写法。
## codex：结合你刚补充的站级架构，你们真正想要的应该不是上面这套“子设备 topic 直接下发”，而是“网关 topic 下发 + 指定目标子设备”。也就是说，在你们架构下，更合适的 OTA 下行应设计成：
## codex：topic：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/ota/upgrade`
## codex：消息体：
```json
{
  "id": "down-ota-gateway-001",
  "requestId": "down-ota-gateway-001",
  "method": "thing.ota.upgrade",
  "params": {
    "subDevice": {
      "productKey": "subProductA",
      "deviceName": "subDevice001"
    },
    "version": "1.0.2",
    "fileUrl": "https://example.com/fw/sub-device-1.0.2.bin",
    "fileSize": 1048576,
    "fileDigestAlgorithm": "SHA256",
    "fileDigestValue": "9f86d081884c7d659a2feaa0c55ad015"
  }
}
```
## codex：如果是“多个子设备升级同一个固件包”，建议扩成 `subDevices` 数组，例如：
```json
{
  "id": "down-ota-gateway-batch-001",
  "requestId": "down-ota-gateway-batch-001",
  "method": "thing.ota.upgrade",
  "params": {
    "subDevices": [
      {
        "productKey": "subProductA",
        "deviceName": "subDevice001"
      },
      {
        "productKey": "subProductA",
        "deviceName": "subDevice002"
      }
    ],
    "version": "1.0.2",
    "fileUrl": "https://example.com/fw/sub-device-1.0.2.bin",
    "fileSize": 1048576,
    "fileDigestAlgorithm": "SHA256",
    "fileDigestValue": "9f86d081884c7d659a2feaa0c55ad015"
  }
}
```
## codex：需要明确：这类“网关批量代理 OTA 升级”也是**站级建议协议**，当前仓库代码**还未实现**。
## codex：之后由网关把升级进度再代子设备上报给平台。若仍想保持“进度也全部走网关 topic”，则可进一步约定为：
## codex：`/sys/{gatewayProductKey}/{gatewayDeviceName}/thing/ota/progress`
## codex：并在 `params` 中增加 `subDevice` 标识。但这一套 **网关代理 OTA 下行/上行格式**，当前仓库并没有现成实现，需要作为你们站级 EMS 的协议扩展项来做。
```json
{
  "id": "down-ota-001",
  "requestId": "down-ota-001",
  "method": "thing.ota.upgrade",
  "params": {
    "version": "1.0.2",
    "fileUrl": "https://example.com/fw/device-1.0.2.bin",
    "fileSize": 1048576,
    "fileDigestAlgorithm": "SHA256",
    "fileDigestValue": "9f86d081884c7d659a2feaa0c55ad015"
  }
}
```

设备回复样例：

```json
{
  "requestId": "down-ota-001",
  "method": "thing.ota.upgrade_reply",
  "code": 0,
  "msg": "success",
  "data": null
}
```

后续设备还会继续上报：

- `thing.ota.progress`

## 5. 特殊流程补充

## 5.1 普通 MQTT 认证连接

普通设备 / 网关认证不是通过业务 topic 完成，而是通过 MQTT `CONNECT` 报文完成。

认证字段：

- `clientId`
- `username`
- `password`

认证成功后：

- MQTT 连接建立
- 平台内部会自动生成一条 `thing.state.update` 在线消息

断开连接后：

- 平台内部会自动生成一条 `thing.state.update` 离线消息

因此，这个流程本身没有“设备主动 publish 的业务 topic”。

## 5.2 设备回复上行请求时的统一规则

以下上行 method 平台会自动回 `_reply`：

- `thing.device.state.pack.post`
- `thing.topo.add`
- `thing.topo.delete`
- `thing.topo.get`
- `thing.auth.register`
- `thing.auth.register.sub`
- `thing.property.post`
- `thing.event.property.pack.post`
- `thing.event.post`

以下上行 method 平台不会回 `_reply`：

- `thing.state.update`
- `thing.ota.progress`

## 6. 一页总表

| 方向 | method | topic | reply topic | 适用对象 | 当前状态 |
| --- | --- | --- | --- | --- | --- |
| 上行 | `thing.state.update` | `/sys/{pk}/{dn}/thing/state/update` | 无 | 设备/网关 | 已实现 |
| 上行 | `thing.device.state.pack.post` | `/sys/{pk}/{dn}/thing/device/state/pack/post` | `/sys/{pk}/{dn}/thing/device/state/pack/post_reply` | 网关 | 已实现 |
| 上行 | `thing.topo.add` | `/sys/{pk}/{dn}/thing/topo/add` | `/sys/{pk}/{dn}/thing/topo/add_reply` | 网关 | 已实现 |
| 上行 | `thing.topo.delete` | `/sys/{pk}/{dn}/thing/topo/delete` | `/sys/{pk}/{dn}/thing/topo/delete_reply` | 网关 | 已实现 |
| 上行 | `thing.topo.get` | `/sys/{pk}/{dn}/thing/topo/get` | `/sys/{pk}/{dn}/thing/topo/get_reply` | 网关 | 已实现 |
| 上行 | `thing.auth.register` | MQTT CONNECT 触发 | `/sys/{pk}/{dn}/thing/auth/register_reply` | 直连设备/网关 | 已实现 |
| 上行 | `thing.auth.register.sub` | `/sys/{pk}/{dn}/thing/auth/sub-device/register` | `/sys/{pk}/{dn}/thing/auth/sub-device/register_reply` | 网关 | 已实现 |
| 上行 | `thing.property.post` | `/sys/{pk}/{dn}/thing/property/post` | `/sys/{pk}/{dn}/thing/property/post_reply` | 设备/网关 | 已实现 |
| 上行 | `thing.event.property.pack.post` | `/sys/{pk}/{dn}/thing/event/property/pack/post` | `/sys/{pk}/{dn}/thing/event/property/pack/post_reply` | 网关 | 已实现 |
| 上行 | `thing.event.post` | `/sys/{pk}/{dn}/thing/event/post` | `/sys/{pk}/{dn}/thing/event/post_reply` | 设备/网关 | 已实现 |
| 上行 | `thing.ota.progress` | `/sys/{pk}/{dn}/thing/ota/progress` | 无 | 设备/网关 | 已实现 |
| 下行 | `thing.topo.change` | `/sys/{pk}/{dn}/thing/topo/change` | `/sys/{pk}/{dn}/thing/topo/change_reply` | 网关 | 已实现，有业务发送入口 |
| 下行 | `thing.property.set` | `/sys/{pk}/{dn}/thing/property/set` | `/sys/{pk}/{dn}/thing/property/set_reply` | 设备/网关 | 已实现，有业务发送入口 |
| 下行 | `thing.service.invoke` | `/sys/{pk}/{dn}/thing/service/invoke` | `/sys/{pk}/{dn}/thing/service/invoke_reply` | 设备/网关 | 已实现，有业务发送入口 |
| 下行 | `thing.config.push` | `/sys/{pk}/{dn}/thing/config/push` | `/sys/{pk}/{dn}/thing/config/push_reply` | 设备/网关 | 已定义协议模型，暂未看到业务发送入口 |
| 下行 | `thing.ota.upgrade` | `/sys/{pk}/{dn}/thing/ota/upgrade` | `/sys/{pk}/{dn}/thing/ota/upgrade_reply` | 设备/网关 | 已实现，有业务发送入口 |

## 7. 本文依据的核心代码位置

- MQTT topic 规则：`east-module-iot/east-module-iot-gateway/src/main/java/com/ems/east/module/iot/gateway/util/IotMqttTopicUtils.java`
- 消息方法枚举：`east-module-iot/east-module-iot-core/src/main/java/com/ems/east/module/iot/core/enums/IotDeviceMessageMethodEnum.java`
- MQTT 上行处理：`east-module-iot/east-module-iot-gateway/src/main/java/com/ems/east/module/iot/gateway/protocol/mqtt/handler/upstream/IotMqttUpstreamHandler.java`
- MQTT 下行处理：`east-module-iot/east-module-iot-gateway/src/main/java/com/ems/east/module/iot/gateway/protocol/mqtt/handler/downstream/IotMqttDownstreamHandler.java`
- 上行业务处理：`east-module-iot/east-module-iot-biz/src/main/java/com/ems/east/module/iot/service/device/message/IotDeviceMessageServiceImpl.java`
- 拓扑变更通知下发：`east-module-iot/east-module-iot-biz/src/main/java/com/ems/east/module/iot/service/device/IotDeviceServiceImpl.java`
- OTA 下发：`east-module-iot/east-module-iot-biz/src/main/java/com/ems/east/module/iot/service/ota/IotOtaTaskRecordServiceImpl.java`
- 场景规则下发属性设置：`east-module-iot/east-module-iot-biz/src/main/java/com/ems/east/module/iot/service/rule/scene/action/IotDevicePropertySetSceneRuleAction.java`
- 场景规则下发服务调用：`east-module-iot/east-module-iot-biz/src/main/java/com/ems/east/module/iot/service/rule/scene/action/IotDeviceServiceInvokeSceneRuleAction.java`
- MQTT 集成测试样例：`east-module-iot/east-module-iot-gateway/src/test/java/com/ems/east/module/iot/gateway/protocol/mqtt/`
