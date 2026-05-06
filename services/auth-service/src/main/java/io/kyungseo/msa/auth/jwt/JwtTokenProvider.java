package io.kyungseo.msa.auth.jwt;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import io.kyungseo.msa.auth.exception.AuthErrorCode;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.security.JwtProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    private static final String CLAIM_USER_ID = "userId";
    private static final String CLAIM_ROLE = "role";
    private static final String CLAIM_TYPE = "type";
    private static final String TYPE_ACCESS = "access";
    private static final String TYPE_REFRESH = "refresh";

    private final JwtProperties jwtProperties;

    public String createAccessToken(Long userId, String role) {
        return buildToken(userId, role, TYPE_ACCESS, jwtProperties.getAccessTokenExpiry());
    }

    public String createRefreshToken(Long userId) {
        return buildToken(userId, null, TYPE_REFRESH, jwtProperties.getRefreshTokenExpiry());
    }

    private String buildToken(Long userId, String role, String type, long expirySeconds) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expirySeconds * 1000L);

        var builder = Jwts.builder()
                .id(UUID.randomUUID().toString())
                .subject(String.valueOf(userId))
                .claim(CLAIM_USER_ID, userId)
                .claim(CLAIM_TYPE, type)
                .issuedAt(now)
                .expiration(expiry)
                .signWith(signingKey());

        if (role != null) {
            builder.claim(CLAIM_ROLE, role);
        }

        return builder.compact();
    }

    public Claims parseAndValidate(String token) {
        try {
            return Jwts.parser()
                    .verifyWith(signingKey())
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();
        } catch (ExpiredJwtException e) {
            throw new BusinessException(AuthErrorCode.TOKEN_EXPIRED);
        } catch (JwtException | IllegalArgumentException e) {
            throw new BusinessException(AuthErrorCode.INVALID_TOKEN);
        }
    }

    public void validateAccessToken(String token) {
        Claims claims = parseAndValidate(token);
        if (!TYPE_ACCESS.equals(claims.get(CLAIM_TYPE, String.class))) {
            throw new BusinessException(AuthErrorCode.INVALID_TOKEN);
        }
    }

    public void validateRefreshToken(String token) {
        Claims claims = parseAndValidate(token);
        if (!TYPE_REFRESH.equals(claims.get(CLAIM_TYPE, String.class))) {
            // Refresh 엔드포인트에 Access Token 사용 시 token confusion attack 차단
            throw new BusinessException(AuthErrorCode.INVALID_TOKEN);
        }
    }

    public Long extractUserId(String token) {
        return parseAndValidate(token).get(CLAIM_USER_ID, Long.class);
    }

    public String extractRole(String token) {
        return parseAndValidate(token).get(CLAIM_ROLE, String.class);
    }

    public String extractJti(String token) {
        return parseAndValidate(token).getId();
    }

    public long extractRemainingSeconds(String token) {
        Date expiry = parseAndValidate(token).getExpiration();
        long remainingMs = expiry.getTime() - System.currentTimeMillis();
        return Math.max(remainingMs / 1000L, 1L);
    }

    private SecretKey signingKey() {
        return Keys.hmacShaKeyFor(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
    }
}
