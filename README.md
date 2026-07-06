# EMS Minimal Base

This repository is a trimmed EMS backend base for the current `east` backend stack.

## Retained backend modules

- `east-dependencies`
- `east-framework`
- `east-server`
- `east-module-system`
- `east-module-infra`

## Retained system capabilities

- auth and captcha
- users, roles, menus, permissions
- departments and posts
- dictionaries and parameter config
- notices
- login and operate logs

## Retained infra capabilities

- config management
- file storage and file config
- scheduled jobs and job logs
- API access logs and API error logs

## Removed from this base

- WMS and other business modules
- OAuth2 and social login
- sms, mail, notify
- data source management
- code generation and demo data
- extra frontend placeholders

## Database

Only PostgreSQL bootstrap scripts are retained under `sql/postgresql/`.

## EMS docs

Project-specific planning notes live under `docs/ems/`.
