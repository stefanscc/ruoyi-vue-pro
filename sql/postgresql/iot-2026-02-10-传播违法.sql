-- PostgreSQL IoT seed converted from iot-2026-02-10-传播违法1.sql
-- Includes all source product/device/thing_model rows plus an expanded pack-pressure-test dataset.
-- Safe to run multiple times.

BEGIN;

DO $$
DECLARE
    missing_tables text;
BEGIN
    SELECT string_agg(required_table, ', ')
    INTO missing_tables
    FROM (
        SELECT unnest(ARRAY['iot_product', 'iot_device', 'iot_thing_model']) AS required_table
        EXCEPT
        SELECT tablename FROM pg_tables WHERE schemaname = 'public'
    ) t;

    IF missing_tables IS NOT NULL THEN
        RAISE EXCEPTION 'Missing required PostgreSQL IoT tables: %', missing_tables;
    END IF;
END $$;

INSERT INTO public.iot_product (
    id, name, product_key, product_secret, register_enabled, category_id, icon, pic_url, description, status, device_type, net_type, protocol_type, serialize_type, creator, create_time, updater, update_time, deleted
) VALUES
    (4, '直传电表', '1de24640dfe', NULL, true, 4, NULL, NULL, '3', 0, 0, 0, 'mqtt', 'json', '1', '2024-09-07 19:22:53', '1', '2026-02-12 13:07:49', 0),
    (5, '智能电表', 'f13f57c63e9', NULL, false, 3, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2024-09-21 08:59:19', '1', '2026-02-11 09:50:45', 0),
    (6, '电表 2', 'f0851ee0ebb', NULL, false, 3, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2024-10-10 20:35:06', '1', '2025-07-05 01:58:13', 1),
    (7, '温湿度V1', 'dcba9928e37', NULL, false, 3, NULL, NULL, '温湿度产品', 0, 0, 0, 'mqtt', 'json', '1', '2024-11-24 17:20:47', '1', '2025-07-05 01:58:13', 0),
    (8, '插座', 'zXXHolcC2Hfxd7I1', NULL, false, 13, 'http://test.yudao.iocoder.cn/e71669a0c827bbb96b3e320b6ed19a9fd3d53027833f880fc38a010cac2a2eff.png', 'http://test.yudao.iocoder.cn/3f55f6955a5d453688eef75c66641fdf66e163de250d93124a2746385f1504a6.jpeg', '我是描述！', 1, 2, 0, 'mqtt', 'json', '1', '2024-12-07 19:41:23', '1', '2025-11-24 19:30:32', 0),
    (9, 'ZGW01', 'PHg5XcqNfDt4tk3p', NULL, false, 10, NULL, 'http://test.yudao.iocoder.cn/3f2a1f61740b56b3e532412b52890a2d4cf29742cfd4ec64969e29844472103c.jpg', NULL, 1, 2, 0, 'mqtt', 'json', '1', '2024-12-14 12:04:03', '1', '2025-11-24 19:30:29', 0),
    (10, '小爱同学', 'YzvHxd4r67sT4s2B', NULL, false, 10, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-14 13:33:53', '1', '2025-11-24 19:30:25', 0),
    (11, '插座', 'jAufEMTF1W6wnPhn', NULL, false, 13, NULL, NULL, NULL, 1, 1, 0, 'mqtt', 'json', '1', '2024-12-14 15:59:14', '1', '2026-01-24 22:20:26', 0),
    (12, '超长的ProductKey', 'CJVS54fObwZJ9Qe5CJVS54fObwZJ9Qe5', NULL, false, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-16 13:38:44', '1', '2025-11-24 19:30:20', 0),
    (13, '好好长的productkey', 'wSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgFwSmfNFlmUBfBPOgF', NULL, false, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-16 14:06:38', '1', '2025-11-24 19:30:18', 0),
    (14, '测试产品1', 'hBtBtQC6ULI4ewBZ', NULL, false, 5, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-26 12:57:21', '1', '2026-02-14 09:08:29', 0),
    (15, '2222', 'efCs2ruTcmchWF61', NULL, false, 4, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2024-12-30 21:12:10', '1', '2025-11-24 19:30:13', 0),
    (16, '智能马桶', '4aymZgOTOOCrDKRT', 'test-product-secret', true, 14, NULL, NULL, NULL, 1, 0, 0, 'mqtt', 'json', '1', '2025-01-24 14:10:56', '1', '2026-02-13 17:21:34', 0),
    (17, '温度感应器', 'fqTn4Afs982Nak4N', NULL, false, 4, NULL, NULL, NULL, 1, 0, 1, 'mqtt', 'json', '1', '2025-02-26 10:58:41', '1', '2025-11-24 19:30:06', 0),
    (18, 'modbus-tcp 轮询设备', 'KFhmQZjv6vyWJALA', NULL, false, 4, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2026-01-17 18:57:38', '1', '2026-01-17 18:57:43', 1),
    (19, 'modbus 产品', 'FrRHlBZJfU7yVSMl', NULL, false, 4, NULL, NULL, NULL, 0, 0, 0, 'mqtt', 'json', '1', '2026-01-17 19:00:49', '1', '2026-01-17 19:01:15', 1),
    (20, 'modbus-tcp 产品示例', 'modbus-tcp-demo', NULL, false, 4, NULL, NULL, NULL, 0, 0, 0, 'modbus_tcp_client', 'json', '1', '2026-01-17 19:01:45', '1', '2026-02-12 23:23:51', 1),
    (21, 'w我是网关噢', 'm6XcS1ZJ3TW8eC0v', 'abac', true, 4, NULL, NULL, NULL, 1, 2, 0, 'mqtt', 'json', '1', '2026-01-22 00:44:54', '1', '2026-01-25 08:30:00', 0),
    (22, 'Modbus TCP Client 产品示例', 'modbus_tcp_client_product_demo', '36ab002f28e841febff8551963a09731', false, 15, NULL, NULL, NULL, 1, 0, 0, 'modbus_tcp_client', 'json', '1', '2026-02-08 18:32:43', '1', '2026-02-12 23:23:03', 0),
    (23, 'Modbus TCP Server 产品示例', 'modbus_tcp_server_product_demo', 'ac1e6aac73c3424a84624dd0dd9d3fa5', false, 14, NULL, NULL, NULL, 1, 0, 0, 'modbus_tcp_server', 'json', '1', '2026-02-08 18:35:23', '1', '2026-02-12 23:22:57', 0)
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
    id, device_name, nickname, serial_number, pic_url, group_ids, product_id, product_key, device_type, gateway_id, state, online_time, offline_time, active_time, firmware_id, device_secret, latitude, longitude, config, creator, create_time, updater, update_time, deleted
) VALUES
    (6, '0010', '电表家里2', NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '705580aaafbd45d2aa0dd74fd3d1b1b2', NULL, NULL, NULL, '1', '2024-09-21 20:17:28', '1', '2025-07-05 02:01:18', 1),
    (8, 'dianbiao1', '智能电表1', NULL, NULL, '16', 5, 'f13f57c63e9', 0, NULL, 1, '2025-03-08 21:41:50', '2025-03-08 21:41:43', '2024-10-31 21:43:55', NULL, '38a357dd4997418e822b1c679a5dd448', NULL, NULL, NULL, '1', '2024-10-27 10:33:22', '', '2025-07-05 02:01:18', 0),
    (9, 'new-123', NULL, NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, 1, '33dc27fd54be4d0e871b8acdc7335c7f', NULL, NULL, NULL, '1', '2024-12-06 09:38:06', '1', '2025-07-05 02:01:18', 0),
    (10, 'test333', NULL, NULL, NULL, '16,17', 10, 'YzvHxd4r67sT4s2B', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f0fc32eab0244d169368ddf5adc03366', NULL, NULL, NULL, '1', '2024-12-14 13:34:08', '1', '2025-07-05 02:01:18', 0),
    (11, 'AA:BB', NULL, NULL, NULL, '17', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '805c69c341e2472fb23ec24c0afbeb94', NULL, NULL, NULL, '1', '2024-12-14 15:55:26', '1', '2025-07-05 02:01:18', 0),
    (12, 'gateway110', NULL, NULL, NULL, '17', 9, 'PHg5XcqNfDt4tk3p', 2, NULL, 0, NULL, NULL, NULL, NULL, '0fba9833cead44a8ac743bc273f596a0', NULL, NULL, NULL, '1', '2024-12-14 15:58:28', '1', '2025-07-05 02:01:18', 0),
    (13, 'biubiu', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, 12, 0, NULL, NULL, NULL, NULL, 'e03dff4f4b2f487b9c8febb40d643c94', NULL, NULL, NULL, '1', '2024-12-14 16:01:13', '1', '2025-07-05 02:01:18', 0),
    (14, 'test01', NULL, NULL, NULL, '', 9, 'PHg5XcqNfDt4tk3p', 2, NULL, 0, NULL, NULL, NULL, NULL, '4efe0f34fddc4e978b336f0f851923b3', NULL, NULL, NULL, '1', '2024-12-14 19:09:55', '1', '2025-07-05 02:01:18', 1),
    (15, '温度传感器001', NULL, NULL, NULL, '16,17', 4, '1de24640dfe', 0, 12, 0, NULL, NULL, NULL, NULL, '2d92c51a52ec470d8f09ca410a5983b3', NULL, NULL, NULL, '1', '2024-12-15 10:45:47', '1', '2025-07-05 02:01:18', 0),
    (16, 'abc_45', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '88d121a0da9d4ea58cc48bcdeef6313e', NULL, NULL, NULL, '1', '2024-12-16 13:31:29', '1', '2025-07-05 02:01:18', 0),
    (17, 'acb-sdsd', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '5ac8a92454d946539dc4e8a52a61e6c8', NULL, NULL, NULL, '1', '2024-12-16 13:32:31', '1', '2025-07-05 02:01:18', 0),
    (18, 'dsad', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 0, NULL, NULL, NULL, NULL, '506bef8827a1468d921eeab356938f15', NULL, NULL, NULL, '1', '2024-12-16 13:33:06', '1', '2025-07-05 02:01:18', 1),
    (19, 'ssss', NULL, NULL, NULL, '', 12, 'CJVS54fObwZJ9Qe5CJVS54fObwZJ9Qe5', 0, NULL, 0, NULL, NULL, NULL, NULL, '7609964cfa844ee68d1288b35de25b97', NULL, NULL, NULL, '1', '2024-12-16 13:57:16', '1', '2025-07-05 02:01:18', 0),
    (20, '545465464', NULL, NULL, NULL, '', 5, 'f13f57c63e9', 0, NULL, 0, NULL, NULL, NULL, NULL, 'd2776a58bdc6422ea5d48ca502eb1782', NULL, NULL, NULL, '1', '2024-12-30 21:33:06', '1', '2025-07-05 02:01:18', 1),
    (21, 'fjb_001', NULL, NULL, NULL, '', 15, 'efCs2ruTcmchWF61', 0, NULL, 1, '2025-02-20 16:55:20', NULL, '2025-02-20 16:55:20', NULL, 'cbd9a823c53644e4bffe163cdb0075dc', NULL, NULL, NULL, '1', '2024-12-31 16:56:40', '', '2025-07-05 02:01:18', 0),
    (22, 'testtest', NULL, NULL, NULL, '', 15, 'efCs2ruTcmchWF61', 0, NULL, 1, '2025-02-20 16:53:33', '2025-02-20 16:53:32', '2025-02-20 16:53:32', NULL, '03e224e5dfb042ddb367fb632b542cc9', NULL, NULL, NULL, '1', '2025-01-24 14:05:01', '1', '2025-07-05 02:01:18', 0),
    (23, 'bintest', NULL, NULL, NULL, '', 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, '2025-01-24 14:20:19', NULL, '2025-01-24 14:20:19', NULL, '66cd0ab9f4fb43e99d1fd965dad263db', '39.912344', '116.381003', NULL, '1', '2025-01-24 14:13:13', '1', '2026-01-21 13:22:07', 0),
    (24, 'kejie', NULL, NULL, NULL, '', 4, '1de24640dfe', 0, NULL, 1, '2025-02-20 16:53:44', NULL, '2025-01-29 11:09:55', NULL, '1625a3918ae7498ba616124d987ae923', NULL, NULL, '{"abc":"efgee"}', '1', '2025-01-27 13:47:22', '1', '2025-07-05 02:01:18', 0),
    (25, 'small', '12345', NULL, NULL, '', 16, '4aymZgOTOOCrDKRT', 0, NULL, 1, '2026-02-13 18:12:25', '2026-02-12 18:05:21', '2025-01-29 11:25:43', 2, '0baa4c2ecc104ae1a26b4070c218bdf3', '2.000000', '1.000000', 'null', '1', '2025-01-27 16:37:08', '', '2026-02-13 18:12:25', 0),
    (27, 'a', 'dylan''s device', NULL, NULL, NULL, 11, 'jAufEMTF1W6wnPhn', 1, 12, 1, '2025-02-21 09:03:44', NULL, '2025-02-21 09:03:44', NULL, '9dbc3808b9634894bf8c31fb471ae795', NULL, NULL, '{"abc":"123"}', '', '2025-02-08 20:50:04', '1', '2025-07-05 02:01:18', 0),
    (28, 'jiali001', '家里001', '000001', NULL, '17', 7, 'dcba9928e37', 0, NULL, 1, '2025-03-15 16:38:28', NULL, '2025-03-15 16:38:28', NULL, '4f32b188da644e99b055544376dbecaf', NULL, NULL, NULL, '1', '2025-03-15 16:37:44', '1', '2025-07-05 02:01:18', 1),
    (29, 'jiali001', '家里001', '000001', NULL, '17', 17, 'fqTn4Afs982Nak4N', 0, NULL, 1, '2025-03-15 17:52:21', '2025-03-15 17:52:16', '2025-03-15 17:10:12', NULL, '0ee694bbc2674fe78584f198195acb70', NULL, NULL, '{"xx":"yy","qq":2}', '1', '2025-03-15 16:39:40', '1', '2025-07-05 02:01:18', 0),
    (30, 'demo01', NULL, NULL, NULL, '', 20, 'modbus-tcp-demo', 0, NULL, 1, '2026-02-08 22:44:39', NULL, '2026-01-17 23:33:44', NULL, '1e0f6e168c024d0392dc96ec2f8d6ba7', '41.231395', '124.610078', NULL, '1', '2026-01-17 19:02:39', '1', '2026-02-08 22:45:15', 1),
    (31, 'sub-ddd', NULL, NULL, NULL, '', 21, 'm6XcS1ZJ3TW8eC0v', 2, NULL, 1, '2026-02-03 14:45:50', '2026-02-01 03:32:41', '2026-01-24 21:37:59', NULL, 'b3d62c70f8a4495487ed1d35d61ac2b3', NULL, NULL, '{"v1":1,"v2":"2"}', '1', '2026-01-22 00:45:54', '1', '2026-02-10 17:05:59', 0),
    (32, 'chazuo', NULL, NULL, NULL, '', 8, 'zXXHolcC2Hfxd7I1', 2, NULL, 0, NULL, NULL, NULL, NULL, '84bf90591a59412c9b88a754d548a5b2', NULL, NULL, NULL, '1', '2026-01-22 00:47:20', '1', '2026-01-22 00:47:38', 1),
    (33, 'chazuo-it', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, 31, 2, '2026-01-25 22:11:36', '2026-01-27 00:04:40', '2026-01-24 22:23:23', NULL, 'd46ef9b28ab14238b9c00a3a668032af', NULL, NULL, NULL, '1', '2026-01-22 00:48:06', '', '2026-02-03 14:45:50', 0),
    (34, 'test-1769330415908', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '769886d9e3f94d9caec2289a6dcb756b', NULL, NULL, NULL, '', '2026-01-25 16:40:16', '', '2026-01-25 16:40:16', 0),
    (35, 'balabala', NULL, NULL, NULL, '', 21, 'm6XcS1ZJ3TW8eC0v', 2, NULL, 0, NULL, NULL, NULL, NULL, '55ff23cac303448ab74b048ede1efada', NULL, NULL, NULL, '1', '2026-01-25 16:41:30', '1', '2026-01-25 16:41:39', 1),
    (36, 'mougezishebei', NULL, NULL, NULL, '', 11, 'jAufEMTF1W6wnPhn', 1, NULL, 0, NULL, NULL, NULL, NULL, 'dd0a1e710bbe4a57b8aa1faf8767e8d5', NULL, NULL, NULL, '1', '2026-01-25 16:42:00', '', '2026-02-12 03:20:38', 0),
    (37, 'test-1769340407229', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f9f1a4573a9a4476a8544901a60bbc13', NULL, NULL, NULL, '', '2026-01-25 19:26:47', '1', '2026-02-07 22:44:01', 1),
    (38, 'test-1769343854384', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'a0df41f6e5144105826a5ddb331a456e', NULL, NULL, NULL, '', '2026-01-25 20:24:14', '1', '2026-02-07 22:44:01', 1),
    (39, 'test-1769401423394', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '3adaaba3faeb49749fcfe6c8d60b82de', NULL, NULL, NULL, '', '2026-01-26 12:23:44', '1', '2026-02-07 22:44:01', 1),
    (40, 'test-tcp-1769434285110', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'a16a4f73a57d40bb96ee4eca1b0d3a1c', NULL, NULL, NULL, '', '2026-01-26 21:31:25', '1', '2026-02-07 22:43:51', 1),
    (41, 'test-mqtt-1769442101041', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'f6c621937a694ba9acfd1b6b0af4f66b', NULL, NULL, NULL, '', '2026-01-26 23:41:41', '1', '2026-02-07 22:43:51', 1),
    (42, 'test-ws-1769494399710', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '445b9aaf49f94ba39b51905ae785d535', NULL, NULL, NULL, '', '2026-01-27 14:13:20', '1', '2026-02-07 22:43:51', 1),
    (43, 'test-tcp-1769886358277', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '2c32c90904624ff0aed2d8d571079c35', NULL, NULL, NULL, '', '2026-02-01 03:05:59', '1', '2026-02-07 22:43:51', 1),
    (44, 'test-udp-1769920415009', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '051d50750e4b491798c9673b365d963e', NULL, NULL, NULL, '', '2026-02-01 12:33:35', '1', '2026-02-07 22:43:51', 1),
    (45, 'test-mqtt-1769953732108', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '383062f8ee1242589db8031897017890', NULL, NULL, NULL, '', '2026-02-01 21:48:52', '1', '2026-02-07 22:43:51', 1),
    (46, 'test-mqtt-1769954867274', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '098e2a73ec384aa4bfaeaa79060738c4', NULL, NULL, NULL, '', '2026-02-01 22:07:47', '1', '2026-02-07 22:43:51', 1),
    (47, 'test-mqtt-1769954899502', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '9d20b716fcf944ac9dd09981d6e9672b', NULL, NULL, NULL, '', '2026-02-01 22:08:20', '1', '2026-02-07 22:43:51', 1),
    (48, 'test-1769964550851', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b2a679a02f6545c0981e1b82240f02c5', NULL, NULL, NULL, '', '2026-02-02 00:49:11', '1', '2026-02-07 22:43:51', 1),
    (49, 'test-mqtt-1769992401585', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b809c291a7aa472193d41e41ab2eabb3', NULL, NULL, NULL, '', '2026-02-02 08:33:22', '1', '2026-02-07 22:43:51', 1),
    (50, 'test-mqtt-1769995250899', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '5eacb5c8621145f5b33eb12206b7a4a5', NULL, NULL, NULL, '', '2026-02-02 09:20:51', '1', '2026-02-07 22:43:40', 1),
    (51, 'test-mqtt-1770124854510', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '4ade777003984ea4a961d8b47a7873f4', NULL, NULL, NULL, '', '2026-02-03 21:21:03', '1', '2026-02-07 22:43:40', 1),
    (52, 'test-mqtt-1770124954448', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7d20d53a11554fca8ebc060c9dddda95', NULL, NULL, NULL, '', '2026-02-03 21:22:35', '1', '2026-02-07 22:43:40', 1),
    (53, 'test-mqtt-1770124982510', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7616744b523f439585a0c692f0a9cdde', NULL, NULL, NULL, '', '2026-02-03 21:23:03', '1', '2026-02-07 22:43:40', 1),
    (54, 'test-mqtt-1770125063868', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'e7d126c56d47415c919d0e4374c182fb', NULL, NULL, NULL, '', '2026-02-03 21:24:24', '1', '2026-02-07 22:43:40', 1),
    (55, 'test-mqtt-1770125100373', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '02e090c953df4df4a0a02413414019e8', NULL, NULL, NULL, '', '2026-02-03 21:25:01', '1', '2026-02-07 22:43:40', 1),
    (56, 'test-mqtt-1770125122216', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '45efb3a3fe5348919b5786da7c06eb9d', NULL, NULL, NULL, '', '2026-02-03 21:25:22', '1', '2026-02-07 22:43:40', 1),
    (57, 'test-mqtt-1770125245610', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'b0695f54e0f04d83bace7ce354cb9019', NULL, NULL, NULL, '', '2026-02-03 21:27:26', '1', '2026-02-07 22:43:40', 1),
    (58, 'test-mqtt-1770125319161', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '781d53c6343d4563919bfc2d5705cfad', NULL, NULL, NULL, '', '2026-02-03 21:28:39', '1', '2026-02-07 22:43:40', 1),
    (59, 'test-mqtt-1770125330577', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'affcdb056dd741fb8b24cb83d7a4c092', NULL, NULL, NULL, '', '2026-02-03 21:28:51', '1', '2026-02-07 22:43:40', 1),
    (60, 'test-mqtt-1770125353810', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'ef11da7b1c5b4552bf61dd49394ebe07', NULL, NULL, NULL, '', '2026-02-03 21:29:14', '1', '2026-02-07 22:43:32', 1),
    (61, 'test-mqtt-1770125578091', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:33:08', NULL, NULL, '58a4504d5a34432e8f29cd82c134928e', NULL, NULL, NULL, '', '2026-02-03 21:32:58', '1', '2026-02-07 22:43:32', 1),
    (62, 'test-mqtt-1770126059698', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:41:10', NULL, NULL, '355847fe96ad4b439707c3f8b22595ad', NULL, NULL, NULL, '', '2026-02-03 21:41:00', '1', '2026-02-07 22:43:32', 1),
    (63, 'test-mqtt-1770126122260', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:42:13', NULL, NULL, '3a591a25d2494e86bfc734cd6e509a00', NULL, NULL, NULL, '', '2026-02-03 21:42:02', '1', '2026-02-07 22:43:32', 1),
    (64, 'test-mqtt-1770126147054', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:42:43', NULL, NULL, 'a743b944893b422f8177fe5aef2146d4', NULL, NULL, NULL, '', '2026-02-03 21:42:27', '1', '2026-02-07 22:43:15', 1),
    (65, 'test-mqtt-1770126193247', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:43:20', NULL, NULL, '09097fb7e59f4094bad45fed7e58cad3', NULL, NULL, NULL, '', '2026-02-03 21:43:13', '1', '2026-02-07 22:43:32', 1),
    (66, 'test-mqtt-1770126311268', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:45:22', NULL, NULL, '9964a178d62a4ab18547f203fc9346cf', NULL, NULL, NULL, '', '2026-02-03 21:45:11', '1', '2026-02-07 22:43:20', 1),
    (67, 'test-mqtt-1770126399974', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:46:50', NULL, NULL, '5789ea6022ef4eae80775856798e0cba', NULL, NULL, NULL, '', '2026-02-03 21:46:40', '1', '2026-02-07 22:43:18', 1),
    (68, 'test-mqtt-1770126468584', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:48:06', NULL, NULL, '901a89de80cf457091026ba5836c6db4', NULL, NULL, NULL, '', '2026-02-03 21:47:49', '1', '2026-02-07 22:43:16', 1),
    (69, 'test-mqtt-1770126608484', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:51:59', NULL, NULL, '983f5d1984db41118e235da7e5f45929', NULL, NULL, NULL, '', '2026-02-03 21:50:09', '1', '2026-02-07 22:43:32', 1),
    (70, 'test-mqtt-1770126698661', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'e1db93d726e044389da7588e47c3b409', NULL, NULL, NULL, '', '2026-02-03 21:51:59', '1', '2026-02-07 22:43:32', 1),
    (71, 'test-mqtt-1770126722283', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:52:21', NULL, NULL, '4bb765177cd24edd94fe3a70a13fb189', NULL, NULL, NULL, '', '2026-02-03 21:52:03', '1', '2026-02-07 22:43:32', 1),
    (72, 'test-mqtt-1770127068400', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 21:58:16', NULL, NULL, '3537ea77b75a4c499f2eb4a908bd194a', NULL, NULL, NULL, '', '2026-02-03 21:57:49', '1', '2026-02-07 22:43:32', 1),
    (73, 'test-mqtt-1770127097453', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '2ff1dfc320a5467dbbd45b6b1896da11', NULL, NULL, NULL, '', '2026-02-03 21:58:18', '1', '2026-02-07 22:43:32', 1),
    (74, 'test-mqtt-1770127158718', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:00:04', NULL, NULL, '78537a8d1ea2466dbdb153bc92d56076', NULL, NULL, NULL, '', '2026-02-03 21:59:19', '1', '2026-02-07 22:43:10', 1),
    (75, 'test-mqtt-1770127207087', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:00:25', NULL, NULL, '7497af4af6b2492b979a6447d58aea56', NULL, NULL, NULL, '', '2026-02-03 22:00:07', '1', '2026-02-07 22:43:08', 1),
    (76, 'test-mqtt-1770127251247', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, NULL, '2026-02-03 22:01:02', NULL, NULL, '68aa8cbfd812426cae596e3021a6a94e', NULL, NULL, NULL, '', '2026-02-03 22:00:51', '1', '2026-02-07 22:43:06', 1),
    (77, 'test-mqtt-1770128309033', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 2, '2026-02-03 22:18:29', '2026-02-03 22:18:34', '2026-02-03 22:18:29', NULL, 'dc2073e4ea474ebfb3d0057582bcf824', NULL, NULL, NULL, '', '2026-02-03 22:18:29', '1', '2026-02-07 22:43:02', 1),
    (78, 'test-mqtt-1770128811425', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, 'd708cdc5c4c948c08ebfa7accc39e46f', NULL, NULL, NULL, '', '2026-02-03 22:26:52', '1', '2026-02-07 22:43:00', 1),
    (79, 'test-mqtt-1770165480031', NULL, NULL, NULL, NULL, 16, '4aymZgOTOOCrDKRT', 0, NULL, 0, NULL, NULL, NULL, NULL, '7a5717fc427b43eaa2577c449d2dac26', NULL, NULL, NULL, '', '2026-02-04 08:38:00', '1', '2026-02-07 22:42:57', 1),
    (80, 'modbus_tcp_server_device_demo_tcp', NULL, NULL, NULL, '', 23, 'modbus_tcp_server_product_demo', 0, NULL, 2, '2026-02-13 15:00:48', '2026-02-13 15:04:08', '2026-02-08 20:45:13', NULL, '8e4adeb3d25342ab88643421d3fba3f6', NULL, NULL, NULL, '1', '2026-02-08 20:19:23', '', '2026-02-13 15:04:08', 0),
    (81, 'modbus_tcp_server_device_demo_rtu', NULL, NULL, NULL, '', 23, 'modbus_tcp_server_product_demo', 0, NULL, 1, '2026-02-12 23:30:03', '2026-02-12 23:29:58', '2026-02-08 22:32:29', NULL, 'af01c55eb8e3424bb23fc6c783936b2e', NULL, NULL, NULL, '1', '2026-02-08 21:41:02', '', '2026-02-12 23:30:03', 0),
    (82, 'modbus_tcp_client_device_demo', NULL, NULL, NULL, '', 22, 'modbus_tcp_client_product_demo', 0, NULL, 1, '2026-02-13 11:34:01', NULL, '2026-02-08 22:46:07', NULL, 'a2f713affc6d4910a49c663e83c42c63', NULL, NULL, NULL, '1', '2026-02-08 21:42:38', '', '2026-02-13 11:34:01', 0)
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
    id, identifier, name, description, product_id, product_key, type, property, event, service, creator, create_time, updater, update_time, deleted
) VALUES
    (80, 'close', '关闭插座', NULL, 11, 'jAufEMTF1W6wnPhn', 2, NULL, NULL, '{"name": "关闭插座", "method": null, "callType": "sync", "required": null, "identifier": "close", "inputParams": [{"name": "开关状态", "dataType": "bool", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "status", "dataSpecsList": [{"name": "关", "value": 0, "dataType": "bool"}, {"name": "开", "value": 1, "dataType": "bool"}]}], "outputParams": [{"name": "开关状态", "dataType": "bool", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "status", "dataSpecsList": [{"name": "关", "value": 0, "dataType": "bool"}, {"name": "开", "value": 1, "dataType": "bool"}]}]}', '1', '2024-12-26 14:45:17', '1', '2024-12-27 11:35:32', 0),
    (81, 'power', '电流功率', NULL, 11, 'jAufEMTF1W6wnPhn', 1, '{"name": "电流功率", "dataType": "int", "required": null, "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "accessMode": "r", "identifier": "power", "dataSpecsList": null}', NULL, NULL, '1', '2024-12-26 14:49:12', '1', '2024-12-26 14:49:12', 0),
    (82, 'post', '属性上报', '属性上报事件', 11, 'jAufEMTF1W6wnPhn', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}]}', NULL, '1', '2024-12-26 14:49:13', '1', '2025-06-29 15:36:59', 1),
    (83, 'get', '属性获取', '属性获取服务', 11, 'jAufEMTF1W6wnPhn', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}], "outputParams": [{"name": "电流功率", "dataType": "int", "dataSpecs": {"max": "1200", "min": "0", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "power", "dataSpecsList": null}]}', '1', '2024-12-26 14:49:13', '1', '2025-06-29 15:37:01', 1),
    (84, 'soul', '加热', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "加热", "dataType": "int", "required": null, "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "accessMode": "rw", "identifier": "soul", "dataSpecsList": null}', NULL, NULL, '1', '2024-12-31 16:22:15', '1', '2025-01-03 13:38:31', 0),
    (85, 'post', '属性上报', '属性上报事件', 15, 'efCs2ruTcmchWF61', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "output", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}]}', NULL, '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0),
    (86, 'set', '属性设置', '属性设置服务', 15, 'efCs2ruTcmchWF61', 2, NULL, NULL, '{"name": "属性设置", "method": "thing.service.property.set", "callType": "async", "required": null, "identifier": "set", "inputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "input", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}], "outputParams": []}', '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0),
    (87, 'get', '属性获取', '属性获取服务', 15, 'efCs2ruTcmchWF61', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "input", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "input", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}], "outputParams": [{"name": "加热", "dataType": "int", "dataSpecs": {"max": "99", "min": "0", "step": "2", "unit": "W/㎡", "precise": null, "dataType": "int", "unitName": "太阳总辐射", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "soul", "dataSpecsList": null}, {"name": "属性test0", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "property_test0", "dataSpecsList": null}, {"name": "时间", "dataType": "date", "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "times", "dataSpecsList": null}, {"name": "结构体", "dataType": "struct", "dataSpecs": null, "direction": "output", "paraOrder": 0, "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}, {"name": "队列", "dataType": "array", "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "direction": "output", "paraOrder": 0, "identifier": "array", "dataSpecsList": null}]}', '1', '2024-12-31 16:22:15', '1', '2025-02-20 16:58:35', 0),
    (88, '5A_test', '5a服务', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 2, NULL, NULL, '{"name": "5a服务", "method": null, "callType": "async", "required": null, "identifier": "5A_test", "inputParams": null, "outputParams": null}', '1', '2025-01-01 16:49:22', '1', '2025-01-01 16:49:22', 0),
    (89, 'property_test0', '属性test0', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "属性test0", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "accessMode": "rw", "identifier": "property_test0", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-01 16:58:23', '1', '2025-01-01 16:58:23', 0),
    (90, 'event_test0', 'Event_test0', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 3, NULL, '{"name": "Event_test0", "type": "info", "method": null, "required": null, "identifier": "event_test0", "outputParams": null}', NULL, '1', '2025-01-01 16:59:05', '1', '2025-01-01 16:59:05', 0),
    (91, 'times', '时间', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "时间", "dataType": "date", "required": null, "dataSpecs": {"length": null, "dataType": "text", "defaultValue": null}, "accessMode": "rw", "identifier": "times", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-03 20:21:09', '1', '2025-01-03 20:21:09', 0),
    (92, 'struct', '结构体', NULL, 15, 'efCs2ruTcmchWF61', 1, '{"name": "结构体", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "struct", "dataSpecsList": [{"name": "2", "dataType": "struct", "required": null, "dataSpecs": {"max": "2222", "min": "22", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "2dede", "childDataType": "float", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-01-03 20:21:30', '1', '2025-02-20 16:58:35', 0),
    (93, 'array', '队列', NULL, 15, 'efCs2ruTcmchWF610000000000000000000000000000000000000', 1, '{"name": "队列", "dataType": "array", "required": null, "dataSpecs": {"size": 5, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "accessMode": "rw", "identifier": "array", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-03 20:21:58', '1', '2025-01-03 20:21:58', 0),
    (94, 'water', '出水量', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "出水量", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "accessMode": "rw", "identifier": "water", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-24 14:11:37', '1', '2025-01-24 14:11:37', 0),
    (95, 'post', '属性上报', '属性上报事件', 16, '4aymZgOTOOCrDKRT', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}]}', NULL, '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:11:00', 1),
    (96, 'set', '属性设置', '属性设置服务', 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "属性设置", "method": "thing.service.property.set", "callType": "async", "required": null, "identifier": "set", "inputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}], "outputParams": []}', '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:10:58', 1),
    (97, 'get', '属性获取', '属性获取服务', 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}], "outputParams": [{"name": "出水量", "dataType": "int", "dataSpecs": {"max": "100", "min": "0", "step": "1", "unit": "var", "precise": null, "dataType": "int", "unitName": "乏", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "water", "dataSpecsList": null}, {"name": "高度", "dataType": "int", "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "height", "dataSpecsList": null}, {"name": "宽度", "dataType": "int", "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "width", "dataSpecsList": null}, {"name": "一二", "dataType": "int", "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "onetwo", "dataSpecsList": null}, {"name": "一三", "dataType": "int", "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "oneThree", "dataSpecsList": null}]}', '1', '2025-01-24 14:11:37', '1', '2025-06-29 16:10:56', 1),
    (98, 'height', '高度', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "10", "step": "1", "unit": "cm", "precise": null, "dataType": "int", "unitName": "厘米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-27 16:36:04', '1', '2025-01-27 16:36:04', 0),
    (99, 'width', '宽度', '132', 16, '4aymZgOTOOCrDKRT', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "20", "step": "1", "unit": "mm", "precise": null, "dataType": "int", "unitName": "毫米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-27 16:36:32', '1', '2025-01-27 22:22:40', 0),
    (100, 'onetwo', '一二', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "一二", "dataType": "int", "required": null, "dataSpecs": {"max": "1000", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": "rw", "identifier": "onetwo", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-28 22:57:42', '1', '2025-01-28 22:57:42', 0),
    (101, 'oneThree', '一三', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "一三", "dataType": "int", "required": null, "dataSpecs": {"max": "5", "min": "1", "step": "2", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": "rw", "identifier": "oneThree", "dataSpecsList": null}', NULL, NULL, '1', '2025-01-28 23:03:17', '1', '2025-01-28 23:03:17', 0),
    (102, 'kwhp', '正向有功电能', NULL, 5, 'f13f57c63e9', 1, '{"name": "正向有功电能", "dataType": "double", "required": null, "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "accessMode": "r", "identifier": "kwhp", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0),
    (103, 'post', '属性上报', '属性上报事件', 5, 'f13f57c63e9', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}]}', NULL, '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0),
    (104, 'get', '属性获取', '属性获取服务', 5, 'f13f57c63e9', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}], "outputParams": [{"name": "正向有功电能", "dataType": "double", "dataSpecs": {"max": "1000000000", "min": "-1000000000", "step": "1", "unit": "kW·h", "precise": null, "dataType": "int", "unitName": "千瓦时", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "kwhp", "dataSpecsList": null}]}', '1', '2025-03-03 21:44:12', '1', '2025-03-03 21:44:12', 0),
    (105, 'temperature', '温度', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "温度", "dataType": "double", "required": null, "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "accessMode": "r", "identifier": "temperature", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:32:09', 0),
    (106, 'post', '属性上报', '属性上报事件', 17, 'fqTn4Afs982Nak4N', 3, NULL, '{"name": "属性上报", "type": "info", "method": "thing.event.property.post", "required": null, "identifier": "post", "outputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}]}', NULL, '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:33:53', 0),
    (107, 'get', '属性获取', '属性获取服务', 17, 'fqTn4Afs982Nak4N', 2, NULL, NULL, '{"name": "属性获取", "method": "thing.service.property.get", "callType": "async", "required": null, "identifier": "get", "inputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}], "outputParams": [{"name": "温度", "dataType": "double", "dataSpecs": {"max": "85", "min": "-40", "step": "0.1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "temperature", "dataSpecsList": null}, {"name": "湿度", "dataType": "double", "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "humidity", "dataSpecsList": null}]}', '1', '2025-03-15 16:32:09', '1', '2025-03-15 16:33:53', 0),
    (108, 'humidity', '湿度', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "湿度", "dataType": "double", "required": null, "dataSpecs": {"max": "100", "min": "0", "step": "0.1", "unit": "%", "precise": null, "dataType": "int", "unitName": "百分比", "defaultValue": null}, "accessMode": "r", "identifier": "humidity", "dataSpecsList": null}', NULL, NULL, '1', '2025-03-15 16:33:53', '1', '2025-03-15 16:33:53', 0),
    (109, 'eat', '吃饭', NULL, 16, '4aymZgOTOOCrDKRT', 3, NULL, '{"name": "吃饭", "type": "info", "method": null, "required": null, "identifier": "eat", "outputParams": [{"name": "米", "dataType": "int", "dataSpecs": {"max": "10", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "rice", "dataSpecsList": null}]}', NULL, '1', '2025-06-19 13:15:21', '1', '2025-06-19 13:15:21', 0),
    (110, 'u100', 'u100', NULL, 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "u100", "method": null, "callType": "async", "required": null, "identifier": "u100", "inputParams": [{"name": "a", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "a", "dataSpecsList": null}, {"name": "b", "dataType": "int", "dataSpecs": {"max": "100", "min": "50", "step": "20", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "b", "dataSpecsList": null}], "outputParams": [{"name": "r1", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "dS/m", "precise": null, "dataType": "int", "unitName": "土壤EC值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "r1", "dataSpecsList": null}, {"name": "r2", "dataType": "int", "dataSpecs": {"max": "30", "min": "20", "step": "5", "unit": "dS/m", "precise": null, "dataType": "int", "unitName": "土壤EC值", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "r2", "dataSpecsList": null}]}', '1', '2025-06-21 15:18:58', '1', '2025-06-21 15:18:58', 0),
    (111, 'demo', 'demo', NULL, 17, 'fqTn4Afs982Nak4N', 1, '{"name": "demo", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "demo", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "b", "dataType": "struct", "required": null, "dataSpecs": {"max": "50", "min": "20", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "b", "childDataType": "int", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-06-29 15:45:11', '"1"', '2025-06-29 15:45:55', 0),
    (112, 'demo_json', 'demo_json', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_json", "dataType": "struct", "required": null, "dataSpecs": null, "accessMode": "rw", "identifier": "demo_json", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "b", "dataType": "struct", "required": null, "dataSpecs": {"max": "100", "min": "50", "step": "30", "unit": "mg/kg", "precise": null, "dataType": "int", "unitName": "毫克每千克", "defaultValue": null}, "accessMode": null, "identifier": "b", "childDataType": "int", "dataSpecsList": null}]}', NULL, NULL, '1', '2025-06-29 16:11:40', '1', '2025-06-29 16:11:40', 0),
    (113, 'demo_array_int', 'demo_array_int', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_array_int", "dataType": "array", "required": null, "dataSpecs": {"size": 10, "dataType": "array", "childDataType": "int", "dataSpecsList": null}, "accessMode": "rw", "identifier": "demo_array_int", "dataSpecsList": null}', NULL, NULL, '1', '2025-06-29 16:31:31', '1', '2025-06-29 16:31:31', 0),
    (114, 'demo_array_json', 'demo_array_json', NULL, 16, '4aymZgOTOOCrDKRT', 1, '{"name": "demo_array_json", "dataType": "array", "required": null, "dataSpecs": {"size": 10, "dataType": "array", "childDataType": "struct", "dataSpecsList": [{"name": "a", "dataType": "struct", "required": null, "dataSpecs": {"max": "10", "min": "1", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "a", "childDataType": "int", "dataSpecsList": null}, {"name": "cc", "dataType": "struct", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "accessMode": null, "identifier": "cc", "childDataType": "int", "dataSpecsList": null}]}, "accessMode": "rw", "identifier": "demo_array_json", "dataSpecsList": null}', NULL, NULL, '1', '2025-06-29 16:32:02', '"1"', '2025-06-29 16:51:30', 0),
    (115, 'width', '宽度', NULL, 20, 'modbus-tcp-demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "1", "unit": "mm/s", "precise": null, "dataType": "int", "unitName": "毫米每秒", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-17 23:24:08', '1', '2026-01-17 23:24:08', 0),
    (116, 'height', '高度', NULL, 20, 'modbus-tcp-demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "1", "unit": "pH", "precise": null, "dataType": "int", "unitName": "PH值", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-17 23:24:26', '1', '2026-01-17 23:24:26', 0),
    (117, 'temperature', '温度', NULL, 21, 'm6XcS1ZJ3TW8eC0v', 1, '{"name": "温度", "dataType": "int", "required": null, "dataSpecs": {"max": "50", "min": "0", "step": "1", "unit": "°C", "precise": null, "dataType": "int", "unitName": "摄氏度", "defaultValue": null}, "accessMode": "rw", "identifier": "temperature", "dataSpecsList": null}', NULL, NULL, '1', '2026-01-24 22:15:21', '1', '2026-01-24 22:15:21', 0),
    (118, 'statusReport', '状态汇报', NULL, 21, 'm6XcS1ZJ3TW8eC0v', 3, NULL, '{"name": "状态汇报", "type": "info", "method": null, "required": null, "identifier": "statusReport", "outputParams": [{"name": "内容", "dataType": "text", "dataSpecs": {"length": 1000, "dataType": "text", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "message", "dataSpecsList": null}]}', NULL, '1', '2026-01-24 22:16:59', '1', '2026-01-24 22:16:59', 0),
    (119, 'healthCheck', '健康检查', NULL, 11, 'jAufEMTF1W6wnPhn', 3, NULL, '{"name": "健康检查", "type": "info", "method": null, "required": null, "identifier": "healthCheck", "outputParams": [{"name": "错误码", "dataType": "int", "dataSpecs": {"max": "500", "min": "0", "step": "1", "unit": "L/s", "precise": null, "dataType": "int", "unitName": "升每秒", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "errorCode", "dataSpecsList": null}]}', NULL, '1', '2026-01-24 22:20:24', '1', '2026-01-24 22:20:24', 0),
    (120, 'height', '高度', NULL, 22, 'modbus_tcp_master_product_demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "100", "min": "10", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:34:14', '1', '2026-02-08 18:34:14', 0),
    (121, 'width', '宽度', NULL, 22, 'modbus_tcp_master_product_demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:34:40', '1', '2026-02-08 18:34:40', 0),
    (122, 'height', '高度', NULL, 23, 'modbus_tcp_slave_product_demo', 1, '{"name": "高度", "dataType": "int", "required": null, "dataSpecs": {"max": "20", "min": "10", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "height", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:36:08', '1', '2026-02-08 18:36:08', 0),
    (123, 'width', '宽度', NULL, 23, 'modbus_tcp_slave_product_demo', 1, '{"name": "宽度", "dataType": "int", "required": null, "dataSpecs": {"max": "128", "min": "0", "step": "5", "unit": "m", "precise": null, "dataType": "int", "unitName": "米", "defaultValue": null}, "accessMode": "rw", "identifier": "width", "dataSpecsList": null}', NULL, NULL, '1', '2026-02-08 18:36:30', '1', '2026-02-08 18:36:30', 0),
    (124, 'test_scene_rule', '测试场景联动', NULL, 16, '4aymZgOTOOCrDKRT', 2, NULL, NULL, '{"name": "测试场景联动", "method": null, "callType": "async", "required": null, "identifier": "test_scene_rule", "inputParams": [{"name": "a", "dataType": "int", "dataSpecs": {"max": "20", "min": "10", "step": "1", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "a", "dataSpecsList": null}, {"name": "b", "dataType": "int", "dataSpecs": {"max": "100", "min": "5", "step": "50", "unit": "L/min", "precise": null, "dataType": "int", "unitName": "升每分钟", "defaultValue": null}, "direction": "input", "paraOrder": 0, "identifier": "b", "dataSpecsList": null}], "outputParams": [{"name": "sum", "dataType": "int", "dataSpecs": {"max": "5000", "min": "1000", "step": "50", "unit": "mg/kg", "precise": null, "dataType": "int", "unitName": "毫克每千克", "defaultValue": null}, "direction": "output", "paraOrder": 0, "identifier": "sum", "dataSpecsList": null}]}', '1', '2026-02-13 17:21:32', '1', '2026-02-13 17:21:32', 0)
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
SELECT setval('public.iot_product_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM public.iot_product), 1102), true);
SELECT setval('public.iot_device_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM public.iot_device), 2301), true);
SELECT setval('public.iot_thing_model_seq', GREATEST((SELECT COALESCE(MAX(id), 0) FROM public.iot_thing_model), 3431), true);

COMMIT;
