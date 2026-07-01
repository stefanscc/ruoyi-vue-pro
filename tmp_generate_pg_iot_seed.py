from __future__ import annotations

import re
from pathlib import Path


SOURCE = Path(r"sql/postgresql/iot-2026-02-10-传播违法1.sql")
TARGET = Path(r"sql/postgresql/iot-2026-02-10-传播违法.sql")

TABLES = ["iot_product", "iot_device", "iot_thing_model"]

PG_COLUMNS = {
    "iot_product": [
        "id",
        "name",
        "product_key",
        "product_secret",
        "register_enabled",
        "category_id",
        "icon",
        "pic_url",
        "description",
        "status",
        "device_type",
        "net_type",
        "protocol_type",
        "serialize_type",
        "creator",
        "create_time",
        "updater",
        "update_time",
        "deleted",
    ],
    "iot_device": [
        "id",
        "device_name",
        "nickname",
        "serial_number",
        "pic_url",
        "group_ids",
        "product_id",
        "product_key",
        "device_type",
        "gateway_id",
        "state",
        "online_time",
        "offline_time",
        "active_time",
        "firmware_id",
        "device_secret",
        "latitude",
        "longitude",
        "config",
        "creator",
        "create_time",
        "updater",
        "update_time",
        "deleted",
    ],
    "iot_thing_model": [
        "id",
        "identifier",
        "name",
        "description",
        "product_id",
        "product_key",
        "type",
        "property",
        "event",
        "service",
        "creator",
        "create_time",
        "updater",
        "update_time",
        "deleted",
    ],
}

SEQUENCES = {
    "iot_product": "iot_product_seq",
    "iot_device": "iot_device_seq",
    "iot_thing_model": "iot_thing_model_seq",
}

DEFAULTS = {
    "iot_product": {
        "name": "",
        "product_key": "",
        "register_enabled": False,
        "status": 0,
        "device_type": 0,
        "net_type": 0,
        "protocol_type": "mqtt",
        "serialize_type": "json",
        "creator": "",
        "create_time": "CURRENT_TIMESTAMP",
        "updater": "",
        "update_time": "CURRENT_TIMESTAMP",
        "deleted": 0,
    },
    "iot_device": {
        "device_name": "",
        "product_key": "",
        "device_type": 0,
        "state": 0,
        "device_secret": "",
        "creator": "",
        "create_time": "CURRENT_TIMESTAMP",
        "updater": "",
        "update_time": "CURRENT_TIMESTAMP",
        "deleted": 0,
    },
    "iot_thing_model": {
        "identifier": "",
        "name": "",
        "product_key": "",
        "creator": "",
        "create_time": "CURRENT_TIMESTAMP",
        "updater": "",
        "update_time": "CURRENT_TIMESTAMP",
        "deleted": 0,
    },
}

