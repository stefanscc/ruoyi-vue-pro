package com.ems.yudao.module.pay.controller.admin.wallet;

import com.ems.yudao.framework.common.pojo.CommonResult;
import com.ems.yudao.framework.common.pojo.PageResult;
import com.ems.yudao.module.pay.controller.admin.wallet.vo.wallet.PayWalletPageReqVO;
import com.ems.yudao.module.pay.controller.admin.wallet.vo.wallet.PayWalletRespVO;
import com.ems.yudao.module.pay.controller.admin.wallet.vo.wallet.PayWalletUpdateBalanceReqVO;
import com.ems.yudao.module.pay.controller.admin.wallet.vo.wallet.PayWalletUserReqVO;
import com.ems.yudao.module.pay.convert.wallet.PayWalletConvert;
import com.ems.yudao.module.pay.dal.dataobject.wallet.PayWalletDO;
import com.ems.yudao.module.pay.enums.wallet.PayWalletBizTypeEnum;
import com.ems.yudao.module.pay.service.wallet.PayWalletService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import javax.validation.Valid;

import static com.ems.yudao.framework.common.enums.UserTypeEnum.MEMBER;
import static com.ems.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static com.ems.yudao.framework.common.pojo.CommonResult.success;
import static com.ems.yudao.module.pay.enums.ErrorCodeConstants.WALLET_NOT_FOUND;

@Tag(name = "管理后台 - 用户钱包")
@RestController
@RequestMapping("/pay/wallet")
@Validated
@Slf4j
public class PayWalletController {

    @Resource
    private PayWalletService payWalletService;

    @GetMapping("/get")
    @PreAuthorize("@ss.hasPermission('pay:wallet:query')")
    @Operation(summary = "获得用户钱包明细")
    public CommonResult<PayWalletRespVO> getWallet(PayWalletUserReqVO reqVO) {
        PayWalletDO wallet = payWalletService.getOrCreateWallet(reqVO.getUserId(), MEMBER.getValue());
        return success(PayWalletConvert.INSTANCE.convert02(wallet));
    }

    @GetMapping("/page")
    @Operation(summary = "获得会员钱包分页")
    @PreAuthorize("@ss.hasPermission('pay:wallet:query')")
    public CommonResult<PageResult<PayWalletRespVO>> getWalletPage(@Valid PayWalletPageReqVO pageVO) {
        PageResult<PayWalletDO> pageResult = payWalletService.getWalletPage(pageVO);
        return success(PayWalletConvert.INSTANCE.convertPage(pageResult));
    }

    @PutMapping("/update-balance")
    @Operation(summary = "更新会员用户余额")
    @PreAuthorize("@ss.hasPermission('pay:wallet:update-balance')")
    public CommonResult<Boolean> updateWalletBalance(@Valid @RequestBody PayWalletUpdateBalanceReqVO updateReqVO) {
        // 获得用户钱包
        PayWalletDO wallet = payWalletService.getOrCreateWallet(updateReqVO.getUserId(), MEMBER.getValue());
        if (wallet == null) {
            log.error("[updateWalletBalance]，updateReqVO({}) 用户钱包不存在.", updateReqVO);
            throw exception(WALLET_NOT_FOUND);
        }

        // 更新钱包余额
        payWalletService.addWalletBalance(wallet.getId(), String.valueOf(updateReqVO.getUserId()),
                PayWalletBizTypeEnum.UPDATE_BALANCE, updateReqVO.getBalance());
        return success(true);
    }

}
