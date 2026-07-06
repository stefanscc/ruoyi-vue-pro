package com.ems.east.module.iot.core.biz.dto;

import lombok.Data;

/**
 * IoT 设备信息 Response DTO
 *
 * @author Hand of God
 */
@Data
public class IotDeviceRespDTO {

    /**
     * 设备编号
     */
    private Long id;
    /**
     * 产品标识
     */
    private String productKey;
    /**
     * 设备名称
     */
    private String deviceName;

    // ========== 产品相关字段 ==========

    /**
     * 产品编号
     */
    private Long productId;
    /**
     * 协议类型
     */
    private String protocolType;
    /**
     * 序列化类型
     */
    private String serializeType;

}