PACK_SQL = r"""
-- Additional pack-pressure-test seed
INSERT INTO public.iot_product (
    id, name, product_key, product_secret, register_enabled, category_id, icon, pic_url,
    description, status, device_type, net_type, protocol_type, serialize_type,
    creator, create_time, updater, update_time, deleted
) VALUES
    (1101, 'Gateway Test Product', 'gwPkStatePack01', 'gw-product-secret', false, NULL, NULL, NULL,
     'Pack pressure test gateway product', 0, 2, 0, 'mqtt', 'json',
     'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0),
    (1102, 'Sub Device Test Product', 'subPkStatePack01', 'sub-product-secret', false, NULL, NULL, NULL,
     'Pack pressure test sub-device product', 0, 1, 0, 'mqtt', 'json',
     'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    product_key = EXCLUDED.product_key,
    product_secret = EXCLUDED.product_secret,
    register_enabled = EXCLUDED.register_enabled,
    category_id = EXCLUDED.category_id,
    icon = EXCLUDED.icon,
    pic_url = EXCLUDED.pic_url,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    device_type = EXCLUDED.device_type,
    net_type = EXCLUDED.net_type,
    protocol_type = EXCLUDED.protocol_type,
    serialize_type = EXCLUDED.serialize_type,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_device (
    id, device_name, nickname, serial_number, pic_url, group_ids, product_id, product_key,
    device_type, gateway_id, state, online_time, offline_time, active_time, firmware_id,
    device_secret, latitude, longitude, config, creator, create_time, updater, update_time, deleted
) VALUES
    (2101, 'gw-001', 'gw-001', NULL, NULL, NULL, 1101, 'gwPkStatePack01',
     2, NULL, 2, NULL, NULL, TIMESTAMP '2026-02-10 17:00:00', NULL,
     'gw-secret-001', NULL, NULL, NULL, 'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0)
ON CONFLICT (id) DO UPDATE SET
    device_name = EXCLUDED.device_name,
    nickname = EXCLUDED.nickname,
    serial_number = EXCLUDED.serial_number,
    pic_url = EXCLUDED.pic_url,
    group_ids = EXCLUDED.group_ids,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    device_type = EXCLUDED.device_type,
    gateway_id = EXCLUDED.gateway_id,
    state = EXCLUDED.state,
    online_time = EXCLUDED.online_time,
    offline_time = EXCLUDED.offline_time,
    active_time = EXCLUDED.active_time,
    firmware_id = EXCLUDED.firmware_id,
    device_secret = EXCLUDED.device_secret,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    config = EXCLUDED.config,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_device (
    id, device_name, nickname, serial_number, pic_url, group_ids, product_id, product_key,
    device_type, gateway_id, state, online_time, offline_time, active_time, firmware_id,
    device_secret, latitude, longitude, config, creator, create_time, updater, update_time, deleted
)
SELECT
    2101 + n,
    'sub-' || lpad(n::text, 3, '0'),
    'sub-' || lpad(n::text, 3, '0'),
    NULL,
    NULL,
    NULL,
    1102,
    'subPkStatePack01',
    1,
    2101,
    2,
    NULL,
    NULL,
    TIMESTAMP '2026-02-10 17:00:00' + make_interval(secs => n),
    NULL,
    'sub-secret-' || lpad(n::text, 3, '0'),
    NULL,
    NULL,
    NULL,
    'codex',
    CURRENT_TIMESTAMP,
    'codex',
    CURRENT_TIMESTAMP,
    0
FROM generate_series(1, 200) AS gs(n)
ON CONFLICT (id) DO UPDATE SET
    device_name = EXCLUDED.device_name,
    nickname = EXCLUDED.nickname,
    serial_number = EXCLUDED.serial_number,
    pic_url = EXCLUDED.pic_url,
    group_ids = EXCLUDED.group_ids,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    device_type = EXCLUDED.device_type,
    gateway_id = EXCLUDED.gateway_id,
    state = EXCLUDED.state,
    online_time = EXCLUDED.online_time,
    offline_time = EXCLUDED.offline_time,
    active_time = EXCLUDED.active_time,
    firmware_id = EXCLUDED.firmware_id,
    device_secret = EXCLUDED.device_secret,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    config = EXCLUDED.config,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, create_time, updater, update_time, deleted
) VALUES
    (3101, 'temperature', 'Temperature', 'Gateway temperature property for pack pressure tests',
     1101, 'gwPkStatePack01', 1,
     '{"identifier":"temperature","name":"Temperature","accessMode":"rw","required":true,"dataType":"double","dataSpecs":{"dataType":"double","max":"100","min":"-50","step":"0.1","defaultValue":"0","unit":"C","unitName":"Celsius"}}',
     NULL, NULL, 'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0),
    (3102, 'alarm', 'Alarm', 'Gateway alarm event for pack pressure tests',
     1101, 'gwPkStatePack01', 3,
     NULL,
     '{"identifier":"alarm","name":"Alarm","type":"info","outputData":[{"identifier":"level","name":"Level","dataType":"text","dataSpecs":{"dataType":"text","length":64}},{"identifier":"message","name":"Message","dataType":"text","dataSpecs":{"dataType":"text","length":128}}]}',
     NULL, 'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0),
    (3103, 'power', 'Power', 'Sub-device power property for pack pressure tests',
     1102, 'subPkStatePack01', 1,
     '{"identifier":"power","name":"Power","accessMode":"rw","required":true,"dataType":"int","dataSpecs":{"dataType":"int","max":"100000","min":"0","step":"1","defaultValue":"0","unit":"W","unitName":"Watt"}}',
     NULL, NULL, 'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0),
    (3104, 'alarm', 'Alarm', 'Sub-device alarm event for pack pressure tests',
     1102, 'subPkStatePack01', 3,
     NULL,
     '{"identifier":"alarm","name":"Alarm","type":"info","outputData":[{"identifier":"level","name":"Level","dataType":"text","dataSpecs":{"dataType":"text","length":64}},{"identifier":"message","name":"Message","dataType":"text","dataSpecs":{"dataType":"text","length":128}}]}',
     NULL, 'codex', CURRENT_TIMESTAMP, 'codex', CURRENT_TIMESTAMP, 0)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    service = EXCLUDED.service,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, create_time, updater, update_time, deleted
)
SELECT
    3110 + n,
    'gw_metric_' || lpad(n::text, 3, '0'),
    'Gateway Metric ' || lpad(n::text, 3, '0'),
    'Gateway property for pack pressure tests',
    1101,
    'gwPkStatePack01',
    1,
    jsonb_build_object(
        'identifier', 'gw_metric_' || lpad(n::text, 3, '0'),
        'name', 'Gateway Metric ' || lpad(n::text, 3, '0'),
        'accessMode', 'rw',
        'required', true,
        'dataType', 'int',
        'dataSpecs', jsonb_build_object(
            'dataType', 'int',
            'max', '100000',
            'min', '0',
            'step', '1',
            'defaultValue', '0',
            'unit', 'cnt',
            'unitName', 'Count'
        )
    )::text,
    NULL,
    NULL,
    'codex',
    CURRENT_TIMESTAMP,
    'codex',
    CURRENT_TIMESTAMP,
    0
FROM generate_series(1, 15) AS gs(n)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    service = EXCLUDED.service,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, create_time, updater, update_time, deleted
)
SELECT
    3130 + n,
    'gw_alarm_' || lpad(n::text, 3, '0'),
    'Gateway Alarm ' || lpad(n::text, 3, '0'),
    'Gateway event for pack pressure tests',
    1101,
    'gwPkStatePack01',
    3,
    NULL,
    jsonb_build_object(
        'identifier', 'gw_alarm_' || lpad(n::text, 3, '0'),
        'name', 'Gateway Alarm ' || lpad(n::text, 3, '0'),
        'type', 'info',
        'outputData', jsonb_build_array(
            jsonb_build_object(
                'identifier', 'level',
                'name', 'Level',
                'dataType', 'text',
                'dataSpecs', jsonb_build_object('dataType', 'text', 'length', 64)
            ),
            jsonb_build_object(
                'identifier', 'message',
                'name', 'Message',
                'dataType', 'text',
                'dataSpecs', jsonb_build_object('dataType', 'text', 'length', 128)
            )
        )
    )::text,
    NULL,
    'codex',
    CURRENT_TIMESTAMP,
    'codex',
    CURRENT_TIMESTAMP,
    0
FROM generate_series(1, 7) AS gs(n)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    service = EXCLUDED.service,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, create_time, updater, update_time, deleted
)
SELECT
    3200 + n,
    'sub_metric_' || lpad(n::text, 3, '0'),
    'Sub Metric ' || lpad(n::text, 3, '0'),
    'Sub-device property for pack pressure tests',
    1102,
    'subPkStatePack01',
    1,
    jsonb_build_object(
        'identifier', 'sub_metric_' || lpad(n::text, 3, '0'),
        'name', 'Sub Metric ' || lpad(n::text, 3, '0'),
        'accessMode', 'rw',
        'required', true,
        'dataType', CASE WHEN n % 8 = 0 THEN 'double' ELSE 'int' END,
        'dataSpecs', CASE
            WHEN n % 8 = 0 THEN jsonb_build_object(
                'dataType', 'double',
                'max', '99999.9',
                'min', '0',
                'step', '0.1',
                'defaultValue', '0',
                'unit', 'kW',
                'unitName', 'Kilowatt'
            )
            ELSE jsonb_build_object(
                'dataType', 'int',
                'max', '100000',
                'min', '0',
                'step', '1',
                'defaultValue', '0',
                'unit', 'W',
                'unitName', 'Watt'
            )
        END
    )::text,
    NULL,
    NULL,
    'codex',
    CURRENT_TIMESTAMP,
    'codex',
    CURRENT_TIMESTAMP,
    0
FROM generate_series(1, 127) AS gs(n)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    service = EXCLUDED.service,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, create_time, updater, update_time, deleted
)
SELECT
    3400 + n,
    'sub_alarm_' || lpad(n::text, 3, '0'),
    'Sub Alarm ' || lpad(n::text, 3, '0'),
    'Sub-device event for pack pressure tests',
    1102,
    'subPkStatePack01',
    3,
    NULL,
    jsonb_build_object(
        'identifier', 'sub_alarm_' || lpad(n::text, 3, '0'),
        'name', 'Sub Alarm ' || lpad(n::text, 3, '0'),
        'type', 'info',
        'outputData', jsonb_build_array(
            jsonb_build_object(
                'identifier', 'level',
                'name', 'Level',
                'dataType', 'text',
                'dataSpecs', jsonb_build_object('dataType', 'text', 'length', 64)
            ),
            jsonb_build_object(
                'identifier', 'message',
                'name', 'Message',
                'dataType', 'text',
                'dataSpecs', jsonb_build_object('dataType', 'text', 'length', 128)
            )
        )
    )::text,
    NULL,
    'codex',
    CURRENT_TIMESTAMP,
    'codex',
    CURRENT_TIMESTAMP,
    0
FROM generate_series(1, 31) AS gs(n)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    service = EXCLUDED.service,
    creator = EXCLUDED.creator,
    create_time = EXCLUDED.create_time,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;
"""


