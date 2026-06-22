# Local File Center Design

**Date:** 2026-05-31

## Goal

为当前精简后的后台基座补回“通用本地文件中心”能力，满足以下目标：

- 提供管理后台可复用的本地文件上传、下载、删除、查询能力
- 保持接口、权限和代码风格与现有 `infra` 模块一致
- 只支持本地磁盘存储，不恢复多存储器、云存储和文件配置中心
- 让后续头像、附件、业务单据等上传场景可以复用同一条后端链路

## Non-Goals

本次不做以下事情：

- 不恢复 `file_config`、`file_content`、主配置切换、多存储器选择
- 不恢复 S3、FTP、SFTP、数据库存储等扩展实现
- 不恢复 App 端文件接口
- 不恢复后台文件管理页面
- 不实现匿名直链访问、分片上传、秒传、去重、预签名 URL

## Current State

当前仓库并非“完全没有文件功能”，而是处于“轻量骨架已在，初始化和收尾未完成”的状态：

- 已保留管理后台控制器：[FileController](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/controller/admin/file/FileController.java)
- 已保留服务接口和实现：[FileService](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/service/file/FileService.java)、[FileServiceImpl](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/service/file/FileServiceImpl.java)
- 已保留文件元数据模型和查询：[FileDO](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/dal/dataobject/file/FileDO.java)、[FileMapper](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/dal/mysql/file/FileMapper.java)
- 已新增轻量本地存储层：[LocalFileStorage](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/file/core/LocalFileStorage.java)
- 已保留本地存储根目录配置：[application.yaml](/home/xcao/project/ruoyi-vue-pro-jdk17/east-server/src/main/resources/application.yaml)

但当前仍存在关键缺口：

- `sql/postgresql/ruoyi-vue-pro.sql` 中已删除 `infra_file` 表结构和相关序列
- 文件权限点和初始化种子数据已被移除
- 部分旧文件模块残留已删除，只剩“本地版主链路”，需要明确以此为准

## Chosen Approach

采用“精简版本地文件中心”方案：

1. 不恢复上游完整文件模块
2. 直接完善当前仓库已保留的轻量文件链路
3. 只保留一张文件元数据表 `infra_file`
4. 只支持本地磁盘存储
5. 文件访问统一走受控下载接口，而不是开放静态目录

选择该方案的原因：

- 比“完整恢复旧模块”更符合当前极简基座目标
- 比“纯落盘不入库”更适合作为通用文件中心复用
- 当前仓库已经具备 70% 左右的实现骨架，修补成本和风险都更低

## Target State

完成后，项目应具备如下能力：

- 管理后台可通过 `/admin-api/infra/file/upload` 上传文件
- 文件上传后写入本地磁盘，并在数据库记录元数据
- 管理后台可通过 `/admin-api/infra/file/download/{id}` 下载文件
- 管理后台可按 `id` 查询单个文件信息、按条件分页查询文件列表
- 管理后台可删除文件，同时删除本地文件和数据库记录
- 全部接口受登录态和权限控制

## API Design

保留并收口以下管理后台接口：

- `POST /admin-api/infra/file/upload`
  - 输入：`MultipartFile file`，可选 `directory`
  - 输出：`FileRespVO`
- `GET /admin-api/infra/file/get?id=`
  - 输入：文件 `id`
  - 输出：`FileRespVO`
- `GET /admin-api/infra/file/page`
  - 输入：分页参数、`path`、`type`、`createTime`
  - 输出：`PageResult<FileRespVO>`
- `GET /admin-api/infra/file/download/{id}`
  - 输入：文件 `id`
  - 输出：附件下载响应流
- `DELETE /admin-api/infra/file/delete?id=`
  - 输入：文件 `id`
  - 输出：删除结果

权限点使用：

- `infra:file:create`
- `infra:file:query`
- `infra:file:delete`

下载接口继续复用 `infra:file:query`，不单独拆 `download` 权限。

## Data Model

只恢复一张精简表 `infra_file`，字段与 [FileDO](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/dal/dataobject/file/FileDO.java) 对齐：

- `id`
- `name`
- `path`
- `url`
- `type`
- `size`
- `creator`
- `create_time`
- `updater`
- `update_time`
- `deleted`

同时恢复：

- `infra_file_seq`
- `pk_infra_file`

不恢复以下旧结构：

- `infra_file_config`
- `infra_file_content`
- `infra_file_config_seq`
- `infra_file_content_seq`

## Storage Design

### Root Directory

文件根目录继续使用：

- `east.file.base-path`

默认值保持为：

- `${user.home}/.east/files`

### Relative Path Strategy

上传后的相对路径格式保持当前实现：

