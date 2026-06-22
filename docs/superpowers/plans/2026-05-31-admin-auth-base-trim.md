# Admin Auth Base Trim Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trim the project down to an admin-auth-only backend base that preserves admin users, role/menu permissions, login/logout/refresh-token, captcha, and the basic security chain.

**Architecture:** Keep the existing admin auth flow and token mechanism, but remove unrelated framework capabilities and dead feature branches around it. Preserve only the OAuth2 token pieces required by login/logout/refresh-token, and clean configuration, SQL, and dependencies to match the reduced backend base.

**Tech Stack:** Spring Boot 3, Spring Security, MyBatis Plus, Redis, PostgreSQL, Maven, aj-captcha

---

### Task 1: Lock the auth boundary before deletions

**Files:**
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/docs/superpowers/specs/2026-05-31-admin-auth-base-trim-design.md`
- Inspect: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/auth/AdminAuthServiceImpl.java`
- Inspect: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2TokenServiceImpl.java`
- Inspect: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/controller/admin/auth/AuthController.java`

- [ ] **Step 1: Re-read the design and auth entry points**

Run: `sed -n '1,260p' docs/superpowers/specs/2026-05-31-admin-auth-base-trim-design.md`
Expected: the preserved capabilities remain login/logout/refresh-token, captcha, and admin permission assembly.

- [ ] **Step 2: Confirm the required auth methods**

Run: `rg -n "login\\(|logout\\(|refreshToken\\(|createAccessToken\\(|refreshAccessToken\\(" east-module-system/src/main/java`
Expected: only the admin auth flow and token flow are treated as must-keep paths.

- [ ] **Step 3: Record any newly discovered auth blockers inline in the spec if needed**

```md
## Risk Areas

### 5. Newly found auth coupling

If another required class is discovered during execution, update this section before deleting its dependencies.
```

- [ ] **Step 4: Re-open compile baseline**

Run: `mvn -q -pl east-server -am -DskipTests compile`
Expected: success before further deletions.

### Task 2: Remove non-target framework dependencies and dead bridge code

