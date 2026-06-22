package cn.iocoder.east.module.iot.service.device;

import cn.hutool.extra.spring.SpringUtil;
import cn.iocoder.east.framework.test.core.ut.BaseMockitoUnitTest;
import cn.iocoder.east.module.iot.core.enums.device.IotDeviceStateEnum;
import cn.iocoder.east.module.iot.dal.dataobject.device.IotDeviceDO;
import cn.iocoder.east.module.iot.dal.mysql.device.IotDeviceMapper;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockedStatic;

import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.verify;

/**
 * {@link IotDeviceServiceImpl} 的单元测试
 */
public class IotDeviceStateTimeTest extends BaseMockitoUnitTest {

    @InjectMocks
    private IotDeviceServiceImpl service;

    @Mock
    private IotDeviceMapper deviceMapper;

    @Test
    public void testUpdateDeviceState_withReportTime_onlineUsesGivenStateTime() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 10, 11, 12);
        IotDeviceDO device = IotDeviceDO.builder()
                .id(1L)
                .state(IotDeviceStateEnum.INACTIVE.getState())
                .onlineTime(null)
                .build();

        try (MockedStatic<SpringUtil> springUtilMock = mockStatic(SpringUtil.class)) {
            springUtilMock.when(() -> SpringUtil.getBean(IotDeviceServiceImpl.class)).thenReturn(service);
            service.updateDeviceState(device, IotDeviceStateEnum.ONLINE.getState(), reportTime);
        }

        IotDeviceDO updateObj = captureUpdatedDevice();
        assertEquals(reportTime, updateObj.getActiveTime());
        assertEquals(reportTime, updateObj.getOnlineTime());
        assertNull(updateObj.getOfflineTime());
    }

    @Test
    public void testUpdateDeviceState_withReportTime_offlineUsesGivenStateTime() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 20, 21, 22);
        IotDeviceDO device = IotDeviceDO.builder()
                .id(2L)
                .state(IotDeviceStateEnum.ONLINE.getState())
                .onlineTime(LocalDateTime.of(2026, 6, 13, 9, 0))
                .build();

        try (MockedStatic<SpringUtil> springUtilMock = mockStatic(SpringUtil.class)) {
            springUtilMock.when(() -> SpringUtil.getBean(IotDeviceServiceImpl.class)).thenReturn(service);
            service.updateDeviceState(device, IotDeviceStateEnum.OFFLINE.getState(), reportTime);
        }

        IotDeviceDO updateObj = captureUpdatedDevice();
        assertEquals(reportTime, updateObj.getOfflineTime());
        assertNull(updateObj.getActiveTime());
        assertNull(updateObj.getOnlineTime());
    }

    private IotDeviceDO captureUpdatedDevice() {
        ArgumentCaptor<IotDeviceDO> captor = ArgumentCaptor.forClass(IotDeviceDO.class);
        verify(deviceMapper).updateById(captor.capture());
        return captor.getValue();
    }

}