def extract_insert(text: str, table: str) -> tuple[list[str], str]:
    pattern = re.compile(
        rf"INSERT INTO `{table}` \((.*?)\) VALUES (.*?);",
        re.S,
    )
    match = pattern.search(text)
    if not match:
        raise RuntimeError(f"insert not found for {table}")
    columns = [c.strip().strip("`") for c in match.group(1).split(",")]
    return columns, match.group(2).strip()


def split_tuples(values_sql: str) -> list[str]:
    tuples: list[str] = []
    depth = 0
    in_quote = False
    escaped = False
    start = None
    for i, ch in enumerate(values_sql):
        if in_quote:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == "'":
                in_quote = False
            continue
        if ch == "'":
            in_quote = True
        elif ch == "(":
            if depth == 0:
                start = i + 1
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0 and start is not None:
                tuples.append(values_sql[start:i])
                start = None
    return tuples


def split_fields(tuple_sql: str) -> list[str]:
    fields: list[str] = []
    in_quote = False
    escaped = False
    start = 0
    for i, ch in enumerate(tuple_sql):
        if in_quote:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == "'":
                in_quote = False
            continue
        if ch == "'":
            in_quote = True
        elif ch == ",":
            fields.append(tuple_sql[start:i].strip())
            start = i + 1
    fields.append(tuple_sql[start:].strip())
    return fields


