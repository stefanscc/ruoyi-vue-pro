package com.ems.yudao.module.mes.dal.mysql.wm.productproduce;

import com.ems.yudao.framework.mybatis.core.mapper.BaseMapperX;
import com.ems.yudao.module.mes.dal.dataobject.wm.productproduce.MesWmProductProduceDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * MES 生产入库单 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MesWmProductProduceMapper extends BaseMapperX<MesWmProductProduceDO> {

    default MesWmProductProduceDO selectByFeedbackId(Long feedbackId) {
        return selectOne(MesWmProductProduceDO::getFeedbackId, feedbackId);
    }

}
