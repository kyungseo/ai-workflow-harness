package io.kyungseo.msa.gateway.filter;

import io.jsonwebtoken.Claims;
import io.kyungseo.msa.gateway.config.GatewayProperties;
import io.kyungseo.msa.gateway.security.JwtVerifier;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveRedisTemplate;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Optional;

/**
 * JWT 서명·만료·type 검증 및 Redis Blacklist 조회를 수행한다.
 *
 * [공개 경로 처리]
 * 공개 경로는 이 필터를 건너뜀 (whitelist 우선 skip).
 *
 * [Blacklist fail 정책]
 * - fail-close (기본값): Redis 조회 실패 시 401 반환 — 보안 우선
 * - fail-open: Redis 조회 실패 시 통과 허용 — 가용성 우선
 * 환경변수 BLACKLIST_FAIL_POLICY로 제어.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthFilter implements GlobalFilter, Ordered {

    static final List<String> PUBLIC_PATHS = List.of(
            "/api/v1/auth/login",
            "/api/v1/auth/refresh",
            "/actuator/health"
    );
    // POST /api/v1/users 는 메서드까지 확인 필요 — UserContextFilter에서도 재확인
    static final String PUBLIC_POST_PATH = "/api/v1/users";

    private final JwtVerifier jwtVerifier;
    private final ReactiveRedisTemplate<String, String> redisTemplate;
    private final GatewayProperties gatewayProperties;

    @Override
    public int getOrder() {
        return -2;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        String method = exchange.getRequest().getMethod().name();

        if (isPublicPath(path, method)) {
            return chain.filter(exchange);
        }

        String authHeader = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return unauthorized(exchange);
        }

        String token = authHeader.substring(7);
        Optional<Claims> claimsOpt = jwtVerifier.verify(token);
        if (claimsOpt.isEmpty()) {
            return unauthorized(exchange);
        }

        Claims claims = claimsOpt.get();
        String jti = claims.getId();

        return checkBlacklist(jti)
                .flatMap(blacklisted -> {
                    if (blacklisted) {
                        log.warn("Blacklisted token used: jti={}", jti);
                        return unauthorized(exchange);
                    }
                    exchange.getAttributes().put("claims", claims);
                    return chain.filter(exchange);
                });
    }

    private Mono<Boolean> checkBlacklist(String jti) {
        if (jti == null) {
            return Mono.just(false);
        }
        return redisTemplate.hasKey("bl:" + jti)
                .onErrorResume(e -> {
                    log.error("Redis blacklist check failed for jti={}: {}", jti, e.getMessage());
                    if (gatewayProperties.isFailClose()) {
                        return Mono.just(true);   // fail-close: 조회 실패 → 차단
                    }
                    return Mono.just(false);      // fail-open: 조회 실패 → 허용
                });
    }

    private boolean isPublicPath(String path, String method) {
        if (PUBLIC_PATHS.stream().anyMatch(path::startsWith)) {
            return true;
        }
        return "POST".equalsIgnoreCase(method) && path.equals(PUBLIC_POST_PATH);
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        return exchange.getResponse().setComplete();
    }
}
