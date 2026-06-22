# Remove Tenant And Enable IoT Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Physically remove tenant support from the repository, wire the IoT module into the build, and verify MQTT device messages persist into history and event storage.

**Architecture:** Remove tenant behavior at the framework boundary first, then delete tenant-carrying fields from IoT models, messages, and SQL so schema and runtime stay aligned. After the code compiles and targeted tests pass, run the main server and IoT gateway locally and verify end-to-end MQTT ingestion with direct database checks.

**Tech Stack:** Java 17, Spring Boot 3, Maven, MyBatis, PostgreSQL, TDengine, Redis, Vert.x MQTT

---

### Task 1: Wire IoT Into The Reactor And Create The First Red Build

**Files:**
- Modify: `pom.xml`
- Modify: `east-server/pom.xml`
- Modify: `east-module-iot/east-module-iot-biz/pom.xml`
- Test: reactor compile for `east-server` and IoT modules

- [ ] **Step 1: Add IoT modules to the root reactor**

```xml
<modules>
    <module>east-dependencies</module>
    <module>east-framework</module>
    <module>east-server</module>
    <module>east-module-system</module>
    <module>east-module-infra</module>
    <module>east-module-iot</module>
</modules>
```

- [ ] **Step 2: Add IoT business module to the main server container**

```xml
<dependency>
    <groupId>com.ems.boot</groupId>
    <artifactId>east-module-iot-biz</artifactId>
    <version>${revision}</version>
</dependency>
```

- [ ] **Step 3: Remove the tenant starter from IoT business dependencies**

```xml
<!-- delete this block -->
<dependency>
    <groupId>com.ems.boot</groupId>
    <artifactId>east-spring-boot-starter-biz-tenant</artifactId>
</dependency>
```

- [ ] **Step 4: Run compile to create the first failing baseline**

Run: `mvn -pl east-server -am -DskipTests compile`

Expected: FAIL with unresolved tenant imports, fields, or inheritance in framework and IoT code.

- [ ] **Step 5: Capture the first compile blockers in the task log and commit only after Task 2 is green**

```bash
git status --short
```

Expected: `pom.xml`, `east-server/pom.xml`, and IoT POM changes visible; no commit yet.

### Task 2: Remove Tenant Handling From Shared Framework Contracts

**Files:**
- Modify: `east-framework/east-spring-boot-starter-web/src/main/java/cn/iocoder/east/framework/web/core/util/WebFrameworkUtils.java`
- Modify: `east-framework/east-spring-boot-starter-security/src/main/java/cn/iocoder/east/framework/security/core/LoginUser.java`
- Modify: `east-framework/east-spring-boot-starter-security/src/main/java/cn/iocoder/east/framework/security/core/filter/TokenAuthenticationFilter.java`
- Modify: `east-framework/east-spring-boot-starter-security/src/main/java/cn/iocoder/east/framework/security/core/util/SecurityFrameworkUtils.java`
- Modify: `east-framework/east-common/src/main/java/cn/iocoder/east/framework/common/biz/system/oauth2/dto/OAuth2AccessTokenCheckRespDTO.java`
- Modify or Delete: `east-framework/east-common/src/main/java/cn/iocoder/east/framework/common/biz/system/tenant/TenantCommonApi.java`
- Test: `east-framework/east-spring-boot-starter-security` and affected framework tests

- [ ] **Step 1: Write a failing unit test for a tenant-free login contract**

Create or extend a focused framework test so the login object and token parsing no longer require tenant fields:

```java
@Test
public void testBuildLoginUser_withoutTenantFields() {
    LoginUser loginUser = new LoginUser()
            .setId(1L)
            .setUserType(1)
            .setScopes(Set.of("all"));

    assertEquals(1L, loginUser.getId());
    assertEquals(Set.of("all"), loginUser.getScopes());
}
```

- [ ] **Step 2: Run the focused framework test to verify it fails for the right reason**

Run: `mvn -pl east-framework/east-spring-boot-starter-security -Dtest=*LoginUser* test`

Expected: FAIL because tenant fields or tenant-dependent builder paths still exist.

- [ ] **Step 3: Remove tenant headers and tenant fields from shared contracts**

Use these code-level changes:

```java
// WebFrameworkUtils.java
public static final String HEADER_TENANT_ID = null; // remove constant entirely
public static final String HEADER_VISIT_TENANT_ID = null; // remove constant entirely

// LoginUser.java
// delete:
// private Long tenantId;
// private Long visitTenantId;
```

