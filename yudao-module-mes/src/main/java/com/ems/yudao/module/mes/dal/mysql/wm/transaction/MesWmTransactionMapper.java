package com.ems.yudao.module.mes.dal.mysql.wm.transaction;

import com.ems.yudao.framework.mybatis.core.mapper.BaseMapperX;
import com.ems.yudao.module.mes.dal.dataobject.wm.transaction.MesWmTransactionDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * MES 库存事务流水 Mapper
 */
@Mapper
public interface MesWmTransactionMapper extends BaseMapperX<MesWmTransactionDO> {

}