def parse_string(token: str) -> str:
    assert token.startswith("'") and token.endswith("'")
    body = token[1:-1]
    out: list[str] = []
    escaped = False
    for ch in body:
        if escaped:
            out.append(ch)
            escaped = False
        elif ch == "\\":
            escaped = True
        else:
            out.append(ch)
    return "".join(out)


def parse_value(token: str):
    token = token.strip()
    upper = token.upper()
    if upper == "NULL":
        return None
    if token.startswith("b'") and token.endswith("'"):
        return 1 if token == "b'1'" else 0
    if token.startswith("'") and token.endswith("'"):
        return parse_string(token)
    if re.fullmatch(r"-?\d+", token):
        return int(token)
    if re.fullmatch(r"-?\d+\.\d+", token):
        return token
    return token


def sql_literal(value) -> str:
    if value is None:
        return "NULL"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, int):
        return str(value)
    if isinstance(value, str):
        if value == "CURRENT_TIMESTAMP":
            return value
        escaped = value.replace("'", "''")
        return f"'{escaped}'"
    return str(value)


def normalize_row(table: str, source_columns: list[str], row_values: list[str]) -> dict[str, object]:
    source = {col: parse_value(val) for col, val in zip(source_columns, row_values)}
    result: dict[str, object] = {}
    for col in PG_COLUMNS[table]:
        value = source.get(col)
        if col == "register_enabled" and value is not None:
            value = bool(int(value))
        if col == "deleted" and value is not None:
            value = int(value)
        if value is None and col in DEFAULTS.get(table, {}):
            value = DEFAULTS[table][col]
        result[col] = value
    return result


