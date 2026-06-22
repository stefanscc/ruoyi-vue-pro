CREATE SEQUENCE IF NOT EXISTS public.iot_product_seq START WITH 1001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.iot_device_seq START WITH 2001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.iot_thing_model_seq START WITH 3001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.iot_data_bridge_seq START WITH 4001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.iot_data_rule_seq START WITH 5001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE IF NOT EXISTS public.iot_scene_rule_seq START WITH 6001 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

CREATE TABLE IF NOT EXISTS public.iot_product (
    id bigint NOT NULL,
    name varchar(255) NOT NULL DEFAULT '',
    product_key varchar(100) NOT NULL DEFAULT '',
    product_secret varchar(100) DEFAULT NULL,
    register_enabled boolean DEFAULT false,
    category_id bigint DEFAULT NULL,
    icon varchar(255) DEFAULT NULL,
    pic_url varchar(500) DEFAULT NULL,
    description varchar(500) DEFAULT NULL,
    status smallint NOT NULL DEFAULT 0,
    device_type smallint NOT NULL DEFAULT 0,
    net_type smallint NOT NULL DEFAULT 0,
    protocol_type varchar(32) NOT NULL DEFAULT 'mqtt',
    serialize_type varchar(32) NOT NULL DEFAULT 'json',
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_product_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_device (
    id bigint NOT NULL,
    device_name varchar(255) NOT NULL DEFAULT '',
    nickname varchar(255) DEFAULT NULL,
    serial_number varchar(100) DEFAULT NULL,
    pic_url varchar(500) DEFAULT NULL,
    group_ids varchar(255) DEFAULT NULL,
    product_id bigint NOT NULL,
    product_key varchar(100) NOT NULL DEFAULT '',
    device_type smallint NOT NULL DEFAULT 0,
    gateway_id bigint DEFAULT NULL,
    state smallint NOT NULL DEFAULT 0,
    online_time timestamp without time zone DEFAULT NULL,
    offline_time timestamp without time zone DEFAULT NULL,
    active_time timestamp without time zone DEFAULT NULL,
    firmware_id bigint DEFAULT NULL,
    device_secret varchar(100) NOT NULL DEFAULT '',
    latitude numeric(10, 6) DEFAULT NULL,
    longitude numeric(10, 6) DEFAULT NULL,
    config text DEFAULT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_device_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_thing_model (
    id bigint NOT NULL,
    identifier varchar(100) NOT NULL DEFAULT '',
    name varchar(255) NOT NULL DEFAULT '',
    description varchar(500) DEFAULT NULL,
    product_id bigint NOT NULL,
    product_key varchar(100) NOT NULL DEFAULT '',
    type smallint NOT NULL,
    property text DEFAULT NULL,
    event text DEFAULT NULL,
    service text DEFAULT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_thing_model_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_data_sink (
    id bigint NOT NULL,
    name varchar(255) NOT NULL DEFAULT '',
    description varchar(500) DEFAULT NULL,
    status smallint NOT NULL DEFAULT 0,
    type integer NOT NULL,
    config text NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_data_sink_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_data_rule (
    id bigint NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(256) DEFAULT '',
    status integer NOT NULL,
    source_configs text NOT NULL,
    sink_ids varchar(512) NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_data_rule_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_scene_rule (
    id bigint NOT NULL,
    name varchar(255) NOT NULL DEFAULT '',
    description varchar(500) DEFAULT NULL,
    status integer NOT NULL DEFAULT 0,
    last_trigger_time timestamp without time zone DEFAULT NULL,
    triggers text DEFAULT NULL,
    actions text DEFAULT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_scene_rule_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS public.iot_test_event_log (
    id varchar(64) NOT NULL,
    device_id bigint NOT NULL,
    method varchar(100) NOT NULL,
    report_time timestamp without time zone DEFAULT NULL,
    data text DEFAULT NULL,
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT iot_test_event_log_pkey PRIMARY KEY (id)
);

CREATE INDEX IF NOT EXISTS idx_iot_product_product_key ON public.iot_product (product_key);
CREATE INDEX IF NOT EXISTS idx_iot_device_product_key_name ON public.iot_device (product_key, device_name);
CREATE INDEX IF NOT EXISTS idx_iot_thing_model_product_id ON public.iot_thing_model (product_id);
CREATE INDEX IF NOT EXISTS idx_iot_data_rule_status ON public.iot_data_rule (status);

INSERT INTO public.iot_product (
    id, name, product_key, product_secret, register_enabled, category_id, icon, pic_url,
    description, status, device_type, net_type, protocol_type, serialize_type,
    creator, updater, deleted
) VALUES (
    1001, 'MQTT Smoke Product', '4aymZgOTOOCrDKRT', 'unused-product-secret', false, NULL, NULL, NULL,
    'Local MQTT smoke test product', 0, 0, 0, 'mqtt', 'json',
    'codex', 'codex', 0
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    product_key = EXCLUDED.product_key,
    product_secret = EXCLUDED.product_secret,
    register_enabled = EXCLUDED.register_enabled,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    device_type = EXCLUDED.device_type,
    net_type = EXCLUDED.net_type,
    protocol_type = EXCLUDED.protocol_type,
    serialize_type = EXCLUDED.serialize_type,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_device (
    id, device_name, nickname, serial_number, pic_url, group_ids, product_id, product_key,
    device_type, gateway_id, state, online_time, offline_time, active_time, firmware_id,
    device_secret, latitude, longitude, config, creator, updater, deleted
) VALUES (
    2001, 'small', 'small', 'SN-small', NULL, NULL, 1001, '4aymZgOTOOCrDKRT',
    0, NULL, 0, NULL, NULL, NULL, NULL,
    '0baa4c2ecc104ae1a26b4070c218bdf3', NULL, NULL, NULL, 'codex', 'codex', 0
)
ON CONFLICT (id) DO UPDATE SET
    device_name = EXCLUDED.device_name,
    nickname = EXCLUDED.nickname,
    serial_number = EXCLUDED.serial_number,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    device_type = EXCLUDED.device_type,
    state = EXCLUDED.state,
    device_secret = EXCLUDED.device_secret,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_thing_model (
    id, identifier, name, description, product_id, product_key, type, property, event, service,
    creator, updater, deleted
) VALUES
(
    3001, 'temperature', 'Temperature', 'Smoke test temperature property', 1001, '4aymZgOTOOCrDKRT', 1,
    '{"identifier":"temperature","name":"Temperature","accessMode":"rw","required":true,"dataType":"double","dataSpecs":{"dataType":"double","max":"100","min":"-50","step":"0.1","defaultValue":"0","unit":"C","unitName":"Celsius"}}',
    NULL, NULL, 'codex', 'codex', 0
),
(
    3002, 'alarm', 'Alarm', 'Smoke test alarm event', 1001, '4aymZgOTOOCrDKRT', 3,
    NULL,
    '{"identifier":"alarm","name":"Alarm","type":"info","outputData":[{"identifier":"level","name":"Level","dataType":"text","dataSpecs":{"dataType":"text","length":64}}]}',
    NULL, 'codex', 'codex', 0
)
ON CONFLICT (id) DO UPDATE SET
    identifier = EXCLUDED.identifier,
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    product_id = EXCLUDED.product_id,
    product_key = EXCLUDED.product_key,
    type = EXCLUDED.type,
    property = EXCLUDED.property,
    event = EXCLUDED.event,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_data_sink (
    id, name, description, status, type, config, creator, updater, deleted
) VALUES (
    4001, 'Local Event Sink', 'Write event messages into PostgreSQL', 0, 20,
    '{"type":"20","jdbcUrl":"jdbc:postgresql://127.0.0.1:5432/ruoyi_vue_pro","username":"iot","password":"iot123456","tableName":"iot_test_event_log"}',
    'codex', 'codex', 0
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    type = EXCLUDED.type,
    config = EXCLUDED.config,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;

INSERT INTO public.iot_data_rule (
    id, name, description, status, source_configs, sink_ids, creator, updater, deleted
) VALUES (
    5001, 'Local Alarm Event Rule', 'Route alarm events to PostgreSQL table', 0,
    '[{"method":"thing.event.post","productId":1001,"deviceId":2001,"identifier":"alarm"}]',
    '4001',
    'codex', 'codex', 0
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    status = EXCLUDED.status,
    source_configs = EXCLUDED.source_configs,
    sink_ids = EXCLUDED.sink_ids,
    updater = EXCLUDED.updater,
    update_time = CURRENT_TIMESTAMP,
    deleted = 0;
