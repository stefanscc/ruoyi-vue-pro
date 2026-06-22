# Sub Device State Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add gateway-side batch reporting for sub-device online/offline state using `productKey + deviceName`, and route each valid record through the existing `thing.state.update` pipeline.

**Architecture:** Extend the IoT message contract with a dedicated `thing.device.state.pack.post` upstream method and a matching DTO, then expand each sub-device record into a normal `thing.state.update` message on the biz side. Keep gateway protocol ingress generic, and only add the smallest timestamp propagation changes needed so per-item `time` can reach device report time and online/offline timestamps.

**Tech Stack:** Java 17, Spring Boot 3, Maven, JUnit 5, Mockito, Vert.x MQTT, Hutool JSON/date utilities

---

## File Structure

- `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/enums/IotDeviceMessageMethodEnum.java`
  Add the new upstream method constant.
- `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/topic/state/IotSubDeviceStatePackPostReqDTO.java`
  New contract DTO for batch sub-device state reporting.
- `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessage.java`
  Add a reusable state-update builder that can preserve a custom `reportTime`, plus a first-class sub-device state-pack builder.
- `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceService.java`
  Extend the state-update contract to accept an effective state time.
- `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceServiceImpl.java`
  Persist online/offline timestamps from the effective state time instead of always using `now`.
- `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriber.java`
  Propagate `message.getReportTime()` to the device report-time cache path.
- `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpander.java`
  New focused helper that parses, validates, and expands the batch state pack.
- `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImpl.java`
  Wire the new upstream method into the existing dispatch flow by delegating to the expander.
- `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpanderTest.java`
  Focused unit tests for valid, invalid, and mixed pack records.
- `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriberTest.java`
  Verify report-time propagation uses the message timestamp.
- `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/IotDeviceStateTimeTest.java`
  Verify online/offline timestamps use the provided state time.
- `east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/http/IotGatewayDeviceHttpProtocolIntegrationTest.java`
  Add a disabled manual HTTP example for `thing.device.state.pack.post`.
- `east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/mqtt/IotGatewayDeviceMqttProtocolIntegrationTest.java`
  Add a disabled manual MQTT example for `thing.device.state.pack.post`.

Note:
No production gateway protocol handler changes are planned because HTTP ingress already uses the generic route `/topic/sys/:productKey/:deviceName/*`, and MQTT topics are derived generically by replacing dots with slashes.

### Task 1: Add The New Message Contract And State-Update Builder

**Files:**
- Modify: `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/enums/IotDeviceMessageMethodEnum.java`
- Modify: `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessage.java`
- Create: `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/topic/state/IotSubDeviceStatePackPostReqDTO.java`
- Create: `east-module-iot/east-module-iot-core/src/test/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessageStatePackSupportTest.java`

- [ ] **Step 1: Write the failing core test**

```java
package com.ems.east.module.iot.core.mq.message;

import com.ems.east.framework.common.util.json.JsonUtils;
import com.ems.east.module.iot.core.enums.IotDeviceMessageMethodEnum;
import com.ems.east.module.iot.core.topic.IotDeviceIdentity;
import com.ems.east.module.iot.core.topic.state.IotDeviceStateUpdateReqDTO;
import com.ems.east.module.iot.core.topic.state.IotSubDeviceStatePackPostReqDTO;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class IotDeviceMessageStatePackSupportTest {

    @Test
    void testBuildStateUpdate_withCustomReportTime() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 18, 0, 0);

        IotDeviceMessage message = IotDeviceMessage.buildStateUpdate(1, reportTime);

        assertEquals(IotDeviceMessageMethodEnum.STATE_UPDATE.getMethod(), message.getMethod());
        assertEquals(reportTime, message.getReportTime());
        assertInstanceOf(IotDeviceStateUpdateReqDTO.class, message.getParams());
        assertEquals(1, ((IotDeviceStateUpdateReqDTO) message.getParams()).getState());
    }

    @Test
    void testBuildSubDeviceStatePackPost() {
        IotSubDeviceStatePackPostReqDTO params = new IotSubDeviceStatePackPostReqDTO();
        params.setSubDevices(List.of(new IotSubDeviceStatePackPostReqDTO.SubDeviceState()
                .setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"))
                .setState(1)
                .setTime(1781290000000L)));

        IotDeviceMessage message = IotDeviceMessage.buildSubDeviceStatePackPost(params);

        assertEquals(IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), message.getMethod());
        assertSame(params, message.getParams());
        assertInstanceOf(IotSubDeviceStatePackPostReqDTO.class, message.getParams());
    }

    @Test
    void testStatePackDto_jsonRoundTrip() {
        String json = JsonUtils.toJsonString(Map.of(
                "subDevices", List.of(Map.of(
                        "identity", Map.of("productKey", "smoke_sensor_v1", "deviceName", "A10001"),
                        "state", 1,
                        "time", 1781290000000L
                ))
        ));

        IotSubDeviceStatePackPostReqDTO dto = JsonUtils.parseObject(json, IotSubDeviceStatePackPostReqDTO.class);

        assertEquals(1, dto.getSubDevices().size());
        assertEquals(new IotDeviceIdentity("smoke_sensor_v1", "A10001"), dto.getSubDevices().get(0).getIdentity());
        assertEquals(1, dto.getSubDevices().get(0).getState());
        assertEquals(1781290000000L, dto.getSubDevices().get(0).getTime());
    }
}
```

