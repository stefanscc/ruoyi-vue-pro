package com.ems.yudao.module.infra.api.logger;

import com.ems.yudao.framework.common.biz.infra.logger.ApiErrorLogCommonApi;
import com.ems.yudao.framework.common.biz.infra.logger.dto.ApiErrorLogCreateReqDTO;
import com.ems.yudao.module.infra.service.logger.ApiErrorLogService;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

import javax.annotation.Resource;

/**
 * API 访问日志的 API 接口
 *
 * @author 芋道源码
 */
@Service
@Validated
public class ApiErrorLogApiImpl implements ApiErrorLogCommonApi {

    @Resource
    private ApiErrorLogService apiErrorLogService;

    @Override
    public void createApiErrorLog(ApiErrorLogCreateReqDTO createDTO) {
        apiErrorLogService.createApiErrorLog(createDTO);
    }

}
