package com.ems.east.module.system.controller.admin.auth;

import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.ems.east.framework.common.enums.CommonStatusEnum;
import com.ems.east.framework.common.pojo.CommonResult;
import com.ems.east.framework.datapermission.core.annotation.DataPermission;
import com.ems.east.framework.security.config.SecurityProperties;
import com.ems.east.framework.security.core.util.SecurityFrameworkUtils;
import com.ems.east.module.system.controller.admin.auth.vo.AuthLoginReqVO;
import com.ems.east.module.system.controller.admin.auth.vo.AuthLoginRespVO;
import com.ems.east.module.system.controller.admin.auth.vo.AuthPermissionInfoRespVO;
import com.ems.east.module.system.convert.auth.AuthConvert;
import com.ems.east.module.system.dal.dataobject.permission.MenuDO;
import com.ems.east.module.system.dal.dataobject.permission.RoleDO;
import com.ems.east.module.system.dal.dataobject.user.AdminUserDO;
import com.ems.east.module.system.enums.logger.LoginLogTypeEnum;
import com.ems.east.module.system.service.auth.AdminAuthService;
import com.ems.east.module.system.service.permission.MenuService;
import com.ems.east.module.system.service.permission.PermissionService;
import com.ems.east.module.system.service.permission.RoleService;
import com.ems.east.module.system.service.user.AdminUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.annotation.security.PermitAll;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.List;
import java.util.Set;

import static com.ems.east.framework.common.pojo.CommonResult.success;
import static com.ems.east.framework.common.util.collection.CollectionUtils.convertSet;
import static com.ems.east.framework.security.core.util.SecurityFrameworkUtils.getLoginUserId;

@Tag(name = "管理后台 - 认证")
@RestController
@RequestMapping("/system/auth")
@Validated
@Slf4j
public class AuthController {

    @Resource
    private AdminAuthService authService;
    @Resource
    private AdminUserService userService;
    @Resource
    private RoleService roleService;
    @Resource
    private MenuService menuService;
    @Resource
    private PermissionService permissionService;
    @Resource
    private SecurityProperties securityProperties;

    @PostMapping("/login")
    @PermitAll
    @Operation(summary = "使用账号密码登录")
    public CommonResult<AuthLoginRespVO> login(@RequestBody @Valid AuthLoginReqVO reqVO) {
        return success(authService.login(reqVO));
    }

    @PostMapping("/logout")
    @PermitAll
    @Operation(summary = "退出系统")
    public CommonResult<Boolean> logout(HttpServletRequest request) {
        String token = SecurityFrameworkUtils.obtainAuthorization(request,
                securityProperties.getTokenHeader(), securityProperties.getTokenParameter());
        if (StrUtil.isNotBlank(token)) {
            authService.logout(token, LoginLogTypeEnum.LOGOUT_SELF.getType());
        }
        return success(true);
    }

    @PostMapping("/refresh-token")
    @PermitAll
    @Operation(summary = "刷新令牌")
    @Parameter(name = "refreshToken", description = "刷新令牌", required = true)
    public CommonResult<AuthLoginRespVO> refreshToken(@RequestParam("refreshToken") String refreshToken) {
        return success(authService.refreshToken(refreshToken));
    }

    @GetMapping("/get-permission-info")
    @Operation(summary = "获取登录用户的权限信息")
    @DataPermission(enable = false)
    public CommonResult<AuthPermissionInfoRespVO> getPermissionInfo() {
        AdminUserDO user = userService.getUser(getLoginUserId());
        if (user == null) {
            return success(null);
        }

        Set<Long> roleIds = permissionService.getUserRoleIdListByUserId(getLoginUserId());
        if (CollUtil.isEmpty(roleIds)) {
            return success(AuthConvert.INSTANCE.convert(user, Collections.emptyList(), Collections.emptyList()));
        }
        List<RoleDO> roles = roleService.getRoleList(roleIds);
        roles.removeIf(role -> !CommonStatusEnum.ENABLE.getStatus().equals(role.getStatus()));
        Set<Long> menuIds = permissionService.getRoleMenuListByRoleId(convertSet(roles, RoleDO::getId));
        List<MenuDO> menuList = menuService.filterDisableMenus(menuService.getMenuList(menuIds));
        return success(AuthConvert.INSTANCE.convert(user, roles, menuList));
    }

}
