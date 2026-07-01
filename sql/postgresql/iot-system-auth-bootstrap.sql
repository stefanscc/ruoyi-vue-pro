-- IoT system auth bootstrap for ruoyi-vue-pro PostgreSQL
-- Prerequisites:
--   1. sql/postgresql/ruoyi-vue-pro.sql
--   2. sql/postgresql/iot-local-bootstrap.sql
--
-- Purpose:
--   - Create a minimal IoT admin menu tree in system_menu
--   - Create a dedicated IoT admin role in system_role
--   - Create a dedicated IoT admin user in system_users
--   - Grant the IoT menus to the IoT admin role
--   - Bind the IoT admin user to the IoT admin role
--
-- Default login:
--   username: iotadmin
--   password: admin123

BEGIN;

MERGE INTO public.system_menu AS t
USING (
    VALUES
        (6100::bigint, '物联网', ''::varchar, 1::smallint, 30::int, 0::bigint, '/iot'::varchar, 'ep:connection'::varchar, NULL::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6101::bigint, '产品管理', ''::varchar, 2::smallint, 1::int, 6100::bigint, 'product'::varchar, 'ep:box'::varchar, 'iot/product/index'::varchar, 'IotProduct'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6102::bigint, '设备管理', ''::varchar, 2::smallint, 2::int, 6100::bigint, 'device'::varchar, 'ep:cpu'::varchar, 'iot/device/index'::varchar, 'IotDevice'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6103::bigint, '物模型', ''::varchar, 2::smallint, 3::int, 6100::bigint, 'thing-model'::varchar, 'ep:files'::varchar, 'iot/thing-model/index'::varchar, 'IotThingModel'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6104::bigint, '数据转发', ''::varchar, 2::smallint, 4::int, 6100::bigint, 'data-sink'::varchar, 'ep:share'::varchar, 'iot/rule/data-sink/index'::varchar, 'IotDataSink'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6105::bigint, '数据规则', ''::varchar, 2::smallint, 5::int, 6100::bigint, 'data-rule'::varchar, 'ep:set-up'::varchar, 'iot/rule/data-rule/index'::varchar, 'IotDataRule'::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),

        (6111::bigint, '产品查询', 'iot:product:query'::varchar, 3::smallint, 1::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6112::bigint, '产品新增', 'iot:product:create'::varchar, 3::smallint, 2::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6113::bigint, '产品修改', 'iot:product:update'::varchar, 3::smallint, 3::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6114::bigint, '产品删除', 'iot:product:delete'::varchar, 3::smallint, 4::int, 6101::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),

        (6121::bigint, '设备查询', 'iot:device:query'::varchar, 3::smallint, 1::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6122::bigint, '设备新增', 'iot:device:create'::varchar, 3::smallint, 2::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6123::bigint, '设备修改', 'iot:device:update'::varchar, 3::smallint, 3::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6124::bigint, '设备删除', 'iot:device:delete'::varchar, 3::smallint, 4::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6125::bigint, '设备认证信息', 'iot:device:auth-info'::varchar, 3::smallint, 5::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6126::bigint, '设备消息查询', 'iot:device:message-query'::varchar, 3::smallint, 6::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6127::bigint, '设备消息结束', 'iot:device:message-end'::varchar, 3::smallint, 7::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6128::bigint, '设备属性查询', 'iot:device:property-query'::varchar, 3::smallint, 8::int, 6102::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),

        (6131::bigint, '物模型查询', 'iot:thing-model:query'::varchar, 3::smallint, 1::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6132::bigint, '物模型新增', 'iot:thing-model:create'::varchar, 3::smallint, 2::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6133::bigint, '物模型修改', 'iot:thing-model:update'::varchar, 3::smallint, 3::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6134::bigint, '物模型删除', 'iot:thing-model:delete'::varchar, 3::smallint, 4::int, 6103::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),

        (6141::bigint, '转发查询', 'iot:data-sink:query'::varchar, 3::smallint, 1::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6142::bigint, '转发新增', 'iot:data-sink:create'::varchar, 3::smallint, 2::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6143::bigint, '转发修改', 'iot:data-sink:update'::varchar, 3::smallint, 3::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6144::bigint, '转发删除', 'iot:data-sink:delete'::varchar, 3::smallint, 4::int, 6104::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),

        (6151::bigint, '规则查询', 'iot:data-rule:query'::varchar, 3::smallint, 1::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6152::bigint, '规则新增', 'iot:data-rule:create'::varchar, 3::smallint, 2::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6153::bigint, '规则修改', 'iot:data-rule:update'::varchar, 3::smallint, 3::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint),
        (6154::bigint, '规则删除', 'iot:data-rule:delete'::varchar, 3::smallint, 4::int, 6105::bigint, ''::varchar, ''::varchar, ''::varchar, NULL::varchar, 0::smallint, true, true, true, 'codex'::varchar, 'codex'::varchar, 0::smallint)
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

COMMIT;
