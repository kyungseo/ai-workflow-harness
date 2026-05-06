package io.kyungseo.msa.gateway.filter;

import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.env.Environment;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.Arrays;

@Component
public class SecurityHeadersFilter implements GlobalFilter, Ordered {

    private final boolean hstsEnabled;

    public SecurityHeadersFilter(Environment environment) {
        this.hstsEnabled = Arrays.stream(environment.getActiveProfiles())
                .anyMatch(p -> p.equals("stg") || p.equals("prd"));
    }

    @Override
    public int getOrder() {
        return -4;
    }

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        return chain.filter(exchange).doFirst(() -> {
            HttpHeaders headers = exchange.getResponse().getHeaders();
            headers.set("X-Content-Type-Options", "nosniff");
            headers.set("X-Frame-Options", "DENY");
            headers.set("X-XSS-Protection", "1; mode=block");
            if (hstsEnabled) {
                headers.set("Strict-Transport-Security", "max-age=31536000; includeSubDomains");
            }
        });
    }
}
