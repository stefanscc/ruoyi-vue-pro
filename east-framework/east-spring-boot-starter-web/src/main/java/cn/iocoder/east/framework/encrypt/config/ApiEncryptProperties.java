package cn.iocoder.east.framework.encrypt.config;

import cn.hutool.core.util.StrUtil;
import jakarta.validation.constraints.AssertTrue;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

/**
 * HTTP API 加解密配置
 *
 * @author 芋道源码
 */
@ConfigurationProperties(prefix = "east.api-encrypt")
@Validated
@Data
public class ApiEncryptProperties {

    /**
     * 是否开启
     */
    private Boolean enable = false;

    /**
     * 请求头（响应头）名称
     *
     * 1. 如果该请求头非空，则表示请求参数已被「前端」加密，「后端」需要解密
     * 2. 如果该响应头非空，则表示响应结果已被「后端」加密，「前端」需要解密
     */
    private String header = "X-Api-Encrypt";

    /**
     * 对称加密算法，用于请求/响应的加解密
     *
     * 目前支持
     * 【对称加密】：
     *      1. {@link cn.hutool.crypto.symmetric.SymmetricAlgorithm#AES}
     *      2. {@link cn.hutool.crypto.symmetric.SM4#ALGORITHM_NAME} （需要自己二次开发，成本低）
     * 【非对称加密】
     *      1. {@link cn.hutool.crypto.asymmetric.AsymmetricAlgorithm#RSA}
     *      2. {@link cn.hutool.crypto.asymmetric.SM2} （需要自己二次开发，成本低）
     *
     * @see <a href="https://help.aliyun.com/zh/ssl-certificate/what-are-a-public-key-and-a-private-key">什么是公钥和私钥？</a>
     */
    private String algorithm = "AES";

    /**
     * 请求的解密密钥
     *
     * 注意：
     * 1. 如果是【对称加密】时，它「后端」对应的是“密钥”。对应的，「前端」也对应的也是“密钥”。
     * 2. 如果是【非对称加密】时，它「后端」对应的是“私钥”。对应的，「前端」对应的是“公钥”。（重要！！！）
     */
    private String requestKey;

    /**
     * 响应的加密密钥
     *
     * 注意：
     * 1. 如果是【对称加密】时，它「后端」对应的是“密钥”。对应的，「前端」也对应的也是“密钥”。
     * 2. 如果是【非对称加密】时，它「后端」对应的是“公钥”。对应的，「前端」对应的是“私钥”。（重要！！！）
     */
    private String responseKey;

    @AssertTrue(message = "开启 API 加解密时，algorithm、requestKey、responseKey 不能为空")
    public boolean isEncryptionConfigValid() {
        if (!Boolean.TRUE.equals(enable)) {
            return true;
        }
        return StrUtil.isNotBlank(algorithm)
                && StrUtil.isNotBlank(requestKey)
                && StrUtil.isNotBlank(responseKey);
    }

}
