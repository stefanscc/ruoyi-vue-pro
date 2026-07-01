-- PostgreSQL script converted from iot-2026-02-10-传播违法1.sql
-- Includes table structure, comments, sequences, constraints, indexes and seed data.

BEGIN;

CREATE OR REPLACE FUNCTION public.tg_set_update_time()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

DROP TABLE IF EXISTS public.iot_alert_config CASCADE;
DROP SEQUENCE IF EXISTS public.iot_alert_config_seq CASCADE;
DROP TABLE IF EXISTS public.iot_alert_record CASCADE;
DROP SEQUENCE IF EXISTS public.iot_alert_record_seq CASCADE;
DROP TABLE IF EXISTS public.iot_data_rule CASCADE;
DROP SEQUENCE IF EXISTS public.iot_data_rule_seq CASCADE;
DROP TABLE IF EXISTS public.iot_data_sink CASCADE;
DROP SEQUENCE IF EXISTS public.iot_data_bridge_seq CASCADE;
DROP TABLE IF EXISTS public.iot_device CASCADE;
DROP SEQUENCE IF EXISTS public.iot_device_seq CASCADE;
DROP TABLE IF EXISTS public.iot_device_group CASCADE;
DROP SEQUENCE IF EXISTS public.iot_device_group_seq CASCADE;
DROP TABLE IF EXISTS public.iot_device_modbus_config CASCADE;
DROP SEQUENCE IF EXISTS public.iot_device_modbus_config_seq CASCADE;
DROP TABLE IF EXISTS public.iot_device_modbus_point CASCADE;
DROP SEQUENCE IF EXISTS public.iot_device_modbus_point_seq CASCADE;
DROP TABLE IF EXISTS public.iot_ota_firmware CASCADE;
DROP SEQUENCE IF EXISTS public.iot_ota_firmware_seq CASCADE;
DROP TABLE IF EXISTS public.iot_ota_task CASCADE;
DROP SEQUENCE IF EXISTS public.iot_ota_task_seq CASCADE;
DROP TABLE IF EXISTS public.iot_ota_task_record CASCADE;
DROP SEQUENCE IF EXISTS public.iot_ota_task_record_seq CASCADE;
DROP TABLE IF EXISTS public.iot_product CASCADE;
DROP SEQUENCE IF EXISTS public.iot_product_seq CASCADE;
DROP TABLE IF EXISTS public.iot_product_category CASCADE;
DROP SEQUENCE IF EXISTS public.iot_product_category_seq CASCADE;
DROP TABLE IF EXISTS public.iot_rule_scene CASCADE;
DROP SEQUENCE IF EXISTS public.iot_rule_scene_seq CASCADE;
DROP TABLE IF EXISTS public.iot_scene_rule CASCADE;
DROP SEQUENCE IF EXISTS public.iot_scene_rule_seq CASCADE;
DROP TABLE IF EXISTS public.iot_thing_model CASCADE;
DROP SEQUENCE IF EXISTS public.iot_thing_model_seq CASCADE;

CREATE SEQUENCE public.iot_alert_config_seq START WITH 3 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_alert_record_seq START WITH 6 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_data_rule_seq START WITH 7 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_data_bridge_seq START WITH 14 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_device_seq START WITH 83 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_device_group_seq START WITH 18 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_device_modbus_config_seq START WITH 5 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_device_modbus_point_seq START WITH 9 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_ota_firmware_seq START WITH 3 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_ota_task_seq START WITH 7 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_ota_task_record_seq START WITH 20 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_product_seq START WITH 24 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_product_category_seq START WITH 16 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_rule_scene_seq START WITH 4 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_scene_rule_seq START WITH 6 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;
CREATE SEQUENCE public.iot_thing_model_seq START WITH 125 INCREMENT BY 1 NO MINVALUE NO MAXVALUE CACHE 1;

