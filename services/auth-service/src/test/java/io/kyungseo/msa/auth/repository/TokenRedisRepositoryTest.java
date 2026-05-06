package io.kyungseo.msa.auth.repository;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;

import java.util.Set;
import java.util.concurrent.TimeUnit;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class TokenRedisRepositoryTest {

    @Mock StringRedisTemplate redisTemplate;
    @Mock ValueOperations<String, String> valueOps;

    private TokenRedisRepository repository;

    @BeforeEach
    void setUp() {
        given(redisTemplate.opsForValue()).willReturn(valueOps);
        repository = new TokenRedisRepository(redisTemplate);
    }

    @Test
    void saveRefreshToken_setsValueWithTtl() {
        repository.saveRefreshToken(1L, "device1", "token", 604800L);

        verify(valueOps).set("rt:1:device1", "token", 604800L, TimeUnit.SECONDS);
    }

    @Test
    void getRefreshToken_returnsStoredToken() {
        given(valueOps.get("rt:1:device1")).willReturn("token");

        assertThat(repository.getRefreshToken(1L, "device1")).isEqualTo("token");
    }

    @Test
    void deleteRefreshToken_deletesKey() {
        repository.deleteRefreshToken(1L, "device1");

        verify(redisTemplate).delete("rt:1:device1");
    }

    @Test
    void deleteAllRefreshTokens_deletesAllUserKeys() {
        Set<String> keys = Set.of("rt:1:device1", "rt:1:device2");
        given(redisTemplate.keys("rt:1:*")).willReturn(keys);

        repository.deleteAllRefreshTokens(1L);

        verify(redisTemplate).delete(keys);
    }

    @Test
    void addToBlacklist_setsBlacklistEntry() {
        repository.addToBlacklist("jti-123", 300L);

        verify(valueOps).set("bl:jti-123", "logout", 300L, TimeUnit.SECONDS);
    }

    @Test
    void isBlacklisted_returnsTrueWhenKeyExists() {
        given(redisTemplate.hasKey("bl:jti-123")).willReturn(Boolean.TRUE);

        assertThat(repository.isBlacklisted("jti-123")).isTrue();
    }

    @Test
    void isBlacklisted_returnsFalseWhenKeyAbsent() {
        given(redisTemplate.hasKey("bl:jti-123")).willReturn(null);

        assertThat(repository.isBlacklisted("jti-123")).isFalse();
    }
}