**Files:**
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/pom.xml`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/pom.xml`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-server/src/main/resources/application.yaml`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-server/src/main/resources/application-dev.yaml`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-server/src/main/resources/application-local.yaml`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/auth/AdminAuthServiceImpl.java`
- Delete/Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/member/*`
- Delete/Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/job/DemoJob.java`
- Delete/Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/websocket/*`
- Delete/Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/monitor/*`

- [ ] **Step 1: Remove direct module dependencies not allowed in the target base**

```xml
<!-- remove from east-module-system -->
<artifactId>east-spring-boot-starter-biz-tenant</artifactId>
<artifactId>east-spring-boot-starter-biz-ip</artifactId>
<artifactId>east-spring-boot-starter-job</artifactId>
<artifactId>east-spring-boot-starter-mq</artifactId>

<!-- remove from east-module-infra -->
<artifactId>east-spring-boot-starter-biz-tenant</artifactId>
<artifactId>east-spring-boot-starter-websocket</artifactId>
<artifactId>east-spring-boot-starter-job</artifactId>
<artifactId>east-spring-boot-starter-mq</artifactId>
<artifactId>east-spring-boot-starter-monitor</artifactId>
<artifactId>mybatis-plus-generator</artifactId>
<artifactId>velocity-engine-core</artifactId>
<artifactId>spring-boot-admin-starter-server</artifactId>
<artifactId>commons-net</artifactId>
<artifactId>jsch</artifactId>
<artifactId>s3</artifactId>
<artifactId>tika-core</artifactId>
```

- [ ] **Step 2: Remove non-target config blocks**

```yaml
# delete from application*.yaml
rocketmq:
spring.kafka:
spring.ai:
east.ai:
east.tenant:
east.websocket:
```

- [ ] **Step 3: Remove the member bridge from logout logging**

```java
private void createLogoutLog(Long userId, Integer userType, Integer logType) {
    LoginLogCreateReqDTO reqDTO = new LoginLogCreateReqDTO();
    reqDTO.setLogType(logType);
    reqDTO.setTraceId(TracerUtils.getTraceId());
    reqDTO.setUserId(userId);
    reqDTO.setUserType(userType);
    reqDTO.setUsername(getUsername(userId));
    reqDTO.setUserAgent(ServletUtils.getUserAgent());
    reqDTO.setUserIp(ServletUtils.getClientIP());
    reqDTO.setResult(LoginResultEnum.SUCCESS.getResult());
    loginLogService.createLoginLog(reqDTO);
}
```

- [ ] **Step 4: Delete demo, monitor, websocket, and unused bridge code**

Run: `rg -n "DemoJob|MemberService|websocket|AdminServerConfiguration" east-module-system/src/main/java east-module-infra/src/main/java`
Expected: no remaining auth-unrelated demo bridge code.

- [ ] **Step 5: Re-run compile after framework cleanup**

Run: `mvn -q -pl east-server -am -DskipTests compile`
Expected: success or a reduced set of compile failures pointing only to the next cleanup layer.

### Task 3: Reduce OAuth2 to token-only support

**Files:**
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2TokenService.java`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2TokenServiceImpl.java`
- Modify/Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2ClientService*.java`
- Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2ApproveService*.java`
- Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2CodeService*.java`
- Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/service/oauth2/OAuth2GrantService*.java`
- Delete/Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/controller/admin/oauth2/**`
- Modify/Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/dal/dataobject/oauth2/**`
- Modify/Delete: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/main/java/cn/iocoder/east/module/system/dal/mysql/oauth2/**`

- [ ] **Step 1: Replace dynamic OAuth2 client lookup with a fixed token client profile**

```java
private static final String DEFAULT_CLIENT_ID = OAuth2ClientConstants.CLIENT_ID_DEFAULT;
private static final long ACCESS_TOKEN_VALIDITY_SECONDS = 60L * 60 * 24;
private static final long REFRESH_TOKEN_VALIDITY_SECONDS = 60L * 60 * 24 * 30;
```

- [ ] **Step 2: Remove token service dependencies on full client/grant/approve/code machinery**

```java
public OAuth2AccessTokenDO createAccessToken(Long userId, Integer userType, String clientId, List<String> scopes) {
    OAuth2RefreshTokenDO refreshTokenDO = createOAuth2RefreshToken(userId, userType, scopes);
    return createOAuth2AccessToken(refreshTokenDO);
}
```

- [ ] **Step 3: Delete token admin page and client-management API surfaces because they are outside the target base**

Run: `rg -n "OAuth2ClientPageReqVO|OAuth2ClientSaveReqVO|OAuth2AccessTokenPageReqVO|controller/admin/oauth2" east-module-system/src/main/java`
Expected: only token structures still needed by auth/security remain.

- [ ] **Step 4: Remove tenant handling from token DOs and token service**

```java
// delete tenant-dependent code paths
accessTokenDO.setTenantId(tenantId);
TenantUtils.execute(...);
TenantContextHolder.getTenantId();
```

- [ ] **Step 5: Re-run compile after token-only reduction**

Run: `mvn -q -pl east-server -am -DskipTests compile`
Expected: success or only SQL/test/resource cleanup fallout.

### Task 4: Sync SQL, tests, and docs with the trimmed base

**Files:**
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/sql/postgresql/ruoyi-vue-pro.sql`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/sql/postgresql/quartz.sql`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/README.md`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/test/resources/sql/create_tables.sql`
- Modify: `/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-system/src/test/resources/sql/clean.sql`
- Delete/Modify: OAuth2, tenant, MQ, websocket, monitor related tests under `east-module-system/src/test/java` and `east-module-infra/src/test/java`

- [ ] **Step 1: Remove SQL structures no longer backed by code**

Run: `rg -n "tenant_id|system_oauth2_approve|system_oauth2_client|system_oauth2_code|websocket|mq|demo" sql/postgresql/ruoyi-vue-pro.sql`
Expected: only auth-required token tables and admin auth-related tables remain.

- [ ] **Step 2: Update README to match the new backend base**

```md
## Retained system capabilities

- auth, captcha, refresh token
- admin users
- roles, menus, permissions
```

- [ ] **Step 3: Remove tests that target deleted capabilities and keep auth/permission coverage compiling**

Run: `rg -n "oauth2|tenant|mail|sms|notify|social|websocket|monitor|demo" east-module-system/src/test east-module-infra/src/test`
Expected: deleted capabilities no longer have tests wired into the project.

- [ ] **Step 4: Run the final compile verification**

Run: `mvn -q -pl east-server -am -DskipTests compile`
Expected: exit code 0.

- [ ] **Step 5: Commit the implementation**

```bash
git add README.md sql/postgresql/ruoyi-vue-pro.sql east-module-system east-module-infra east-server docs/superpowers/plans/2026-05-31-admin-auth-base-trim.md
git commit -m "refactor: trim backend to admin auth base"
```
