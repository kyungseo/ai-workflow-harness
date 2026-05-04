#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

SERVICE_NAME="${1:?Usage: $0 <service-name>}"
SERVICE_DIR="${PROJECT_ROOT}/services/${SERVICE_NAME}"
PACKAGE_BASE="io.kyungseo.msa"
PACKAGE_DIR="${PACKAGE_BASE//./\/}"
CLASS_NAME="$(echo "${SERVICE_NAME}" | sed -E 's/(^|-)([a-z])/\U\2/g')"

if [[ -d "${SERVICE_DIR}" ]]; then
  echo "ERROR: Service '${SERVICE_NAME}' already exists at ${SERVICE_DIR}" >&2
  exit 1
fi

echo "Creating service: ${SERVICE_NAME}"

# Source directories
mkdir -p "${SERVICE_DIR}/src/main/java/${PACKAGE_DIR}/${SERVICE_NAME//[-]//}"
mkdir -p "${SERVICE_DIR}/src/main/resources"
mkdir -p "${SERVICE_DIR}/src/test/java/${PACKAGE_DIR}/${SERVICE_NAME//[-]//}"

# build.gradle.kts
cat > "${SERVICE_DIR}/build.gradle.kts" << 'GRADLE'
plugins {
    id("org.springframework.boot")
    id("io.spring.dependency-management")
}

dependencies {
    implementation(project(":common:common-core"))
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation(libs.mybatis.starter)
    implementation(libs.springdoc.mvc)
    implementation(libs.jjwt.api)
    implementation(libs.mapstruct)
    compileOnly(libs.lombok)
    annotationProcessor(libs.lombok)
    annotationProcessor(libs.mapstruct.processor)
    runtimeOnly(libs.jjwt.impl)
    runtimeOnly(libs.jjwt.jackson)
    runtimeOnly("org.postgresql:postgresql")
    runtimeOnly(libs.logstash)
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation(libs.mybatis.starter.test)
    testImplementation(libs.tc.postgresql)
    testImplementation(libs.tc.junit)
    testImplementation(libs.tc.spring)
}
GRADLE

# Application class
SERVICE_PACKAGE="${SERVICE_NAME//-/}"
APP_DIR="${SERVICE_DIR}/src/main/java/${PACKAGE_DIR}/${SERVICE_PACKAGE}"
mkdir -p "${APP_DIR}"

cat > "${APP_DIR}/${CLASS_NAME}Application.java" << JAVA
package ${PACKAGE_BASE}.${SERVICE_PACKAGE};

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${CLASS_NAME}Application {
    public static void main(String[] args) {
        SpringApplication.run(${CLASS_NAME}Application.class, args);
    }
}
JAVA

# application.yml profiles
cat > "${SERVICE_DIR}/src/main/resources/application.yml" << 'YAML'
spring:
  application:
    name: REPLACE_WITH_SERVICE_NAME
  threads:
    virtual:
      enabled: true
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: ${DB_POOL_MAX:10}
      minimum-idle: ${DB_POOL_MIN:5}
      connection-timeout: ${DB_CONN_TIMEOUT:30000}
  data:
    redis:
      host: ${REDIS_HOST:localhost}
      port: ${REDIS_PORT:6379}
  lifecycle:
    timeout-per-shutdown-phase: 30s

server:
  port: REPLACE_WITH_PORT
  shutdown: graceful

management:
  server:
    port: 8099
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: when-authorized

mybatis:
  mapper-locations: classpath:mappers/**/*.xml
  configuration:
    map-underscore-to-camel-case: true
YAML

for PROFILE in local dev; do
cat > "${SERVICE_DIR}/src/main/resources/application-${PROFILE}.yml" << YAML
logging:
  level:
    root: INFO
    io.kyungseo: DEBUG
    org.mybatis: DEBUG
  pattern:
    console: "[${SERVICE_NAME},%X{traceId},%X{spanId},%X{X-Correlation-ID}] %d{HH:mm:ss.SSS} %-5level %logger{36} - %msg%n"

springdoc:
  api-docs:
    enabled: true
  swagger-ui:
    enabled: true
YAML
done

cat > "${SERVICE_DIR}/src/main/resources/application-stg.yml" << 'YAML'
logging:
  level:
    root: INFO
    org.mybatis: "OFF"

springdoc:
  api-docs:
    enabled: false
  swagger-ui:
    enabled: false
YAML

cat > "${SERVICE_DIR}/src/main/resources/application-prd.yml" << 'YAML'
logging:
  level:
    root: WARN
    org.mybatis: "OFF"

springdoc:
  api-docs:
    enabled: false
  swagger-ui:
    enabled: false
YAML

# Register in settings.gradle.kts (duplicate-safe)
SETTINGS_FILE="${PROJECT_ROOT}/settings.gradle.kts"
INCLUDE_LINE="include(\"services:${SERVICE_NAME}\")"
if ! grep -qF "${INCLUDE_LINE}" "${SETTINGS_FILE}"; then
  echo "${INCLUDE_LINE}" >> "${SETTINGS_FILE}"
  echo "Added to settings.gradle.kts: ${INCLUDE_LINE}"
else
  echo "Already registered in settings.gradle.kts (skipped)"
fi

echo ""
echo "Service '${SERVICE_NAME}' created at ${SERVICE_DIR}"
echo "Next steps:"
echo "  1. Update application.yml: set spring.application.name and server.port"
echo "  2. Run: cd ${PROJECT_ROOT} && ./gradlew build -x test"
