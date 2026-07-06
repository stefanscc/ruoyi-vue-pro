package com.ems.east.module.iot.gateway.protocol.modbus.tcpclient.handler.downstream;

import com.ems.east.module.iot.core.messagebus.core.IotMessageBus;
import com.ems.east.module.iot.core.mq.message.IotDeviceMessage;
import com.ems.east.module.iot.gateway.protocol.AbstractIotProtocolDownstreamSubscriber;
import com.ems.east.module.iot.gateway.protocol.modbus.tcpclient.IotModbusTcpClientProtocol;
import lombok.extern.slf4j.Slf4j;

/**
 * IoT Modbus TCP 下行消息订阅器：订阅消息总线的下行消息并转发给处理器
 *
 * @author Hand of God
 */
@Slf4j
public class IotModbusTcpClientDownstreamSubscriber extends AbstractIotProtocolDownstreamSubscriber {

    private final IotModbusTcpClientDownstreamHandler downstreamHandler;

    public IotModbusTcpClientDownstreamSubscriber(IotModbusTcpClientProtocol protocol,
                                                  IotModbusTcpClientDownstreamHandler downstreamHandler,
                                                  IotMessageBus messageBus) {
        super(protocol, messageBus);
        this.downstreamHandler = downstreamHandler;
    }

    @Override
    protected void handleMessage(IotDeviceMessage message) {
        downstreamHandler.handle(message);
    }

}