def build_insert_sql(table: str, rows: list[dict[str, object]]) -> str:
    cols = PG_COLUMNS[table]
    head = ", ".join(cols)
    values = []
    for row in rows:
        values.append(
            "(" + ", ".join(sql_literal(row[col]) for col in cols) + ")"
        )
    update_cols = [c for c in cols if c != "id"]
    update_lines = []
    for col in update_cols:
        if col == "update_time":
            update_lines.append(f"    {col} = CURRENT_TIMESTAMP")
        elif col == "deleted":
            update_lines.append(f"    {col} = 0")
        else:
            update_lines.append(f"    {col} = EXCLUDED.{col}")
    return (
        f"INSERT INTO public.{table} (\n    {head}\n) VALUES\n    "
        + ",\n    ".join(values)
        + "\nON CONFLICT (id) DO UPDATE SET\n"
        + ",\n".join(update_lines)
        + ";\n"
    )


def build_script(parsed: dict[str, list[dict[str, object]]]) -> str:
    max_ids = {table: max(int(r["id"]) for r in rows) for table, rows in parsed.items()}
    max_ids["iot_product"] = max(max_ids["iot_product"], 1102)
    max_ids["iot_device"] = max(max_ids["iot_device"], 2301)
    max_ids["iot_thing_model"] = max(max_ids["iot_thing_model"], 3431)
    parts = [
        "-- PostgreSQL IoT seed converted from iot-2026-02-10-传播违法1.sql",
        "-- Includes all source product/device/thing_model rows plus an expanded pack-pressure-test dataset.",
        "-- Safe to run multiple times.",
        "",
        "BEGIN;",
        "",
        "DO $$",
        "DECLARE",
        "    missing_tables text;",
        "BEGIN",
        "    SELECT string_agg(required_table, ', ')",
        "    INTO missing_tables",
        "    FROM (",
        "        SELECT unnest(ARRAY['iot_product', 'iot_device', 'iot_thing_model']) AS required_table",
        "        EXCEPT",
        "        SELECT tablename FROM pg_tables WHERE schemaname = 'public'",
        "    ) t;",
        "",
        "    IF missing_tables IS NOT NULL THEN",
        "        RAISE EXCEPTION 'Missing required PostgreSQL IoT tables: %', missing_tables;",
        "    END IF;",
        "END $$;",
        "",
    ]
    for table in TABLES:
        parts.append(build_insert_sql(table, parsed[table]))
    parts.append(PACK_SQL.strip())
    for table, seq in SEQUENCES.items():
        parts.append(
            f"SELECT setval('public.{seq}', "
            f"GREATEST((SELECT COALESCE(MAX(id), 0) FROM public.{table}), {max_ids[table]}), true);"
        )
    parts.extend(["", "COMMIT;", ""])
    return "\n".join(parts)


def main() -> None:
    text = SOURCE.read_text(encoding="utf-8")
    parsed: dict[str, list[dict[str, object]]] = {}
    for table in TABLES:
        columns, values_sql = extract_insert(text, table)
        rows = []
        for tuple_sql in split_tuples(values_sql):
            fields = split_fields(tuple_sql)
            rows.append(normalize_row(table, columns, fields))
        parsed[table] = rows
        print(f"{table}: {len(rows)} rows")
    TARGET.write_text(build_script(parsed), encoding="utf-8")
    print(f"wrote {TARGET}")


if __name__ == "__main__":
    main()
