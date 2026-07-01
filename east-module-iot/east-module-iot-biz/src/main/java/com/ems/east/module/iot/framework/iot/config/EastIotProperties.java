package com.ems.east.module.iot.framework.iot.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.time.Duration;

/**
 * 芋道 IoT 全局配置类
 *
 * @author 芋道源码
 */
@Component
@ConfigurationProperties(prefix = "east.iot")
@Data
public class EastIotProperties {

    /**
     * 设备连接超时时间
     */
    private Duration keepAliveTime = Duration.ofMinutes(10);
    /**
     * 设备连接超时时间的因子
     *
     * 因为设备可能会有网络抖动，所以需要乘以一个因子，避免误判
     */
    private double keepAliveFactor = 1.5D;

    private GoIngestion goIngestion = new GoIngestion();

    @Data
    public static class GoIngestion {

        private boolean enabled = true;

        private String baseUrl = "http://127.0.0.1:8090";

        private String internalToken = "change-me";

        private Duration timeout = Duration.ofSeconds(10);

    }

}
