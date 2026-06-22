package com.ems.east.framework.banner.core;

import cn.hutool.core.thread.ThreadUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;

import java.util.concurrent.TimeUnit;

/**
 * Print a concise startup banner after the application is ready.
 */
@Slf4j
public class BannerApplicationRunner implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) {
        ThreadUtil.execute(() -> {
            ThreadUtil.sleep(1, TimeUnit.SECONDS);
            log.info("\n----------------------------------------------------------\n\t" +
                            "EMS base application started\n\t" +
                            "API docs: \t{} \n\t" +
                            "Project docs: \t{} \n" +
                            "----------------------------------------------------------",
                    "https://doc.iocoder.cn/api-doc/",
                    "https://doc.iocoder.cn");
        });
    }

}