- `{directory可选}/{yyyyMMdd}/{uuid.ext}`

例如：

- `avatar/20260531/2d6a7b1d8f1d4d7a8e1e.jpg`
- `attachment/20260531/cc9d2e4e91c04d5f.pdf`

### Access Strategy

不开放静态资源目录映射。所有下载统一走：

- `/admin-api/infra/file/download/{id}`

原因：

- 权限控制统一
- 避免把本地目录直接暴露为公网可猜测路径
- 后续如果接入业务审计或下载日志，不需要改入口

## Validation and Security

### Upload Validation

保留并强化以下约束：

- 文件不能为空
- `directory` 不能包含 `..`
- `directory` 不能以 `/` 或 `\\` 开头
- 磁盘写入前统一生成服务端文件名，避免信任用户原始文件名

### Path Traversal Protection

[LocalFileStorage](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/file/core/LocalFileStorage.java) 继续通过：

- `basePath.resolve(relativePath).normalize()`
- `absolutePath.startsWith(basePath)`

来阻断目录穿越。

### Download Protection

下载不接受前端传物理路径，只允许按 `id` 读取数据库中的 `path`，再由后端解析为绝对路径。

### Delete Behavior

删除文件时：

1. 先校验数据库记录存在
2. 尝试删除本地磁盘文件
3. 删除数据库记录

如果磁盘文件已不存在，也允许继续清理数据库记录，不应让系统长期残留脏元数据。

## Error Handling

继续复用 `FILE_NOT_EXISTS`：

- 文件记录不存在时返回该错误
- 文件记录存在但磁盘文件缺失时，也返回该错误

对于参数错误：

- 上传文件为空
- 目录不合法

使用现有 `invalidParamException(...)` 风格返回统一业务异常。

## Implementation Scope

### Java Code

本次允许修改的核心文件：

- [FileController](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/controller/admin/file/FileController.java)
- [FileService](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/service/file/FileService.java)
- [FileServiceImpl](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/service/file/FileServiceImpl.java)
- [FileMapper](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/dal/mysql/file/FileMapper.java)
- [FileDO](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/dal/dataobject/file/FileDO.java)
- [FileUploadReqVO](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/controller/admin/file/vo/file/FileUploadReqVO.java)
- [FileRespVO](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/controller/admin/file/vo/file/FileRespVO.java)
- [LocalFileStorage](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/file/core/LocalFileStorage.java)
- [EastFileProperties](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/file/config/EastFileProperties.java)

### SQL

需要在 [ruoyi-vue-pro.sql](/home/xcao/project/ruoyi-vue-pro-jdk17/sql/postgresql/ruoyi-vue-pro.sql) 中补回：

- `infra_file` 表
- `infra_file_seq`
- `pk_infra_file`

需要补回权限相关菜单 / 按钮种子数据：

- `infra:file:create`
- `infra:file:query`
- `infra:file:delete`

同时补回与默认角色相关的 `system_role_menu` 绑定，但不补页面级菜单入口。

## Risks

### 1. SQL 与代码脱节

当前 Java 链路已在，但 SQL 已删掉 `infra_file`。如果只改 Java 不改初始化脚本，新库启动后文件接口会直接报表不存在。

### 2. 控制器与实现存在“旧模块残留命名”

当前控制器和 VO 名称来自旧文件模块，但实现已经转向轻量本地版本。实施时要避免再次引入 `FileConfig` 或多存储器依赖。

### 3. 下载响应细节

下载接口依赖 [FileTypeUtils](/home/xcao/project/ruoyi-vue-pro-jdk17/east-module-infra/src/main/java/cn/iocoder/east/module/infra/framework/file/core/utils/FileTypeUtils.java) 正确写出 `Content-Type` 和附件头。若该工具类仍带有上游重型文件模块假设，需要同步校正。

### 4. 旧权限数据已被删除

如果权限点只在控制器上恢复、不在 SQL 里补回，默认角色将无法访问接口，表现会像“功能没恢复”。

## Verification

完成后必须满足：

- `mvn -q -pl east-server -am -DskipTests compile` 成功
- 能成功上传文件到 `east.file.base-path`
- 上传后数据库存在 `infra_file` 记录
- 可按 `id` 查询详情和分页
- 可按 `id` 下载文件
- 删除后数据库记录和本地文件都被移除
- 无 `infra_file_config`、`infra_file_content` 等重型结构回流

## Recommended Follow-Up

本次完成后，若后续需要继续增强，可在单独迭代中考虑：

- 用户头像上传复用到文件中心
- 业务附件字段统一改为保存文件 `id`
- 文件下载日志或引用计数

这些增强都不属于本次恢复范围。
