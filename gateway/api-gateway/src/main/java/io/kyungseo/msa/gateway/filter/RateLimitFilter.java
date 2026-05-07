package io.kyungseo.msa.gateway.filter;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.data.redis.core.ReactiveRedisOperations;
import org.springframework.data.redis.core.script.RedisScript;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.List;
import java.util.Objects;

/**
 * Redis 기반 Fixed Window Rate Limiting (1s window).
 * - 인증 경로 (/api/v1/auth/**): 5 req/s, 경로 액션별 독립 버킷 (login/refresh/logout 분리)
 * - 일반 경로: 100 req/s
 * - Key: rl:{userId} (인증 후) | rl:ip:{addr}:{action} (auth) | rl:ip:{addr} (일반)
 * - 초과 시 429 + Retry-After: 1
 *
 * Lua script로 INCR + TTL을 원자적으로 처리하여 race condition 방지.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class RateLimitFilter implements GlobalFilter, Ordered {

    private static final int AUTH_LIMIT = 5;
    private static final int DEFAULT_LIMIT = 100;

    // Lua: INCR key, set TTL 1s on first call, return current count
    private static final RedisScript<Long> RATE_LIMIT_SCRIPT = RedisScript.of(
            "local count = redis.call('INCR', KEYS[1])\n" +
            "if count == 1 then\n" +
            "  redis.call('PEXPIRE', KEYS[1], 1000)\n" +
            "end\n" +
            "return count",
            Long.class);

    private final ReactiveRedisOperations<String, String> redisTemplate;

    @Override
    public int getOrder() {
        return -3;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String path = exchange.getRequest().getPath().value();
        boolean isAuthPath = path.startsWith("/api/v1/auth/");
        int limit = isAuthPath ? AUTH_LIMIT : DEFAULT_LIMIT;

        String rateLimitKey = buildKey(exchange, isAuthPath);

        return redisTemplate.execute(RATE_LIMIT_SCRIPT, List.of(rateLimitKey), List.of())
                .next()
                .flatMap(count -> {
                    if (count > limit) {
                        log.warn("Rate limit exceeded: key={}, count={}, limit={}", rateLimitKey, count, limit);
                        exchange.getResponse().setStatusCode(HttpStatus.TOO_MANY_REQUESTS);
                        exchange.getResponse().getHeaders().set("Retry-After", "1");
                        return exchange.getResponse().setComplete();
                    }
                    return chain.filter(exchange);
                })
                .onErrorResume(e -> {
                    log.error("Rate limit Redis error — allowing request through: {}", e.getMessage());
                    return chain.filter(exchange);
                });
    }

    private String buildKey(ServerWebExchange exchange, boolean isAuthPath) {
        String userId = exchange.getRequest().getHeaders().getFirst("X-User-Id");
        if (userId != null && !isAuthPath) {
            return "rl:" + userId;
        }
        String remoteAddr = Objects.requireNonNull(
                exchange.getRequest().getRemoteAddress()).getAddress().getHostAddress();
        if (isAuthPath) {
            // login/refresh/logout별 독립 버킷 — login brute-force 방지와 무관한 경로가 한도를 소모하지 않도록
            String path = exchange.getRequest().getPath().value();
            String action = path.substring(path.lastIndexOf('/') + 1);
            return "rl:ip:" + remoteAddr + ":" + action;
        }
        return "rl:ip:" + remoteAddr;
    }
}
