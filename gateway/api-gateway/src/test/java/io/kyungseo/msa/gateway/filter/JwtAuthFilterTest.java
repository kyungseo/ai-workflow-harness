package io.kyungseo.msa.gateway.filter;

import io.jsonwebtoken.Claims;
import io.kyungseo.msa.gateway.config.GatewayProperties;
import io.kyungseo.msa.gateway.security.JwtVerifier;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.lenient;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class JwtAuthFilterTest {

    @Mock JwtVerifier jwtVerifier;
    @Mock GatewayFilterChain chain;
    @Mock GatewayProperties gatewayProperties;
    @InjectMocks JwtAuthFilter filter;

    private static final String VALID_TOKEN = "valid.jwt.token";

    @BeforeEach
    void setUp() {
        lenient().when(chain.filter(any())).thenReturn(Mono.empty());
    }

    @Test
    void publicPath_skipFilter() {
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.post("/api/v1/auth/login").build());

        StepVerifier.create(filter.filter(exchange, chain))
                .verifyComplete();

        verify(jwtVerifier, never()).verify(any());
        verify(chain).filter(any());
    }

    @Test
    void validToken_notBlacklisted_passThrough() {
        Claims claims = mock(Claims.class);
        given(claims.getId()).willReturn("jti-123");
        given(jwtVerifier.verify(VALID_TOKEN)).willReturn(Optional.of(claims));

        var redisTemplate = org.mockito.Mockito.mock(
                org.springframework.data.redis.core.ReactiveRedisTemplate.class);

        // Rebuild filter with mocked redisTemplate
        JwtAuthFilter filterWithRedis = new JwtAuthFilter(jwtVerifier, redisTemplate, gatewayProperties);
        given(redisTemplate.hasKey("bl:jti-123")).willReturn(Mono.just(false));

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + VALID_TOKEN)
                        .build());

        StepVerifier.create(filterWithRedis.filter(exchange, chain))
                .verifyComplete();

        verify(chain).filter(any());
    }

    @Test
    void noAuthHeader_returns401() {
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos").build());

        StepVerifier.create(filter.filter(exchange, chain))
                .verifyComplete();

        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        verify(chain, never()).filter(any());
    }

    @Test
    void invalidToken_returns401() {
        given(jwtVerifier.verify(VALID_TOKEN)).willReturn(Optional.empty());

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + VALID_TOKEN)
                        .build());

        StepVerifier.create(filter.filter(exchange, chain))
                .verifyComplete();

        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        verify(chain, never()).filter(any());
    }

    @Test
    void redisFailClose_returns401() {
        Claims claims = mock(Claims.class);
        given(claims.getId()).willReturn("jti-abc");
        given(jwtVerifier.verify(VALID_TOKEN)).willReturn(Optional.of(claims));
        given(gatewayProperties.isFailClose()).willReturn(true);

        @SuppressWarnings("unchecked")
        var redisTemplate = (org.springframework.data.redis.core.ReactiveRedisTemplate<String, String>)
                org.mockito.Mockito.mock(org.springframework.data.redis.core.ReactiveRedisTemplate.class);

        JwtAuthFilter filterWithRedis = new JwtAuthFilter(jwtVerifier, redisTemplate, gatewayProperties);
        given(redisTemplate.hasKey("bl:jti-abc"))
                .willReturn(Mono.error(new RuntimeException("Redis down")));

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + VALID_TOKEN)
                        .build());

        StepVerifier.create(filterWithRedis.filter(exchange, chain))
                .verifyComplete();

        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        verify(chain, never()).filter(any());
    }

    @Test
    void redisFailOpen_passThrough() {
        Claims claims = mock(Claims.class);
        given(claims.getId()).willReturn("jti-xyz");
        given(jwtVerifier.verify(VALID_TOKEN)).willReturn(Optional.of(claims));
        given(gatewayProperties.isFailClose()).willReturn(false);

        @SuppressWarnings("unchecked")
        var redisTemplate = (org.springframework.data.redis.core.ReactiveRedisTemplate<String, String>)
                org.mockito.Mockito.mock(org.springframework.data.redis.core.ReactiveRedisTemplate.class);

        JwtAuthFilter filterWithRedis = new JwtAuthFilter(jwtVerifier, redisTemplate, gatewayProperties);
        given(redisTemplate.hasKey("bl:jti-xyz"))
                .willReturn(Mono.error(new RuntimeException("Redis down")));

        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/api/v1/todos")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + VALID_TOKEN)
                        .build());

        StepVerifier.create(filterWithRedis.filter(exchange, chain))
                .verifyComplete();

        verify(chain).filter(any());
    }
}
