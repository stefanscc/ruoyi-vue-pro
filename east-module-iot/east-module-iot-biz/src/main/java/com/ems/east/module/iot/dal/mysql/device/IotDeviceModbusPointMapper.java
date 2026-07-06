package com.ems.east.module.iot.dal.mysql.device;

import com.ems.east.framework.common.pojo.PageResult;
import com.ems.east.framework.mybatis.core.mapper.BaseMapperX;
import com.ems.east.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.ems.east.module.iot.controller.admin.device.vo.modbus.IotDeviceModbusPointPageReqVO;
import com.ems.east.module.iot.dal.dataobject.device.IotDeviceModbusPointDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.Collection;
import java.util.List;

/**
 * IoT 设备 Modbus 点位配置 Mapper
 *
 * @author Hand of God
 */
@Mapper
public interface IotDeviceModbusPointMapper extends BaseMapperX<IotDeviceModbusPointDO> {

    default PageResult<IotDeviceModbusPointDO> selectPage(IotDeviceModbusPointPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<IotDeviceModbusPointDO>()
                .eqIfPresent(IotDeviceModbusPointDO::getDeviceId, reqVO.getDeviceId())
                .likeIfPresent(IotDeviceModbusPointDO::getIdentifier, reqVO.getIdentifier())
                .likeIfPresent(IotDeviceModbusPointDO::getName, reqVO.getName())
                .eqIfPresent(IotDeviceModbusPointDO::getFunctionCode, reqVO.getFunctionCode())
                .eqIfPresent(IotDeviceModbusPointDO::getStatus, reqVO.getStatus())
                .orderByDesc(IotDeviceModbusPointDO::getId));
    }

    default List<IotDeviceModbusPointDO> selectListByDeviceIdsAndStatus(Collection<Long> deviceIds, Integer status) {
        return selectList(new LambdaQueryWrapperX<IotDeviceModbusPointDO>()
                .in(IotDeviceModbusPointDO::getDeviceId, deviceIds)
                .eq(IotDeviceModbusPointDO::getStatus, status));
    }

    default IotDeviceModbusPointDO selectByDeviceIdAndIdentifier(Long deviceId, String identifier) {
        return selectOne(IotDeviceModbusPointDO::getDeviceId, deviceId,
                IotDeviceModbusPointDO::getIdentifier, identifier);
    }

    default void updateByThingModelId(Long thingModelId, IotDeviceModbusPointDO updateObj) {
        update(updateObj, new LambdaQueryWrapperX<IotDeviceModbusPointDO>()
                .eq(IotDeviceModbusPointDO::getThingModelId, thingModelId));
    }

}
