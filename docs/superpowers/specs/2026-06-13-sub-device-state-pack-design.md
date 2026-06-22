# Sub Device State Pack Design

## Background

The current IoT platform already supports gateway devices, sub-device binding, property/event reporting, and gateway-side online/offline updates. It identifies a device by `productKey + deviceName`, and uses `gatewayId` only as the topology binding between a gateway and its sub-devices.

The new requirement is to support online/offline updates for many sub-devices that do not connect to MQTT individually. A field gateway maintains each sub-device's communication status and reports those statuses upstream through the existing IoT gateway service.

The user confirmed that sub-device identification should continue to use `productKey + deviceName`.

## Goals

1. Let a gateway report online/offline states for multiple sub-devices in one upstream message.
2. Reuse the existing `thing.state.update` state pipeline for the final device-state update behavior.
3. Keep the current device identity model unchanged: `productKey + deviceName`.
4. Ensure the platform validates that the reported sub-device belongs to the reporting gateway.

## Non-Goals

1. Introduce a new device identity scheme such as business device type plus business device number.
2. Change the direct-device online/offline flow or the EMQX client connected/disconnected handling.
3. Redesign the topology model, device table structure, or existing property/event pack behavior.

## Current Findings

1. Device identity is modeled by `IotDeviceIdentity`, which contains only `productKey` and `deviceName`.
2. Gateway property/event batch reporting already supports mixed sub-device models in a single packet because each sub-device carries its own `identity`.
3. Existing sub-device state updates are only produced indirectly:
   - direct `thing.state.update`
   - EMQX client connected/disconnected mapped to gateway device state
   - forced online when a non-state upstream message arrives
   - offline timeout job
4. There is no existing upstream method for a gateway to report many sub-device states in one message.

## Approaches Considered

### 1. Add a dedicated sub-device state pack message

Add a new upstream method such as `thing.device.state.pack.post`. The gateway reports a list of sub-device identities and their target states. The platform splits the pack into standard state updates.

Why this is recommended:
1. It matches the semantics exactly.
2. It keeps sub-device state handling aligned with the current state-update pipeline.
3. It avoids overloading property or event reporting with transport-state meaning.

### 2. Reuse property pack reporting with a synthetic status property

Carry online/offline as a property like `commState` inside `thing.event.property.pack.post`.

Why this is not recommended:
1. Communication status is not really a business property.
2. It would require extra rule or property-side interpretation to become device online/offline state.
3. It blurs the boundary between device telemetry and platform connectivity state.

### 3. Send one `thing.state.update` per sub-device

Have the field gateway emit one normal state message for each sub-device.

Why this is acceptable but not preferred:
1. It is simple.
2. It creates more traffic and more per-message overhead.
3. It is less natural for a gateway that already batches downstream sub-device observations.

## Recommended Design

Use approach 1 and introduce a new upstream method:

`thing.device.state.pack.post`

The message is reported by a gateway device. Its payload contains a `subDevices` list, and each list item contains:
1. `identity.productKey`
2. `identity.deviceName`
3. `state`
4. `time` optional report timestamp in milliseconds, omitted when the gateway has no per-item time

The platform receives the pack, validates the gateway/sub-device relationship, converts each sub-device record into a standard `thing.state.update`, and pushes those converted messages through the existing MQ and device-state flow.

## Message Contract

### Upstream method

`thing.device.state.pack.post`

### Example payload

```json
{
  "id": "state-pack-1001",
  "method": "thing.device.state.pack.post",
  "params": {
    "subDevices": [
      {
        "identity": {
          "productKey": "smoke_sensor_v1",
          "deviceName": "A10001"
        },
        "state": 1,
        "time": 1781290000000
      },
      {
        "identity": {
          "productKey": "temp_humi_v1",
          "deviceName": "T20001"
        },
        "state": 0,
        "time": 1781290005000
      }
    ]
  }
}
```

### State values

Use the existing device state values already understood by the platform:
1. `1` for online
2. `0` for offline

If other values appear, the platform should reject that sub-device record as invalid and continue processing the rest of the pack.

## Processing Flow

### 1. Gateway ingress

The upstream protocol handlers continue to treat the gateway itself as the reporting device. The message enters the existing IoT gateway service exactly like other upstream methods.

### 2. Message dispatch

The biz-side device message service recognizes `thing.device.state.pack.post` as a new upstream method and routes it to a dedicated pack handler.

### 3. Pack expansion

For each `subDevices` item:
1. Read `identity.productKey + identity.deviceName`
2. Load the sub-device from cache/database
3. Verify the sub-device exists
4. Verify `subDevice.gatewayId == gatewayDevice.id`
5. Build a standard `thing.state.update` message for that sub-device
6. Preserve the per-item timestamp when provided
7. Send the converted state message to the existing device message producer

### 4. Final state update

The converted `thing.state.update` messages are then processed by the existing pipeline:
1. device message subscriber
2. upstream device message handling
3. `deviceService.updateDeviceState(...)`
4. cache eviction and online/offline time maintenance
5. scene-rule/device-state trigger logic

This keeps the new feature isolated to pack parsing and expansion instead of creating a second state-update mechanism.

## Validation And Error Handling

### Per-pack validation

1. The reporting device must be a gateway device.
2. `params.subDevices` must not be empty.

If the pack itself is invalid, reject the whole message.

### Per-sub-device validation

1. `identity` must contain both `productKey` and `deviceName`.
2. The sub-device must exist.
3. The sub-device must belong to the reporting gateway.
4. `state` must be a supported device state.

If one sub-device record fails validation:
1. log the failure with gateway identity and sub-device identity
2. skip only that record
3. continue processing the rest of the pack

This matches the platform's existing tolerant behavior for property/event pack expansion.

## Data And Compatibility Impact

1. No database schema change is required.
2. No change is required to the device identity model.
3. Existing direct-device state updates keep working as-is.
4. Existing gateway property/event pack reporting keeps working as-is.
5. EMQX webhook-based gateway online/offline handling keeps working as-is.

## Testing Strategy

1. Add unit tests for the new pack DTO parsing and handler behavior.
2. Add service tests that verify:
   - valid sub-device records are expanded into standard `thing.state.update`
   - unknown sub-devices are skipped
   - sub-devices bound to another gateway are skipped
   - mixed online/offline states in one pack are both processed
3. Add protocol integration coverage for at least one gateway upstream path that already supports pack reporting.
4. Verify that expanded sub-device states still trigger the existing device-state update path and scene-rule matching.

## Success Criteria

1. A gateway can report multiple sub-device online/offline states in one upstream message.
2. The platform resolves sub-devices by `productKey + deviceName` only.
3. Each valid sub-device state is converted into the existing `thing.state.update` flow.
4. Invalid sub-device records do not block valid ones in the same pack.
5. No schema change or identity-model change is introduced.
