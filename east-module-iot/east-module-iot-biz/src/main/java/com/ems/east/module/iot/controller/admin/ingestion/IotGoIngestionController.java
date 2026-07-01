package com.ems.east.module.iot.controller.admin.ingestion;

import com.ems.east.framework.common.pojo.CommonResult;
import com.ems.east.module.iot.service.ingestion.IotGoIngestionClient;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

import static com.ems.east.framework.common.pojo.CommonResult.success;

@Tag(name = "管理后台 - IoT Go Ingestion")
@RestController
@RequestMapping("/iot/go-ingestion")
@Validated
public class IotGoIngestionController {

    @Resource
    private IotGoIngestionClient goIngestionClient;

    @GetMapping("/health")
    @Operation(summary = "获得 Go ingestion 健康状态")
    @PreAuthorize("@ss.hasPermission('iot:device:query')")
    public CommonResult<Map<String, Object>> health() {
        return success(goIngestionClient.health());
    }

}
