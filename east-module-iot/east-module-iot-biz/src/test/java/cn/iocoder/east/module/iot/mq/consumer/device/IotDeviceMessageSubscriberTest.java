package cn.iocoder.east.module.iot.mq.consumer.device;

import cn.iocoder.east.framework.test.core.ut.BaseMockitoUnitTest;
import cn.iocoder.east.module.iot.core.enums.IotDeviceMessageMethodEnum;
import cn.iocoder.east.module.iot.core.enums.device.IotDeviceStateEnum;
import cn.iocoder.east.module.iot.core.mq.message.IotDeviceMessage;
import cn.iocoder.east.module.iot.dal.dataobject.device.IotDeviceDO;
import cn.iocoder.east.module.iot.service.device.IotDeviceService;
import cn.iocoder.east.module.iot.service.device.message.IotDeviceMessageService;
import cn.iocoder.east.module.iot.service.device.property.IotDevicePropertyService;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;

import java.time.LocalDateTime;
import java.util.HashMap;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link IotDeviceMessageSubscriber} 的单元测试
 */
public class IotDeviceMessageSubscriberTest extends BaseMockitoUnitTest {

    @InjectMocks
    private IotDeviceMessageSubscriber subscriber;

    @Mock
    private IotDeviceService deviceService;
    @Mock
    private IotDevicePropertyService devicePropertyService;
    @Mock
    private IotDeviceMessageService deviceMessageService;

    @Test
    public void testOnMessage_usesMessageReportTimeForLastReportTime() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 8, 9, 10);
        IotDeviceMessage message = buildUpstreamMessage(reportTime);
        IotDeviceDO device = IotDeviceDO.builder()
                .id(1L)
                .state(IotDeviceStateEnum.ONLINE.getState())
                .build();
        when(deviceService.validateDeviceExistsFromCache(message.getDeviceId())).thenReturn(device);

        subscriber.onMessage(message);

        ArgumentCaptor<LocalDateTime> captor = ArgumentCaptor.forClass(LocalDateTime.class);
        verify(devicePropertyService).updateDeviceReportTimeAsync(eq(device.getId()), captor.capture());
        assertEquals(reportTime, captor.getValue());
    }

    @Test
    public void testOnMessage_whenReportTimeMissing_fallbackNow() {
        IotDeviceMessage message = buildUpstreamMessage(null);
        IotDeviceDO device = IotDeviceDO.builder()
                .id(2L)
                .state(IotDeviceStateEnum.ONLINE.getState())
                .build();
        when(deviceService.validateDeviceExistsFromCache(message.getDeviceId())).thenReturn(device);
        LocalDateTime before = LocalDateTime.now().minusSeconds(1);

        subscriber.onMessage(message);
        LocalDateTime after = LocalDateTime.now().plusSeconds(1);

        ArgumentCaptor<LocalDateTime> captor = ArgumentCaptor.forClass(LocalDateTime.class);
        verify(devicePropertyService).updateDeviceReportTimeAsync(eq(device.getId()), captor.capture());
        assertTrue(!captor.getValue().isBefore(before) && !captor.getValue().isAfter(after),
                "fallback 时间应接近当前时间，实际为 " + captor.getValue());
        assertEquals(captor.getValue(), message.getReportTime(), "fallback 时间需要回写到消息体，避免后续链路仍然读到 null");
    }

    private IotDeviceMessage buildUpstreamMessage(LocalDateTime reportTime) {
        IotDeviceMessage message = new IotDeviceMessage();
        message.setId("msg-1");
        message.setDeviceId(1L);
        message.setMethod(IotDeviceMessageMethodEnum.PROPERTY_POST.getMethod());
        message.setParams(new HashMap<>());
        message.setReportTime(reportTime);
        return message;
    }

}
