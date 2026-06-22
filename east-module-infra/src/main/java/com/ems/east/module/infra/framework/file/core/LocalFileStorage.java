package com.ems.east.module.infra.framework.file.core;

import com.ems.east.framework.common.exception.util.ServiceExceptionUtil;
import com.ems.east.module.infra.framework.file.config.EastFileProperties;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@Component
public class LocalFileStorage {

    @Resource
    private EastFileProperties fileProperties;

    public Path save(String relativePath, MultipartFile file) throws IOException {
        Path absolutePath = resolvePath(relativePath);
        Files.createDirectories(absolutePath.getParent());
        try (InputStream inputStream = file.getInputStream()) {
            Files.copy(inputStream, absolutePath, StandardCopyOption.REPLACE_EXISTING);
        }
        return absolutePath;
    }

    public Path resolvePath(String relativePath) {
        Path basePath = Paths.get(fileProperties.getBasePath()).toAbsolutePath().normalize();
        Path absolutePath = basePath.resolve(relativePath).normalize();
        if (!absolutePath.startsWith(basePath)) {
            throw ServiceExceptionUtil.invalidParamException("文件路径不正确");
        }
        return absolutePath;
    }

    public void delete(String relativePath) throws IOException {
        Files.deleteIfExists(resolvePath(relativePath));
    }

}
