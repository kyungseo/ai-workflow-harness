package io.kyungseo.msa.gateway.filter;

import io.jsonwebtoken.Claims;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.mock;

@ExtendWith(MockitoExtension.class)
class UserContextFilterTest {

    @Mock GatewayFilterChain chain;
    @InjectMocks UserContextFilter filter;

    @BeforeEach
    void setUp() {
        given(chain.filter(any())).willReturn(Mono.empty());
    }

    @Test
    void externalHeaderInjection_removedAndReplacedWithClaims() {
        Claims claims = mock(Claims.class);
        given(claims.get("userId", Long.class)).willReturn(42L);
        given(claims.get("role", String.class)).willReturn("ROLE_USER");

        AtomicReference<ServerWebExchange> capturedExchange = new AtomicReference<>();
        given(chain.filter(any())).willAnswer(inv -> {
            capturedExchange.set(inv.getArgument(0));
            return Mono.empty();
        });

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos")
                        // 외부에서 주입 시도한 스푸핑 헤더
                        .header("X-User-Id", "999")
                        .header("X-User-Role", "ROLE_ADMIN")
                        .build());
        exchange.getAttributes().put("claims", claims);

        StepVerifier.create(filter.filter(exchange, chain))
                .verifyComplete();

        ServerWebExchange captured = capturedExchange.get();
        assertThat(captured.getRequest().getHeaders().getFirst("X-User-Id")).isEqualTo("42");
        assertThat(captured.getRequest().getHeaders().getFirst("X-User-Role")).isEqualTo("ROLE_USER");
    }

    @Test
    void noClaims_externalHeaderRemoved() {
        AtomicReference<ServerWebExchange> capturedExchange = new AtomicReference<>();
        given(chain.filter(any())).willAnswer(inv -> {
            capturedExchange.set(inv.getArgument(0));
            return Mono.empty();
        });

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/auth/login")
                        .header("X-User-Id", "999")
                        .header("X-User-Role", "ROLE_ADMIN")
                        .build());
        // claims 없음 — 공개 경로

        StepVerifier.create(filter.filter(exchange, chain))
                .verifyComplete();

        ServerWebExchange captured = capturedExchange.get();
        assertThat(captured.getRequest().getHeaders().getFirst("X-User-Id")).isNull();
        assertThat(captured.getRequest().getHeaders().getFirst("X-User-Role")).isNull();
    }
}
