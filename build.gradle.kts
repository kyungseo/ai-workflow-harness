import io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension

plugins {
    id("org.springframework.boot") version "3.5.0" apply false
    id("io.spring.dependency-management") version "1.1.7" apply false
    java
}

allprojects {
    group = "io.kyungseo.msa"
    version = "0.0.1-SNAPSHOT"
}

subprojects {
    apply(plugin = "java")
    apply(plugin = "io.spring.dependency-management")

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    // Spring Boot BOM + Spring Cloud BOM 공통 임포트
    // 버전은 libs.versions.toml의 spring-boot-plugin / spring-cloud 와 일치 유지
    configure<DependencyManagementExtension> {
        imports {
            mavenBom("org.springframework.boot:spring-boot-dependencies:3.5.0")
            mavenBom("org.springframework.cloud:spring-cloud-dependencies:2024.0.1")
        }
    }

    dependencies {
        // Gradle 8.x + JUnit Platform 버전 정합성 보장 (junit-platform-engine/launcher 불일치 방지)
        "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
    }

    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-parameters")
    }

    tasks.withType<Test> {
        useJUnitPlatform()
    }
}