```java
// TokenAuthenticationFilter.java
LoginUser loginUser = new LoginUser()
        .setId(accessToken.getUserId())
        .setUserType(accessToken.getUserType())
        .setScopes(accessToken.getScopes());
```

- [ ] **Step 4: Run the focused framework test again**

Run: `mvn -pl east-framework/east-spring-boot-starter-security -Dtest=*LoginUser* test`

Expected: PASS

- [ ] **Step 5: Re-run the server compile to expose the next layer of tenant fallout**

Run: `mvn -pl east-server -am -DskipTests compile`

Expected: FAIL moves from shared framework contracts to IoT domain/model code.

### Task 3: Remove Tenant Fields From IoT Models, Messages, And Jobs

**Files:**
- Modify: `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/mq/message/IotDeviceMessage.java`
- Modify: `east-module-iot/east-module-iot-core/src/main/java/cn/iocoder/east/module/iot/core/biz/dto/IotDeviceRespDTO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/device/IotDeviceDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/device/IotDeviceModbusConfigDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/device/IotDeviceModbusPointDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/device/IotDeviceMessageDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/product/IotProductDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/dal/dataobject/rule/IotSceneRuleDO.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/job/device/IotDeviceOfflineCheckJob.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/job/ota/IotOtaUpgradeJob.java`
- Test: `east-module-iot/east-module-iot-core/src/test/.../IotDeviceMessageUtilsTest.java`

- [ ] **Step 1: Write a failing IoT core test for tenant-free message creation**

Extend the IoT core tests with a call site that uses the new message factory signature:

```java
@Test
public void testRequestOf_withoutTenantId() {
    IotDeviceMessage message = IotDeviceMessage.requestOf(
            1L, "server-1",
            IotDeviceMessageMethodEnum.EVENT_POST.getMethod(),
            IotDeviceEventPostReqDTO.of("alarm", "hot"));

    assertEquals(1L, message.getDeviceId());
    assertEquals("server-1", message.getServerId());
    assertEquals("thing.event.post", message.getMethod());
}
```

- [ ] **Step 2: Run the focused IoT core test and verify the red state**

Run: `mvn -pl east-module-iot/east-module-iot-core -Dtest=IotDeviceMessageUtilsTest test`

Expected: FAIL because `requestOf` still requires `tenantId` or the message still exposes tenant fields.

- [ ] **Step 3: Remove tenant fields and tenant inheritance from IoT models**

Apply these structural edits:

```java
// IotDeviceMessage.java
// delete: private Long tenantId;
public static IotDeviceMessage requestOf(Long deviceId, String serverId,
        String method, Object params) {
    return new IotDeviceMessage()
            .setDeviceId(deviceId)
            .setServerId(serverId)
            .setMethod(method)
            .setParams(params);
}
```

```java
// IotDeviceDO / IotProductDO / IotSceneRuleDO / modbus DOs
public class IotDeviceDO extends BaseDO {
    // explicit fields only; no tenantId
}
```

```java
// jobs
// remove TenantJob import/annotation/wrapping and keep plain scheduled job logic
```

- [ ] **Step 4: Run the focused IoT core test again**

Run: `mvn -pl east-module-iot/east-module-iot-core -Dtest=IotDeviceMessageUtilsTest test`

Expected: PASS

- [ ] **Step 5: Re-run compile to expose service and mapper call sites still passing tenantId**

Run: `mvn -pl east-server -am -DskipTests compile`

Expected: FAIL in IoT services and MQ consumers still referencing `getTenantId()` or `TenantUtils`.

### Task 4: Remove Tenant Context Switching From IoT Services, MQ, And HTTP Examples

**Files:**
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/IotDeviceServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/product/IotProductServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/rule/scene/IotSceneRuleServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/thingmodel/IotThingModelServiceImpl.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/mq/consumer/device/IotDeviceMessageSubscriber.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/mq/consumer/rule/IotDataRuleMessageSubscriber.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/rule/data/action/IotHttpDataSinkAction.java`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/controller/admin/**/*.http`
- Test: `east-module-iot/east-module-iot-biz/src/test/java/cn/iocoder/east/module/iot/service/device/message/IotDeviceMessageServiceImplTest.java`

- [ ] **Step 1: Write a failing IoT service test for pack-message fan-out without tenant propagation**

