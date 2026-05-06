package io.kyungseo.msa.gateway.filter;

import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;

/**
 * X-Correlation-ID 헤더를 추출(없으면 생성)하여 하위 서비스로 전파한다.
 *
 * correlationId는 Reactor Context에 저장한다 (contextWrite).
 * ThreadLocal MDC 직접 설정은 WebFlux 비동기 체인에서 신뢰할 수 없으므로 사용하지 않는다.
 * Gateway 자체 로그의 MDC 주입(Hooks.onEachOperator 방식)은 Phase 2에서 적용한다.
 */
@Slf4j
@Component
public class MdcGatewayFilter implements GlobalFilter, Ordered {

    static final String CORRELATION_ID_HEADER = "X-Correlation-ID";
    static final String CORRELATION_ID_ATTR = "correlationId";

    @Override
    public int getOrder() {
        return -5;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        String correlationId = exchange.getRequest().getHeaders()
                .getFirst(CORRELATION_ID_HEADER);
        if (correlationId == null || correlationId.isBlank()) {
            correlationId = UUID.randomUUID().toString();
        }

        exchange.getAttributes().put(CORRELATION_ID_ATTR, correlationId);

        final String finalCorrelationId = correlationId;
        exchange.getResponse().getHeaders().set(CORRELATION_ID_HEADER, finalCorrelationId);
        ServerWebExchange mutatedExchange = exchange.mutate()
                .request(r -> r.header(CORRELATION_ID_HEADER, finalCorrelationId))
                .build();

        return chain.filter(mutatedExchange)
                .contextWrite(ctx -> ctx.put(CORRELATION_ID_ATTR, finalCorrelationId));
    }
}
