package com.ems.yudao.module.mp.dal.mysql.message;

import com.ems.yudao.framework.mybatis.core.mapper.BaseMapperX;
import com.ems.yudao.module.mp.controller.admin.message.vo.template.MpMessageTemplateListReqVO;
import com.ems.yudao.module.mp.dal.dataobject.message.MpMessageTemplateDO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface MpMessageTemplateMapper extends BaseMapperX<MpMessageTemplateDO> {

    default List<MpMessageTemplateDO> selectList(MpMessageTemplateListReqVO listReqVO) {
        return selectList(MpMessageTemplateDO::getAccountId, listReqVO.getAccountId());
    }

}