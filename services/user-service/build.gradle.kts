plugins {
    id("org.springframework.boot")
    id("io.spring.dependency-management")
}

dependencies {
    implementation(project(":common:common-core"))
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-cache")
    // MyBatis
    implementation(libs.mybatis.starter)
    runtimeOnly(libs.postgresql)
    // Caffeine local cache - JVM-scoped, no cross-pod sharing (allowed by design), short TTL required
    implementation(libs.caffeine)
    // MapStruct DTO conversion - annotation processor order mandatory: lombok -> mapstruct
    implementation(libs.mapstruct)
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
    annotationProcessor(libs.mapstruct.processor)
    // API docs (active on local/dev profiles only)
    implementation(libs.springdoc.mvc)
    // Micrometer Tracing
    implementation(libs.micrometer.tracing)
    // JSON structured logs (stg/prd only, runtimeOnly)
    runtimeOnly(libs.logstash)

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.springframework.security:spring-security-test")
    testImplementation(libs.mybatis.starter.test)
    testImplementation(libs.tc.postgresql)
    testImplementation(libs.tc.junit)
    testImplementation(libs.tc.spring)
}
