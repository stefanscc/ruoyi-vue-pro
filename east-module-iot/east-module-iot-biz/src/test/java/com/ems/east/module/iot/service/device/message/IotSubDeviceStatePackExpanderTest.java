package com.ems.east.module.iot.service.device.message;

import com.ems.east.framework.test.core.ut.BaseMockitoUnitTest;
import com.ems.east.module.iot.core.enums.IotDeviceMessageMethodEnum;
import com.ems.east.module.iot.core.mq.message.IotDeviceMessage;
import com.ems.east.module.iot.core.mq.producer.IotDeviceMessageProducer;
import com.ems.east.module.iot.core.topic.IotDeviceIdentity;
import com.ems.east.module.iot.core.topic.state.IotDeviceStateUpdateReqDTO;
import com.ems.east.module.iot.core.topic.state.IotSubDeviceStatePackPostReqDTO;
import com.ems.east.module.iot.dal.dataobject.device.IotDeviceDO;
import com.ems.east.module.iot.service.device.IotDeviceService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link IotSubDeviceStatePackExpander} 的单元测试
 */
public class IotSubDeviceStatePackExpanderTest extends BaseMockitoUnitTest {

    @InjectMocks
    private IotSubDeviceStatePackExpander expander;

    @Mock
    private IotDeviceService deviceService;
    @Mock
    private IotDeviceMessageProducer deviceMessageProducer;

    @Test
    public void testExpand_validSubDevice_publishStateMessage() {
        LocalDateTime fallbackReportTime = LocalDateTime.of(2026, 6, 13, 22, 10, 11);
        LocalDateTime subDeviceReportTime = LocalDateTime.of(2026, 6, 13, 22, 12, 13);
        IotDeviceDO gateway = IotDeviceDO.builder().id(100L).build();
        IotDeviceDO subDevice = IotDeviceDO.builder().id(200L).gatewayId(100L).build();
        when(deviceService.getDeviceFromCache("smoke_sensor_v1", "A10001")).thenReturn(subDevice);

        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"));
        subDeviceState.setState(1);
        subDeviceState.setTime(toEpochMilli(subDeviceReportTime));
        expander.expand(buildPackMessage(fallbackReportTime, subDeviceState), gateway);

        ArgumentCaptor<IotDeviceMessage> captor = ArgumentCaptor.forClass(IotDeviceMessage.class);
        verify(deviceMessageProducer).sendDeviceMessage(captor.capture());
        IotDeviceMessage stateMessage = captor.getValue();
        assertEquals(200L, stateMessage.getDeviceId());
        assertEquals(IotDeviceMessageMethodEnum.STATE_UPDATE.getMethod(), stateMessage.getMethod());
        assertEquals(subDeviceReportTime, stateMessage.getReportTime());
        assertNull(stateMessage.getServerId());
        IotDeviceStateUpdateReqDTO params = (IotDeviceStateUpdateReqDTO) stateMessage.getParams();
        assertEquals(1, params.getState());
    }

    @Test
    public void testExpand_subDeviceMissing_skipPublish() {
        IotDeviceDO gateway = IotDeviceDO.builder().id(100L).build();
        when(deviceService.getDeviceFromCache("smoke_sensor_v1", "A10001")).thenReturn(null);

        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"));
        subDeviceState.setState(1);
        expander.expand(buildPackMessage(LocalDateTime.of(2026, 6, 13, 22, 10, 11), subDeviceState), gateway);

        verify(deviceMessageProducer, never()).sendDeviceMessage(org.mockito.ArgumentMatchers.any());
    }

    @Test
    public void testExpand_gatewayMismatch_skipPublish() {
        IotDeviceDO gateway = IotDeviceDO.builder().id(100L).build();
        IotDeviceDO subDevice = IotDeviceDO.builder().id(200L).gatewayId(999L).build();
        when(deviceService.getDeviceFromCache("smoke_sensor_v1", "A10001")).thenReturn(subDevice);

        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"));
        subDeviceState.setState(1);
        expander.expand(buildPackMessage(LocalDateTime.of(2026, 6, 13, 22, 10, 11), subDeviceState), gateway);

        verify(deviceMessageProducer, never()).sendDeviceMessage(org.mockito.ArgumentMatchers.any());
    }

    @Test
    public void testExpand_withoutSubDeviceTime_fallbackToPackReportTime() {
        LocalDateTime fallbackReportTime = LocalDateTime.of(2026, 6, 13, 22, 10, 11);
        IotDeviceDO gateway = IotDeviceDO.builder().id(100L).build();
        IotDeviceDO subDevice = IotDeviceDO.builder().id(200L).gatewayId(100L).build();
        when(deviceService.getDeviceFromCache("smoke_sensor_v1", "A10001")).thenReturn(subDevice);

        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("smoke_sensor_v1", "A10001"));
        subDeviceState.setState(0);
        expander.expand(buildPackMessage(fallbackReportTime, subDeviceState), gateway);

        ArgumentCaptor<IotDeviceMessage> captor = ArgumentCaptor.forClass(IotDeviceMessage.class);
        verify(deviceMessageProducer, times(1)).sendDeviceMessage(captor.capture());
        assertEquals(fallbackReportTime, captor.getValue().getReportTime());
    }

    private IotDeviceMessage buildPackMessage(LocalDateTime packReportTime,
                                              IotSubDeviceStatePackPostReqDTO.SubDeviceState... subDevices) {
        IotSubDeviceStatePackPostReqDTO params = new IotSubDeviceStatePackPostReqDTO();
        params.setSubDevices(List.of(subDevices));
        return IotDeviceMessage.requestOf(IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), params)
                .setReportTime(packReportTime);
    }

    private long toEpochMilli(LocalDateTime reportTime) {
        return cn.hutool.core.date.LocalDateTimeUtil.toEpochMilli(reportTime);
    }

}