- [ ] **Step 2: Run the focused core test to verify the red state**

Run: `mvn -pl east-module-iot/east-module-iot-core -Dtest=IotDeviceMessageStatePackSupportTest test`

Expected: FAIL because `buildStateUpdate(Integer, LocalDateTime)`、`buildSubDeviceStatePackPost(...)` and `IotSubDeviceStatePackPostReqDTO` do not exist yet.

- [ ] **Step 3: Implement the contract and builder**

```java
// IotDeviceMessageMethodEnum.java
SUB_DEVICE_STATE_PACK_POST("thing.device.state.pack.post", "批量上报子设备状态", true),
```

```java
// IotSubDeviceStatePackPostReqDTO.java
@Data
public class IotSubDeviceStatePackPostReqDTO {

    private List<SubDeviceState> subDevices;

    @Data
    public static class SubDeviceState {
        private IotDeviceIdentity identity;
        private Integer state;
        private Long time;
    }
}
```

```java
// IotDeviceMessage.java
public static IotDeviceMessage buildStateUpdate(Integer state) {
    return buildStateUpdate(state, null);
}

public static IotDeviceMessage buildStateUpdate(Integer state, LocalDateTime reportTime) {
    IotDeviceMessage message = requestOf(IotDeviceMessageMethodEnum.STATE_UPDATE.getMethod(),
            new IotDeviceStateUpdateReqDTO(state));
    if (reportTime != null) {
        message.setReportTime(reportTime);
    }
    return message;
}

public static IotDeviceMessage buildStateUpdateOnline() {
    return buildStateUpdate(IotDeviceStateEnum.ONLINE.getState());
}

public static IotDeviceMessage buildStateOffline() {
    return buildStateUpdate(IotDeviceStateEnum.OFFLINE.getState());
}

public static IotDeviceMessage buildSubDeviceStatePackPost(IotSubDeviceStatePackPostReqDTO params) {
    return requestOf(IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), params);
}
```

- [ ] **Step 4: Run the focused core test again**

Run: `mvn -pl east-module-iot/east-module-iot-core -Dtest=IotDeviceMessageStatePackSupportTest test`

Expected: PASS

- [ ] **Step 5: Commit the core contract change**

```bash
git add \
  east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/enums/IotDeviceMessageMethodEnum.java \
  east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessage.java \
  east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/topic/state/IotSubDeviceStatePackPostReqDTO.java \
  east-module-iot/east-module-iot-core/src/test/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessageStatePackSupportTest.java
git commit -m "feat(iot): add sub-device state pack contract"
```

### Task 2: Propagate Message Time Through The Device-State Path

