package io.kyungseo.msa.auth.repository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.Set;
import java.util.concurrent.TimeUnit;

@Slf4j
@Repository
@RequiredArgsConstructor
public class TokenRedisRepository {

    private static final String RT_PREFIX = "rt:";
    private static final String BL_PREFIX = "bl:";

    private final StringRedisTemplate redisTemplate;

    public void saveRefreshToken(Long userId, String deviceId, String token, long ttlSeconds) {
        redisTemplate.opsForValue().set(rtKey(userId, deviceId), token, ttlSeconds, TimeUnit.SECONDS);
    }

    public String getRefreshToken(Long userId, String deviceId) {
        return redisTemplate.opsForValue().get(rtKey(userId, deviceId));
    }

    public void deleteRefreshToken(Long userId, String deviceId) {
        redisTemplate.delete(rtKey(userId, deviceId));
    }

    public void deleteAllRefreshTokens(Long userId) {
        // 탈취 의심 시 해당 사용자의 모든 디바이스 세션 무효화
        Set<String> keys = redisTemplate.keys(RT_PREFIX + userId + ":*");
        if (keys != null && !keys.isEmpty()) {
            redisTemplate.delete(keys);
            log.warn("All refresh tokens invalidated for userId={}, count={}", userId, keys.size());
        }
    }

    public void addToBlacklist(String jti, long ttlSeconds) {
        redisTemplate.opsForValue().set(blKey(jti), "logout", ttlSeconds, TimeUnit.SECONDS);
    }

    public boolean isBlacklisted(String jti) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(blKey(jti)));
    }

    private String rtKey(Long userId, String deviceId) {
        return RT_PREFIX + userId + ":" + deviceId;
    }

    private String blKey(String jti) {
        return BL_PREFIX + jti;
    }
}
