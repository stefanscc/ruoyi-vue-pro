package com.ems.east.module.iot.core.mq.message;

import com.ems.east.framework.common.util.json.JsonUtils;
import com.ems.east.module.iot.core.enums.IotDeviceMessageMethodEnum;
import com.ems.east.module.iot.core.topic.IotDeviceIdentity;
import com.ems.east.module.iot.core.topic.state.IotDeviceStateUpdateReqDTO;
import com.ems.east.module.iot.core.topic.state.IotSubDeviceStatePackPostReqDTO;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * {@link IotDeviceMessage} 的子设备状态批量上报支持测试
 */
public class IotDeviceMessageStatePackSupportTest {

    @Test
    public void testBuildStateUpdatePreserveCustomReportTime() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 10, 20, 30);

        IotDeviceMessage message = IotDeviceMessage.buildStateUpdate(1, reportTime);

        assertEquals(reportTime, message.getReportTime());
        assertEquals("thing.state.update", message.getMethod());
        assertInstanceOf(IotDeviceStateUpdateReqDTO.class, message.getParams());
        assertEquals(1, ((IotDeviceStateUpdateReqDTO) message.getParams()).getState());
    }

    @Test
    public void testStatePackPostReqDTOJsonRoundTrip() {
        IotSubDeviceStatePackPostReqDTO reqDTO = new IotSubDeviceStatePackPostReqDTO();
        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("pk-1", "dev-1"));
        subDeviceState.setState(1);
        subDeviceState.setTime(1710000000000L);
        reqDTO.setSubDevices(List.of(subDeviceState));

        String json = JsonUtils.toJsonString(reqDTO);
        assertTrue(json.contains("\"subDevices\""));
        assertTrue(json.contains("\"identity\""));
        assertTrue(json.contains("\"productKey\""));
        assertTrue(json.contains("\"deviceName\""));
        assertTrue(json.contains("\"state\""));
        assertTrue(json.contains("\"time\""));
        assertTrue(json.contains("pk-1"));
        assertTrue(json.contains("dev-1"));
        assertTrue(json.contains("1710000000000"));

        IotSubDeviceStatePackPostReqDTO parsed = JsonUtils.parseObject(json, IotSubDeviceStatePackPostReqDTO.class);

        assertNotNull(parsed);
        assertNotNull(parsed.getSubDevices());
        assertEquals(1, parsed.getSubDevices().size());
        assertEquals("pk-1", parsed.getSubDevices().get(0).getIdentity().getProductKey());
        assertEquals("dev-1", parsed.getSubDevices().get(0).getIdentity().getDeviceName());
        assertEquals(1, parsed.getSubDevices().get(0).getState());
        assertEquals(1710000000000L, parsed.getSubDevices().get(0).getTime());
    }

    @Test
    public void testBuildSubDeviceStatePackPost() {
        IotSubDeviceStatePackPostReqDTO reqDTO = new IotSubDeviceStatePackPostReqDTO();
        IotSubDeviceStatePackPostReqDTO.SubDeviceState subDeviceState = new IotSubDeviceStatePackPostReqDTO.SubDeviceState();
        subDeviceState.setIdentity(new IotDeviceIdentity("pk-1", "dev-1"));
        subDeviceState.setState(1);
        subDeviceState.setTime(1710000000000L);
        reqDTO.setSubDevices(List.of(subDeviceState));

        IotDeviceMessage message = IotDeviceMessage.buildSubDeviceStatePackPost(reqDTO);

        assertEquals(IotDeviceMessageMethodEnum.SUB_DEVICE_STATE_PACK_POST.getMethod(), message.getMethod());
        assertSame(reqDTO, message.getParams());
        assertInstanceOf(IotSubDeviceStatePackPostReqDTO.class, message.getParams());
        IotSubDeviceStatePackPostReqDTO parsedParams = (IotSubDeviceStatePackPostReqDTO) message.getParams();
        assertNotNull(parsedParams.getSubDevices());
        assertEquals(1, parsedParams.getSubDevices().size());
        assertEquals("pk-1", parsedParams.getSubDevices().get(0).getIdentity().getProductKey());
        assertEquals("dev-1", parsedParams.getSubDevices().get(0).getIdentity().getDeviceName());
        assertEquals(1, parsedParams.getSubDevices().get(0).getState());
        assertEquals(1710000000000L, parsedParams.getSubDevices().get(0).getTime());
    }

}
