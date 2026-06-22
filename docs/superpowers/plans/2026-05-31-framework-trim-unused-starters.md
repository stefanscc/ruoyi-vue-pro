# Framework Trim Unused Starters Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove the unused tenant, websocket, mq, monitor, biz-ip, and protection framework starters while keeping data-permission, excel, and job intact.

**Architecture:** Trim from the outside in: first remove build and dependency entry points, then clean runtime configuration, then delete the unused starter source trees. Verify by compiling the remaining modules that still participate in the application build.

**Tech Stack:** Maven multi-module project, Spring Boot 3, Java 17

---

### Task 1: Remove build entry points

**Files:**
- Modify: `east-framework/pom.xml`
- Modify: `east-dependencies/pom.xml`
- Modify: `east-server/pom.xml`

- [x] Delete the unused starter module declarations from `east-framework/pom.xml`.
- [x] Delete the matching dependency-management entries from `east-dependencies/pom.xml`.
- [x] Delete the direct `east-spring-boot-starter-protection` dependency from `east-server/pom.xml`.

### Task 2: Clean runtime configuration

**Files:**
- Modify: `east-server/src/main/resources/application-dev.yaml`
- Modify: `east-server/src/main/resources/application-local.yaml`

- [x] Remove `lock4j` configuration blocks that only serve the deleted protection starter.
- [x] Keep Quartz and Actuator settings because job and current infra endpoints still use them.

### Task 3: Delete unused framework starter sources

**Files:**
- Delete: `east-framework/east-spring-boot-starter-biz-tenant/**`
- Delete: `east-framework/east-spring-boot-starter-websocket/**`
- Delete: `east-framework/east-spring-boot-starter-mq/**`
- Delete: `east-framework/east-spring-boot-starter-monitor/**`
- Delete: `east-framework/east-spring-boot-starter-biz-ip/**`
- Delete: `east-framework/east-spring-boot-starter-protection/**`

- [x] Delete each unused starter directory after build entry points are removed so Maven no longer expects them.

### Task 4: Verify surviving modules

**Files:**
- Verify only

- [x] Run `mvn -pl east-server -am -DskipTests compile`.
- [x] If compile fails, fix any lingering references introduced by the trim and rerun the same command.