CREATE TABLE public.iot_alert_config (
    id bigint DEFAULT nextval('public.iot_alert_config_seq'::regclass) NOT NULL,
    name varchar(100) NOT NULL,
    description varchar(512),
    level smallint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    scene_rule_ids varchar(1000),
    receive_user_ids varchar(1000),
    receive_types varchar(500),
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_alert_config_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_alert_config_seq OWNED BY public.iot_alert_config.id;
CREATE TRIGGER trg_iot_alert_config_update_time BEFORE UPDATE ON public.iot_alert_config FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_alert_config IS 'IoT 告警配置表';
COMMENT ON COLUMN public.iot_alert_config.id IS '配置编号';
COMMENT ON COLUMN public.iot_alert_config.name IS '配置名称';
COMMENT ON COLUMN public.iot_alert_config.description IS '配置描述';
COMMENT ON COLUMN public.iot_alert_config.level IS '告警级别';
COMMENT ON COLUMN public.iot_alert_config.status IS '配置状态';
COMMENT ON COLUMN public.iot_alert_config.scene_rule_ids IS '关联的场景联动规则编号数组';
COMMENT ON COLUMN public.iot_alert_config.receive_user_ids IS '接收的用户编号数组';
COMMENT ON COLUMN public.iot_alert_config.receive_types IS '接收的类型数组';
COMMENT ON COLUMN public.iot_alert_config.creator IS '创建者';
COMMENT ON COLUMN public.iot_alert_config.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_alert_config.updater IS '更新者';
COMMENT ON COLUMN public.iot_alert_config.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_alert_config.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_alert_config.tenant_id IS '租户编号';

CREATE TABLE public.iot_alert_record (
    id bigint DEFAULT nextval('public.iot_alert_record_seq'::regclass) NOT NULL,
    config_id bigint NOT NULL,
    config_name varchar(128) NOT NULL,
    config_level smallint NOT NULL,
    scene_rule_id bigint NOT NULL,
    product_id bigint,
    device_id bigint,
    device_message varchar(2048),
    process_status smallint DEFAULT 0 NOT NULL,
    process_remark varchar(512) DEFAULT '',
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_alert_record_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_alert_record_seq OWNED BY public.iot_alert_record.id;
CREATE TRIGGER trg_iot_alert_record_update_time BEFORE UPDATE ON public.iot_alert_record FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_alert_record IS 'IoT 告警记录表';
COMMENT ON COLUMN public.iot_alert_record.id IS '记录编号';
COMMENT ON COLUMN public.iot_alert_record.config_id IS '告警配置编号';
COMMENT ON COLUMN public.iot_alert_record.config_name IS '告警名称';
COMMENT ON COLUMN public.iot_alert_record.config_level IS '告警级别';
COMMENT ON COLUMN public.iot_alert_record.scene_rule_id IS '场景联动规则编号';
COMMENT ON COLUMN public.iot_alert_record.product_id IS '产品编号';
COMMENT ON COLUMN public.iot_alert_record.device_id IS '设备编号';
COMMENT ON COLUMN public.iot_alert_record.device_message IS '触发的设备消息';
COMMENT ON COLUMN public.iot_alert_record.process_status IS '是否处理';
COMMENT ON COLUMN public.iot_alert_record.process_remark IS '处理结果（备注）';
COMMENT ON COLUMN public.iot_alert_record.creator IS '创建者';
COMMENT ON COLUMN public.iot_alert_record.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_alert_record.updater IS '更新者';
COMMENT ON COLUMN public.iot_alert_record.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_alert_record.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_alert_record.tenant_id IS '租户编号';

CREATE TABLE public.iot_data_rule (
    id bigint DEFAULT nextval('public.iot_data_rule_seq'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(256) DEFAULT '',
    status integer NOT NULL,
    source_configs varchar(10000) NOT NULL,
    sink_ids varchar(512) NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_data_rule_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_data_rule_seq OWNED BY public.iot_data_rule.id;
CREATE TRIGGER trg_iot_data_rule_update_time BEFORE UPDATE ON public.iot_data_rule FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_data_rule IS 'IoT 数据流转规则表';
COMMENT ON COLUMN public.iot_data_rule.id IS '数据流转规格编号';
COMMENT ON COLUMN public.iot_data_rule.name IS '数据流转规格名称';
COMMENT ON COLUMN public.iot_data_rule.description IS '数据流转规格描述';
COMMENT ON COLUMN public.iot_data_rule.status IS '数据流转规格状态';
COMMENT ON COLUMN public.iot_data_rule.source_configs IS '数据源配置数组';
COMMENT ON COLUMN public.iot_data_rule.sink_ids IS '数据目的编号数组';
COMMENT ON COLUMN public.iot_data_rule.creator IS '创建者';
COMMENT ON COLUMN public.iot_data_rule.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_data_rule.updater IS '更新者';
COMMENT ON COLUMN public.iot_data_rule.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_data_rule.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_data_rule.tenant_id IS '租户编号';

CREATE TABLE public.iot_data_sink (
    id bigint DEFAULT nextval('public.iot_data_bridge_seq'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(255) DEFAULT '',
    status integer NOT NULL,
    type integer NOT NULL,
    config text,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_data_sink_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_data_bridge_seq OWNED BY public.iot_data_sink.id;
CREATE TRIGGER trg_iot_data_sink_update_time BEFORE UPDATE ON public.iot_data_sink FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_data_sink IS 'IoT 数据流转目的';
COMMENT ON COLUMN public.iot_data_sink.id IS '数据流转目的编号';
COMMENT ON COLUMN public.iot_data_sink.name IS '数据流转目的名称';
COMMENT ON COLUMN public.iot_data_sink.description IS '桥梁描述';
COMMENT ON COLUMN public.iot_data_sink.status IS '桥梁状态';
COMMENT ON COLUMN public.iot_data_sink.type IS '桥梁类型';
COMMENT ON COLUMN public.iot_data_sink.config IS '桥梁配置';
COMMENT ON COLUMN public.iot_data_sink.creator IS '创建者';
COMMENT ON COLUMN public.iot_data_sink.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_data_sink.updater IS '更新者';
COMMENT ON COLUMN public.iot_data_sink.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_data_sink.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_data_sink.tenant_id IS '租户编号';

CREATE TABLE public.iot_device (
    id bigint DEFAULT nextval('public.iot_device_seq'::regclass) NOT NULL,
    device_name varchar(255) NOT NULL,
    nickname varchar(255),
    serial_number varchar(100),
    pic_url varchar(512),
    group_ids varchar(512),
    product_id bigint NOT NULL,
    product_key varchar(255) NOT NULL,
    device_type smallint DEFAULT 0 NOT NULL,
    gateway_id bigint,
    state smallint DEFAULT 0 NOT NULL,
    online_time timestamp without time zone,
    offline_time timestamp without time zone,
    active_time timestamp without time zone,
    firmware_id bigint,
    device_secret varchar(255),
    latitude numeric(10, 6),
    longitude numeric(10, 6),
    config varchar(1024),
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_device_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_device_seq OWNED BY public.iot_device.id;
CREATE TRIGGER trg_iot_device_update_time BEFORE UPDATE ON public.iot_device FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_device IS 'IoT 设备表';
COMMENT ON COLUMN public.iot_device.id IS '设备 ID，主键，自增';
COMMENT ON COLUMN public.iot_device.device_name IS '设备名称，在产品内唯一，用于标识设备';
COMMENT ON COLUMN public.iot_device.nickname IS '设备备注名称，供用户自定义备注';
COMMENT ON COLUMN public.iot_device.serial_number IS '设备序列号';
COMMENT ON COLUMN public.iot_device.pic_url IS '设备图片';
COMMENT ON COLUMN public.iot_device.group_ids IS '设备分组编号集合';
COMMENT ON COLUMN public.iot_device.product_id IS '产品 ID';
COMMENT ON COLUMN public.iot_device.product_key IS '产品 Key';
COMMENT ON COLUMN public.iot_device.device_type IS '设备类型，参见 IotProductDeviceTypeEnum 枚举';
COMMENT ON COLUMN public.iot_device.gateway_id IS '网关设备 ID，子设备需要关联的网关设备 ID';
COMMENT ON COLUMN public.iot_device.state IS '设备状态，参见 IotDeviceStateEnum 枚举';
COMMENT ON COLUMN public.iot_device.online_time IS '最后上线时间';
COMMENT ON COLUMN public.iot_device.offline_time IS '最后离线时间';
COMMENT ON COLUMN public.iot_device.active_time IS '设备激活时间';
COMMENT ON COLUMN public.iot_device.firmware_id IS 'OTA 固件编号';
COMMENT ON COLUMN public.iot_device.device_secret IS '设备密钥，用于设备认证，需安全存储';
COMMENT ON COLUMN public.iot_device.latitude IS '设备位置的纬度';
COMMENT ON COLUMN public.iot_device.longitude IS '设备位置的经度';
COMMENT ON COLUMN public.iot_device.config IS '设备配置，JSON 格式';
COMMENT ON COLUMN public.iot_device.creator IS '创建者';
COMMENT ON COLUMN public.iot_device.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_device.updater IS '更新者';
COMMENT ON COLUMN public.iot_device.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_device.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_device.tenant_id IS '租户编号';
CREATE UNIQUE INDEX uniq_device_name_product_id ON public.iot_device (device_name, product_id);
CREATE INDEX iot_device_idx_product_id ON public.iot_device (product_id);
CREATE INDEX idx_gateway_id ON public.iot_device (gateway_id);

CREATE TABLE public.iot_device_group (
    id bigint DEFAULT nextval('public.iot_device_group_seq'::regclass) NOT NULL,
    name varchar(100) NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    description varchar(1000),
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_device_group_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_device_group_seq OWNED BY public.iot_device_group.id;
CREATE TRIGGER trg_iot_device_group_update_time BEFORE UPDATE ON public.iot_device_group FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_device_group IS 'IoT 设备分组表';
COMMENT ON COLUMN public.iot_device_group.id IS '分组 ID';
COMMENT ON COLUMN public.iot_device_group.name IS '分组名字';
COMMENT ON COLUMN public.iot_device_group.status IS '分组状态';
COMMENT ON COLUMN public.iot_device_group.description IS '分组描述';
COMMENT ON COLUMN public.iot_device_group.creator IS '创建者';
COMMENT ON COLUMN public.iot_device_group.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_device_group.updater IS '更新者';
COMMENT ON COLUMN public.iot_device_group.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_device_group.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_device_group.tenant_id IS '租户编号';

CREATE TABLE public.iot_device_modbus_config (
    id bigint DEFAULT nextval('public.iot_device_modbus_config_seq'::regclass) NOT NULL,
    device_id bigint NOT NULL,
    product_id bigint,
    ip varchar(50) DEFAULT '' NOT NULL,
    port integer DEFAULT 502 NOT NULL,
    slave_id integer DEFAULT 1 NOT NULL,
    timeout integer DEFAULT 3000 NOT NULL,
    retry_interval integer DEFAULT 1000 NOT NULL,
    mode smallint DEFAULT 1 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    frame_format smallint DEFAULT 1 NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_device_modbus_config_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_device_modbus_config_seq OWNED BY public.iot_device_modbus_config.id;
CREATE TRIGGER trg_iot_device_modbus_config_update_time BEFORE UPDATE ON public.iot_device_modbus_config FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_device_modbus_config IS 'IoT 设备 Modbus 连接配置表';
COMMENT ON COLUMN public.iot_device_modbus_config.id IS '主键';
COMMENT ON COLUMN public.iot_device_modbus_config.device_id IS '设备编号';
COMMENT ON COLUMN public.iot_device_modbus_config.product_id IS '产品编号';
COMMENT ON COLUMN public.iot_device_modbus_config.ip IS 'Modbus 服务器 IP 地址';
COMMENT ON COLUMN public.iot_device_modbus_config.port IS 'Modbus 服务器端口';
COMMENT ON COLUMN public.iot_device_modbus_config.slave_id IS '从站地址';
COMMENT ON COLUMN public.iot_device_modbus_config.timeout IS '连接超时时间，单位：毫秒';
COMMENT ON COLUMN public.iot_device_modbus_config.retry_interval IS '重试间隔，单位：毫秒';
COMMENT ON COLUMN public.iot_device_modbus_config.mode IS '工作模式';
COMMENT ON COLUMN public.iot_device_modbus_config.status IS '状态';
COMMENT ON COLUMN public.iot_device_modbus_config.frame_format IS '数据帧格式';
COMMENT ON COLUMN public.iot_device_modbus_config.creator IS '创建者';
COMMENT ON COLUMN public.iot_device_modbus_config.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_device_modbus_config.updater IS '更新者';
COMMENT ON COLUMN public.iot_device_modbus_config.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_device_modbus_config.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_device_modbus_config.tenant_id IS '租户编号';
CREATE UNIQUE INDEX uk_device_id ON public.iot_device_modbus_config (device_id, deleted, tenant_id);
COMMENT ON INDEX public.uk_device_id IS '设备编号唯一索引';

CREATE TABLE public.iot_device_modbus_point (
    id bigint DEFAULT nextval('public.iot_device_modbus_point_seq'::regclass) NOT NULL,
    device_id bigint NOT NULL,
    thing_model_id bigint NOT NULL,
    identifier varchar(100) DEFAULT '' NOT NULL,
    name varchar(255) DEFAULT '' NOT NULL,
    function_code smallint DEFAULT 3 NOT NULL,
    register_address integer DEFAULT 0 NOT NULL,
    register_count integer DEFAULT 1 NOT NULL,
    byte_order varchar(10) DEFAULT 'AB' NOT NULL,
    raw_data_type varchar(20) DEFAULT 'INT16' NOT NULL,
    scale numeric(20, 6) DEFAULT 1.000000 NOT NULL,
    poll_interval integer DEFAULT 5000 NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_device_modbus_point_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_device_modbus_point_seq OWNED BY public.iot_device_modbus_point.id;
CREATE TRIGGER trg_iot_device_modbus_point_update_time BEFORE UPDATE ON public.iot_device_modbus_point FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_device_modbus_point IS 'IoT 设备 Modbus 点位配置表';
COMMENT ON COLUMN public.iot_device_modbus_point.id IS '主键';
COMMENT ON COLUMN public.iot_device_modbus_point.device_id IS '设备编号';
COMMENT ON COLUMN public.iot_device_modbus_point.thing_model_id IS '物模型属性编号';
COMMENT ON COLUMN public.iot_device_modbus_point.identifier IS '属性标识符';
COMMENT ON COLUMN public.iot_device_modbus_point.name IS '属性名称';
COMMENT ON COLUMN public.iot_device_modbus_point.function_code IS 'Modbus 功能码（1-读线圈 2-读离散输入 3-读保持寄存器 4-读输入寄存器）';
COMMENT ON COLUMN public.iot_device_modbus_point.register_address IS '寄存器起始地址';
COMMENT ON COLUMN public.iot_device_modbus_point.register_count IS '寄存器数量';
COMMENT ON COLUMN public.iot_device_modbus_point.byte_order IS '字节序（AB/BA/ABCD/CDAB/DCBA/BADC）';
COMMENT ON COLUMN public.iot_device_modbus_point.raw_data_type IS '原始数据类型（INT16/UINT16/INT32/UINT32/FLOAT/DOUBLE/BOOLEAN/STRING）';
COMMENT ON COLUMN public.iot_device_modbus_point.scale IS '缩放因子';
COMMENT ON COLUMN public.iot_device_modbus_point.poll_interval IS '轮询间隔，单位：毫秒';
COMMENT ON COLUMN public.iot_device_modbus_point.status IS '状态（0-开启 1-禁用）';
COMMENT ON COLUMN public.iot_device_modbus_point.creator IS '创建者';
COMMENT ON COLUMN public.iot_device_modbus_point.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_device_modbus_point.updater IS '更新者';
COMMENT ON COLUMN public.iot_device_modbus_point.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_device_modbus_point.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_device_modbus_point.tenant_id IS '租户编号';
CREATE UNIQUE INDEX uk_device_thing_model ON public.iot_device_modbus_point (device_id, thing_model_id, deleted, tenant_id);
COMMENT ON INDEX public.uk_device_thing_model IS '设备+物模型唯一索引';
CREATE INDEX idx_device_id ON public.iot_device_modbus_point (device_id);
COMMENT ON INDEX public.idx_device_id IS '设备编号索引';

CREATE TABLE public.iot_ota_firmware (
    id bigint DEFAULT nextval('public.iot_ota_firmware_seq'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(512) DEFAULT '',
    version varchar(64) NOT NULL,
    product_id bigint NOT NULL,
    file_url varchar(1024) NOT NULL,
    file_size bigint NOT NULL,
    file_digest_algorithm varchar(32) NOT NULL,
    file_digest_value varchar(256) NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_ota_firmware_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_ota_firmware_seq OWNED BY public.iot_ota_firmware.id;
CREATE TRIGGER trg_iot_ota_firmware_update_time BEFORE UPDATE ON public.iot_ota_firmware FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_ota_firmware IS 'IoT OTA 固件表';
COMMENT ON COLUMN public.iot_ota_firmware.id IS '固件编号';
COMMENT ON COLUMN public.iot_ota_firmware.name IS '固件名称';
COMMENT ON COLUMN public.iot_ota_firmware.description IS '固件描述';
COMMENT ON COLUMN public.iot_ota_firmware.version IS '版本号';
COMMENT ON COLUMN public.iot_ota_firmware.product_id IS '产品编号';
COMMENT ON COLUMN public.iot_ota_firmware.file_url IS '固件文件 URL';
COMMENT ON COLUMN public.iot_ota_firmware.file_size IS '固件文件大小';
COMMENT ON COLUMN public.iot_ota_firmware.file_digest_algorithm IS '固件文件签名算法';
COMMENT ON COLUMN public.iot_ota_firmware.file_digest_value IS '固件文件签名结果';
COMMENT ON COLUMN public.iot_ota_firmware.creator IS '创建者';
COMMENT ON COLUMN public.iot_ota_firmware.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_ota_firmware.updater IS '更新者';
COMMENT ON COLUMN public.iot_ota_firmware.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_ota_firmware.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_ota_firmware.tenant_id IS '租户编号';

CREATE TABLE public.iot_ota_task (
    id bigint DEFAULT nextval('public.iot_ota_task_seq'::regclass) NOT NULL,
    name varchar(255) NOT NULL,
    description varchar(1000),
    firmware_id bigint NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    device_scope smallint DEFAULT 0 NOT NULL,
    device_total_count integer DEFAULT 0 NOT NULL,
    device_success_count integer DEFAULT 0 NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_ota_task_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_ota_task_seq OWNED BY public.iot_ota_task.id;
CREATE TRIGGER trg_iot_ota_task_update_time BEFORE UPDATE ON public.iot_ota_task FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_ota_task IS 'IoT OTA 升级任务表';
COMMENT ON COLUMN public.iot_ota_task.id IS '任务编号，主键，自增';
COMMENT ON COLUMN public.iot_ota_task.name IS '任务名称';
COMMENT ON COLUMN public.iot_ota_task.description IS '任务描述';
COMMENT ON COLUMN public.iot_ota_task.firmware_id IS '固件编号';
COMMENT ON COLUMN public.iot_ota_task.status IS '任务状态，参见 IotOtaTaskStatusEnum 枚举';
COMMENT ON COLUMN public.iot_ota_task.device_scope IS '设备升级范围，参见 IotOtaTaskDeviceScopeEnum 枚举';
COMMENT ON COLUMN public.iot_ota_task.device_total_count IS '设备总数数量';
COMMENT ON COLUMN public.iot_ota_task.device_success_count IS '设备成功数量';
COMMENT ON COLUMN public.iot_ota_task.creator IS '创建者';
COMMENT ON COLUMN public.iot_ota_task.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_ota_task.updater IS '更新者';
COMMENT ON COLUMN public.iot_ota_task.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_ota_task.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_ota_task.tenant_id IS '租户编号';

CREATE TABLE public.iot_ota_task_record (
    id bigint DEFAULT nextval('public.iot_ota_task_record_seq'::regclass) NOT NULL,
    firmware_id bigint NOT NULL,
    task_id bigint NOT NULL,
    device_id bigint NOT NULL,
    from_firmware_id bigint,
    status smallint DEFAULT 0 NOT NULL,
    progress smallint DEFAULT 0 NOT NULL,
    description varchar(500),
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_ota_task_record_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_ota_task_record_seq OWNED BY public.iot_ota_task_record.id;
CREATE TRIGGER trg_iot_ota_task_record_update_time BEFORE UPDATE ON public.iot_ota_task_record FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_ota_task_record IS 'IoT OTA 升级任务记录表';
COMMENT ON COLUMN public.iot_ota_task_record.id IS '记录编号，主键，自增';
COMMENT ON COLUMN public.iot_ota_task_record.firmware_id IS '固件编号';
COMMENT ON COLUMN public.iot_ota_task_record.task_id IS '任务编号';
COMMENT ON COLUMN public.iot_ota_task_record.device_id IS '设备编号';
COMMENT ON COLUMN public.iot_ota_task_record.from_firmware_id IS '来源的固件编号';
COMMENT ON COLUMN public.iot_ota_task_record.status IS '升级状态，参见 IotOtaTaskRecordStatusEnum 枚举';
COMMENT ON COLUMN public.iot_ota_task_record.progress IS '升级进度，百分比（0-100）';
COMMENT ON COLUMN public.iot_ota_task_record.description IS '升级进度描述';
COMMENT ON COLUMN public.iot_ota_task_record.creator IS '创建者';
COMMENT ON COLUMN public.iot_ota_task_record.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_ota_task_record.updater IS '更新者';
COMMENT ON COLUMN public.iot_ota_task_record.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_ota_task_record.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_ota_task_record.tenant_id IS '租户编号';

CREATE TABLE public.iot_product (
    id bigint DEFAULT nextval('public.iot_product_seq'::regclass) NOT NULL,
    name varchar(100) NOT NULL,
    product_key varchar(64) NOT NULL,
    product_secret varchar(255),
    register_enabled smallint DEFAULT 0 NOT NULL,
    category_id bigint NOT NULL,
    icon varchar(512),
    pic_url varchar(512),
    description varchar(1000),
    status smallint DEFAULT 0 NOT NULL,
    device_type smallint NOT NULL,
    net_type smallint,
    protocol_type varchar(50) DEFAULT 'mqtt' NOT NULL,
    serialize_type varchar(50) DEFAULT 'json' NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_product_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_product_seq OWNED BY public.iot_product.id;
CREATE TRIGGER trg_iot_product_update_time BEFORE UPDATE ON public.iot_product FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_product IS 'IoT 产品表';
COMMENT ON COLUMN public.iot_product.id IS '产品 ID';
COMMENT ON COLUMN public.iot_product.name IS '产品名称';
COMMENT ON COLUMN public.iot_product.product_key IS '产品标识';
COMMENT ON COLUMN public.iot_product.product_secret IS '产品密钥，用于动态注册设备';
COMMENT ON COLUMN public.iot_product.register_enabled IS '是否开启动态注册';
COMMENT ON COLUMN public.iot_product.category_id IS '产品分类 ID';
COMMENT ON COLUMN public.iot_product.icon IS '产品图标';
COMMENT ON COLUMN public.iot_product.pic_url IS '产品图片';
COMMENT ON COLUMN public.iot_product.description IS '产品描述';
COMMENT ON COLUMN public.iot_product.status IS '产品状态，参见 IotProductStatusEnum 枚举';
COMMENT ON COLUMN public.iot_product.device_type IS '设备类型，参见 IotProductDeviceTypeEnum 枚举';
COMMENT ON COLUMN public.iot_product.net_type IS '联网方式，参见 IotNetTypeEnum 枚举';
COMMENT ON COLUMN public.iot_product.protocol_type IS '协议类型';
COMMENT ON COLUMN public.iot_product.serialize_type IS '序列化类型';
COMMENT ON COLUMN public.iot_product.creator IS '创建者';
COMMENT ON COLUMN public.iot_product.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_product.updater IS '更新者';
COMMENT ON COLUMN public.iot_product.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_product.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_product.tenant_id IS '租户编号';

CREATE TABLE public.iot_product_category (
    id bigint DEFAULT nextval('public.iot_product_category_seq'::regclass) NOT NULL,
    name varchar(100) NOT NULL,
    sort integer NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    description varchar(1000),
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_product_category_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_product_category_seq OWNED BY public.iot_product_category.id;
CREATE TRIGGER trg_iot_product_category_update_time BEFORE UPDATE ON public.iot_product_category FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_product_category IS 'IoT 产品分类表';
COMMENT ON COLUMN public.iot_product_category.id IS '分类 ID';
COMMENT ON COLUMN public.iot_product_category.name IS '分类名字';
COMMENT ON COLUMN public.iot_product_category.sort IS '分类排序';
COMMENT ON COLUMN public.iot_product_category.status IS '分类状态';
COMMENT ON COLUMN public.iot_product_category.description IS '分类描述';
COMMENT ON COLUMN public.iot_product_category.creator IS '创建者';
COMMENT ON COLUMN public.iot_product_category.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_product_category.updater IS '更新者';
COMMENT ON COLUMN public.iot_product_category.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_product_category.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_product_category.tenant_id IS '租户编号';

CREATE TABLE public.iot_rule_scene (
    id bigint DEFAULT nextval('public.iot_rule_scene_seq'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(256) DEFAULT '',
    status smallint NOT NULL,
    triggers text NOT NULL,
    actions text NOT NULL,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_rule_scene_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_rule_scene_seq OWNED BY public.iot_rule_scene.id;
CREATE TRIGGER trg_iot_rule_scene_update_time BEFORE UPDATE ON public.iot_rule_scene FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_rule_scene IS 'IoT 场景联动规则';
COMMENT ON COLUMN public.iot_rule_scene.id IS '数据流转编号';
COMMENT ON COLUMN public.iot_rule_scene.name IS '数据流转名称';
COMMENT ON COLUMN public.iot_rule_scene.description IS '数据流转描述';
COMMENT ON COLUMN public.iot_rule_scene.status IS '数据流转状态';
COMMENT ON COLUMN public.iot_rule_scene.triggers IS '触发器数组';
COMMENT ON COLUMN public.iot_rule_scene.actions IS '执行器数组';
COMMENT ON COLUMN public.iot_rule_scene.creator IS '创建者';
COMMENT ON COLUMN public.iot_rule_scene.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_rule_scene.updater IS '更新者';
COMMENT ON COLUMN public.iot_rule_scene.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_rule_scene.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_rule_scene.tenant_id IS '租户编号';

CREATE TABLE public.iot_scene_rule (
    id bigint DEFAULT nextval('public.iot_scene_rule_seq'::regclass) NOT NULL,
    name varchar(128) NOT NULL,
    description varchar(256) DEFAULT '',
    status smallint NOT NULL,
    triggers text NOT NULL,
    actions text NOT NULL,
    last_trigger_time timestamp without time zone,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_scene_rule_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_scene_rule_seq OWNED BY public.iot_scene_rule.id;
CREATE TRIGGER trg_iot_scene_rule_update_time BEFORE UPDATE ON public.iot_scene_rule FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_scene_rule IS 'IoT 场景联动规则';
COMMENT ON COLUMN public.iot_scene_rule.id IS '数据流转编号';
COMMENT ON COLUMN public.iot_scene_rule.name IS '数据流转名称';
COMMENT ON COLUMN public.iot_scene_rule.description IS '数据流转描述';
COMMENT ON COLUMN public.iot_scene_rule.status IS '数据流转状态';
COMMENT ON COLUMN public.iot_scene_rule.triggers IS '触发器数组';
COMMENT ON COLUMN public.iot_scene_rule.actions IS '执行器数组';
COMMENT ON COLUMN public.iot_scene_rule.last_trigger_time IS '最后触发时间';
COMMENT ON COLUMN public.iot_scene_rule.creator IS '创建者';
COMMENT ON COLUMN public.iot_scene_rule.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_scene_rule.updater IS '更新者';
COMMENT ON COLUMN public.iot_scene_rule.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_scene_rule.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_scene_rule.tenant_id IS '租户编号';

CREATE TABLE public.iot_thing_model (
    id bigint DEFAULT nextval('public.iot_thing_model_seq'::regclass) NOT NULL,
    identifier varchar(255) NOT NULL,
    name varchar(255) NOT NULL,
    description varchar(255),
    product_id bigint NOT NULL,
    product_key varchar(255) NOT NULL,
    type smallint NOT NULL,
    property text,
    event text,
    service text,
    creator varchar(64) DEFAULT '',
    create_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updater varchar(64) DEFAULT '',
    update_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted smallint DEFAULT 0 NOT NULL,
    tenant_id bigint DEFAULT 0 NOT NULL,
    CONSTRAINT iot_thing_model_pkey PRIMARY KEY (id)
);
ALTER SEQUENCE public.iot_thing_model_seq OWNED BY public.iot_thing_model.id;
CREATE TRIGGER trg_iot_thing_model_update_time BEFORE UPDATE ON public.iot_thing_model FOR EACH ROW EXECUTE FUNCTION public.tg_set_update_time();
COMMENT ON TABLE public.iot_thing_model IS 'IoT 产品物模型功能表';
COMMENT ON COLUMN public.iot_thing_model.id IS '物模型功能编号';
COMMENT ON COLUMN public.iot_thing_model.identifier IS '功能标识';
COMMENT ON COLUMN public.iot_thing_model.name IS '功能名称';
COMMENT ON COLUMN public.iot_thing_model.description IS '功能描述';
COMMENT ON COLUMN public.iot_thing_model.product_id IS '产品ID（关联 IotProductDO 的 id）';
COMMENT ON COLUMN public.iot_thing_model.product_key IS '产品Key（关联 IotProductDO 的 productKey）';
COMMENT ON COLUMN public.iot_thing_model.type IS '功能类型（1 - 属性，2 - 服务，3 - 事件）';
COMMENT ON COLUMN public.iot_thing_model.property IS '属性（存储 ThingModelProperty 的 JSON 数据）';
COMMENT ON COLUMN public.iot_thing_model.event IS '事件（存储 ThingModelEvent 的 JSON 数据）';
COMMENT ON COLUMN public.iot_thing_model.service IS '服务（存储服务的 JSON 数据）';
COMMENT ON COLUMN public.iot_thing_model.creator IS '创建者';
COMMENT ON COLUMN public.iot_thing_model.create_time IS '创建时间';
COMMENT ON COLUMN public.iot_thing_model.updater IS '更新者';
COMMENT ON COLUMN public.iot_thing_model.update_time IS '更新时间';
COMMENT ON COLUMN public.iot_thing_model.deleted IS '是否删除';
COMMENT ON COLUMN public.iot_thing_model.tenant_id IS '租户编号';
CREATE INDEX iot_thing_model_idx_product_id ON public.iot_thing_model (product_id);
CREATE INDEX idx_product_key ON public.iot_thing_model (product_key);

INSERT INTO public.iot_alert_config (id, name, description, level, status, scene_rule_ids, receive_user_ids, receive_types, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, '11', '2', 1, 0, '3,1', '1,100', '1,2', '1', '2025-06-27 23:37:06', '1', '2025-06-27 23:40:27', 0, 1),
    (2, '高度超标告警', NULL, 1, 0, '5', '1', '3', '1', '2026-02-13 20:35:40', '1', '2026-02-13 20:35:40', 0, 1);

INSERT INTO public.iot_alert_record (id, config_id, config_name, config_level, scene_rule_id, product_id, device_id, device_message, process_status, process_remark, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 1, '测试配置', 1, 0, 16, 25, '{"id":"dc3d96506bd346f6bc050a40b22351de","reportTime":1751097989116,"deviceId":25,"tenantId":1,"serverId":"192_168_64_1_8092","requestId":"dc3d96506bd346f6bc050a40b22351de","method":"thing.state.update","params":{"state":1},"data":null,"code":null,"msg":null}', 0, '3213211', '', '2025-06-28 08:08:17', '1', '2026-02-13 12:31:00', 0, 1),
    (2, 1, '测试配置', 1, 0, NULL, NULL, '', 1, '3213211', '', '2025-06-28 08:08:17', '1', '2025-06-28 08:35:45', 0, 1),
    (3, 2, '高度超标告警', 1, 5, 16, 25, '{"id":"30fc8edd63cb4d1bacef289f9d225815","reportTime":1770986155393,"deviceId":25,"tenantId":1,"serverId":null,"requestId":"30fc8edd63cb4d1bacef289f9d225815","method":"thing.property.post","params":{"height":"2500"},"data":null,"code":null,"msg":null}', 0, '', NULL, '2026-02-13 20:35:58', NULL, '2026-02-13 20:35:58', 0, 1),
    (4, 2, '高度超标告警', 1, 5, 16, 25, '{"id":"abcbe301cdd8408c995585997475008c","reportTime":1770993895483,"deviceId":25,"tenantId":1,"serverId":null,"requestId":"abcbe301cdd8408c995585997475008c","method":"thing.property.post","params":{"width":"1000","height":"3000"},"data":null,"code":null,"msg":null}', 0, '', NULL, '2026-02-13 22:44:56', NULL, '2026-02-13 22:44:56', 0, 1),
    (5, 2, '高度超标告警', 1, 5, 16, 25, '{"id":"abcbe301cdd8408c995585997475008c","reportTime":1770993895483,"deviceId":25,"tenantId":1,"serverId":null,"requestId":"abcbe301cdd8408c995585997475008c","method":"thing.property.post","params":{"width":"1000","height":"3000"},"data":null,"code":null,"msg":null}', 0, '', NULL, '2026-02-13 22:50:35', NULL, '2026-02-13 22:50:35', 0, 1);

INSERT INTO public.iot_data_rule (id, name, description, status, source_configs, sink_ids, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (4, '1', '2', 0, '[{"method":"thing.property.post","productId":16,"deviceId":25,"identifier":null}]', '11,12', '1', '2025-06-25 13:22:11', '1', '2025-06-26 09:44:48', 0, 1),
    (5, '1', '2', 0, '[{"method":"thing.state.update","productId":4,"deviceId":0,"identifier":null}]', '11', '1', '2025-11-21 11:27:33', '1', '2025-11-21 11:27:38', 1, 1),
    (6, '演示规则', '', 0, '[{"method":"thing.property.post","productId":16,"deviceId":25,"identifier":null}]', '13', '1', '2026-02-13 22:00:41', '1', '2026-02-13 22:00:41', 0, 1);

INSERT INTO public.iot_data_sink (id, name, description, status, type, config, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (11, '插座', '', 1, 30, '{"tags": "test-tag", "type": "30", "group": "test-group", "topic": "test-topic", "accessKey": " ", "secretKey": " ", "nameServer": "127.0.0.1:9876"}', '1', '2025-03-14 16:55:18', '1', '2026-01-17 18:52:41', 0, 1),
    (12, 'biubiu', 'xx', 1, 1, '{"url": "http://127.0.0.1:8080/test", "body": "", "type": "1", "query": {}, "method": "POST", "headers": {}}', '1', '2025-06-24 22:25:31', '1', '2026-02-13 22:02:57', 0, 1),
    (13, '演示 HTTP 目的地', '', 0, 1, '{"url": "https://httpbin.org/post", "body": "", "type": "1", "query": {}, "method": "POST", "headers": {}}', '1', '2026-02-13 22:00:12', '1', '2026-02-13 22:48:09', 0, 1);

INSERT INTO public.iot_device (id, device_name, nickname, serial_number, pic_url, group_ids, product_id, product_key, device_type, gateway_id, state, online_time, offline_time, active_time, firmware_id, device_secret, latitude, longitude, config, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (6, '0010', '电表家里2', NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '705580aaafbd45d2aa0dd74fd3d1b1b2', NULL, NULL, NULL, '1', '2024-09-21 20:17:28', '1', '2025-07-05 02:01:18', 1, 1),
    (8, 'dianbiao1', '智能电表1', NULL, NULL, '16', 5, 'f13f57c63e9', 0, NULL, 1, '2025-03-08 21:41:50', '2025-03-08 21:41:43', '2024-10-31 21:43:55', NULL, '38a357dd4997418e822b1c679a5dd448', NULL, NULL, NULL, '1', '2024-10-27 10:33:22', NULL, '2025-07-05 02:01:18', 0, 1),
    (9, 'new-123', NULL, NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, 1, '33dc27fd54be4d0e871b8acdc7335c7f', NULL, NULL, NULL, '1', '2024-12-06 09:38:06', '1', '2025-07-05 02:01:18', 0, 1),
    (10, 'test333', NULL, NULL, NULL, '16,17', 10, 'YzvHxd4r67sT4s2B', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f0fc32eab0244d169368ddf5adc03366', NULL, NULL, NULL, '1', '2024-12-14 13:34:08', '1', '2025-07-05 02:01:18', 0, 1),
    (11, 'AA:BB', NULL, NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '805c69c341e2472fb23ec24c0afbeb94', NULL, NULL, NULL, '1', '2024-12-14 15:55:26', '1', '2025-07-05 02:01:18', 0, 1),
    (12, 'gateway110', NULL, NULL, NULL, '17', 9, 'PHg5XcqNfDt4tk3p', 2, NULL, 0, NULL, NULL, NULL, NULL, '0fba9833cead44a8ac743bc273f596a0', NULL, NULL, NULL, '1', '2024-12-14 15:58:28', '1', '2025-07-05 02:01:18', 0, 1),
    (13, 'biubiu', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, 12, 0, NULL, NULL, NULL, NULL, 'e03dff4f4b2f487b9c8febb40d643c94', NULL, NULL, NULL, '1', '2024-12-14 16:01:13', '1', '2025-07-05 02:01:18', 0, 1),
    (14, 'test01', NULL, NULL, NULL, '', 9, 'PHg5XcqNfDt4tk3p', 2, NULL, 0, NULL, NULL, NULL, NULL, '4efe0f34fddc4e978b336f0f851923b3', NULL, NULL, NULL, '1', '2024-12-14 19:09:55', '1', '2025-07-05 02:01:18', 1, 1),
    (15, '温度传感器001', NULL, NULL, NULL, '16,17', 4, '1de24640dfe', 0, 12, 0, NULL, NULL, NULL, NULL, '2d92c51a52ec470d8f09ca410a5983b3', NULL, NULL, NULL, '1', '2024-12-15 10:45:47', '1', '2025-07-05 02:01:18', 0, 1),
    (16, 'abc_45', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '88d121a0da9d4ea58cc48bcdeef6313e', NULL, NULL, NULL, '1', '2024-12-16 13:31:29', '1', '2025-07-05 02:01:18', 0, 1),
    (17, 'acb-sdsd', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '5ac8a92454d946539dc4e8a52a61e6c8', NULL, NULL, NULL, '1', '2024-12-16 13:32:31', '1', '2025-07-05 02:01:18', 0, 1),
    (18, 'dsad', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '506bef8827a1468d921eeab356938f15', NULL, NULL, NULL, '1', '2024-12-16 13:33:06', '1', '2025-07-05 02:01:18', 1, 1),
    (19, 'ssss', NULL, NULL, NULL, '', 12, 'CJVS54fObwZJ9Qe5CJVS54fObwZJ9Qe5', 0, NULL, 0, NULL, NULL, NULL, NULL, '7609964cfa844ee68d1288b35de25b97', NULL, NULL, NULL, '1', '2024-12-16 13:57:16', '1', '2025-07-05 02:01:18', 0, 1),
    (20, '545465464', NULL, NULL, NULL, '', 5, 'f13f57c63e9', 0, NULL, 0, NULL, NULL, NULL, NULL, 'd2776a58bdc6422ea5d48ca502eb1782', NULL, NULL, NULL, '1', '2024-12-30 21:33:06', '1', '2025-07-05 02:01:18', 1, 1),
    (21, 'fjb_001', NULL, NULL, NULL, '', 15, 'efCs2ruTcmchWF61', 0, NULL, 1, '2025-02-20 16:55:20', NULL, '2025-02-20 16:55:20', NULL, 'cbd9a823c53644e4bffe163cdb0075dc', NULL, NULL, NULL, '1', '2024-12-31 16:56:40', NULL, '2025-07-05 02:01:18', 0, 1),
    (22, 'testtest', NULL, NULL, NULL, '', 15, 'efCs2ruTcmchWF61', 0, NULL, 1, '2025-02-20 16:53:33', '2025-02-20 16:53:32', '2025-02-20 16:53:32', NULL, '03e224e5dfb042ddb367fb632b542cc9', NULL, NULL, NULL, '1', '2025-01-24 14:05:01', '1', '2025-07-05 02:01:18', 0, 1),
    (23, 'bintest', NULL, NULL, NULL, '', 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, '2025-01-24 14:20:19', NULL, '2025-01-24 14:20:19', NULL, '66cd0ab9f4fb43e99d1fd965dad263db', 39.912344, 116.381003, NULL, '1', '2025-01-24 14:13:13', '1', '2026-01-21 13:22:07', 0, 1),
    (24, 'kejie', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 1, '2025-02-20 16:53:44', NULL, '2025-01-29 11:09:55', NULL, '1625a3918ae7498ba616124d987ae923', NULL, NULL, '{"abc":"efgee"}', '1', '2025-01-27 13:47:22', '1', '2025-07-05 02:01:18', 0, 1),
    (25, 'small', '12345', NULL, NULL, '', 16, '4aymZgOTOOCrDKRT', 0, NULL, 1, '2026-02-13 18:12:25', '2026-02-12 18:05:21', '2025-01-29 11:25:43', 2, '0baa4c2ecc104ae1a26b4070c218bdf3', 2.000000, 1.000000, 'null', '1', '2025-01-27 16:37:08', NULL, '2026-02-13 18:12:25', 0, 1),
    (27, 'a', 'dylan''s device', NULL, NULL, NULL, 11, 'jAufEMTF1W6wnPhn', 1, 12, 1, '2025-02-21 09:03:44', NULL, '2025-02-21 09:03:44', NULL, '9dbc3808b9634894bf8c31fb471ae795', NULL, NULL, '{"abc":"123"}', NULL, '2025-02-08 20:50:04', '1', '2025-07-05 02:01:18', 0, 1),
    (28, 'jiali001', '家里001', '000001', NULL, '17', 7, 'dcba9928e37', 0, NULL, 1, '2025-03-15 16:38:28', NULL, '2025-03-15 16:38:28', NULL, '4f32b188da644e99b055544376dbecaf', NULL, NULL, NULL, '1', '2025-03-15 16:37:44', '1', '2025-07-05 02:01:18', 1, 1),
    (29, 'jiali001', '家里001', '000001', NULL, '17', 17, 'fqTn4Afs982Nak4N', 0, NULL, 1, '2025-03-15 17:52:21', '2025-03-15 17:52:16', '2025-03-15 17:10:12', NULL, '0ee694bbc2674fe78584f198195acb70', NULL, NULL, '{"xx":"yy","qq":2}', '1', '2025-03-15 16:39:40', '1', '2025-07-05 02:01:18', 0, 1),
    (30, 'demo01', NULL, NULL, NULL, '', 20, 'modbus-tcp-demo', 0, NULL, 1, '2026-02-08 22:44:39', NULL, '2026-01-17 23:33:44', NULL, '1e0f6e168c024d0392dc96ec2f8d6ba7', 41.231395, 124.610078, NULL, '1', '2026-01-17 19:02:39', '1', '2026-02-08 22:45:15', 1, 1),
    (31, 'sub-ddd', NULL, NULL, NULL, '', 21, 'm6XcS1ZJ3TW8eC0v', 2, NULL, 1, '2026-02-03 14:45:50', '2026-02-01 03:32:41', '2026-01-24 21:37:59', NULL, 'b3d62c70f8a4495487ed1d35d61ac2b3', NULL, NULL, '{"v1":1,"v2":"2"}', '1', '2026-01-22 00:45:54', '1', '2026-02-10 17:05:59', 0, 1),
    (32, 'chazuo', NULL, NULL, NULL, '', 8, 'zXXHolcC2Hfxd7I1', 2, NULL, 0, NULL, NULL, NULL, NULL, '84bf90591a59412c9b88a754d548a5b2', NULL, NULL, NULL, '1', '2026-01-22 00:47:20', '1', '2026-01-22 00:47:38', 1, 1),
    (33, 'chazuo-it', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, 31, 2, '2026-01-25 22:11:36', '2026-01-27 00:04:40', '2026-01-24 22:23:23', NULL, 'd46ef9b28ab14238b9c00a3a668032af', NULL, NULL, NULL, '1', '2026-01-22 00:48:06', NULL, '2026-02-03 14:45:50', 0, 1),
    (34, 'test-1769330415908', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '769886d9e3f94d9caec2289a6dcb756b', NULL, NULL, NULL, NULL, '2026-01-25 16:40:16', NULL, '2026-01-25 16:40:16', 0, 1),
    (35, 'balabala', NULL, NULL, NULL, '', 21, 'm6XcS1ZJ3TW8eC0v', 2, NULL, 0, NULL, NULL, NULL, NULL, '55ff23cac303448ab74b048ede1efada', NULL, NULL, NULL, '1', '2026-01-25 16:41:30', '1', '2026-01-25 16:41:39', 1, 1),
    (36, 'mougezishebei', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, NULL, 0, NULL, NULL, NULL, NULL, 'dd0a1e710bbe4a57b8aa1faf8767e8d5', NULL, NULL, NULL, '1', '2026-01-25 16:42:00', NULL, '2026-02-12 03:20:38', 0, 1),
    (37, 'test-1769340407229', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f9f1a4573a9a4476a8544901a60bbc13', NULL, NULL, NULL, NULL, '2026-01-25 19:26:47', '1', '2026-02-07 22:44:01', 1, 1),
    (38, 'test-1769343854384', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'a0df41f6e5144105826a5ddb331a456e', NULL, NULL, NULL, NULL, '2026-01-25 20:24:14', '1', '2026-02-07 22:44:01', 1, 1),
    (39, 'test-1769401423394', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '3adaaba3faeb49749fcfe6c8d60b82de', NULL, NULL, NULL, NULL, '2026-01-26 12:23:44', '1', '2026-02-07 22:44:01', 1, 1),
    (40, 'test-tcp-1769434285110', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'a16a4f73a57d40bb96ee4eca1b0d3a1c', NULL, NULL, NULL, NULL, '2026-01-26 21:31:25', '1', '2026-02-07 22:43:51', 1, 1),
    (41, 'test-mqtt-1769442101041', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f6c621937a694ba9acfd1b6b0af4f66b', NULL, NULL, NULL, NULL, '2026-01-26 23:41:41', '1', '2026-02-07 22:43:51', 1, 1),
    (42, 'test-ws-1769494399710', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '445b9aaf49f94ba39b51905ae785d535', NULL, NULL, NULL, NULL, '2026-01-27 14:13:20', '1', '2026-02-07 22:43:51', 1, 1),
    (43, 'test-tcp-1769886358277', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '2c32c90904624ff0aed2d8d571079c35', NULL, NULL, NULL, NULL, '2026-02-01 03:05:59', '1', '2026-02-07 22:43:51', 1, 1),
    (44, 'test-udp-1769920415009', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '051d50750e4b491798c9673b365d963e', NULL, NULL, NULL, NULL, '2026-02-01 12:33:35', '1', '2026-02-07 22:43:51', 1, 1),
    (45, 'test-mqtt-1769953732108', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '383062f8ee1242589db8031897017890', NULL, NULL, NULL, NULL, '2026-02-01 21:48:52', '1', '2026-02-07 22:43:51', 1, 1),
    (46, 'test-mqtt-1769954867274', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '098e2a73ec384aa4bfaeaa79060738c4', NULL, NULL, NULL, NULL, '2026-02-01 22:07:47', '1', '2026-02-07 22:43:51', 1, 1),
    (47, 'test-mqtt-1769954899502', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '9d20b716fcf944ac9dd09981d6e9672b', NULL, NULL, NULL, NULL, '2026-02-01 22:08:20', '1', '2026-02-07 22:43:51', 1, 1),
    (48, 'test-1769964550851', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b2a679a02f6545c0981e1b82240f02c5', NULL, NULL, NULL, NULL, '2026-02-02 00:49:11', '1', '2026-02-07 22:43:51', 1, 1),
    (49, 'test-mqtt-1769992401585', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b809c291a7aa472193d41e41ab2eabb3', NULL, NULL, NULL, NULL, '2026-02-02 08:33:22', '1', '2026-02-07 22:43:51', 1, 1),
    (50, 'test-mqtt-1769995250899', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '5eacb5c8621145f5b33eb12206b7a4a5', NULL, NULL, NULL, NULL, '2026-02-02 09:20:51', '1', '2026-02-07 22:43:40', 1, 1),
    (51, 'test-mqtt-1770124854510', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '4ade777003984ea4a961d8b47a7873f4', NULL, NULL, NULL, NULL, '2026-02-03 21:21:03', '1', '2026-02-07 22:43:40', 1, 1),
    (52, 'test-mqtt-1770124954448', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7d20d53a11554fca8ebc060c9dddda95', NULL, NULL, NULL, NULL, '2026-02-03 21:22:35', '1', '2026-02-07 22:43:40', 1, 1),
    (53, 'test-mqtt-1770124982510', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7616744b523f439585a0c692f0a9cdde', NULL, NULL, NULL, NULL, '2026-02-03 21:23:03', '1', '2026-02-07 22:43:40', 1, 1),
    (54, 'test-mqtt-1770125063868', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'e7d126c56d47415c919d0e4374c182fb', NULL, NULL, NULL, NULL, '2026-02-03 21:24:24', '1', '2026-02-07 22:43:40', 1, 1),
    (55, 'test-mqtt-1770125100373', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '02e090c953df4df4a0a02413414019e8', NULL, NULL, NULL, NULL, '2026-02-03 21:25:01', '1', '2026-02-07 22:43:40', 1, 1),
    (56, 'test-mqtt-1770125122216', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '45efb3a3fe5348919b5786da7c06eb9d', NULL, NULL, NULL, NULL, '2026-02-03 21:25:22', '1', '2026-02-07 22:43:40', 1, 1),
    (57, 'test-mqtt-1770125245610', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b0695f54e0f04d83bace7ce354cb9019', NULL, NULL, NULL, NULL, '2026-02-03 21:27:26', '1', '2026-02-07 22:43:40', 1, 1),
    (58, 'test-mqtt-1770125319161', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '781d53c6343d4563919bfc2d5705cfad', NULL, NULL, NULL, NULL, '2026-02-03 21:28:39', '1', '2026-02-07 22:43:40', 1, 1),
    (59, 'test-mqtt-1770125330577', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'affcdb056dd741fb8b24cb83d7a4c092', NULL, NULL, NULL, NULL, '2026-02-03 21:28:51', '1', '2026-02-07 22:43:40', 1, 1),
    (60, 'test-mqtt-1770125353810', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'ef11da7b1c5b4552bf61dd49394ebe07', NULL, NULL, NULL, NULL, '2026-02-03 21:29:14', '1', '2026-02-07 22:43:32', 1, 1),
    (61, 'test-mqtt-1770125578091', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:33:08', NULL, NULL, '58a4504d5a34432e8f29cd82c134928e', NULL, NULL, NULL, NULL, '2026-02-03 21:32:58', '1', '2026-02-07 22:43:32', 1, 1),
    (62, 'test-mqtt-1770126059698', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:41:10', NULL, NULL, '355847fe96ad4b439707c3f8b22595ad', NULL, NULL, NULL, NULL, '2026-02-03 21:41:00', '1', '2026-02-07 22:43:32', 1, 1),
    (63, 'test-mqtt-1770126122260', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:42:13', NULL, NULL, '3a591a25d2494e86bfc734cd6e509a00', NULL, NULL, NULL, NULL, '2026-02-03 21:42:02', '1', '2026-02-07 22:43:32', 1, 1),
    (64, 'test-mqtt-1770126147054', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:42:43', NULL, NULL, 'a743b944893b422f8177fe5aef2146d4', NULL, NULL, NULL, NULL, '2026-02-03 21:42:27', '1', '2026-02-07 22:43:15', 1, 1),
    (65, 'test-mqtt-1770126193247', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:43:20', NULL, NULL, '09097fb7e59f4094bad45fed7e58cad3', NULL, NULL, NULL, NULL, '2026-02-03 21:43:13', '1', '2026-02-07 22:43:32', 1, 1),
    (66, 'test-mqtt-1770126311268', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:45:22', NULL, NULL, '9964a178d62a4ab18547f203fc9346cf', NULL, NULL, NULL, NULL, '2026-02-03 21:45:11', '1', '2026-02-07 22:43:20', 1, 1),
    (67, 'test-mqtt-1770126399974', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:46:50', NULL, NULL, '5789ea6022ef4eae80775856798e0cba', NULL, NULL, NULL, NULL, '2026-02-03 21:46:40', '1', '2026-02-07 22:43:18', 1, 1),
    (68, 'test-mqtt-1770126468584', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:48:06', NULL, NULL, '901a89de80cf457091026ba5836c6db4', NULL, NULL, NULL, NULL, '2026-02-03 21:47:49', '1', '2026-02-07 22:43:16', 1, 1),
    (69, 'test-mqtt-1770126608484', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:51:59', NULL, NULL, '983f5d1984db41118e235da7e5f45929', NULL, NULL, NULL, NULL, '2026-02-03 21:50:09', '1', '2026-02-07 22:43:32', 1, 1),
    (70, 'test-mqtt-1770126698661', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'e1db93d726e044389da7588e47c3b409', NULL, NULL, NULL, NULL, '2026-02-03 21:51:59', '1', '2026-02-07 22:43:32', 1, 1),
    (71, 'test-mqtt-1770126722283', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:52:21', NULL, NULL, '4bb765177cd24edd94fe3a70a13fb189', NULL, NULL, NULL, NULL, '2026-02-03 21:52:03', '1', '2026-02-07 22:43:32', 1, 1),
    (72, 'test-mqtt-1770127068400', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:58:16', NULL, NULL, '3537ea77b75a4c499f2eb4a908bd194a', NULL, NULL, NULL, NULL, '2026-02-03 21:57:49', '1', '2026-02-07 22:43:32', 1, 1),
    (73, 'test-mqtt-1770127097453', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '2ff1dfc320a5467dbbd45b6b1896da11', NULL, NULL, NULL, NULL, '2026-02-03 21:58:18', '1', '2026-02-07 22:43:32', 1, 1),
    (74, 'test-mqtt-1770127158718', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:00:04', NULL, NULL, '78537a8d1ea2466dbdb153bc92d56076', NULL, NULL, NULL, NULL, '2026-02-03 21:59:19', '1', '2026-02-07 22:43:10', 1, 1),
    (75, 'test-mqtt-1770127207087', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:00:25', NULL, NULL, '7497af4af6b2492b979a6447d58aea56', NULL, NULL, NULL, NULL, '2026-02-03 22:00:07', '1', '2026-02-07 22:43:08', 1, 1),
    (76, 'test-mqtt-1770127251247', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:01:02', NULL, NULL, '68aa8cbfd812426cae596e3021a6a94e', NULL, NULL, NULL, NULL, '2026-02-03 22:00:51', '1', '2026-02-07 22:43:06', 1, 1),
    (77, 'test-mqtt-1770128309033', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, '2026-02-03 22:18:29', '2026-02-03 22:18:34', '2026-02-03 22:18:29', NULL, 'dc2073e4ea474ebfb3d0057582bcf824', NULL, NULL, NULL, NULL, '2026-02-03 22:18:29', '1', '2026-02-07 22:43:02', 1, 1),
    (78, 'test-mqtt-1770128811425', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'd708cdc5c4c948c08ebfa7accc39e46f', NULL, NULL, NULL, NULL, '2026-02-03 22:26:52', '1', '2026-02-07 22:43:00', 1, 1),
    (79, 'test-mqtt-1770165480031', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7a5717fc427b43eaa2577c449d2dac26', NULL, NULL, NULL, NULL, '2026-02-04 08:38:00', '1', '2026-02-07 22:42:57', 1, 1),
    (80, 'modbus_tcp_server_device_demo_tcp', NULL, NULL, NULL, '', 23, 'modbus_tcp_server_product_demo', 0, NULL, 2, '2026-02-13 15:00:48', '2026-02-13 15:04:08', '2026-02-08 20:45:13', NULL, '8e4adeb3d25342ab88643421d3fba3f6', NULL, NULL, NULL, '1', '2026-02-08 20:19:23', NULL, '2026-02-13 15:04:08', 0, 1),
    (81, 'modbus_tcp_server_device_demo_rtu', NULL, NULL, NULL, '', 23, 'modbus_tcp_server_product_demo', 0, NULL, 1, '2026-02-12 23:30:03', '2026-02-12 23:29:58', '2026-02-08 22:32:29', NULL, 'af01c55eb8e3424bb23fc6c783936b2e', NULL, NULL, NULL, '1', '2026-02-08 21:41:02', NULL, '2026-02-12 23:30:03', 0, 1),
    (82, 'modbus_tcp_client_device_demo', NULL, NULL, NULL, '', 22, 'modbus_tcp_client_product_demo', 0, NULL, 1, '2026-02-13 11:34:01', NULL, '2026-02-08 22:46:07', NULL, 'a2f713affc6d4910a49c663e83c42c63', NULL, NULL, NULL, '1', '2026-02-08 21:42:38', NULL, '2026-02-13 11:34:01', 0, 1);

INSERT INTO public.iot_device_group (id, name, status, description, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (16, '灰度分组', 0, '123', '1', '2024-12-14 17:22:20', '1', '2024-12-14 17:43:56', 0, 1),
    (17, '生产分组', 0, NULL, '1', '2024-12-14 17:22:29', '1', '2024-12-14 17:22:29', 0, 1);

INSERT INTO public.iot_device_modbus_config (id, device_id, product_id, ip, port, slave_id, timeout, retry_interval, mode, status, frame_format, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 30, NULL, '127.0.0.1', 5020, 1, 3000, 1000, 1, 0, 1, '1', '2026-01-17 23:25:50', '1', '2026-02-08 12:22:36', 0, 1),
    (2, 80, NULL, '', 502, 1, 3000, 10000, 1, 0, 1, '1', '2026-02-08 20:41:04', '1', '2026-02-08 20:45:04', 0, 1),
    (3, 81, NULL, '', 502, 1, 3000, 10000, 1, 0, 2, '1', '2026-02-08 21:41:13', '1', '2026-02-14 09:13:06', 0, 1),
    (4, 82, NULL, '127.0.0.1', 5020, 1, 3000, 10000, 1, 0, 1, '1', '2026-02-08 21:42:51', '1', '2026-02-08 22:44:55', 0, 1);

INSERT INTO public.iot_device_modbus_point (id, device_id, thing_model_id, identifier, name, function_code, register_address, register_count, byte_order, raw_data_type, scale, poll_interval, status, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 30, 116, 'height', '高度', 3, 1, 1, 'AB', 'UINT16', 1.000000, 5000, 0, '1', '2026-01-17 23:24:46', '1', '2026-01-17 23:29:25', 0, 1),
    (2, 30, 115, 'width', '宽度', 3, 0, 1, 'AB', 'INT16', 1.000000, 5000, 0, '1', '2026-01-17 23:24:55', '1', '2026-01-17 23:29:50', 0, 1),
    (3, 80, 123, 'width', '宽度', 3, 0, 1, 'AB', 'INT16', 1.000000, 5000, 0, '1', '2026-02-08 20:43:07', '1', '2026-02-08 20:43:07', 0, 1),
    (4, 80, 122, 'height', '高度', 3, 1, 1, 'AB', 'UINT16', 1.000000, 5000, 0, '1', '2026-02-08 20:43:33', '1', '2026-02-08 20:43:33', 0, 1),
    (5, 81, 123, 'width', '宽度', 3, 0, 1, 'AB', 'INT16', 1.000000, 5000, 0, '1', '2026-02-08 21:44:04', '1', '2026-02-08 21:44:04', 0, 1),
    (6, 81, 122, 'height', '高度', 3, 1, 1, 'AB', 'UINT16', 1.000000, 5000, 0, '1', '2026-02-08 21:44:46', '1', '2026-02-08 21:44:46', 0, 1),
    (7, 82, 121, 'width', '宽度', 3, 0, 1, 'AB', 'INT16', 1.000000, 5000, 0, '1', '2026-02-08 21:45:03', '1', '2026-02-08 21:45:03', 0, 1),
    (8, 82, 120, 'height', '高度', 3, 1, 1, 'AB', 'UINT16', 1.000000, 5000, 0, '1', '2026-02-08 21:45:13', '1', '2026-02-08 21:45:13', 0, 1);

INSERT INTO public.iot_ota_firmware (id, name, description, version, product_id, file_url, file_size, file_digest_algorithm, file_digest_value, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 'a', 'b', '2', 4, 'http://test.yudao.iocoder.cn/20250630/codegen-AlertConfig_1751276570898.zip', 14929, 'MD5', 'c4a31d28df26bde385b3840418961590', '1', '2025-06-30 19:04:32', '"1"', '2025-06-30 19:06:01', 0, 1),
    (2, '马桶升级啦！', '好马桶！', '1.0.0', 16, 'http://test.yudao.iocoder.cn/20250704/codegen-IotAlertRecord (1)_1751558430387.zip', 14867, 'MD5', 'e329c811cd9ce48cd49b17d902e19a5d', '1', '2025-07-04 00:00:32', '1', '2025-07-04 00:00:32', 0, 1);

INSERT INTO public.iot_ota_task (id, name, description, firmware_id, status, device_scope, device_total_count, device_success_count, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 'abc', 'abc', 1, 30, 1, 6, 0, '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (2, '2', '2', 1, 20, 1, 5, 0, '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:56', 0, 1),
    (3, '1', '1', 1, 20, 2, 1, 0, '1', '2025-07-03 15:39:16', '"1"', '2025-07-03 15:39:20', 0, 1),
    (4, '3', '1', 1, 20, 2, 1, 0, '1', '2025-07-03 15:42:50', '"1"', '2025-07-03 15:42:54', 0, 1),
    (5, 'bbb', 'ccc', 1, 30, 1, 5, 0, '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (6, 'aab', 'bbc', 2, 20, 2, 1, 0, '1', '2025-07-04 00:00:48', NULL, '2025-07-04 17:40:29', 0, 1);

INSERT INTO public.iot_ota_task_record (id, firmware_id, task_id, device_id, from_firmware_id, status, progress, description, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, 1, 1, 9, 1, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (2, 1, 1, 11, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (3, 1, 1, 15, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (4, 1, 1, 16, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (5, 1, 1, 17, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (6, 1, 1, 24, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-02 01:24:32', '"1"', '2025-07-03 00:04:56', 0, 1),
    (7, 1, 2, 11, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:47', 0, 1),
    (8, 1, 2, 15, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:50', 0, 1),
    (9, 1, 2, 16, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:52', 0, 1),
    (10, 1, 2, 17, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:53', 0, 1),
    (11, 1, 2, 24, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:27:29', '"1"', '2025-07-03 15:34:56', 0, 1),
    (12, 1, 3, 24, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:39:16', '"1"', '2025-07-03 15:39:20', 0, 1),
    (13, 1, 4, 24, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 15:42:50', '"1"', '2025-07-03 15:42:54', 0, 1),
    (14, 1, 5, 11, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (15, 1, 5, 15, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (16, 1, 5, 16, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (17, 1, 5, 17, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (18, 1, 5, 24, NULL, 50, 0, '管理员手动取消升级记录（单个）', '1', '2025-07-03 23:49:57', '"1"', '2025-07-03 23:52:58', 0, 1),
    (19, 2, 6, 25, NULL, 30, 100, '1', '1', '2025-07-04 00:00:48', NULL, '2025-07-04 17:50:17', 0, 1);

INSERT INTO public.iot_product (id, name, product_key, product_secret, register_enabled, category_id, icon, pic_url, description, status, device_type, net_type, protocol_type, serialize_type, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (4, '直传电表', '1de24640dfe', NULL, 1, 4, NULL, NULL, '3', 0, 0, 0, 'mqtt', 'json', '1', '2024-09-07 19:22:53', '1', '2026-02-12 13:07:49', 0, 1),
    (5, '智能电表', 'f13f57c63e9', NULL, 0, 3, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2024-09-21 08:59:19', '1', '2026-02-11 09:50:45', 0, 1),
    (6, '电表 2', 'f0851ee0ebb', NULL, 0, 3, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2024-10-10 20:35:06', '1', '2025-07-05 01:58:13', 1, 1),
    (7, '温湿度V1', 'dcba9928e37', NULL, 0, 3, NULL, NULL, '温湿度产品', 0, 0, 0, 'mqtt', 'json', '1', '2024-11-24 17:20:47', '1', '2025-07-05 01:58:13', 0, 1),
    (8, '插座', 'zXXHolcC2Hfxd7I1', NULL, 0, 13, 'http://test.yudao.iocoder.cn/e71669a0c827bbb96b3e320b6ed19a9fd3d53027833f880fc38a010cac2a2eff.png', 'http://test.yudao.iocoder.cn/3f55f6955a5d453688eef75c66641fdf66e163de250d93124a2746385f1504a6.jpeg', '我是描述！', 1, 2, 0, 'mqtt', 'json', '1', '2024-12-07 19:41:23', '1', '2025-11-24 19:30:32', 0, 1),
    (9, 'ZGW01', 'PHg5XcqNfDt4tk3p', NULL, 0, 10, NULL, 'http://test.yudao.iocoder.cn/3f2a1f61740b56b3e532412b52890a2d4cf29742cfd4ec64969e29844472103c.jpg', NULL, 1, 2, 0, 'mqtt', 'json', '1', '2024-12-14 12:04:03', '1', '2025-11-24 19:30:29', 0, 1),
    (10, '小爱同学', 'YzvHxd4r67sT4s2B', NULL, 0, 10, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-14 13:33:53', '1', '2025-11-24 19:30:25', 0, 1),
    (11, '插座', 'jAufEMTF1W6wnPhn', NULL, 0, 13, NULL, NULL, NULL, 1, 1, NULL, 'mqtt', 'json', '1', '2024-12-14 15:59:14', '1', '2026-01-24 22:20:26', 0, 1),
    (12, '超长的ProductKey', 'CJVS54fObwZJ9Qe5CJVS54fObwZJ9Qe5', NULL, 0, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-16 13:38:44', '1', '2025-11-24 19:30:20', 0, 1),
    (13, '好好长的productkey', 'wSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgF', NULL, 0, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-16 14:06:38', '1', '2025-11-24 19:30:18', 0, 1),
    (14, '测试产品1', 'hBtBtQC6ULI4ewBZ', NULL, 0, 5, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-26 12:57:21', '1', '2026-02-14 09:08:29', 0, 1),
    (15, '2222', 'efCs2ruTcmchWF61', NULL, 0, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-30 21:12:10', '1', '2025-11-24 19:30:13', 0, 1),
    (16, '智能马桶', '4aymZgOTOOCrDKRT', 'test-product-secret', 1, 14, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2025-01-24 14:10:56', '1', '2026-02-13 17:21:34', 0, 1),
    (17, '温度感应器', 'fqTn4Afs982Nak4N', NULL, 0, 4, NULL, NULL, NULL, 1, 0, 1, 'mqtt', 'json', '1', '2025-02-26 10:58:41', '1', '2025-11-24 19:30:06', 0, 1),
    (18, 'modbus-tcp 轮询设备', 'KFhmQZjv6vyWJALA', NULL, 0, 4, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2026-01-17 18:57:38', '1', '2026-01-17 18:57:43', 1, 1),
    (19, 'modbus 产品', 'FrRHlBZJfU7yVSMl', NULL, 0, 4, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2026-01-17 19:00:49', '1', '2026-01-17 19:01:15', 1, 1),
    (20, 'modbus-tcp 产品示例', 'modbus-tcp-demo', NULL, 0, 4, NULL, NULL, NULL, 0, 0, 0, 'modbus_tcp_client', 'json', '1', '2026-01-17 19:01:45', '1', '2026-02-12 23:23:51', 1, 1),
    (21, 'w我是网关噢', 'm6XcS1ZJ3TW8eC0v', 'abac', 1, 4, NULL, NULL, NULL, 1, 2, 0, 'mqtt', 'json', '1', '2026-01-22 00:44:54', '1', '2026-01-25 08:30:00', 0, 1),
    (22, 'Modbus TCP Client 产品示例', 'modbus_tcp_client_product_demo', '36ab002f28e841febff8551963a09731', 0, 15, NULL, NULL, NULL, 1, 0, 0, 'modbus_tcp_client', 'json', '1', '2026-02-08 18:32:43', '1', '2026-02-12 23:23:03', 0, 1),
    (23, 'Modbus TCP Server 产品示例', 'modbus_tcp_server_product_demo', 'ac1e6aac73c3424a84624dd0dd9d3fa5', 0, 14, NULL, NULL, NULL, 1, 0, 0, 'modbus_tcp_server', 'json', '1', '2026-02-08 18:35:23', '1', '2026-02-12 23:22:57', 0, 1);

INSERT INTO public.iot_product_category (id, name, sort, status, description, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (4, '传感器', 2, 0, '', '1', '2024-09-07 19:22:53', '1', '2024-12-14 08:37:35', 0, 1),
    (5, '开关', 1, 0, '', '1', '2024-09-21 08:59:19', '1', '2024-12-14 08:31:56', 0, 1),
    (8, '表计', 3, 0, NULL, '1', '2024-12-14 08:37:29', '1', '2024-12-14 08:37:29', 0, 1),
    (9, '灯', 4, 0, NULL, '1', '2024-12-14 08:37:43', '1', '2024-12-14 08:37:43', 0, 1),
    (10, '网关', 5, 0, NULL, '1', '2024-12-14 08:37:51', '1', '2024-12-14 08:37:51', 0, 1),
    (11, '风扇', 6, 0, NULL, '1', '2024-12-14 08:38:00', '1', '2024-12-14 08:38:00', 0, 1),
    (12, '门磁', 7, 0, NULL, '1', '2024-12-14 08:38:09', '1', '2024-12-14 08:38:09', 0, 1),
    (13, '智能插座', 8, 0, NULL, '1', '2024-12-14 08:38:17', '1', '2024-12-14 08:38:17', 0, 1),
    (14, '新风', 9, 0, NULL, '1', '2024-12-14 08:38:27', '1', '2024-12-14 08:38:27', 0, 1),
    (15, '智能手表', 10, 0, NULL, '1', '2024-12-14 08:38:34', '1', '2024-12-14 08:38:34', 0, 1);

INSERT INTO public.iot_rule_scene (id, name, description, status, triggers, actions, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, '11', '', 0, '[{"type": 1, "conditions": [{"type": "property", "identifier": "set", "parameters": []}], "productKey": "", "deviceNames": [], "cronExpression": null}]', '[{"type": 1, "dataBridgeId": null, "deviceControl": {"data": {"array": "1", "struct": "1", "property_test0": "1"}, "type": "property", "identifier": "set", "productKey": "efCs2ruTcmchWF61", "deviceNames": []}}]', '1', '2025-03-28 18:03:21', '1', '2025-03-28 18:11:41', 0, 1),
    (2, '111', '', 0, '[{"type": 1, "conditions": [{"type": "property", "identifier": "set", "parameters": [{"value": "12", "operator": "=", "identifier": "temperature"}]}], "productKey": "fqTn4Afs982Nak4N", "deviceNames": ["jiali001"], "cronExpression": null}]', '[{"type": 3, "dataBridgeId": 11, "deviceControl": {"data": {}, "type": "property", "identifier": "set", "productKey": "", "deviceNames": []}}]', '1', '2025-03-29 12:48:39', '1', '2025-03-29 12:48:39', 0, 1),
    (3, '全组件展示', '完全形态', 0, '[{"type": 1, "conditions": [{"type": "event", "identifier": "set", "parameters": [{"value": "10", "operator": "=", "identifier": "temperature", "identifier0": "post"}]}, {"type": "service", "identifier": "set", "parameters": [{"value": null, "operator": "not null", "identifier": "temperature", "identifier0": "get"}]}, {"type": "property", "identifier": "set", "parameters": [{"value": "50", "operator": "!=", "identifier": "humidity", "identifier0": null}]}], "productKey": "fqTn4Afs982Nak4N", "deviceNames": ["test333"], "cronExpression": null}, {"type": 2, "conditions": [{"type": "property", "identifier": "set", "parameters": []}], "productKey": "", "deviceNames": [], "cronExpression": "0 0 0 * * ?"}]', '[{"type": 1, "dataBridgeId": null, "deviceControl": {"data": {"times": "2025-03-29 17:26:14", "D32d2d": "文本测试", "struct": "[{\"identifier\":\"对应左侧 identifier 属性值\",\"value\":\"1\"}]", "d3d3d3d3d3": 1, "fg3f43f432f3": 1}, "type": "property", "identifier": "set", "productKey": "efCs2ruTcmchWF61", "deviceNames": ["testtest", "fjb_001"]}}, {"type": 2, "dataBridgeId": null, "deviceControl": {"data": {"get": {"value": "2", "identifier": "temperature"}}, "type": "service", "identifier": "${identifier}", "productKey": "fqTn4Afs982Nak4N", "deviceNames": ["jiali001"]}}, {"type": 3, "dataBridgeId": 11, "deviceControl": {"data": {}, "type": "property", "identifier": "set", "productKey": "", "deviceNames": []}}]', '1', '2025-03-29 13:37:51', '"1"', '2025-08-04 21:42:07', 0, 1);

INSERT INTO public.iot_scene_rule (id, name, description, status, triggers, actions, last_trigger_time, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (1, '11', '', 0, '[{"type": 1, "conditions": [{"type": "property", "identifier": "set", "parameters": []}], "productKey": "", "deviceNames": [], "cronExpression": null}]', '[{"type": 1, "dataBridgeId": null, "deviceControl": {"data": {"array": "1", "struct": "1", "property_test0": "1"}, "type": "property", "identifier": "set", "productKey": "efCs2ruTcmchWF61", "deviceNames": []}}]', NULL, '1', '2025-03-28 18:03:21', '1', '2025-03-28 18:11:41', 0, 1),
    (2, '111', '', 0, '[{"type": 1, "conditions": [{"type": "property", "identifier": "set", "parameters": [{"value": "12", "operator": "=", "identifier": "temperature"}]}], "productKey": "fqTn4Afs982Nak4N", "deviceNames": ["jiali001"], "cronExpression": null}]', '[{"type": 3, "dataBridgeId": 11, "deviceControl": {"data": {}, "type": "property", "identifier": "set", "productKey": "", "deviceNames": []}}]', NULL, '1', '2025-03-29 12:48:39', '1', '2025-03-29 12:48:39', 0, 1),
    (3, '全组件展示', '学习下', 1, '[{"type": 1, "value": "online", "deviceId": 0, "operator": "=", "productId": 5, "identifier": "", "cronExpression": null, "conditionGroups": null}, {"type": 2, "value": "", "deviceId": null, "operator": null, "productId": null, "identifier": null, "cronExpression": null, "conditionGroups": []}]', '[{"type": 1, "params": null, "deviceId": null, "productId": null, "identifier": null, "alertConfigId": null}, {"type": 2, "params": null, "deviceId": null, "productId": null, "identifier": null, "alertConfigId": null}, {"type": 100, "params": null, "deviceId": null, "productId": null, "identifier": null, "alertConfigId": null}]', NULL, '1', '2025-03-29 13:37:51', '1', '2025-09-03 23:05:23', 0, 1),
    (4, '演示场景联动规则', '', 0, '[{"type": 2, "value": "1000", "deviceId": 0, "operator": ">", "productId": 16, "identifier": "width", "cronExpression": null, "conditionGroups": []}]', '[{"type": 2, "params": "{\n  \"a\": 1,\n  \"b\": 2\n}", "deviceId": 25, "productId": 16, "identifier": "test_scene_rule", "alertConfigId": null}]', '2026-02-13 18:15:28', '1', '2026-02-13 18:11:44', NULL, '2026-02-13 18:15:28', 0, 1),
    (5, '高度超标告警规则', '', 0, '[{"type": 2, "value": "2000", "deviceId": 25, "operator": ">", "productId": 16, "identifier": "height", "cronExpression": null, "conditionGroups": []}]', '[{"type": 100, "params": null, "deviceId": null, "productId": null, "identifier": null, "alertConfigId": null}]', '2026-02-13 22:50:35', '1', '2026-02-13 20:34:30', NULL, '2026-02-13 22:50:35', 0, 1);

INSERT INTO public.iot_thing_model (id, identifier, name, description, product_id, product_key, type, property, event, service, creator, create_time, updater, update_time, deleted, tenant_id) VALUES
    (80, 'close', '关闭插座', NULL, 11, 'jAufEMTF1W6wnPhn', 2, NULL, NULL, '{"name": "关闭插座", "method": null, "callType": "sync", "required": null, "identifier": "close", "inputParams": [{"name": "开关状态", "dataType": "bool", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "status", "dataSpecsList": [{"name": "关", "value": 0, "dataType": "bool"}, {"name": "开", "value": 1, "dataType": "bool"}]}], "outputParams": [{"name": "开关状态", "dataType": "bool", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "status", "dataSpecsList": [{"name": "关", "value": 0, "dataType": "bool"}, {"name": "开", "value": 1, "dataType": "bool"}]}]}', '1', '2024-12-26 14:45:17', '1', '2024-12-27 11:35:32', 0, 1),
    (81, 'power', '电流功率', NULL, 11, 'jAufEMTF1W6wnPhn', 1, '{"name": "电流功率", "dataType": "int", "required": null, "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "accessMode": "r", "identifier": "power", "dataSpecsList": null}', NULL, NULL, '1', '2024-12-26 14:49:12', '1', '2024-12-26 14:49:12', 0, 1),
    (82, 'post', '属性上报', '属性上报事件', 11, 'jAufEMTF1W6wnPhn', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}]}', NULL, '1', '2024-12-26 14:49:13', '1', '2025-06-29 15:36:59', 1, 1),
    (83, 'get', '属性获取', '属性获取服务', 11, 'jAufEMTF1W6wnPhn', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}], "outputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}]}', '1', '2024-12-26 14:49:13', '1', '2025-06-29 15:37:01', 1, 1),
    (84, 'soul', '加热', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "加热", "dataType": "int", "required": null, "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "accessMode": "rw", "identifier": "soul", "dataSpecsList": null}', NULL, NULL, '1', '2024-12-31 16:22:15', '1', '2025-01-03 13:38:31', 0, 1),
    (85, 'post', '属性上报', '属性上报事件', 15, 'efCs2ruTcmchWF61', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "output", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}]}', NULL, '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0, 1),
    (86, 'set', '属性设置', '属性设置服务', 15, 'efCs2ruTcmchWF61', 2, NULL, NULL, '{"name": "属性设置", "method": "thing.service.property.set", "callType": "async", "required": null, "identifier": "set", "inputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "input", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}], "outputParams": []}', '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0, 1),
    (87, 'get', '属性获取', '属性获取服务', 15, 'efCs2ruTcmchWF61', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "input", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}], "outputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "output", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}]}', '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0, 1),
    (88, '5A_test', '5a服务', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 2, NULL, NULL, '{"name": "5a服务", "method": null, "callType": "async", "required": null, "identifier": "5A_test", "inputParams": null, "outputParams": null}', '1', '2025-01-01 16:49:22', '1', '2025-01-01 16:49:22', 0, 1),
    (89, 'property_test0', '属性test0', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "属性test0", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "accessMode": "rw", "identifier": "property_test0", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-01 16:58:23', '1', '2025-01-01 16:58:23', 0, 1),
    (90, 'event_test0', 'Event_test0', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 3, NULL, '{"name": "Event_test0", "type": "info", "method": null, "required": null, "identifier": "event_test0", "outputParams": null}', NULL, '1', '2025-01-01 16:59:05', '1', '2025-01-01 16:59:05', 0, 1),
    (91, 'times', '时间', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "时间", "dataType": "date", "required": null, "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "accessMode": "rw", "identifier": "times", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-03 20:21:09', '1', '2025-01-03 20:21:09', 0, 1),
    (92, 'struct', '结构体', NULL, 15, 'efCs2ruTcmchWF61', 1, '{"name": "结构体", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-01-03 20:21:30', '1', '2025-02-20 16:58:35', 0, 1),
    (93, 'array', '队列', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "队列", "dataType": "array", "required": null, "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "accessMode": "rw", "identifier": "array", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-03 20:21:58', '1', '2025-01-03 20:21:58', 0, 1),
    (94, 'water', '出水量', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "出水量", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "accessMode": "rw", "identifier": "water", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-24 14:11:37', '1', '2025-01-24 14:11:37', 0, 1),
    (95, 'post', '属性上报', '属性上报事件', 16, '4aymZgOTOOCrDKRT', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}]}', NULL, '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:11:00', 1, 1),
    (96, 'set', '属性设置', '属性设置服务', 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "属性设置", "method": "thing.service.property.set", "callType": "async", "required": null, "identifier": "set", "inputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}], "outputParams": []}', '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:10:58', 1, 1),
    (97, 'get', '属性获取', '属性获取服务', 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}], "outputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}]}', '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:10:56', 1, 1),
    (98, 'height', '高度', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-27 16:36:04', '1', '2025-01-27 16:36:04', 0, 1),
    (99, 'width', '宽度', '132', 16, '4aymZgOTOOCrDKRT', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-27 16:36:32', '1', '2025-01-27 22:22:40', 0, 1),
    (100, 'onetwo', '一二', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "一二", "dataType": "int", "required": null, "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": "rw", "identifier": "onetwo", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-28 22:57:42', '1', '2025-01-28 22:57:42', 0, 1),
    (101, 'oneThree', '一三', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "一三", "dataType": "int", "required": null, "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": "rw", "identifier": "oneThree", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-28 23:03:17', '1', '2025-01-28 23:03:17', 0, 1),
    (102, 'kwhp', '正向有功电能', NULL, 5, 'f13f57c63e9', 1, '{"name": "正向有功电能", "dataType": "double", "required": null, "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "accessMode": "r", "identifier": "kwhp", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0, 1),
    (103, 'post', '属性上报', '属性上报事件', 5, 'f13f57c63e9', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}]}', NULL, '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0, 1),
    (104, 'get', '属性获取', '属性获取服务', 5, 'f13f57c63e9', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}], "outputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}]}', '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0, 1),
    (105, 'temperature', '温度', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "温度", "dataType": "double", "required": null, "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "accessMode": "r", "identifier": "temperature", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:32:09', 0, 1),
    (106, 'post', '属性上报', '属性上报事件', 17, 'fqTn4Afs982Nak4N', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}]}', NULL, '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:33:53', 0, 1),
    (107, 'get', '属性获取', '属性获取服务', 17, 'fqTn4Afs982Nak4N', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}], "outputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}]}', '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:33:53', 0, 1),
    (108, 'humidity', '湿度', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "湿度", "dataType": "double", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "accessMode": "r", "identifier": "humidity", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-15 16:33:53', '1', '2025-03-15 16:33:53', 0, 1),
    (109, 'eat', '吃饭', NULL, 16, '4aymZgOTOOCrDKRT', 3, NULL, '{"name": "吃饭", "type": "info", "method": null, "required": null, "identifier": "eat", "outputParams": [{"name": "米", "dataType": "int", "dataSpecs": {"max": "10", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "rice", "dataSpecsList": null}]}', NULL, '1', '2025-06-19 13:15:21', '1', '2025-06-19 13:15:21', 0, 1),
    (110, 'u100', 'u100', NULL, 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "u100", "method": null, "callType": "async", "required": null, "identifier": "u100", "inputParams": [{"name": "a", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "a", "dataSpecsList": null}, {"name": "b", "dataType": "int", "dataSpecs": {"max": "100", "min": "50", "step": "20", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "b", "dataSpecsList": null}], "outputParams": [{"name": "r1", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "dS/m", "precise": null, "dataType": "int", "unitName": "土壤EC值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "r1", "dataSpecsList": null}, {"name": "r2", "dataType": "int", "dataSpecs": {"max": "30", "min": "20", "step": "5", "unit": "dS/m", "precise": null, "dataType": "int", "unitName": "土壤EC值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "r2", "dataSpecsList": null}]}', '1', '2025-06-21 15:18:58', '1', '2025-06-21 15:18:58', 0, 1),
    (111, 'demo', 'demo', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "demo", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "demo", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "b", "dataType": "struct", "required": null, "dataSpecs": {"max": "50", "min": "20", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "b", "childDataType": "int", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-06-29 15:45:11', '"1"', '2025-06-29 15:45:55', 0, 1),
    (112, 'demo_json', 'demo_json', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_json", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "demo_json", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "b", "dataType": "struct", "required": null, "dataSpecs": {"max": "100", "min": "50", "step": "30", "unit": "mg/kg", "precise": null, "dataType": "int", "unitName": "毫克每千克", "defaultValue": null}, "accessMode": null, "identifier": "b", "childDataType": "int", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-06-29 16:11:40', '1', '2025-06-29 16:11:40', 0, 1),
    (113, 'demo_array_int', 'demo_array_int', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_array_int", "dataType": "array", "required": null, "dataSpecs": {"size": 10, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "accessMode": "rw", "identifier": "demo_array_int", "dataSpecsList": null}', NULL, NULL, '1', '2025-06-29 16:31:31', '1', '2025-06-29 16:31:31', 0, 1),
    (114, 'demo_array_json', 'demo_array_json', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_array_json", "dataType": "array", "required": null, "dataSpecs": {"size": 10, "dataType": "array", "childDataType": "struct", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "10", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "cc", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "cc", "childDataType": "int", "dataSpecsList": null}]}, "accessMode": "rw", "identifier": "demo_array_json", "dataSpecsList": null}', NULL, NULL, '1', '2025-06-29 16:32:02', '"1"', '2025-06-29 16:51:30', 0, 1),
    (115, 'width', '宽度', NULL, 20, 'modbus-tcp-demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "1", "unit": "mm/s", "precise": null, "dataType": "int", "unitName": "毫米每秒", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-17 23:24:08', '1', '2026-01-17 23:24:08', 0, 1),
    (116, 'height', '高度', NULL, 20, 'modbus-tcp-demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-17 23:24:26', '1', '2026-01-17 23:24:26', 0, 1),
    (117, 'temperature', '温度', NULL, 21, 'm6XcS1ZJ3TW8eC0v', 1, '{"name": "温度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "0", "step": "1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "accessMode": "rw", "identifier": "temperature", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-24 22:15:21', '1', '2026-01-24 22:15:21', 0, 1),
    (118, 'statusReport', '状态汇报', NULL, 21, 'm6XcS1ZJ3TW8eC0v', 3, NULL, '{"name": "状态汇报", "type": "info", "method": null, "required": null, "identifier": "statusReport", "outputParams": [{"name": "内容", "dataType": "text", "dataSpecs": {"length": 1000, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "message", "dataSpecsList": null}]}', NULL, '1', '2026-01-24 22:16:59', '1', '2026-01-24 22:16:59', 0, 1),
    (119, 'healthCheck', '健康检查', NULL, 11, 'jAufEMTF1W6wnPhn', 3, NULL, '{"name": "健康检查", "type": "info", "method": null, "required": null, "identifier": "healthCheck", "outputParams": [{"name": "错误码", "dataType": "int", "dataSpecs": {"max": "500", "min": "0", "step": "1", "unit": "L/s", "precise": null, "dataType": "int", "unitName": "升每秒", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "errorCode", "dataSpecsList": null}]}', NULL, '1', '2026-01-24 22:20:24', '1', '2026-01-24 22:20:24', 0, 1),
    (120, 'height', '高度', NULL, 22, 'modbus_tcp_master_product_demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "10", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:34:14', '1', '2026-02-08 18:34:14', 0, 1),
    (121, 'width', '宽度', NULL, 22, 'modbus_tcp_master_product_demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:34:40', '1', '2026-02-08 18:34:40', 0, 1),
    (122, 'height', '高度', NULL, 23, 'modbus_tcp_slave_product_demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:36:08', '1', '2026-02-08 18:36:08', 0, 1),
    (123, 'width', '宽度', NULL, 23, 'modbus_tcp_slave_product_demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:36:30', '1', '2026-02-08 18:36:30', 0, 1),
    (124, 'test_scene_rule', '测试场景联动', NULL, 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "测试场景联动", "method": null, "callType": "async", "required": null, "identifier": "test_scene_rule", "inputParams": [{"name": "a", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "1", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "a", "dataSpecsList": null}, {"name": "b", "dataType": "int", "dataSpecs": {"max": "100", "min": "5", "step": "50", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "b", "dataSpecsList": null}], "outputParams": [{"name": "sum", "dataType": "int", "dataSpecs": {"max": "5000", "min": "1000", "step": "50", "unit": "mg/kg", "precise": null, "dataType": "int", "unitName": "毫克每千克", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "sum", "dataSpecsList": null}]}', '1', '2026-02-13 17:21:32', '1', '2026-02-13 17:21:32', 0, 1);

MERGE INTO public.system_menu AS t
USING (
    VALUES
        (6100::bigint, '物联网'::varchar, ''::varchar, 1::smallint, 30::int, 0::bigint, '/iot'::varchar, 'ep:connection'::varchar, NULL::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6101::bigint, '产品管理'::varchar, ''::varchar, 2::smallint, 1::int, 6100::bigint, 'product'::varchar, 'ep:box'::varchar, 'iot/product/index'::varchar, 'IotProduct'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6102::bigint, '设备管理'::varchar, ''::varchar, 2::smallint, 2::int, 6100::bigint, 'device'::varchar, 'ep:cpu'::varchar, 'iot/device/index'::varchar, 'IotDevice'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6103::bigint, '物模型'::varchar, ''::varchar, 2::smallint, 3::int, 6100::bigint, 'thing-model'::varchar, 'ep:files'::varchar, 'iot/thing-model/index'::varchar, 'IotThingModel'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6104::bigint, '数据转发'::varchar, ''::varchar, 2::smallint, 4::int, 6100::bigint, 'data-sink'::varchar, 'ep:share'::varchar, 'iot/rule/data-sink/index'::varchar, 'IotDataSink'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6105::bigint, '数据规则'::varchar, ''::varchar, 2::smallint, 5::int, 6100::bigint, 'data-rule'::varchar, 'ep:set-up'::varchar, 'iot/rule/data-rule/index'::varchar, 'IotDataRule'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6111::bigint, '产品查询'::varchar, 'iot:product:query'::varchar, 3::smallint, 1::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6112::bigint, '产品新增'::varchar, 'iot:product:create'::varchar, 3::smallint, 2::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6113::bigint, '产品修改'::varchar, 'iot:product:update'::varchar, 3::smallint, 3::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6114::bigint, '产品删除'::varchar, 'iot:product:delete'::varchar, 3::smallint, 4::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6121::bigint, '设备查询'::varchar, 'iot:device:query'::varchar, 3::smallint, 1::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6122::bigint, '设备新增'::varchar, 'iot:device:create'::varchar, 3::smallint, 2::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6123::bigint, '设备修改'::varchar, 'iot:device:update'::varchar, 3::smallint, 3::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6124::bigint, '设备删除'::varchar, 'iot:device:delete'::varchar, 3::smallint, 4::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6125::bigint, '设备认证信息'::varchar, 'iot:device:auth-info'::varchar, 3::smallint, 5::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6126::bigint, '设备消息查询'::varchar, 'iot:device:message-query'::varchar, 3::smallint, 6::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6127::bigint, '设备消息结束'::varchar, 'iot:device:message-end'::varchar, 3::smallint, 7::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6128::bigint, '设备属性查询'::varchar, 'iot:device:property-query'::varchar, 3::smallint, 8::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6131::bigint, '物模型查询'::varchar, 'iot:thing-model:query'::varchar, 3::smallint, 1::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6132::bigint, '物模型新增'::varchar, 'iot:thing-model:create'::varchar, 3::smallint, 2::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6133::bigint, '物模型修改'::varchar, 'iot:thing-model:update'::varchar, 3::smallint, 3::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6134::bigint, '物模型删除'::varchar, 'iot:thing-model:delete'::varchar, 3::smallint, 4::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6141::bigint, '转发查询'::varchar, 'iot:data-sink:query'::varchar, 3::smallint, 1::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6142::bigint, '转发新增'::varchar, 'iot:data-sink:create'::varchar, 3::smallint, 2::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6143::bigint, '转发修改'::varchar, 'iot:data-sink:update'::varchar, 3::smallint, 3::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6144::bigint, '转发删除'::varchar, 'iot:data-sink:delete'::varchar, 3::smallint, 4::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6151::bigint, '规则查询'::varchar, 'iot:data-rule:query'::varchar, 3::smallint, 1::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6152::bigint, '规则新增'::varchar, 'iot:data-rule:create'::varchar, 3::smallint, 2::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6153::bigint, '规则修改'::varchar, 'iot:data-rule:update'::varchar, 3::smallint, 3::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6154::bigint, '规则删除'::varchar, 'iot:data-rule:delete'::varchar, 3::smallint, 4::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint)
) AS s (
    id, name, permission, type, sort, parent_id, path, icon, component, component_name,
    status, visible, keep_alive, always_show, creator, updater, deleted
)
ON (t.id = s.id)
WHEN MATCHED THEN
    UPDATE SET
        name = s.name,
        permission = s.permission,
        type = s.type,
        sort = s.sort,
        parent_id = s.parent_id,
        path = s.path,
        icon = s.icon,
        component = s.component,
        component_name = s.component_name,
        status = s.status,
        visible = s.visible,
        keep_alive = s.keep_alive,
        always_show = s.always_show,
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, name, permission, type, sort, parent_id, path, icon, component, component_name,
        status, visible, keep_alive, always_show, creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.name, s.permission, s.type, s.sort, s.parent_id, s.path, s.icon, s.component, s.component_name,
        s.status, s.visible, s.keep_alive, s.always_show, s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

MERGE INTO public.system_role AS t
USING (
    VALUES
        (86001::bigint, 'IoT 管理员'::varchar, 'iot_admin'::varchar, 10::int, 1::smallint, ''::varchar, 0::smallint, 2::smallint, 'Go ingestion + IoT backend minimal admin role'::varchar, 'codex'::varchar, 'codex'::varchar, 0::smallint)
) AS s (
    id, name, code, sort, data_scope, data_scope_dept_ids, status, type, remark, creator, updater, deleted
)
ON (t.id = s.id)
WHEN MATCHED THEN
    UPDATE SET
        name = s.name,
        code = s.code,
        sort = s.sort,
        data_scope = s.data_scope,
        data_scope_dept_ids = s.data_scope_dept_ids,
        status = s.status,
        type = s.type,
        remark = s.remark,
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, name, code, sort, data_scope, data_scope_dept_ids, status, type, remark,
        creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.name, s.code, s.sort, s.data_scope, s.data_scope_dept_ids, s.status, s.type, s.remark,
        s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

MERGE INTO public.system_users AS t
USING (
    VALUES
        (
            86002::bigint,
            'iotadmin'::varchar,
            '$2a$10$IqPUCU81.bBtiR3Ib9m.yOZ1h3IF7uQQE1j1xYyK3bfHMaq.YUu.u'::varchar,
            'IoT管理员'::varchar,
            'IoT bootstrap account'::varchar,
            100::bigint,
            NULL::varchar,
            ''::varchar,
            ''::varchar,
            0::smallint,
            ''::varchar,
            0::smallint,
            ''::varchar,
            NULL::timestamp,
            'codex'::varchar,
            'codex'::varchar,
            0::smallint
        )
) AS s (
    id, username, password, nickname, remark, dept_id, post_ids, email, mobile, sex, avatar,
    status, login_ip, login_date, creator, updater, deleted
)
ON (t.id = s.id)
WHEN MATCHED THEN
    UPDATE SET
        username = s.username,
        password = s.password,
        nickname = s.nickname,
        remark = s.remark,
        dept_id = s.dept_id,
        post_ids = s.post_ids,
        email = s.email,
        mobile = s.mobile,
        sex = s.sex,
        avatar = s.avatar,
        status = s.status,
        login_ip = s.login_ip,
        login_date = s.login_date,
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, username, password, nickname, remark, dept_id, post_ids, email, mobile, sex, avatar,
        status, login_ip, login_date, creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.username, s.password, s.nickname, s.remark, s.dept_id, s.post_ids, s.email, s.mobile, s.sex, s.avatar,
        s.status, s.login_ip, s.login_date, s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

MERGE INTO public.system_role_menu AS t
USING (
    VALUES
        (86101::bigint, 86001::bigint, 6100::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86102::bigint, 86001::bigint, 6101::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86103::bigint, 86001::bigint, 6102::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86104::bigint, 86001::bigint, 6103::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86105::bigint, 86001::bigint, 6104::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86106::bigint, 86001::bigint, 6105::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86107::bigint, 86001::bigint, 6111::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86108::bigint, 86001::bigint, 6112::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86109::bigint, 86001::bigint, 6113::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86110::bigint, 86001::bigint, 6114::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86111::bigint, 86001::bigint, 6121::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86112::bigint, 86001::bigint, 6122::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86113::bigint, 86001::bigint, 6123::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86114::bigint, 86001::bigint, 6124::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86115::bigint, 86001::bigint, 6125::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86116::bigint, 86001::bigint, 6126::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86117::bigint, 86001::bigint, 6127::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86118::bigint, 86001::bigint, 6128::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86119::bigint, 86001::bigint, 6131::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86120::bigint, 86001::bigint, 6132::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86121::bigint, 86001::bigint, 6133::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86122::bigint, 86001::bigint, 6134::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86123::bigint, 86001::bigint, 6141::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86124::bigint, 86001::bigint, 6142::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86125::bigint, 86001::bigint, 6143::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86126::bigint, 86001::bigint, 6144::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86127::bigint, 86001::bigint, 6151::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86128::bigint, 86001::bigint, 6152::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86129::bigint, 86001::bigint, 6153::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (86130::bigint, 86001::bigint, 6154::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint)
) AS s (id, role_id, menu_id, creator, updater, deleted)
ON (t.role_id = s.role_id AND t.menu_id = s.menu_id)
WHEN MATCHED THEN
    UPDATE SET
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, role_id, menu_id, creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.role_id, s.menu_id, s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

MERGE INTO public.system_role_menu AS t
USING (
    VALUES
        (87101::bigint, 1::bigint, 6100::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87102::bigint, 1::bigint, 6101::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87103::bigint, 1::bigint, 6102::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87104::bigint, 1::bigint, 6103::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87105::bigint, 1::bigint, 6104::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87106::bigint, 1::bigint, 6105::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87107::bigint, 1::bigint, 6111::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87108::bigint, 1::bigint, 6112::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87109::bigint, 1::bigint, 6113::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87110::bigint, 1::bigint, 6114::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87111::bigint, 1::bigint, 6121::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87112::bigint, 1::bigint, 6122::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87113::bigint, 1::bigint, 6123::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87114::bigint, 1::bigint, 6124::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87115::bigint, 1::bigint, 6125::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87116::bigint, 1::bigint, 6126::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87117::bigint, 1::bigint, 6127::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87118::bigint, 1::bigint, 6128::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87119::bigint, 1::bigint, 6131::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87120::bigint, 1::bigint, 6132::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87121::bigint, 1::bigint, 6133::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87122::bigint, 1::bigint, 6134::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87123::bigint, 1::bigint, 6141::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87124::bigint, 1::bigint, 6142::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87125::bigint, 1::bigint, 6143::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87126::bigint, 1::bigint, 6144::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87127::bigint, 1::bigint, 6151::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87128::bigint, 1::bigint, 6152::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87129::bigint, 1::bigint, 6153::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint),
        (87130::bigint, 1::bigint, 6154::bigint, 'admin'::varchar, 'admin'::varchar, 0::smallint)
) AS s (id, role_id, menu_id, creator, updater, deleted)
ON (t.role_id = s.role_id AND t.menu_id = s.menu_id)
WHEN MATCHED THEN
    UPDATE SET
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, role_id, menu_id, creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.role_id, s.menu_id, s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

MERGE INTO public.system_user_role AS t
USING (
    VALUES
        (86201::bigint, 86002::bigint, 86001::bigint, 'codex'::varchar, 'codex'::varchar, 0::smallint)
) AS s (id, user_id, role_id, creator, updater, deleted)
ON (t.user_id = s.user_id AND t.role_id = s.role_id)
WHEN MATCHED THEN
    UPDATE SET
        updater = s.updater,
        update_time = CURRENT_TIMESTAMP,
        deleted = s.deleted
WHEN NOT MATCHED THEN
    INSERT (
        id, user_id, role_id, creator, create_time, updater, update_time, deleted
    )
    VALUES (
        s.id, s.user_id, s.role_id, s.creator, CURRENT_TIMESTAMP, s.updater, CURRENT_TIMESTAMP, s.deleted
    );

SELECT pg_catalog.setval('public.iot_alert_config_seq', 2, true);
SELECT pg_catalog.setval('public.iot_alert_record_seq', 5, true);
SELECT pg_catalog.setval('public.iot_data_rule_seq', 6, true);
SELECT pg_catalog.setval('public.iot_data_bridge_seq', 13, true);
SELECT pg_catalog.setval('public.iot_device_seq', 82, true);
SELECT pg_catalog.setval('public.iot_device_group_seq', 17, true);
SELECT pg_catalog.setval('public.iot_device_modbus_config_seq', 4, true);
SELECT pg_catalog.setval('public.iot_device_modbus_point_seq', 8, true);
SELECT pg_catalog.setval('public.iot_ota_firmware_seq', 2, true);
SELECT pg_catalog.setval('public.iot_ota_task_seq', 6, true);
SELECT pg_catalog.setval('public.iot_ota_task_record_seq', 19, true);
SELECT pg_catalog.setval('public.iot_product_seq', 23, true);
SELECT pg_catalog.setval('public.iot_product_category_seq', 15, true);
SELECT pg_catalog.setval('public.iot_rule_scene_seq', 3, true);
SELECT pg_catalog.setval('public.iot_scene_rule_seq', 5, true);
SELECT pg_catalog.setval('public.iot_thing_model_seq', 124, true);

COMMIT;
