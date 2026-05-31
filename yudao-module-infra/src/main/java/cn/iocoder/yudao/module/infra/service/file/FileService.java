package cn.iocoder.yudao.module.infra.service.file;

import cn.iocoder.yudao.framework.common.pojo.PageResult;
import cn.iocoder.yudao.module.infra.controller.admin.file.vo.file.FilePageReqVO;
import cn.iocoder.yudao.module.infra.dal.dataobject.file.FileDO;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Path;

public interface FileService {

    PageResult<FileDO> getFilePage(FilePageReqVO pageReqVO);

    FileDO createFile(MultipartFile file, String directory) throws IOException;

    FileDO getFile(Long id);

    FileDownload getFileDownload(Long id);

    void deleteFile(Long id) throws IOException;

    record FileDownload(FileDO file, Path path) {
    }

}
