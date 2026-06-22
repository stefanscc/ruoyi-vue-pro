package cn.iocoder.east.module.iot.core.topic.state;

import cn.iocoder.east.module.iot.core.enums.IotDeviceMessageMethodEnum;
import cn.iocoder.east.module.iot.core.topic.IotDeviceIdentity;
import lombok.Data;

import java.util.List;

/**
 * IoT 子设备状态批量上报 Request DTO
 * <p>
 * 用于 {@link IotDeviceMessageMethodEnum#SUB_DEVICE_STATE_PACK_POST} 消息的 params 参数
 *
 * @author 芋道源码
 */
@Data
public class IotSubDeviceStatePackPostReqDTO {

    /**
     * 子设备状态列表
     */
    private List<SubDeviceState> subDevices;

    /**
     * 子设备状态
     */
    @Data
    public static class SubDeviceState {

        /**
         * 子设备标识
         */
        private IotDeviceIdentity identity;

        /**
         * 设备状态
         */
        private Integer state;

        /**
         * 上报时间（毫秒时间戳）
         */
        private Long time;

    }

}
