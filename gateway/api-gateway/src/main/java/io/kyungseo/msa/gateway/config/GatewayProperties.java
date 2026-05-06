package io.kyungseo.msa.gateway.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

@Getter
@Setter
@Validated
@ConfigurationProperties(prefix = "gateway")
public class GatewayProperties {

    private String blacklistFailPolicy = "fail-close";
    private String allowedOrigins = "http://localhost:3000";

    public boolean isFailClose() {
        return "fail-close".equalsIgnoreCase(blacklistFailPolicy);
    }
}
