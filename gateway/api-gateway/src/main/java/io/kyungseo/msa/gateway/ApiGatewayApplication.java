package io.kyungseo.msa.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication(scanBasePackages = {
        "io.kyungseo.msa.gateway",
        "io.kyungseo.msa.common.exception",  // BusinessException, GlobalExceptionHandler
        "io.kyungseo.msa.common.response",   // ApiResponse, ErrorResponse, PageResponse
        "io.kyungseo.msa.common.security",   // JwtProperties
        "io.kyungseo.msa.common.util"        // DateTimeUtils
        // common.mybatis 제외: Gateway는 MyBatis 미사용 (SlowQueryInterceptor 스캔 불가)
        // common.logging 제외: MdcFilter는 Servlet 기반, Gateway는 MdcGatewayFilter 사용
})
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
