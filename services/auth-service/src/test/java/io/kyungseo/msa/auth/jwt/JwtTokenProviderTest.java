package io.kyungseo.msa.auth.jwt;

import io.kyungseo.msa.auth.exception.AuthErrorCode;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.security.JwtProperties;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class JwtTokenProviderTest {

    private JwtTokenProvider tokenProvider;

    @BeforeEach
    void setUp() {
        JwtProperties props = new JwtProperties();
        // 256-bit (32 bytes * 8) HS256 최소 요구 길이 충족
        props.setSecret("test-secret-key-for-unit-test-must-be-at-least-256bits-long!!");
        props.setAccessTokenExpiry(900L);
        props.setRefreshTokenExpiry(604800L);
        tokenProvider = new JwtTokenProvider(props);
    }

    @Test
    void createAccessToken_extractsClaimsCorrectly() {
        String token = tokenProvider.createAccessToken(1L, "ROLE_USER");

        assertThat(tokenProvider.extractUserId(token)).isEqualTo(1L);
        assertThat(tokenProvider.extractRole(token)).isEqualTo("ROLE_USER");
        assertThat(tokenProvider.extractJti(token)).isNotBlank();
    }

    @Test
    void createRefreshToken_hasNoRole() {
        String token = tokenProvider.createRefreshToken(1L);

        assertThat(tokenProvider.extractUserId(token)).isEqualTo(1L);
        assertThat(tokenProvider.extractRole(token)).isNull();
    }

    @Test
    void validateRefreshToken_withAccessToken_throwsInvalidToken() {
        String accessToken = tokenProvider.createAccessToken(1L, "ROLE_USER");

        assertThatThrownBy(() -> tokenProvider.validateRefreshToken(accessToken))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.INVALID_TOKEN));
    }

    @Test
    void validateAccessToken_withRefreshToken_throwsInvalidToken() {
        String refreshToken = tokenProvider.createRefreshToken(1L);

        assertThatThrownBy(() -> tokenProvider.validateAccessToken(refreshToken))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.INVALID_TOKEN));
    }

    @Test
    void parseAndValidate_withTamperedToken_throwsInvalidToken() {
        String token = tokenProvider.createAccessToken(1L, "ROLE_USER") + "tampered";

        assertThatThrownBy(() -> tokenProvider.parseAndValidate(token))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.INVALID_TOKEN));
    }

    @Test
    void parseAndValidate_withExpiredToken_throwsTokenExpired() {
        JwtProperties shortProps = new JwtProperties();
        shortProps.setSecret("test-secret-key-for-unit-test-must-be-at-least-256bits-long!!");
        shortProps.setAccessTokenExpiry(-1L); // 이미 만료
        shortProps.setRefreshTokenExpiry(604800L);
        JwtTokenProvider shortProvider = new JwtTokenProvider(shortProps);

        String token = shortProvider.createAccessToken(1L, "ROLE_USER");

        assertThatThrownBy(() -> tokenProvider.parseAndValidate(token))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.TOKEN_EXPIRED));
    }

    @Test
    void extractRemainingSeconds_returnsPositive() {
        String token = tokenProvider.createAccessToken(1L, "ROLE_USER");
        assertThat(tokenProvider.extractRemainingSeconds(token)).isPositive();
    }
}
