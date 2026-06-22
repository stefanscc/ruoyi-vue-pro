# Remove Tenant And Enable IoT Design

## Background

The repository was previously trimmed toward a simpler single-application deployment model, but the newly added `east-module-iot` reintroduced tenant-aware code paths, fields, dependencies, and SQL.

The goal of this change is to remove tenant support physically from the repository, not merely disable it. After the cleanup, we also need to run the main application and the IoT gateway, simulate device MQTT messages, and verify message persistence into the history store and event table.

## Goals

1. Remove tenant-specific dependencies, fields, request headers, context switching, and SQL columns from the repository.
2. Convert the repository to a tenant-free runtime model where device and user flows no longer depend on tenant context.
3. Keep the IoT message path working for property history and event persistence.
4. Verify the runtime path end to end by starting the project and sending MQTT messages from a simulated device.

## Non-Goals

1. Preserve backward compatibility for existing tenant-based APIs, DTOs, or SQL schemas.
2. Support both tenant and non-tenant modes at the same time.
3. Refactor unrelated modules beyond what is required to remove tenant coupling and restore build/runtime stability.

## Scope

### In Scope

1. Root/module POM dependency cleanup for tenant starter usage.
2. Framework-level request, security, token, and DTO cleanup where tenant data is still carried.
3. IoT DO/DTO/MQ/service/mapper/test/config cleanup for tenant removal.
4. SQL and TDengine schema updates to remove `tenant_id`.
5. HTTP example files and test fixtures that still send `tenant-id`.
6. End-to-end local verification of MQTT ingestion and persistence.

### Out Of Scope

1. Documentation updates unrelated to the tenant cleanup and IoT verification path.
2. Broad framework redesign not required by compilation or runtime verification.

## Current Findings

1. The workspace has an untracked `east-module-iot/` tree.
2. The main root `pom.xml` does not currently include the IoT module in `<modules>`.
3. The IoT module directly depends on `east-spring-boot-starter-biz-tenant`.
4. The IoT module stores message history in TDengine `device_message` and still includes `tenant_id`.
5. Tenant references still exist in framework security/web classes and in a small set of common DTOs/APIs.

## Recommended Approach

Use a full physical removal strategy:

1. Delete tenant dependencies and data fields rather than turning them into no-ops.
2. Replace tenant-aware base classes and helper calls with direct non-tenant implementations.
3. Update all SQL, mapper XML, and test fixtures in the same pass so schema and code stay aligned.
4. Re-enable IoT integration in the root build and local runtime configuration only after the repository compiles cleanly.

This is the highest-risk option, but it matches the requirement exactly and avoids leaving hidden tenant assumptions in message handling or storage.

## Design

### 1. Build And Module Topology

1. Add `east-module-iot` to the root build if it is intended to compile as part of this workspace.
2. Remove `east-spring-boot-starter-biz-tenant` from IoT and any remaining module dependencies.
3. Resolve follow-on compilation fallout by converting tenant-based imports and inheritance to tenant-free equivalents.

### 2. Framework Cleanup

1. Remove tenant headers from `WebFrameworkUtils` and any caller paths.
2. Remove tenant fields from security login/session/token transfer objects where still present.
3. Remove tenant propagation in token authentication and request handling.
4. Remove or simplify common tenant APIs that no longer have consumers after cleanup.

### 3. Domain Model Cleanup

1. Replace `TenantBaseDO` inheritance in IoT DOs with an appropriate non-tenant base class.
2. Remove `tenantId` from IoT message DTOs, RPC DTOs, and MQ payloads.
3. Remove tenant-dependent execution wrappers such as `TenantUtils.execute(...)`.
4. Remove tenant-aware job annotations or wrappers and keep the job logic single-context.

### 4. Persistence Cleanup

1. Remove `tenant_id` from IoT relational test SQL and any runtime DDL files in scope.
2. Remove `tenant_id` from the TDengine `device_message` stable definition and related inserts/selects.
3. Remove `tenant_id` from event/history sink SQL such as rule action persistence.
4. Keep non-tenant parser workarounds such as `@InterceptorIgnore(tenantLine = "true")` when they are purely parser settings rather than tenant behavior.

### 5. Message Handling Changes

1. Use only `deviceId`, `productKey`, `deviceName`, `serverId`, `requestId`, and message body for routing and persistence.
2. Ensure pack-message expansion for property and event sub-messages no longer injects tenant data.
3. Update MQ consumers so they process messages directly without tenant context switching.
4. Preserve current message semantics for upstream, downstream, reply detection, and rule execution.

### 6. Local Runtime And Verification

1. Ensure local app config contains all required Postgres, Redis, TDengine, and IoT gateway settings.
2. Enable the MQTT protocol listener in `iot-gateway` local config for test execution.
3. Start the main server and IoT gateway locally.
4. Simulate a device MQTT connection and publish:
   - one property message
   - one event message
5. Verify:
   - device message history exists in TDengine `device_message_*`
   - event persistence exists in the configured event table
   - no tenant field is present in message payloads, storage schemas, or runtime APIs

## Implementation Plan Summary

1. Add or adjust failing tests first around IoT message persistence and any framework contracts touched by tenant removal.
2. Remove tenant coupling from shared framework classes.
3. Remove tenant coupling from IoT models, services, MQ payloads, mappers, and SQL.
4. Reconcile build/module wiring and local configuration.
5. Run targeted tests, then local startup and MQTT verification.

## Risks And Mitigations

### Risk: Hidden framework references still expect tenant fields

Mitigation:
Use compile failures and targeted tests to find and remove every remaining dependency path before runtime testing.

### Risk: SQL/schema drift between code and local databases

Mitigation:
Update mapper XML, relational SQL fixtures, TDengine DDL, and verification queries together in one change set.

### Risk: IoT path compiles but runtime ingestion fails

Mitigation:
Verify incrementally:
1. message object creation
2. MQ consumer processing
3. history persistence
4. MQTT end-to-end publish flow

### Risk: Over-deleting names that merely contain tenant-related parser settings

Mitigation:
Delete by behavior, not by substring. Keep parser/config names when they are not tenant runtime features.

## Testing Strategy

1. Update or add targeted unit/integration tests for IoT message persistence and pack-message splitting.
2. Run affected framework and IoT tests after each major cleanup wave.
3. Run local startup verification for both the main server and `iot-gateway`.
4. Publish MQTT test messages with a simulated device and confirm persistence by direct database queries.

## Success Criteria

1. Repository source and configuration no longer carry tenant fields or tenant request headers as runtime behavior.
2. The project builds successfully with the IoT module included.
3. The main server and IoT gateway both start locally.
4. Simulated MQTT messages successfully land in history storage and the event table.
5. No tenant-related runtime error appears during local verification.
