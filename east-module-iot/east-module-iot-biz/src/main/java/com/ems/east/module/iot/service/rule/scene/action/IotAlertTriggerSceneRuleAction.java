package com.ems.east.module.iot.service.rule.scene.action;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DatePattern;
import cn.hutool.core.date.LocalDateTimeUtil;
import com.ems.east.framework.common.enums.CommonStatusEnum;
import com.ems.east.framework.dict.core.DictFrameworkUtils;
import com.ems.east.module.iot.core.mq.message.IotDeviceMessage;
import com.ems.east.module.iot.dal.dataobject.alert.IotAlertConfigDO;
import com.ems.east.module.iot.dal.dataobject.device.IotDeviceDO;
import com.ems.east.module.iot.dal.dataobject.rule.IotSceneRuleDO;
import com.ems.east.module.iot.enums.DictTypeConstants;
import com.ems.east.module.iot.enums.alert.IotAlertReceiveTypeEnum;
import com.ems.east.module.iot.enums.rule.IotSceneRuleActionTypeEnum;
import com.ems.east.module.iot.service.alert.IotAlertConfigService;
import com.ems.east.module.iot.service.alert.IotAlertRecordService;
import com.ems.east.module.iot.service.device.IotDeviceService;
import jakarta.annotation.Nullable;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * IoT 告警触发的 {@link IotSceneRuleAction} 实现类
 *
 * @author 芋道源码
 */
@Component
@Slf4j
public class IotAlertTriggerSceneRuleAction implements IotSceneRuleAction {

    @Resource
    private IotAlertConfigService alertConfigService;
    @Resource
    private IotAlertRecordService alertRecordService;
    @Resource
    private IotDeviceService deviceService;

    @Override
    public void execute(@Nullable IotDeviceMessage message,
                        IotSceneRuleDO rule, IotSceneRuleDO.Action actionConfig) throws Exception {
        List<IotAlertConfigDO> alertConfigs = alertConfigService.getAlertConfigListBySceneRuleIdAndStatus(
                rule.getId(), CommonStatusEnum.ENABLE.getStatus());
        if (CollUtil.isEmpty(alertConfigs)) {
            return;
        }
        // 获得设备信息
        IotDeviceDO device = message != null ? deviceService.getDeviceFromCache(message.getDeviceId()) : null;
        alertConfigs.forEach(alertConfig -> {
            // 创建告警记录
            alertRecordService.createAlertRecord(alertConfig, rule.getId(), message, device);
            // 发送告警消息
            sendAlertMessage(alertConfig, message, device);
        });
    }

    private void sendAlertMessage(IotAlertConfigDO config,
                                  @Nullable IotDeviceMessage deviceMessage,
                                  @Nullable IotDeviceDO device) {
        if (CollUtil.isEmpty(config.getReceiveUserIds()) || CollUtil.isEmpty(config.getReceiveTypes())) {
            return;
        }
        Map<String, Object> templateParams = buildTemplateParams(config, deviceMessage, device);
        config.getReceiveUserIds().forEach(userId ->
                config.getReceiveTypes().forEach(receiveType -> sendAlertMessageToUser(userId, receiveType, templateParams)));
    }

    /**
     * 按指定接收方式，给单个用户发送告警消息
     */
    private void sendAlertMessageToUser(Long userId, Integer receiveType, Map<String, Object> templateParams) {
        IotAlertReceiveTypeEnum typeEnum = IotAlertReceiveTypeEnum.of(receiveType);
        if (typeEnum == null) {
            return;
        }
        log.warn("[sendAlertMessageToUser][用户({}) 模板参数({}) 跳过 {} 告警发送：当前精简工程未集成 system 消息发送 API]",
                userId, templateParams, typeEnum);
    }

    private Map<String, Object> buildTemplateParams(IotAlertConfigDO config,
                                                    @Nullable IotDeviceMessage deviceMessage,
                                                    @Nullable IotDeviceDO device) {
        Map<String, Object> params = new HashMap<>();
        params.put("configName", config.getName());
        params.put("configDescription", config.getDescription());
        params.put("configLevel", DictFrameworkUtils.parseDictDataLabel(DictTypeConstants.ALERT_LEVEL, config.getLevel()));
        params.put("deviceName", device != null ? device.getDeviceName() : null);
        params.put("reportTime", deviceMessage != null
                ? LocalDateTimeUtil.format(deviceMessage.getReportTime(), DatePattern.NORM_DATETIME_PATTERN) : null);
        return params;
    }

    @Override
    public IotSceneRuleActionTypeEnum getType() {
        return IotSceneRuleActionTypeEnum.ALERT_TRIGGER;
    }

}
