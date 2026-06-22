CREATE DATABASE IF NOT EXISTS iot;
USE iot;

CREATE STABLE IF NOT EXISTS product_property_1001 (
    ts TIMESTAMP,
    report_time TIMESTAMP,
    temperature DOUBLE
)
TAGS (
    device_id BIGINT
);
