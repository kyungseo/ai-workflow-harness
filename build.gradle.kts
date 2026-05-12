import io.spring.gradle.dependencymanagement.dsl.DependencyManagementExtension

plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spring.dependency.management) apply false
    java
    checkstyle
}

allprojects {
    group = "io.kyungseo.msa"
    version = "0.0.1-SNAPSHOT"
}

checkstyle {
    toolVersion = "10.21.0"
    configFile = rootProject.file("config/checkstyle/checkstyle.xml")
    isIgnoreFailures = false
    maxWarnings = 0
}

subprojects {
    apply(plugin = "java")
    apply(plugin = "io.spring.dependency-management")
    apply(plugin = "checkstyle")

    java {
        toolchain {
            languageVersion = JavaLanguageVersion.of(21)
        }
    }

    // Spring Boot BOM: common-core(java-library)는 Boot plugin이 없으므로 명시 선언 필요
    // Spring Cloud BOM: Boot plugin 미관리 대상, 명시 선언
    // 버전은 libs.versions.toml의 spring-boot-plugin / spring-cloud 와 일치 유지
    configure<DependencyManagementExtension> {
        imports {
            mavenBom("org.springframework.boot:spring-boot-dependencies:3.5.0")
            mavenBom("org.springframework.cloud:spring-cloud-dependencies:2025.0.0")
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
