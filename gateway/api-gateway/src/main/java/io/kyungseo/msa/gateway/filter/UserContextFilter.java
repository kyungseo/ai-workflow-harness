package io.kyungseo.msa.gateway.filter;

import io.jsonwebtoken.Claims;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

/**
 * Header Spoofing 방어: 외부에서 주입된 X-User-Id / X-User-Role 헤더를 강제 제거 후
 * JWT claims에서 추출한 서버 값으로 교체한다.
 *
 * [주의] 헤더를 덮어쓰기만 하면 기존 헤더가 남을 수 있음 — 반드시 remove 후 add.
 * 공개 경로는 JwtAuthFilter가 claims를 저장하지 않으므로 헤더 주입 없이 통과.
 */
@Slf4j
@Component
public class UserContextFilter implements GlobalFilter, Ordered {

    static final String HEADER_USER_ID = "X-User-Id";
    static final String HEADER_USER_ROLE = "X-User-Role";

    @Override
    public int getOrder() {
        return -1;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        // 외부 유입 헤더 강제 제거
        ServerHttpRequest.Builder requestBuilder = exchange.getRequest().mutate()
                .headers(headers -> {
                    headers.remove(HEADER_USER_ID);
                    headers.remove(HEADER_USER_ROLE);
                });

        Claims claims = exchange.getAttribute("claims");
        if (claims != null) {
            Long userId = claims.get("userId", Long.class);
            String role = claims.get("role", String.class);
            if (userId != null && role != null) {
                requestBuilder
                        .header(HEADER_USER_ID, userId.toString())
                        .header(HEADER_USER_ROLE, role);
            }
        }

        return chain.filter(exchange.mutate().request(requestBuilder.build()).build());
    }
}
