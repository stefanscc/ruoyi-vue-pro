package com.ems.yudao.module.mes.dal.mysql.cal.team;

import com.ems.yudao.framework.common.pojo.PageResult;
import com.ems.yudao.framework.mybatis.core.mapper.BaseMapperX;
import com.ems.yudao.framework.mybatis.core.query.LambdaQueryWrapperX;
import com.ems.yudao.module.mes.controller.admin.cal.team.vo.MesCalTeamPageReqVO;
import com.ems.yudao.module.mes.dal.dataobject.cal.team.MesCalTeamDO;
import org.apache.ibatis.annotations.Mapper;

/**
 * MES 班组 Mapper
 *
 * @author 芋道源码
 */
@Mapper
public interface MesCalTeamMapper extends BaseMapperX<MesCalTeamDO> {

    default PageResult<MesCalTeamDO> selectPage(MesCalTeamPageReqVO reqVO) {
        return selectPage(reqVO, new LambdaQueryWrapperX<MesCalTeamDO>()
                .likeIfPresent(MesCalTeamDO::getCode, reqVO.getCode())
                .likeIfPresent(MesCalTeamDO::getName, reqVO.getName())
                .eqIfPresent(MesCalTeamDO::getCalendarType, reqVO.getCalendarType())
                .orderByDesc(MesCalTeamDO::getId));
    }

    default MesCalTeamDO selectByCode(String code) {
        return selectOne(MesCalTeamDO::getCode, code);
    }

}
