package com.ems.east.module.system.service.auth;

import cn.hutool.core.util.ReflectUtil;
import com.ems.east.framework.common.enums.CommonStatusEnum;
import com.ems.east.framework.common.enums.UserTypeEnum;
import com.ems.east.framework.test.core.ut.BaseDbUnitTest;
import com.ems.east.module.system.controller.admin.auth.vo.AuthLoginReqVO;
import com.ems.east.module.system.controller.admin.auth.vo.AuthLoginRespVO;
import com.ems.east.module.system.dal.dataobject.oauth2.OAuth2AccessTokenDO;
import com.ems.east.module.system.dal.dataobject.user.AdminUserDO;
import com.ems.east.module.system.enums.logger.LoginLogTypeEnum;
import com.ems.east.module.system.enums.logger.LoginResultEnum;
import com.ems.east.module.system.service.logger.LoginLogService;
import com.ems.east.module.system.service.member.MemberService;
import com.ems.east.module.system.service.oauth2.OAuth2TokenService;
import com.ems.east.module.system.service.user.AdminUserService;
import com.anji.captcha.model.common.ResponseModel;
import com.anji.captcha.service.CaptchaService;
import jakarta.annotation.Resource;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import static com.ems.east.framework.test.core.util.AssertUtils.assertPojoEquals;
import static com.ems.east.framework.test.core.util.AssertUtils.assertServiceException;
import static com.ems.east.framework.test.core.util.RandomUtils.randomPojo;
import static com.ems.east.framework.test.core.util.RandomUtils.randomString;
import static com.ems.east.module.system.enums.ErrorCodeConstants.AUTH_LOGIN_BAD_CREDENTIALS;
import static com.ems.east.module.system.enums.ErrorCodeConstants.AUTH_LOGIN_CAPTCHA_CODE_ERROR;
import static com.ems.east.module.system.enums.ErrorCodeConstants.AUTH_LOGIN_USER_DISABLED;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@Import(AdminAuthServiceImpl.class)
class AdminAuthServiceImplTest extends BaseDbUnitTest {

    @Resource
    private AdminAuthServiceImpl authService;

    @MockitoBean
    private AdminUserService userService;
    @MockitoBean
    private CaptchaService captchaService;
    @MockitoBean
    private LoginLogService loginLogService;
    @MockitoBean
    private OAuth2TokenService oauth2TokenService;
    @MockitoBean
    private MemberService memberService;
    @MockitoBean
    private Validator validator;

    @BeforeEach
    void setUp() {
        authService.setCaptchaEnable(true);
        ReflectUtil.setFieldValue(authService, "validator",
                Validation.buildDefaultValidatorFactory().getValidator());
    }

    @Test
    void testAuthenticate_success() {
        String username = randomString();
        String password = randomString();
        AdminUserDO user = randomPojo(AdminUserDO.class, o -> o.setUsername(username)
                .setPassword(password).setStatus(CommonStatusEnum.ENABLE.getStatus()));
        when(userService.getUserByUsername(eq(username))).thenReturn(user);
        when(userService.isPasswordMatch(eq(password), eq(user.getPassword()))).thenReturn(true);

        AdminUserDO loginUser = authService.authenticate(username, password);
        assertPojoEquals(user, loginUser);
    }

    @Test
    void testAuthenticate_userNotFound() {
        assertServiceException(() -> authService.authenticate(randomString(), randomString()),
                AUTH_LOGIN_BAD_CREDENTIALS);
        verify(loginLogService).createLoginLog(argThat(o -> o.getUserId() == null
                && o.getResult().equals(LoginResultEnum.BAD_CREDENTIALS.getResult())));
    }

    @Test
    void testAuthenticate_userDisabled() {
        String username = randomString();
        String password = randomString();
        AdminUserDO user = randomPojo(AdminUserDO.class, o -> o.setUsername(username)
                .setPassword(password).setStatus(CommonStatusEnum.DISABLE.getStatus()));
        when(userService.getUserByUsername(eq(username))).thenReturn(user);
        when(userService.isPasswordMatch(eq(password), eq(user.getPassword()))).thenReturn(true);

        assertServiceException(() -> authService.authenticate(username, password), AUTH_LOGIN_USER_DISABLED);
    }

    @Test
    void testLogin_success() {
        AuthLoginReqVO reqVO = new AuthLoginReqVO("testuser", "testpass");
        reqVO.setCaptchaVerification(randomString());
        authService.setCaptchaEnable(false);

        AdminUserDO user = randomPojo(AdminUserDO.class, o -> o.setId(1L).setUsername("testuser")
                .setPassword("testpass").setStatus(CommonStatusEnum.ENABLE.getStatus()));
        when(userService.getUserByUsername(eq("testuser"))).thenReturn(user);
        when(userService.isPasswordMatch(eq("testpass"), eq(user.getPassword()))).thenReturn(true);
        OAuth2AccessTokenDO accessTokenDO = randomPojo(OAuth2AccessTokenDO.class, o -> o.setUserId(1L)
                .setUserType(UserTypeEnum.ADMIN.getValue()));
        when(oauth2TokenService.createAccessToken(eq(1L), eq(UserTypeEnum.ADMIN.getValue()), eq("default"), isNull()))
                .thenReturn(accessTokenDO);

        AuthLoginRespVO loginRespVO = authService.login(reqVO);
        assertPojoEquals(accessTokenDO, loginRespVO);
    }

    @Test
    void testValidateCaptcha_fail() {
        AuthLoginReqVO reqVO = new AuthLoginReqVO("testuser", "testpass");
        reqVO.setCaptchaVerification(randomString());
        when(captchaService.verification(any())).thenReturn(ResponseModel.errorMsg("bad captcha"));

        assertServiceException(() -> authService.validateCaptcha(reqVO), AUTH_LOGIN_CAPTCHA_CODE_ERROR, "bad captcha");
    }

    @Test
    void testRefreshToken() {
        String refreshToken = randomString();
        OAuth2AccessTokenDO accessTokenDO = randomPojo(OAuth2AccessTokenDO.class);
        when(oauth2TokenService.refreshAccessToken(eq(refreshToken), eq("default"))).thenReturn(accessTokenDO);

        AuthLoginRespVO loginRespVO = authService.refreshToken(refreshToken);
        assertPojoEquals(accessTokenDO, loginRespVO);
    }

    @Test
    void testLogout_success() {
        String token = randomString();
        OAuth2AccessTokenDO accessTokenDO = randomPojo(OAuth2AccessTokenDO.class, o -> o.setUserId(1L)
                .setUserType(UserTypeEnum.ADMIN.getValue()));
        when(oauth2TokenService.removeAccessToken(eq(token))).thenReturn(accessTokenDO);

        authService.logout(token, LoginLogTypeEnum.LOGOUT_SELF.getType());
        verify(loginLogService).createLoginLog(argThat(o ->
                o.getLogType().equals(LoginLogTypeEnum.LOGOUT_SELF.getType())
                        && o.getResult().equals(LoginResultEnum.SUCCESS.getResult())));
    }

    @Test
    void testLogout_whenTokenMissing() {
        authService.logout(randomString(), LoginLogTypeEnum.LOGOUT_SELF.getType());
        verify(loginLogService, never()).createLoginLog(any());
    }

}
