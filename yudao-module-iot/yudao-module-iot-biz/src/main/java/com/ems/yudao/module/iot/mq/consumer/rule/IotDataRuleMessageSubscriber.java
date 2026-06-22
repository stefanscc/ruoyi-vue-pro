package com.ems.yudao.module.iot.mq.consumer.rule;

import com.ems.yudao.framework.tenant.core.util.TenantUtils;
import com.ems.yudao.module.iot.core.messagebus.core.IotMessageBus;
import com.ems.yudao.module.iot.core.messagebus.core.IotMessageSubscriber;
import com.ems.yudao.module.iot.core.mq.message.IotDeviceMessage;
import com.ems.yudao.module.iot.service.rule.data.IotDataRuleService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;

/**
 * 针对 {@link IotDeviceMessage} 的消费者，处理数据流转
 *
 * @author 芋道源码
 */
@Component
@Slf4j
public class IotDataRuleMessageSubscriber implements IotMessageSubscriber<IotDeviceMessage> {

    @Resource
    private IotDataRuleService dataRuleService;

    @Resource
    private IotMessageBus messageBus;

    @PostConstruct
    public void init() {
        messageBus.register(this);
    }

    @Override
    public String getTopic() {
        return IotDeviceMessage.MESSAGE_BUS_DEVICE_MESSAGE_TOPIC;
    }

    @Override
    public String getGroup() {
        return "iot_data_rule_consumer";
    }

    @Override
    public void onMessage(IotDeviceMessage message) {
        TenantUtils.execute(message.getTenantId(), () -> dataRuleService.executeDataRule(message));
    }

}