Extend `IotDeviceMessageServiceImplTest` with a producer capture test:

```java
@Test
public void testHandlePackMessage_publishPropertyAndEventWithoutTenantId() {
    IotDeviceDO device = buildDevice();
    IotDeviceMessage pack = buildPackMessage();

    service.handleUpstreamDeviceMessage(pack, device);

    ArgumentCaptor<IotDeviceMessage> captor = ArgumentCaptor.forClass(IotDeviceMessage.class);
    verify(deviceMessageProducer, atLeast(2)).sendDeviceMessage(captor.capture());
    assertTrue(captor.getAllValues().stream().allMatch(msg -> msg.getDeviceId() != null));
}
```

- [ ] **Step 2: Run the focused IoT service test to verify it fails**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceMessageServiceImplTest test`

Expected: FAIL because service code still calls `getTenantId()`, `TenantUtils.execute(...)`, or tenant-bearing message factories.

- [ ] **Step 3: Remove tenant wrappers and tenant-bearing headers from service code**

Make these behavioral changes:

```java
// IotDeviceMessageServiceImpl.java
message.setId(IotDeviceMessageUtils.generateMessageId())
        .setReportTime(LocalDateTime.now())
        .setDeviceId(device.getId());

IotDeviceMessage propertyMsg = IotDeviceMessage.requestOf(
        device.getId(), serverId,
        IotDeviceMessageMethodEnum.PROPERTY_POST.getMethod(),
        IotDevicePropertyPostReqDTO.of(properties));
```

```java
// MQ subscribers
public void onMessage(IotDeviceMessage message) {
    dataRuleService.executeDataRule(message);
}
```

```http
### delete from .http examples
tenant-id: {{adminTenantId}}
visit-tenant-id: {{adminTenantId}}
```

- [ ] **Step 4: Run the focused IoT service test again**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceMessageServiceImplTest test`

Expected: PASS

- [ ] **Step 5: Re-run compile and confirm only schema/SQL mismatches remain**

Run: `mvn -pl east-server -am -DskipTests compile`

Expected: FAIL now points primarily to SQL/mapper signatures or residual DTO field references.

### Task 5: Remove Tenant Columns From TDengine, SQL Fixtures, And Rule Persistence

**Files:**
- Modify: `east-module-iot/east-module-iot-biz/src/main/resources/mapper/device/IotDeviceMessageMapper.xml`
- Modify: `east-module-iot/east-module-iot-biz/src/main/resources/mapper/device/IotDevicePropertyMapper.xml` if required by field alignment
- Modify: `east-module-iot/east-module-iot-biz/src/test/resources/sql/create_tables.sql`
- Modify: `east-module-iot/east-module-iot-biz/src/test/resources/application-unit-test.yaml`
- Modify: `east-module-iot/east-module-iot-biz/src/main/java/cn/iocoder/east/module/iot/service/rule/data/action/IotDatabaseDataRuleAction.java`
- Test: compile plus IoT business tests

- [ ] **Step 1: Write a failing persistence-focused test or assertion around message log shape**

Extend the existing IoT business unit test to assert `IotDeviceMessageDO` no longer carries tenant fields after log creation:

```java
@Test
public void testCreateDeviceLogAsync_withoutTenantIdField() {
    IotDeviceMessage message = buildMessage(IotDeviceMessageMethodEnum.PROPERTY_POST.getMethod());

    service.createDeviceLogAsync(message);

    ArgumentCaptor<IotDeviceMessageDO> captor = ArgumentCaptor.forClass(IotDeviceMessageDO.class);
    verify(deviceMessageMapper).insert(captor.capture());
    assertNull(BeanUtil.getFieldValue(captor.getValue(), "tenantId"));
}
```

