package cn.iocoder.east.module.iot.service.device.message;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.LocalDateTimeUtil;
import cn.hutool.core.util.ObjUtil;
import cn.iocoder.east.framework.common.util.json.JsonUtils;
import cn.iocoder.east.module.iot.core.mq.message.IotDeviceMessage;
import cn.iocoder.east.module.iot.core.mq.producer.IotDeviceMessageProducer;
import cn.iocoder.east.module.iot.core.topic.IotDeviceIdentity;
import cn.iocoder.east.module.iot.core.topic.state.IotSubDeviceStatePackPostReqDTO;
import cn.iocoder.east.module.iot.dal.dataobject.device.IotDeviceDO;
import cn.iocoder.east.module.iot.service.device.IotDeviceService;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

/**
 * IoT 子设备状态批量消息拆包器
 *
 * @author 芋道源码
 */
@Service
@Slf4j
public class IotSubDeviceStatePackExpander {

    @Resource
    private IotDeviceService deviceService;
    @Resource
    private IotDeviceMessageProducer deviceMessageProducer;

    public void expand(IotDeviceMessage packMessage, IotDeviceDO gatewayDevice) {
        IotSubDeviceStatePackPostReqDTO params = JsonUtils.convertObject(
                packMessage.getParams(), IotSubDeviceStatePackPostReqDTO.class);
        if (params == null || CollUtil.isEmpty(params.getSubDevices())) {
            log.warn("[expand][消息({}) 参数解析失败或子设备状态为空]", packMessage);
            return;
        }

        for (IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState : params.getSubDevices()) {
            try {
                IotDeviceIdentity identity = subDeviceState.getIdentity();
                IotDeviceDO subDevice = deviceService.getDeviceFromCache(identity.getProductKey(), identity.getDeviceName());
                if (subDevice == null) {
                    continue;
                }
                if (!ObjUtil.equal(subDevice.getGatewayId(), gatewayDevice.getId())) {
                    continue;
                }

                LocalDateTime reportTime = subDeviceState.getTime() != null
                        ? LocalDateTimeUtil.of(subDeviceState.getTime())
                        : packMessage.getReportTime();
                IotDeviceMessage stateMessage = IotDeviceMessage.buildStateUpdate(subDeviceState.getState(), reportTime)
                        .setDeviceId(subDevice.getId())
                        .setServerId(null);
                deviceMessageProducer.sendDeviceMessage(stateMessage);
            } catch (Exception ex) {
                log.error("[expand][子设备状态拆包失败 subDeviceState={}]", subDeviceState, ex);
            }
        }
    }

}
