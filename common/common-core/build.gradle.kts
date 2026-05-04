plugins {
    `java-library`
}

dependencies {
    api("org.springframework.boot:spring-boot-starter-web")
    api("org.springframework.boot:spring-boot-starter-validation")

    // GlobalExceptionHandler: AccessDeniedException 처리용 (소비자에게 전파 안 함)
    compileOnly("org.springframework.security:spring-security-core")
    // SlowQueryInterceptor: MyBatis Interceptor API (소비자에게 전파 안 함)
    compileOnly(libs.mybatis.starter)

    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
}
