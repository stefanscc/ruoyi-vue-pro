package cn.iocoder.yudao.module.infra.framework.file.config;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.validation.annotation.Validated;

@Component
@ConfigurationProperties(prefix = "yudao.file")
@Validated
@Data
public class YudaoFileProperties {

    @NotBlank(message = "文件存储根目录不能为空")
    private String basePath;

}
