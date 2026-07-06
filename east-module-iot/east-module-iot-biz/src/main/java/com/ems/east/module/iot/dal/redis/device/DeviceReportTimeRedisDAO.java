package com.ems.east.module.iot.dal.redis.device;

import cn.hutool.core.date.LocalDateTimeUtil;
import com.ems.east.module.iot.dal.redis.RedisKeyConstants;
import jakarta.annotation.Resource;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.connection.RedisZSetCommands;
import org.springframework.data.redis.connection.zset.DefaultTuple;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Set;

import static com.ems.east.framework.common.util.collection.CollectionUtils.convertSet;

/**
 * 设备的最后上报时间的 Redis DAO
 *
 * @author Hand of God
 */
@Repository
public class DeviceReportTimeRedisDAO {

    @Resource
    private StringRedisTemplate stringRedisTemplate;

    public void update(Long deviceId, LocalDateTime reportTime) {
        stringRedisTemplate.opsForZSet().add(RedisKeyConstants.DEVICE_REPORT_TIMES, String.valueOf(deviceId),
                LocalDateTimeUtil.toEpochMilli(reportTime));
    }

    public boolean updateIfNewer(Long deviceId, LocalDateTime reportTime) {
        double newScore = LocalDateTimeUtil.toEpochMilli(reportTime);
        byte[] key = stringRedisTemplate.getStringSerializer().serialize(RedisKeyConstants.DEVICE_REPORT_TIMES);
        byte[] member = stringRedisTemplate.getStringSerializer().serialize(String.valueOf(deviceId));
        Long updated = stringRedisTemplate.execute((RedisCallback<Long>) connection -> connection.zAdd(key,
                Collections.singleton(new DefaultTuple(member, newScore)),
                RedisZSetCommands.ZAddArgs.empty().gt().ch()));
        return updated != null && updated > 0;
    }

    public Set<Long> range(LocalDateTime maxReportTime) {
        Set<String> values = stringRedisTemplate.opsForZSet().rangeByScore(RedisKeyConstants.DEVICE_REPORT_TIMES,
                0, LocalDateTimeUtil.toEpochMilli(maxReportTime));
        return convertSet(values, Long::parseLong);
    }

}
