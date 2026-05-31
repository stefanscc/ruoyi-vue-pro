package cn.iocoder.yudao.module.infra.service.file;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.StrUtil;
import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.framework.web.config.WebProperties;
import cn.iocoder.yudao.module.infra.controller.admin.file.vo.file.FilePageReqVO;
import cn.iocoder.yudao.module.infra.controller.admin.file.vo.file.FileUploadReqVO;
import cn.iocoder.yudao.module.infra.dal.dataobject.file.FileDO;
import cn.iocoder.yudao.module.infra.dal.mysql.file.FileMapper;
import cn.iocoder.yudao.module.infra.framework.file.core.LocalFileStorage;
import cn.iocoder.yudao.module.infra.framework.file.core.utils.FileTypeUtils;
import jakarta.annotation.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.exception;
import static cn.iocoder.yudao.framework.common.exception.util.ServiceExceptionUtil.invalidParamException;
import static cn.iocoder.yudao.module.infra.enums.ErrorCodeConstants.FILE_NOT_EXISTS;

@Service
@Validated
public class FileServiceImpl implements FileService {

    @Resource
    private FileMapper fileMapper;

    @Resource
    private LocalFileStorage localFileStorage;

    @Resource
    private WebProperties webProperties;

    @Override
    public PageResult<FileDO> getFilePage(FilePageReqVO pageReqVO) {
        return fileMapper.selectPage(pageReqVO);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FileDO createFile(MultipartFile file, String directory) throws IOException {
        if (file == null || file.isEmpty()) {
            throw invalidParamException("上传文件不能为空");
        }
        if (!FileUploadReqVO.isDirectoryValid(directory)) {
            throw invalidParamException("文件目录不正确");
        }

        String relativePath = buildRelativePath(file.getOriginalFilename(), directory);
        localFileStorage.save(relativePath, file);

        FileDO fileDO = FileDO.builder()
                .name(StrUtil.blankToDefault(file.getOriginalFilename(), relativePath))
                .path(relativePath)
                .type(FileTypeUtils.detectContentType(file.getOriginalFilename(), file.getContentType()))
                .size(file.getSize())
                .build();
        fileMapper.insert(fileDO);

        fileDO.setUrl(webProperties.getAdminApi().getPrefix() + "/infra/file/download/" + fileDO.getId());
        fileMapper.updateById(FileDO.builder().id(fileDO.getId()).url(fileDO.getUrl()).build());
        return fileDO;
    }

    @Override
    public FileDO getFile(Long id) {
        return validateFileExists(id);
    }

    @Override
    public FileDownload getFileDownload(Long id) {
        FileDO file = validateFileExists(id);
        Path path = localFileStorage.resolvePath(file.getPath());
        if (!Files.exists(path)) {
            throw exception(FILE_NOT_EXISTS);
        }
        return new FileDownload(file, path);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteFile(Long id) throws IOException {
        FileDO file = validateFileExists(id);
        localFileStorage.delete(file.getPath());
        fileMapper.deleteById(id);
    }

    private FileDO validateFileExists(Long id) {
        FileDO file = fileMapper.selectById(id);
        if (file == null) {
            throw exception(FILE_NOT_EXISTS);
        }
        return file;
    }

    private static String buildRelativePath(String originalFilename, String directory) {
        String datePath = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        String extension = StrUtil.blankToDefault(FileUtil.extName(originalFilename), "");
        String fileName = UUID.randomUUID().toString().replace("-", "");
        if (StrUtil.isNotBlank(extension)) {
            fileName = fileName + "." + extension;
        }
        String relativePath = datePath + "/" + fileName;
        if (StrUtil.isBlank(directory)) {
            return relativePath;
        }
        return directory + "/" + relativePath;
    }

}
