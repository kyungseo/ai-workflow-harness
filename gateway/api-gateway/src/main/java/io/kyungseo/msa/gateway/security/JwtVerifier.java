package io.kyungseo.msa.gateway.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import io.kyungseo.msa.common.security.JwtProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Optional;

@Slf4j
@Component
public class JwtVerifier {

    private final SecretKey signingKey;

    public JwtVerifier(JwtProperties jwtProperties) {
        this.signingKey = Keys.hmacShaKeyFor(
                jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
    }

    /**
     * 서명·만료·type 클레임을 검증하고 Claims를 반환한다.
     * 유효하지 않으면 Optional.empty() 반환.
     */
    public Optional<Claims> verify(String token) {
        try {
            Claims claims = Jwts.parser()
                    .verifyWith(signingKey)
                    .build()
                    .parseSignedClaims(token)
                    .getPayload();

            if (!"access".equals(claims.get("type", String.class))) {
                log.warn("Token type is not 'access' — token confusion attempt blocked");
                return Optional.empty();
            }
            return Optional.of(claims);
        } catch (JwtException e) {
            log.debug("JWT verification failed: {}", e.getMessage());
            return Optional.empty();
        }
    }
}
