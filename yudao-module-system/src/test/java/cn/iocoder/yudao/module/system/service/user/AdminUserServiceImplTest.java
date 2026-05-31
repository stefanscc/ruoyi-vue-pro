package cn.iocoder.yudao.module.system.service.user;

import cn.hutool.core.util.RandomUtil;
import cn.iocoder.yudao.framework.common.enums.CommonStatusEnum;
import cn.iocoder.yudao.framework.test.core.ut.BaseDbUnitTest;
import cn.iocoder.yudao.module.system.controller.admin.user.vo.profile.UserProfileUpdatePasswordReqVO;
import cn.iocoder.yudao.module.system.controller.admin.user.vo.user.UserSaveReqVO;
import cn.iocoder.yudao.module.system.dal.dataobject.dept.DeptDO;
import cn.iocoder.yudao.module.system.dal.dataobject.dept.PostDO;
import cn.iocoder.yudao.module.system.dal.dataobject.dept.UserPostDO;
import cn.iocoder.yudao.module.system.dal.dataobject.user.AdminUserDO;
import cn.iocoder.yudao.module.system.dal.mysql.dept.UserPostMapper;
import cn.iocoder.yudao.module.system.dal.mysql.user.AdminUserMapper;
import cn.iocoder.yudao.module.system.enums.common.SexEnum;
import cn.iocoder.yudao.module.system.service.dept.DeptService;
import cn.iocoder.yudao.module.system.service.dept.PostService;
import cn.iocoder.yudao.module.system.service.oauth2.OAuth2TokenService;
import cn.iocoder.yudao.module.system.service.permission.PermissionService;
import jakarta.annotation.Resource;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.stubbing.Answer;
import org.springframework.context.annotation.Import;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.List;
import java.util.function.Consumer;

import static cn.iocoder.yudao.framework.common.util.collection.SetUtils.asSet;
import static cn.iocoder.yudao.framework.test.core.util.AssertUtils.assertPojoEquals;
import static cn.iocoder.yudao.framework.test.core.util.AssertUtils.assertServiceException;
import static cn.iocoder.yudao.framework.test.core.util.RandomUtils.randomPojo;
import static cn.iocoder.yudao.framework.test.core.util.RandomUtils.randomString;
import static cn.iocoder.yudao.module.system.enums.ErrorCodeConstants.USER_PASSWORD_FAILED;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@Import(AdminUserServiceImpl.class)
class AdminUserServiceImplTest extends BaseDbUnitTest {

    @Resource
    private AdminUserServiceImpl userService;
    @Resource
    private AdminUserMapper userMapper;
    @Resource
    private UserPostMapper userPostMapper;

    @MockitoBean
    private DeptService deptService;
    @MockitoBean
    private PostService postService;
    @MockitoBean
    private PermissionService permissionService;
    @MockitoBean
    private PasswordEncoder passwordEncoder;
    @MockitoBean
    private OAuth2TokenService oauth2TokenService;

    @Test
    void testCreateUser_success() {
        UserSaveReqVO reqVO = randomPojo(UserSaveReqVO.class, o -> {
            o.setSex(RandomUtil.randomEle(SexEnum.values()).getSex());
            o.setMobile(randomString());
            o.setPostIds(asSet(1L, 2L));
        }).setId(null);
        DeptDO dept = randomPojo(DeptDO.class, o -> o.setId(reqVO.getDeptId()).setStatus(CommonStatusEnum.ENABLE.getStatus()));
        when(deptService.getDept(eq(dept.getId()))).thenReturn(dept);
        List<PostDO> posts = List.of(
                randomPojo(PostDO.class, o -> o.setId(1L).setStatus(CommonStatusEnum.ENABLE.getStatus())),
                randomPojo(PostDO.class, o -> o.setId(2L).setStatus(CommonStatusEnum.ENABLE.getStatus()))
        );
        when(postService.getPostList(eq(reqVO.getPostIds()), isNull())).thenReturn(posts);
        when(passwordEncoder.encode(eq(reqVO.getPassword()))).thenReturn("encoded");

        Long userId = userService.createUser(reqVO);
        AdminUserDO user = userMapper.selectById(userId);
        assertPojoEquals(reqVO, user, "password", "id");
        assertEquals("encoded", user.getPassword());
        assertEquals(CommonStatusEnum.ENABLE.getStatus(), user.getStatus());
        assertEquals(2, userPostMapper.selectListByUserId(userId).size());
    }

    @Test
    void testUpdateUserStatus_disableRemovesTokens() {
        AdminUserDO dbUser = randomAdminUserDO();
        userMapper.insert(dbUser);

        userService.updateUserStatus(dbUser.getId(), CommonStatusEnum.DISABLE.getStatus());
        verify(oauth2TokenService, times(1)).removeAccessToken(eq(dbUser.getId()), eq(2));
    }

    @Test
    void testDeleteUser_success() {
        AdminUserDO dbUser = randomAdminUserDO();
        userMapper.insert(dbUser);

        userService.deleteUser(dbUser.getId());
        assertNull(userMapper.selectById(dbUser.getId()));
        verify(permissionService).processUserDeleted(dbUser.getId());
    }

    @Test
    void testUpdateUserPassword_success() {
        AdminUserDO dbUser = randomAdminUserDO(o -> o.setPassword("encode:old"));
        userMapper.insert(dbUser);
        UserProfileUpdatePasswordReqVO reqVO = randomPojo(UserProfileUpdatePasswordReqVO.class, o -> {
            o.setOldPassword("old");
            o.setNewPassword("new");
        });
        when(passwordEncoder.encode(anyString())).then((Answer<String>) inv -> "encode:" + inv.getArgument(0));
        when(passwordEncoder.matches(eq("old"), eq("encode:old"))).thenReturn(true);

        userService.updateUserPassword(dbUser.getId(), reqVO);
        assertEquals("encode:new", userMapper.selectById(dbUser.getId()).getPassword());
    }

    @Test
    void testValidateOldPassword_passwordFailed() {
        AdminUserDO dbUser = randomAdminUserDO(o -> o.setPassword("encode:old"));
        userMapper.insert(dbUser);

        assertServiceException(() -> userService.validateOldPassword(dbUser.getId(), "bad"), USER_PASSWORD_FAILED);
    }

    @SafeVarargs
    private static AdminUserDO randomAdminUserDO(Consumer<AdminUserDO>... consumers) {
        Consumer<AdminUserDO> base = o -> {
            o.setStatus(CommonStatusEnum.ENABLE.getStatus());
            o.setSex(RandomUtil.randomEle(SexEnum.values()).getSex());
        };
        return randomPojo(AdminUserDO.class, cn.iocoder.yudao.framework.common.util.collection.ArrayUtils.append(base, consumers));
    }

}
