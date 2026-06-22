package cn.iocoder.east.module.infra.framework.file.core.utils;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

public class FileTypeUtils {

    private FileTypeUtils() {
    }

    public static String detectContentType(String fileName, String fallbackType) {
        if (fallbackType != null && !fallbackType.isBlank()) {
            return fallbackType;
        }
        if (fileName == null || fileName.isBlank()) {
            return MediaType.APPLICATION_OCTET_STREAM_VALUE;
        }
        return MediaTypeFactory.getMediaType(fileName)
                .map(MediaType::toString)
                .orElse(MediaType.APPLICATION_OCTET_STREAM_VALUE);
    }

    public static void writeAttachment(HttpServletResponse response, String fileName,
                                       String contentType, Path path) throws IOException {
        String encodedFileName = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        response.setContentType(detectContentType(fileName, contentType));
        response.setHeader("Content-Disposition",
                "attachment; filename=\"" + encodedFileName + "\"; filename*=UTF-8''" + encodedFileName);
        response.setHeader("Content-Length", String.valueOf(Files.size(path)));
        try (var inputStream = Files.newInputStream(path);
             var outputStream = response.getOutputStream()) {
            inputStream.transferTo(outputStream);
            outputStream.flush();
        }
    }

}
