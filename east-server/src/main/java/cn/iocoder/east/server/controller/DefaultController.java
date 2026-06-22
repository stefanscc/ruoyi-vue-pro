package cn.iocoder.east.server.controller;

import cn.iocoder.east.framework.common.pojo.CommonResult;
import cn.iocoder.east.framework.common.util.servlet.ServletUtils;
import jakarta.annotation.security.PermitAll;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Lightweight default controller for local diagnostics.
 */
@RestController
@Slf4j
public class DefaultController {

    /**
     * Test endpoint: print query, header, body.
     */
    @RequestMapping("/test")
    @PermitAll
    public CommonResult<Boolean> test(HttpServletRequest request) {
        log.info("Query: {}", ServletUtils.getParamMap(request));
        log.info("Header: {}", ServletUtils.getHeaderMap(request));
        log.info("Body: {}", ServletUtils.getBody(request));
        return CommonResult.success(true);
    }

}
