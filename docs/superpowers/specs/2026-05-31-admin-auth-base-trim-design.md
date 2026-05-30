# Admin Auth Base Trim Design

**Date:** 2026-05-31

## Goal

将当前精简版仓库继续收口为仅保留管理后台认证与权限骨架的基础版本，保住以下能力：

- 管理员用户
- 角色 / 菜单 / 权限
- 登录 / 退出 / refresh-token
- 基本 Spring Security + Token 鉴权链路
- 验证码

同时删除与上述目标无关或已处于遗留状态的增强能力、桥接层、示例代码、依赖和配置。

## Non-Goals

本次不做以下事情：

- 不重写认证内核，不把现有 token 机制替换为新的自定义机制
- 不重构为全新的模块边界
- 不保证继续保留文件管理、日志导出、定时任务、通知等非认证主链路能力，若其和目标边界冲突则按裁剪优先
- 不处理前端页面恢复或重建

## Target State

裁剪完成后，项目应表现为一个“后台认证与权限基座”：

- `system` 模块保留管理员用户、角色、菜单、权限、认证、验证码所需代码
- `infra` 模块只保留认证主链路仍强依赖的最小支撑；如不再需要，则允许继续缩减
- 配置文件中不再出现 AI、MCP、多租户、WebSocket、MQ、监控中心等非目标配置块
- SQL 初始化脚本不再保留多租户、完整 OAuth2 授权码批准链路、以及与已删除功能对应的结构

## Required Capabilities

必须保留并验证可用的接口与链路：

- `/system/auth/login`
- `/system/auth/logout`
- `/system/auth/refresh-token`
- 获取登录用户权限信息接口
- 基于用户 -> 角色 -> 菜单的权限装配链路
- 管理员用户查询、密码校验、token 签发与刷新
- 验证码获取与校验链路

## Removal Scope

### 1. 直接删除的框架与功能能力

- 多租户能力
  - `biz-tenant` starter 依赖
  - `@TenantIgnore`、`@TenantJob` 等相关用法
  - 租户配置项
  - SQL 中仅为租户保留的结构与字段
- Biz IP 能力
  - `biz-ip` starter 依赖
  - IP 地域解析相关代码
- MQ 能力
  - `mq` starter 依赖
  - mail / sms producer、message、consumer 残留
  - RocketMQ / Kafka / RabbitMQ 配置
- WebSocket 能力
  - websocket starter 依赖
  - WebSocket API、listener、demo message
  - WebSocket 配置
- 监控中心能力
  - monitor starter 依赖
  - Spring Boot Admin Server 配置
- AI / MCP 配置残留
  - `application*.yaml` 中全部 AI、向量库、MCP 配置块
- 示例与桥接残留
  - `DemoJob`
  - WebSocket demo listener / message
  - `MemberService` 反射桥接
  - 未被主链路使用的 demo error code

### 2. OAuth2 收口范围

保留：

- access token / refresh token 所需的 service、mapper、DO、redis DAO
- 后台登录、刷新、退出直接使用的 token 链路

删除：

- approve / authorization code / grant 扩展链路
- 与其对应的 service、mapper、DO、枚举与 SQL 表
- 不再被后台登录主链路使用的 OAuth2 常量与接口

### 3. 基础设施与依赖收口

保留的基础依赖应尽量收敛到：

- `web`
- `security`
- `mybatis`
- `redis`
- `captcha`
- 为当前主链路仍必需的最小测试依赖

删除候选：

- `biz-tenant`
- `biz-ip`
- `mq`
- `websocket`
- `monitor`
- 若不再使用则删除 `job`
- 若不再使用则删除 `excel`
- 代码生成器相关依赖，例如 `mybatis-plus-generator`、`velocity`
- 文件云存储扩展依赖，例如 FTP / SFTP / S3 / Tika，如果文件模块被进一步裁掉

## Implementation Strategy

采用“先保链路，再做减法”的顺序：

1. 先识别后台认证最小闭环涉及的类、表、配置和依赖
2. 再删除与该闭环无关的能力与配置块
3. 再收口 OAuth2，只保留 login / logout / refresh-token 需要的 token 机制
4. 再同步清理 SQL、错误码、测试、配置注释和 README 描述
5. 每轮删减后都执行编译验证，避免一次性大拆导致问题难定位

## Risk Areas

### 1. 认证链路对 OAuth2 的耦合

当前后台登录直接依赖 token service，而 token service 可能间接依赖更多 OAuth2 结构。裁剪时必须以“保住 refresh-token”为最高优先级，宁可多留少量 token 实现，也不要为了极简误删主链路。

### 2. `system` 与 `infra` 的相互引用

当前 `system` 依赖 `infra`，而 `infra` 内存在配置、日志、文件、任务等多块能力。删除 `infra` 内容时必须确认不会破坏认证链路的 Bean 装配。

### 3. SQL 收口

删除多租户字段和 OAuth2 扩展表会影响现有 DO / mapper。SQL 清理必须与 Java 代码同步进行，不能只删配置不删表结构，也不能只删代码不删初始化脚本。

### 4. 配置安全

`application.yaml` 中存在大量与目标无关的第三方配置和密钥。即使某些功能代码已删，也必须同步移除相关配置，避免继续保留无效敏感信息。

## Verification

最终必须以以下结果作为通过标准：

- `mvn -q -pl yudao-server -am -DskipTests compile` 成功
- 后台认证相关控制器与 service 能成功装配
- 登录、退出、refresh-token 所需代码路径完整
- 用户、角色、菜单、权限主链路仍可通过编译和单元结构检查
- 配置文件中已删除能力的配置块被移除
- README 对基础版能力描述与代码现状一致

## Out of Scope Follow-Up

如果本次裁剪后仍残留少量“非认证主链路但未影响编译”的后台能力，例如日志、文件、任务、字典、通知，可在后续继续做第二轮认证基座化。但本次优先目标是先把明显遗留和高噪音框架能力整体下线，并保住后台登录闭环。
