package io.kyungseo.msa.auth.service;

import io.kyungseo.msa.auth.domain.User;
import io.kyungseo.msa.auth.dto.LoginRequest;
import io.kyungseo.msa.auth.dto.LogoutRequest;
import io.kyungseo.msa.auth.dto.RefreshRequest;
import io.kyungseo.msa.auth.exception.AuthErrorCode;
import io.kyungseo.msa.auth.jwt.JwtTokenProvider;
import io.kyungseo.msa.auth.mapper.UserMapper;
import io.kyungseo.msa.auth.repository.TokenRedisRepository;
import io.kyungseo.msa.common.exception.BusinessException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class AuthServiceTest {

    @Mock UserMapper userMapper;
    @Mock PasswordEncoder passwordEncoder;
    @Mock JwtTokenProvider jwtTokenProvider;
    @Mock TokenRedisRepository tokenRedisRepository;

    @InjectMocks AuthService authService;

    private User sampleUser() {
        return User.builder()
                .id(1L).username("user").email("user@example.com")
                .password("$2a$12$hash").role("ROLE_USER").enabled(true)
                .build();
    }

    private LoginRequest loginRequest() {
        LoginRequest req = new LoginRequest() {};
        // 리플렉션 없이 테스트하기 위해 별도 헬퍼 방식 — 필드 직접 set
        return mockLoginRequest("user", "user", "device1");
    }

    private LoginRequest mockLoginRequest(String username, String password, String deviceId) {
        LoginRequest req = mock(LoginRequest.class);
        given(req.getUsername()).willReturn(username);
        given(req.getPassword()).willReturn(password);
        given(req.getDeviceId()).willReturn(deviceId);
        return req;
    }

    @Test
    void login_success_returnsTokens() {
        User user = sampleUser();
        LoginRequest req = mockLoginRequest("user", "user", "device1");

        given(userMapper.findByUsername("user")).willReturn(Optional.of(user));
        given(passwordEncoder.matches("user", user.getPassword())).willReturn(true);
        given(jwtTokenProvider.createAccessToken(1L, "ROLE_USER")).willReturn("access-token");
        given(jwtTokenProvider.createRefreshToken(1L)).willReturn("refresh-token");
        given(jwtTokenProvider.extractRemainingSeconds("refresh-token")).willReturn(604800L);

        var response = authService.login(req);

        assertThat(response.getAccessToken()).isEqualTo("access-token");
        assertThat(response.getRefreshToken()).isEqualTo("refresh-token");
        assertThat(response.getTokenType()).isEqualTo("Bearer");
        verify(tokenRedisRepository).saveRefreshToken(1L, "device1", "refresh-token", 604800L);
    }

    @Test
    void login_userNotFound_throwsLoginFailed() {
        LoginRequest req = mockLoginRequest("unknown", "pass", "device1");
        given(userMapper.findByUsername("unknown")).willReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login(req))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.LOGIN_FAILED));
    }

    @Test
    void login_wrongPassword_throwsLoginFailed() {
        User user = sampleUser();
        LoginRequest req = mockLoginRequest("user", "wrong", "device1");

        given(userMapper.findByUsername("user")).willReturn(Optional.of(user));
        given(passwordEncoder.matches("wrong", user.getPassword())).willReturn(false);

        assertThatThrownBy(() -> authService.login(req))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.LOGIN_FAILED));
    }

    @Test
    void refresh_success_rotatesTokens() {
        RefreshRequest req = mock(RefreshRequest.class);
        given(req.getRefreshToken()).willReturn("old-refresh");
        given(req.getDeviceId()).willReturn("device1");

        given(jwtTokenProvider.extractUserId("old-refresh")).willReturn(1L);
        given(tokenRedisRepository.getRefreshToken(1L, "device1")).willReturn("old-refresh");
        given(userMapper.findById(1L)).willReturn(Optional.of(sampleUser()));
        given(jwtTokenProvider.createAccessToken(1L, "ROLE_USER")).willReturn("new-access");
        given(jwtTokenProvider.createRefreshToken(1L)).willReturn("new-refresh");
        given(jwtTokenProvider.extractRemainingSeconds("new-refresh")).willReturn(604800L);

        var response = authService.refresh(req);

        assertThat(response.getAccessToken()).isEqualTo("new-access");
        assertThat(response.getRefreshToken()).isEqualTo("new-refresh");
        verify(tokenRedisRepository).deleteRefreshToken(1L, "device1");
        verify(tokenRedisRepository).saveRefreshToken(1L, "device1", "new-refresh", 604800L);
    }

    @Test
    void refresh_tokenNotInRedis_invalidatesAllSessionsAndThrows() {
        RefreshRequest req = mock(RefreshRequest.class);
        given(req.getRefreshToken()).willReturn("stolen-refresh");
        given(req.getDeviceId()).willReturn("device1");
        given(jwtTokenProvider.extractUserId("stolen-refresh")).willReturn(1L);
        given(tokenRedisRepository.getRefreshToken(1L, "device1")).willReturn(null);

        assertThatThrownBy(() -> authService.refresh(req))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(AuthErrorCode.REFRESH_TOKEN_NOT_FOUND));

        verify(tokenRedisRepository).deleteAllRefreshTokens(1L);
    }

    @Test
    void logout_blacklistsTokenAndDeletesRefreshToken() {
        LogoutRequest req = mock(LogoutRequest.class);
        given(req.getDeviceId()).willReturn("device1");
        given(jwtTokenProvider.extractUserId("access-token")).willReturn(1L);
        given(jwtTokenProvider.extractJti("access-token")).willReturn("jti-123");
        given(jwtTokenProvider.extractRemainingSeconds("access-token")).willReturn(300L);

        authService.logout("access-token", req);

        verify(tokenRedisRepository).addToBlacklist("jti-123", 300L);
        verify(tokenRedisRepository).deleteRefreshToken(1L, "device1");
    }
}
