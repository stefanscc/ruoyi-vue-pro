package com.ems.east.module.iot.dal.redis.device;

import cn.hutool.core.date.LocalDateTimeUtil;
import com.ems.east.framework.test.core.ut.BaseMockitoUnitTest;
import com.ems.east.module.iot.dal.redis.RedisKeyConstants;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.springframework.data.redis.connection.RedisConnection;
import org.springframework.data.redis.connection.RedisZSetCommands;
import org.springframework.data.redis.connection.zset.DefaultTuple;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.serializer.StringRedisSerializer;

import java.time.LocalDateTime;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.argThat;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * {@link DeviceReportTimeRedisDAO} 的单元测试
 */
public class DeviceReportTimeRedisDAOTest extends BaseMockitoUnitTest {

    @InjectMocks
    private DeviceReportTimeRedisDAO deviceReportTimeRedisDAO;

    @Mock
    private StringRedisTemplate stringRedisTemplate;
    @Mock
    private RedisConnection redisConnection;

    @Test
    @SuppressWarnings("unchecked")
    public void testUpdateIfNewer_useAtomicZAddGt() {
        LocalDateTime reportTime = LocalDateTime.of(2026, 6, 13, 12, 13, 14);
        when(stringRedisTemplate.getStringSerializer()).thenReturn(StringRedisSerializer.UTF_8);
        when(stringRedisTemplate.execute(any(RedisCallback.class))).thenAnswer(invocation -> {
            RedisCallback<Long> callback = invocation.getArgument(0);
            return callback.doInRedis(redisConnection);
        });
        when(redisConnection.zAdd(any(byte[].class), any(Set.class), any(RedisZSetCommands.ZAddArgs.class))).thenReturn(1L);

        boolean updated = deviceReportTimeRedisDAO.updateIfNewer(1L, reportTime);

        assertTrue(updated);
        verify(redisConnection).zAdd(
                eq(StringRedisSerializer.UTF_8.serialize(RedisKeyConstants.DEVICE_REPORT_TIMES)),
                eq(Set.of(new DefaultTuple(StringRedisSerializer.UTF_8.serialize("1"),
                        Double.valueOf(LocalDateTimeUtil.toEpochMilli(reportTime))))),
                argThat(args -> args.contains(RedisZSetCommands.ZAddArgs.Flag.GT)
                        && args.contains(RedisZSetCommands.ZAddArgs.Flag.CH)));
        verify(stringRedisTemplate, never()).opsForZSet();
    }

    @Test
    @SuppressWarnings("unchecked")
    public void testUpdateIfNewer_whenNotChanged_returnFalse() {
        when(stringRedisTemplate.getStringSerializer()).thenReturn(StringRedisSerializer.UTF_8);
        when(stringRedisTemplate.execute(any(RedisCallback.class))).thenAnswer(invocation -> {
            RedisCallback<Long> callback = invocation.getArgument(0);
            return callback.doInRedis(redisConnection);
        });
        when(redisConnection.zAdd(any(byte[].class), any(Set.class), any(RedisZSetCommands.ZAddArgs.class))).thenReturn(0L);

        boolean updated = deviceReportTimeRedisDAO.updateIfNewer(1L, LocalDateTime.of(2026, 6, 13, 12, 13, 14));

        assertFalse(updated);
    }

}