- [ ] **Step 2: Run the focused IoT business test and verify it fails**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceMessageServiceImplTest test`

Expected: FAIL because `IotDeviceMessageDO` and mapper XML still carry tenant columns or fields.

- [ ] **Step 3: Remove tenant columns from mapper XML and SQL**

Use this exact mapper direction:

```xml
CREATE STABLE IF NOT EXISTS device_message (
    ts TIMESTAMP,
    id NCHAR(50),
    report_time TIMESTAMP,
    server_id NCHAR(50),
    upstream BOOL,
    reply BOOL,
    identifier NCHAR(100),
    request_id NCHAR(50),
    method NCHAR(100),
    params VARCHAR(8192),
    data VARCHAR(8192),
    code INT,
    msg NCHAR(256)
) TAGS (
    device_id BIGINT
)
```

```xml
INSERT INTO device_message_${deviceId} (
    ts, id, report_time, server_id,
    upstream, reply, identifier, request_id, method,
    params, data, code, msg
)
```

```java
// IotDatabaseDataRuleAction.java
"INSERT INTO {} (id, device_id, method, report_time, data, create_time) VALUES (?, ?, ?, ?, ?, NOW())"
```

- [ ] **Step 4: Run the focused IoT business test again**

Run: `mvn -pl east-module-iot/east-module-iot-biz -Dtest=IotDeviceMessageServiceImplTest test`

Expected: PASS

- [ ] **Step 5: Run a compile + targeted test sweep**

Run: `mvn -pl east-server -am test -Dtest=IotDeviceMessageServiceImplTest,IotDeviceMessageUtilsTest -Dsurefire.failIfNoSpecifiedTests=false`

Expected: PASS for the targeted sweep and successful compilation of the connected modules.

### Task 6: Local Startup And MQTT Persistence Verification

**Files:**
- Modify: `east-server/src/main/resources/application-local.yaml`
- Modify: `east-module-iot/east-module-iot-gateway/src/main/resources/application.yaml`
- Modify if needed: local SQL/bootstrap files used for manual verification
- Test: local runtime processes and direct database queries

- [ ] **Step 1: Enable the MQTT protocol and ensure local datasources are complete**

Use configuration changes like:

```yaml
# east-module-iot-gateway/src/main/resources/application.yaml
- id: mqtt-json
  enabled: true
  protocol: mqtt
  port: 1883
```

```yaml
# east-server/src/main/resources/application-local.yaml
spring:
  datasource:
    dynamic:
      datasource:
        tdengine:
          url: jdbc:TAOS-RS://127.0.0.1:6041/iot
```

- [ ] **Step 2: Start the main server and IoT gateway**

Run: `mvn -pl east-server spring-boot:run -Dspring-boot.run.profiles=local`

Run: `mvn -pl east-module-iot/east-module-iot-gateway spring-boot:run`

Expected: both processes start without tenant-related bean, SQL, or message errors.

- [ ] **Step 3: Publish one property message and one event message through MQTT**

Run:

```bash
mosquitto_pub -h 127.0.0.1 -p 1883 \
  -t "/sys/4aymZgOTOOCrDKRT/small/thing/event/property/post" \
  -m '{"id":"prop-1","version":"1.0","params":{"temperature":25.5},"method":"thing.event.property.post"}'
```

Run:

```bash
mosquitto_pub -h 127.0.0.1 -p 1883 \
  -t "/sys/4aymZgOTOOCrDKRT/small/thing/event/post" \
  -m '{"id":"event-1","version":"1.0","params":{"identifier":"alarm","value":"high"},"method":"thing.event.post"}'
```

Expected: gateway logs upstream publish handling and the main server logs message persistence without tenant errors.

- [ ] **Step 4: Verify TDengine history rows and event persistence**

Run:

```bash
DEVICE_ID=$(psql -h 127.0.0.1 -U iot -d ruoyi_vue_pro -tAc "SELECT id FROM iot_device d JOIN iot_product p ON p.id = d.product_id WHERE p.product_key = '4aymZgOTOOCrDKRT' AND d.device_name = 'small' LIMIT 1;")
taos -s "USE iot; SELECT ts,id,method,identifier FROM device_message_${DEVICE_ID} ORDER BY ts DESC LIMIT 10;"
```

Run:

```bash
psql -h 127.0.0.1 -U iot -d ruoyi_vue_pro -c "SELECT id, device_id, method, report_time FROM iot_test_event_log ORDER BY create_time DESC LIMIT 10;"
```

Expected: one property history row and one event persistence row visible with no `tenant_id` column involved.

- [ ] **Step 5: Commit after fresh verification**

```bash
git add pom.xml east-server/pom.xml east-framework east-module-iot docs/superpowers/specs/2026-06-08-remove-tenant-and-enable-iot-design.md docs/superpowers/plans/2026-06-08-remove-tenant-and-enable-iot.md
git commit -m "refactor: remove tenant support and enable iot ingestion"
```

Run before claiming completion:

```bash
mvn -pl east-server -am test -Dsurefire.failIfNoSpecifiedTests=false
```

Expected: PASS or a precisely reported remaining blocker with command output captured.
