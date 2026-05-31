# 本地文件中心使用说明

## 目标

当前项目保留的是一套最小本地文件中心，只支持：

- 上传到本地磁盘
- 文件记录入库
- 后台分页查询
- 按 ID 下载
- 按 ID 删除

不包含：

- 云存储
- 预签名上传
- 文件配置中心
- 文件内容入库
- 前端管理页

## 存储位置

默认本地目录：

`yudao.file.base-path=${user.home}/.yudao/files`

配置位置：

- [application.yaml](/home/xcao/project/ruoyi-vue-pro-jdk17/yudao-server/src/main/resources/application.yaml)

如果需要切换目录，只改 `yudao.file.base-path` 即可。

## 数据表

使用表：

- `infra_file`

字段只保留：

- `id`
- `name`
- `path`
- `url`
- `type`
- `size`
- 审计字段

初始化 SQL：

- [ruoyi-vue-pro.sql](/home/xcao/project/ruoyi-vue-pro-jdk17/sql/postgresql/ruoyi-vue-pro.sql)

## 接口

接口前缀基于当前后台前缀配置，默认是 `/admin-api`。

完整接口为：

- `POST /admin-api/infra/file/upload`
- `GET /admin-api/infra/file/get?id={id}`
- `GET /admin-api/infra/file/page?pageNo=1&pageSize=10`
- `GET /admin-api/infra/file/download/{id}`
- `DELETE /admin-api/infra/file/delete?id={id}`

权限点：

- `infra:file:create`
- `infra:file:query`
- `infra:file:delete`

HTTP 示例：

- [FileController.http](/home/xcao/project/ruoyi-vue-pro-jdk17/yudao-module-infra/src/main/java/cn/iocoder/yudao/module/infra/controller/admin/file/FileController.http)

## 上传规则

- 支持可选目录参数 `directory`
- 目录不允许包含 `..`
- 目录不允许以 `/` 或 `\` 开头
- 实际存储路径格式为 `目录/yyyymmdd/uuid.ext`

## 大小限制

当前已放宽到：

- `max-file-size: 256MB`
- `max-request-size: 256MB`

如果后续点表导入需要更大上限，可以继续调大，但要同步评估：

- Nginx `client_max_body_size`
- Spring Boot multipart 限制
- 磁盘空间
- 异步导入时的临时文件保留策略

## 现阶段限制

当前仓库中的前端管理端骨架不完整，无法直接补一个可运行页面，所以这轮只恢复了后端接口、权限和 SQL。

如果后面要继续做点表导入，建议直接基于这套本地落盘能力扩展为：

- 上传后生成导入任务
- 异步解析 CSV/Excel
- 导入完成后按策略删除或保留原文件
