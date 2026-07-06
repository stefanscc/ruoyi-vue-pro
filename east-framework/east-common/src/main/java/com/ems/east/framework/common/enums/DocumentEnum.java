package com.ems.east.framework.common.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 文档地址
 *
 * @author Hand of God
 */
@Getter
@AllArgsConstructor
public enum DocumentEnum {

    REDIS_INSTALL("https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/", "Redis 安装文档");

    private final String url;
    private final String memo;

}
