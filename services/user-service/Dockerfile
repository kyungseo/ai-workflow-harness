# Build context: repo root (common-core 의존성 포함을 위해 루트에서 빌드)
# docker build -f services/user-service/Dockerfile -t user-service .
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :services:user-service:bootJar --no-daemon && \
    cp $(find services/user-service/build/libs -name "*.jar" | grep -v plain) app.jar

FROM eclipse-temurin:21-jre-jammy
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo "Asia/Seoul" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Seoul
WORKDIR /app
COPY --from=builder /app/app.jar app.jar
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