**Files:**
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceService.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriber.java`
- Create: `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/IotDeviceStateTimeTest.java`
- Create: `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriberTest.java`

- [ ] **Step 1: Write the failing biz tests**

```java
// IotDeviceStateTimeTest.java
@Test
void testUpdateDeviceState_usesProvidedStateTime() {
    IotDeviceDO device = new IotDeviceDO()
            .setId(1L)
            .setState(0);
    LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 18, 30, 0);

    service.updateDeviceState(device, 1, reportTime);

    ArgumentCaptor<IotDeviceDO> captor = ArgumentCaptor.forClass(IotDeviceDO.class);
    verify(deviceMapper).updateById(captor.capture());
    assertEquals(reportTime, captor.getValue().getOnlineTime());
    assertEquals(reportTime, captor.getValue().getActiveTime());
}
```

```java
// IotDeviceMessageSubscriberTest.java
@Test
void testOnMessage_usesMessageReportTimeForDeviceReportTimeCache() {
    LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 18, 45, 0);
    IotDeviceMessage message = IotDeviceMessage.buildStateUpdate(1, reportTime).setDeviceId(1L);
    IotDeviceDO device = new IotDeviceDO().setId(1L).setState(1);
    when(deviceService.validateDeviceExistsFromCache(1L)).thenReturn(device);

    subscriber.onMessage(message);

    verify(devicePropertyService).updateDeviceReportTimeAsync(1L, reportTime);
}
```

- [ ] **Step 2: Run the focused biz tests to verify they fail**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceStateTimeTest,IotDeviceMessageSubscriberTest test`

Expected: FAIL because `updateDeviceState(IotDeviceDO, Integer, LocalDateTime)` does not exist and the subscriber still writes `LocalDateTime.now()`.

- [ ] **Step 3: Implement timestamp-aware state updates**

```java
// IotDeviceService.java
void updateDeviceState(IotDeviceDO device, Integer state, LocalDateTime stateTime);
```

```java
// IotDeviceServiceImpl.java
@Override
public void updateDeviceState(IotDeviceDO device, Integer state) {
    updateDeviceState(device, state, LocalDateTime.now());
}

@Override
public void updateDeviceState(IotDeviceDO device, Integer state, LocalDateTime stateTime) {
    LocalDateTime effectiveTime = stateTime != null ? stateTime : LocalDateTime.now();
    IotDeviceDO updateObj = new IotDeviceDO().setId(device.getId()).setState(state);
    if (device.getOnlineTime() == null && Objects.equals(state, IotDeviceStateEnum.ONLINE.getState())) {
        updateObj.setActiveTime(effectiveTime);
    }
    if (Objects.equals(state, IotDeviceStateEnum.ONLINE.getState())) {
        updateObj.setOnlineTime(effectiveTime);
    } else if (Objects.equals(state, IotDeviceStateEnum.OFFLINE.getState())) {
        updateObj.setOfflineTime(effectiveTime);
    }
    deviceMapper.updateById(updateObj);
    deleteDeviceCache(device);
    if (Objects.equals(state, IotDeviceStateEnum.OFFLINE.getState())
            && IotProductDeviceTypeEnum.isGateway(device.getDeviceType())) {
        handleGatewayOffline(device);
    }
}
```

```java
// IotDeviceMessageSubscriber.java
devicePropertyService.updateDeviceReportTimeAsync(device.getId(), message.getReportTime());
```

- [ ] **Step 4: Run the focused biz tests again**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceStateTimeTest,IotDeviceMessageSubscriberTest test`

Expected: PASS

- [ ] **Step 5: Commit the timestamp propagation change**

```bash
git add \
  east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceService.java \
  east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceServiceImpl.java \
  east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriber.java \
  east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/IotDeviceStateTimeTest.java \
  east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriberTest.java
git commit -m "feat(iot): preserve report time in state updates"
```

### Task 3: Expand Sub-Device State Packs Into Standard State Messages

**Files:**
- Create: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpander.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImpl.java`
- Create: `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpanderTest.java`
- Modify: `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImplTest.java`

- [ ] **Step 1: Write the failing expander test**

