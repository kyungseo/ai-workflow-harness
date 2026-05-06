# Build context: repo root (common-core 의존성 포함을 위해 루트에서 빌드)
# docker build -f services/auth-service/Dockerfile -t auth-service .
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :services:auth-service:bootJar --no-daemon && \
    cp $(find services/auth-service/build/libs -name "*.jar" | grep -v plain) app.jar

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/app.jar app.jar
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
