package cn.iocoder.yudao.module.system.service.auth;

import cn.iocoder.yudao.module.system.controller.admin.auth.vo.AuthLoginReqVO;
import cn.iocoder.yudao.module.system.controller.admin.auth.vo.AuthLoginRespVO;
import cn.iocoder.yudao.module.system.dal.dataobject.user.AdminUserDO;
import jakarta.validation.Valid;

public interface AdminAuthService {

    AdminUserDO authenticate(String username, String password);

    AuthLoginRespVO login(@Valid AuthLoginReqVO reqVO);

    void logout(String token, Integer logType);

    AuthLoginRespVO refreshToken(String refreshToken);

}