```java
@Test
void testExpand_validAndInvalidSubDevices_onlyPublishesValidStateMessages() {
    IotDeviceDO gateway = new IotDeviceDO().setId(100L).setProductKey("gw_pk").setDeviceName("gw_1");
    IotDeviceDO validSub = new IotDeviceDO().setId(200L).setGatewayId(100L)
            .setProductKey("smoke_sensor_v1").setDeviceName("A10001");
    IotDeviceDO otherGatewaySub = new IotDeviceDO().setId(201L).setGatewayId(999L)
            .setProductKey("temp_humi_v1").setDeviceName("T20001");

    when(deviceService.getDeviceFromCache("smoke_sensor_v1", "A10001")).thenReturn(validSub);
    when(deviceService.getDeviceFromCache("temp_humi_v1", "T20001")).thenReturn(otherGatewaySub);

    IotSubDeviceStatePackPostReqDTO params = new IotSubDeviceStatePackPostReqDTO();
    params.setSubDevices(List.of(
            new IotSubDeviceStatePackPostReqDTO.SubDeviceState()
                    .setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"))
                    .setState(1)
                    .setTime(1781290000000L),
            new IotSubDeviceStatePackPostReqDTO.SubDeviceState()
                    .setIdentity(new IotDeviceIdentity("temp_humi_v1", "T20001"))
                    .setState(0)
                    .setTime(1781290005000L)
    ));

    expander.expand(IotDeviceMessage.requestOf(IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), params), gateway);

    ArgumentCaptor<IotDeviceMessage> captor = ArgumentCaptor.forClass(IotDeviceMessage.class);
    verify(deviceMessageProducer, times(1)).sendDeviceMessage(captor.capture());
    assertEquals(200L, captor.getValue().getDeviceId());
    assertEquals(IotDeviceMessageMethodEnum.STATE_UPDATE.getMethod(), captor.getValue().getMethod());
    assertEquals(1, ((IotDeviceStateUpdateReqDTO) captor.getValue().getParams()).getState());
}
```

- [ ] **Step 2: Run the focused expander test to verify the red state**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotSubDeviceStatePackExpanderTest test`

Expected: FAIL because the expander class does not exist and `IotDeviceMessageServiceImpl` has no branch for `thing.device.state.pack.post`.

- [ ] **Step 3: Implement the expander and wire it into dispatch**

```java
// IotSubDeviceStatePackExpander.java
@Service
@RequiredArgsConstructor
public class IotSubDeviceStatePackExpander {

    private final IotDeviceService deviceService;
    private final IotDeviceMessageProducer deviceMessageProducer;

    public void expand(IotDeviceMessage packMessage, IotDeviceDO gatewayDevice) {
        IotSubDeviceStatePackPostReqDTO params = JsonUtils.convertObject(
                packMessage.getParams(), IotSubDeviceStatePackPostReqDTO.class);
        if (params == null || CollUtil.isEmpty(params.getSubDevices())) {
            log.warn("[expand][消息({}) 参数解析失败或子设备为空]", packMessage);
            return;
        }
        for (IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState : params.getSubDevices()) {
            try {
                IotDeviceIdentity identity = subDeviceState.getIdentity();
                IotDeviceDO subDevice = deviceService.getDeviceFromCache(identity.getProductKey(), identity.getDeviceName());
                if (subDevice == null || !Objects.equals(subDevice.getGatewayId(), gatewayDevice.getId())) {
                    continue;
                }
                LocalDateTime reportTime = subDeviceState.getTime() != null
                        ? LocalDateTimeUtil.of(subDeviceState.getTime())
                        : packMessage.getReportTime();
                IotDeviceMessage stateMessage = IotDeviceMessage.buildStateUpdate(subDeviceState.getState(), reportTime)
                        .setDeviceId(subDevice.getId())
                        .setServerId(null);
                deviceMessageProducer.sendDeviceMessage(stateMessage);
            } catch (Exception ex) {
                log.error("[expand][子设备状态拆包失败 subDevice={}]", subDeviceState, ex);
            }
        }
    }
}
```

```java
// IotDeviceMessageServiceImpl.java
@Resource
private IotSubDeviceStatePackExpander subDeviceStatePackExpander;

if (Objects.equal(message.getMethod(), IotDeviceMessageMethodEnum.STATE_UPDATE.getMethod())) {
    String stateStr = IotDeviceMessageUtils.getIdentifier(message);
    Assert.notEmpty(stateStr, "设备状态不能为空");
    deviceService.updateDeviceState(device, Integer.valueOf(stateStr), message.getReportTime());
    return null;
}

