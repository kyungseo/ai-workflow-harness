package io.kyungseo.msa.auth.service;

import io.kyungseo.msa.auth.domain.User;
import io.kyungseo.msa.auth.dto.LoginRequest;
import io.kyungseo.msa.auth.dto.LoginResponse;
import io.kyungseo.msa.auth.dto.LogoutRequest;
import io.kyungseo.msa.auth.dto.RefreshRequest;
import io.kyungseo.msa.auth.dto.RefreshResponse;
import io.kyungseo.msa.auth.exception.AuthErrorCode;
import io.kyungseo.msa.auth.jwt.JwtTokenProvider;
import io.kyungseo.msa.auth.mapper.UserMapper;
import io.kyungseo.msa.auth.repository.TokenRedisRepository;
import io.kyungseo.msa.common.exception.BusinessException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final TokenRedisRepository tokenRedisRepository;

    public LoginResponse login(LoginRequest request) {
        User user = userMapper.findByUsername(request.getUsername())
                .orElseThrow(() -> new BusinessException(AuthErrorCode.LOGIN_FAILED));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            // 사용자 없음과 비밀번호 불일치 동일 메시지 — 정보 노출 방지
            throw new BusinessException(AuthErrorCode.LOGIN_FAILED);
        }

        String accessToken = jwtTokenProvider.createAccessToken(user.getId(), user.getRole());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getId());

        tokenRedisRepository.saveRefreshToken(
                user.getId(), request.getDeviceId(), refreshToken,
                jwtTokenProvider.extractRemainingSeconds(refreshToken)
        );

        log.debug("Login success: userId={}, deviceId={}", user.getId(), request.getDeviceId());
        return LoginResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .build();
    }

    public RefreshResponse refresh(RefreshRequest request) {
        // type == "refresh" 검증 — Access Token으로 갱신 시도 차단 (token confusion 방어)
        jwtTokenProvider.validateRefreshToken(request.getRefreshToken());

        Long userId = jwtTokenProvider.extractUserId(request.getRefreshToken());

        String stored = tokenRedisRepository.getRefreshToken(userId, request.getDeviceId());
        if (stored == null) {
            // Redis에 없으면 탈취 의심 — 해당 userId의 전체 세션 무효화
            tokenRedisRepository.deleteAllRefreshTokens(userId);
            log.warn("Refresh token not found, possible theft. All sessions invalidated for userId={}", userId);
            throw new BusinessException(AuthErrorCode.REFRESH_TOKEN_NOT_FOUND);
        }

        // 기존 토큰 삭제 후 신규 발급 (Token Rotation)
        tokenRedisRepository.deleteRefreshToken(userId, request.getDeviceId());

        User user = userMapper.findById(userId)
                .orElseThrow(() -> new BusinessException(AuthErrorCode.INVALID_TOKEN));

        String newAccessToken = jwtTokenProvider.createAccessToken(user.getId(), user.getRole());
        String newRefreshToken = jwtTokenProvider.createRefreshToken(user.getId());

        tokenRedisRepository.saveRefreshToken(
                userId, request.getDeviceId(), newRefreshToken,
                jwtTokenProvider.extractRemainingSeconds(newRefreshToken)
        );

        return RefreshResponse.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    public void logout(String accessToken, LogoutRequest request) {
        Long userId = jwtTokenProvider.extractUserId(accessToken);
        String jti = jwtTokenProvider.extractJti(accessToken);
        long remainingSeconds = jwtTokenProvider.extractRemainingSeconds(accessToken);

        tokenRedisRepository.addToBlacklist(jti, remainingSeconds);
        tokenRedisRepository.deleteRefreshToken(userId, request.getDeviceId());

        log.debug("Logout success: userId={}, deviceId={}", userId, request.getDeviceId());
    }
}
