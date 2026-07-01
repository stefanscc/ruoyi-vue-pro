package com.ems.east.module.iot.service.ingestion;

import cn.hutool.core.util.StrUtil;
import com.ems.east.framework.common.util.json.JsonUtils;
import com.ems.east.module.iot.core.mq.message.IotDeviceMessage;
import com.ems.east.module.iot.dal.dataobject.device.IotDeviceDO;
import com.ems.east.module.iot.framework.iot.config.EastIotProperties;
import jakarta.annotation.Resource;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;

/**
 * Client used by east-server to delegate MQTT downlink publishing to Go ingestion.
 */
@Component
@Slf4j
public class IotGoIngestionClient {

    @Resource
    private EastIotProperties iotProperties;

    public void sendDownlink(IotDeviceMessage message, IotDeviceDO device) {
        EastIotProperties.GoIngestion properties = iotProperties.getGoIngestion();
        if (!properties.isEnabled()) {
            throw new IllegalStateException("Go ingestion downlink is disabled");
        }
        DownlinkReq req = new DownlinkReq()
                .setDeviceId(device.getId())
                .setProductKey(device.getProductKey())
                .setDeviceName(device.getDeviceName())
                .setRequestId(message.getRequestId())
                .setMethod(message.getMethod())
                .setParams(message.getParams());
        post(properties, "/internal/downlink", req);
    }

    public void reload() {
        EastIotProperties.GoIngestion properties = iotProperties.getGoIngestion();
        if (!properties.isEnabled()) {
            return;
        }
        post(properties, "/internal/reload", Map.of());
    }

    @SuppressWarnings("unchecked")
    public Map<String, Object> health() {
        EastIotProperties.GoIngestion properties = iotProperties.getGoIngestion();
        if (!properties.isEnabled()) {
            return Map.of("status", "DISABLED");
        }
        String body = get(properties, "/internal/health");
        return JsonUtils.parseObject(body, Map.class);
    }

    private void post(EastIotProperties.GoIngestion properties, String path, Object body) {
        try {
            String baseUrl = StrUtil.removeSuffix(properties.getBaseUrl(), "/");
            Duration timeout = properties.getTimeout() != null ? properties.getTimeout() : Duration.ofSeconds(10);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(baseUrl + path))
                    .timeout(timeout)
                    .header("Content-Type", "application/json")
                    .header("X-Internal-Token", properties.getInternalToken())
                    .POST(HttpRequest.BodyPublishers.ofString(JsonUtils.toJsonString(body)))
                    .build();
            HttpClient client = HttpClient.newBuilder().connectTimeout(timeout).build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new IllegalStateException("Go ingestion request failed: status=" + response.statusCode()
                        + ", body=" + response.body());
            }
        } catch (Exception ex) {
            log.error("[post][Go ingestion request failed path({}) body({})]", path, body, ex);
            throw new IllegalStateException("Go ingestion request failed: " + ex.getMessage(), ex);
        }
    }

    private String get(EastIotProperties.GoIngestion properties, String path) {
        try {
            String baseUrl = StrUtil.removeSuffix(properties.getBaseUrl(), "/");
            Duration timeout = properties.getTimeout() != null ? properties.getTimeout() : Duration.ofSeconds(10);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(baseUrl + path))
                    .timeout(timeout)
                    .GET()
                    .build();
            HttpClient client = HttpClient.newBuilder().connectTimeout(timeout).build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new IllegalStateException("Go ingestion request failed: status=" + response.statusCode()
                        + ", body=" + response.body());
            }
            return response.body();
        } catch (Exception ex) {
            log.error("[get][Go ingestion request failed path({})]", path, ex);
            throw new IllegalStateException("Go ingestion request failed: " + ex.getMessage(), ex);
        }
    }

    @Data
    public static class DownlinkReq {

        private Long deviceId;

        private String productKey;

        private String deviceName;

        private String requestId;

        private String method;

        private Object params;

    }

}