if (Objects.equal(message.getMethod(), IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod())) {
    subDeviceStatePackExpander.expand(message, device);
    return null;
}
```

- [ ] **Step 4: Run the focused expander and regression tests**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotSubDeviceStatePackExpanderTest,IotDeviceMessageServiceImplTest,IotDeviceStateTimeTest,IotDeviceMessageSubscriberTest test`

Expected: PASS

- [ ] **Step 5: Commit the biz expansion change**

```bash
git add \
  east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpander.java \
  east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImpl.java \
  east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotSubDeviceStatePackExpanderTest.java \
  east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImplTest.java
git commit -m "feat(iot): expand sub-device state packs"
```

### Task 4: Add Manual Gateway Examples And Verify Module Compile

**Files:**
- Modify: `east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/http/IotGatewayDeviceHttpProtocolIntegrationTest.java`
- Modify: `east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/mqtt/IotGatewayDeviceMqttProtocolIntegrationTest.java`

- [ ] **Step 1: Add the disabled HTTP manual example**

```java
@Test
public void testStatePackPost() {
    String url = String.format("http://%s:%d/topic/sys/%s/%s/thing/device/state/pack/post",
            SERVER_HOST, SERVER_PORT, GATEWAY_PRODUCT_KEY, GATEWAY_DEVICE_NAME);
    IotSubDeviceStatePackPostReqDTO params = new IotSubDeviceStatePackPostReqDTO();
    params.setSubDevices(ListUtil.of(
            new IotSubDeviceStatePackPostReqDTO.SubDeviceState()
                    .setIdentity(new IotDeviceIdentity(SUB_DEVICE_PRODUCT_KEY, SUB_DEVICE_NAME))
                    .setState(1)
                    .setTime(System.currentTimeMillis())
    ));
    String payload = JsonUtils.toJsonString(MapUtil.builder()
            .put("method", IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod())
            .put("params", params)
            .build());
    try (HttpResponse httpResponse = HttpUtil.createPost(url)
            .header("Authorization", GATEWAY_TOKEN)
            .body(payload)
            .execute()) {
        log.info("[testStatePackPost][响应体: {}]", httpResponse.body());
    }
}
```

- [ ] **Step 2: Add the disabled MQTT manual example**

```java
@Test
public void testStatePackPost() throws Exception {
    MqttClient client = connectAndAuth();
    try {
        IotSubDeviceStatePackPostReqDTO params = new IotSubDeviceStatePackPostReqDTO()
                .setSubDevices(ListUtil.of(
                        new IotSubDeviceStatePackPostReqDTO.SubDeviceState()
                                .setIdentity(new IotDeviceIdentity(SUB_DEVICE_PRODUCT_KEY, SUB_DEVICE_NAME))
                                .setState(1)
                                .setTime(System.currentTimeMillis())
                ));
        IotDeviceMessage request = IotDeviceMessage.requestOf(
                IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), params);
        String replyTopic = String.format("/sys/%s/%s/thing/device/state/pack/post_reply",
                GATEWAY_PRODUCT_KEY, GATEWAY_DEVICE_NAME);
        subscribe(client, replyTopic);
        String topic = String.format("/sys/%s/%s/thing/device/state/pack/post",
                GATEWAY_PRODUCT_KEY, GATEWAY_DEVICE_NAME);
        IotDeviceMessage response = publishAndWaitReply(client, topic, request);
        log.info("[testStatePackPost][响应消息: {}]", response);
    } finally {
        disconnect(client);
    }
}
```

- [ ] **Step 3: Run gateway test compilation**

Run: `mvn -pl east-module-iot/east-module-iot-gateway -DskipTests test-compile`

Expected: PASS

- [ ] **Step 4: Run the full targeted verification sweep**

Run: `mvn -pl east-module-iot/east-module-iot-core,east-module-iot/east-module-iot-biz,east-module-iot/east-module-iot-gateway -am -DskipTests test-compile`

Expected: PASS

- [ ] **Step 5: Commit the manual verification examples**

```bash
git add \
  east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/http/IotGatewayDeviceHttpProtocolIntegrationTest.java \
  east-module-iot/east-module-iot-gateway/src/test/java/cn/iocoder/east/module/iot/gateway/protocol/mqtt/IotGatewayDeviceMqttProtocolIntegrationTest.java
git commit -m "test(iot): add sub-device state pack gateway examples"
```
