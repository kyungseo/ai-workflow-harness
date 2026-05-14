# Dockerfile 상세 가이드 (Spring Boot + Gradle 멀티모듈 기준)

> 하단 설명은 gateway/api-gateway/Dockerfile을 예시로 한다.

전체 코드

```dockerfile
# Build context: repo root (common-core 의존성 포함을 위해 루트에서 빌드)
# docker build -f gateway/api-gateway/Dockerfile -t api-gateway .
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :gateway:api-gateway:bootJar --no-daemon && \
    cp $(find gateway/api-gateway/build/libs -name "*.jar" | grep -v plain) app.jar

FROM eclipse-temurin:21-jre-jammy
RUN apt-get update && apt-get install -y --no-install-recommends tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime && \
    echo "Asia/Seoul" > /etc/timezone && \
    rm -rf /var/lib/apt/lists/*
ENV TZ=Asia/Seoul
WORKDIR /app
COPY --from=builder /app/app.jar app.jar
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom -jar app.jar"]
```


## 0. 한 줄 요약
이 Dockerfile은 멀티 스테이지 빌드를 사용하여  
> ① Gradle로 JAR를 빌드하고 → ② 가벼운 JRE 이미지에 실행만 하는 구조

---

## 1. 전체 구조 이해

```dockerfile
FROM gradle:8-jdk21 AS builder   ← 빌드용 컨테이너 
... 
FROM eclipse-temurin:21-jre-jammy ← 실행용 컨테이너 
```

👉 핵심:
- builder stage: 코드 컴파일 + JAR 생성
- runtime stage: 실행만 담당 (가볍고 안전)

---

## 2. 빌드 스테이지 (builder)

### 2.1 베이스 이미지

```dockerfile
FROM gradle:8-jdk21 AS builder 
```

👉 의미:
- Gradle + JDK 21이 이미 설치된 이미지
- 코드 빌드용 환경

---

### 2.2 작업 디렉토리 설정

```dockerfile
WORKDIR /app 
```

👉 컨테이너 내부에서 작업할 기본 경로

---

### 2.3 소스 복사

```dockerfile
COPY . . 
```

👉 중요 포인트:
- repo root 전체 복사
- 이유:
  - common-core 같은 멀티모듈 의존성 포함 필요

---

### 2.4 Gradle 빌드

```dockerfile
RUN gradle :gateway:api-gateway:bootJar --no-daemon
```

👉 의미:
- 특정 모듈만 빌드
- bootJar → 실행 가능한 Spring Boot JAR 생성

---

### 2.5 실행 JAR 추출

```dockerfile
cp $(find gateway/api-gateway/build/libs -name "*.jar" | grep -v plain) app.jar 
```

👉 왜 필요한가?

Spring Boot 빌드 결과:
```text
text xxx.jar        ← 실행용 (fat jar) 
xxx-plain.jar  ← 일반 jar (의존성 없음) 
```

👉 여기서:
- plain 제외
- 실행 가능한 JAR만 선택

---

## 3. 실행 스테이지 (runtime)

### 3.1 베이스 이미지

```dockerfile
FROM eclipse-temurin:21-jre-jammy 
```

👉 의미:
- OpenJDK 21 JRE
- Ubuntu Jammy 기반
- JDK 없음 → 더 가벼움

---

### 3.2 타임존 설정

```dockerfile
RUN apt-get update && apt-get install -y tzdata 
```

👉 목적:
- 컨테이너 시간 맞추기

---

### 한국 시간 설정

```dockerfile
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime 
echo "Asia/Seoul" > /etc/timezone 
```

👉 이유:
- 로그 시간
- 스케줄 작업 정확성

---

### 정리 작업

```dockerfile
rm -rf /var/lib/apt/lists/* 
```

👉 이미지 크기 줄이기

---

### 3.3 환경 변수 설정

```dockerfile
ENV TZ=Asia/Seoul 
```

👉 Java 및 OS에서 동일 timezone 사용

---

### 3.4 작업 디렉토리

```dockerfile
WORKDIR /app 
```

---

### 3.5 빌드 결과 복사

```dockerfile
COPY --from=builder /app/app.jar app.jar 
```

👉 핵심:
- builder stage에서 만든 JAR만 가져옴
- 소스코드는 포함되지 않음

---

## 4. 실행 명령 (ENTRYPOINT)

```dockerfile
ENTRYPOINT ["sh", "-c", "exec java ${JAVA_OPTS} -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom -jar app.jar"] 
```

---

### 4.1 exec 사용 이유

```bash
exec java ... 
```

👉 효과:
- PID 1로 실행
- SIGTERM 정상 처리 (컨테이너 종료 안정성)

---

### 4.2 JAVA_OPTS

```bash
${JAVA_OPTS} 
```

👉 외부에서 JVM 옵션 주입 가능

예:

```bash
-e JAVA_OPTS="-Xms512m -Xmx1g" 
```

---

### 4.3 메모리 설정

```bash
-XX:MaxRAMPercentage=75.0 
```

👉 의미:
- 컨테이너 메모리의 75%를 heap으로 사용

👉 이유:
- Kubernetes 환경에서 안전한 메모리 사용

---

### 4.4 난수 생성 최적화

```bash
-Djava.security.egd=file:/dev/./urandom 
```

👉 효과:
- 빠른 랜덤 생성
- startup 지연 방지

---

## 5. 왜 멀티 스테이지를 쓰는가

### 단일 스테이지

- Gradle + 소스 + build tool 전부 포함
- 이미지 매우 큼

---

### 멀티 스테이지

- 빌드 결과만 포함
- 이미지 작고 안전

---

## 6. 빌드 방법

```bash
docker build -f gateway/api-gateway/Dockerfile -t api-gateway . 
```

👉 포인트:
- 반드시 repo root에서 실행
- 이유:
  - common-core 등 의존성 포함 필요

---

## 7. 실행 방법

```bash
docker run -p 8090:8090 api-gateway
```

---

## 8. 실무 팁

### Gradle 캐시 최적화 (개선 가능)

현재:

```dockerfile
COPY . . 
```

👉 문제:
- 코드 변경 시 매번 전체 rebuild

👉 개선:


```dockerfile
COPY gradle gradle 
COPY build.gradle.kts settings.gradle.kts . 
RUN gradle dependencies

COPY . . 
```

---

### JVM 옵션 외부화

```bash
JAVA_OPTS="-Xms512m -Xmx1g" 
```

---

### Health Check 추가 (추천)

---

## 9. 구조 요약

```text
[ Builder Stage ]
  Gradle + JDK
   ↓ build
  app.jar 생성

[ Runtime Stage ]
  JRE only
   ↓ copy
  app.jar 실행
```

---

## 10. 한 줄 결론

> 이 Dockerfile은  
> “빌드는 무겁게, 실행은 가볍게”라는 컨테이너 설계 원칙을 정확히 따르는 구조다.

---

## 추가 확장 (다음 단계)
- Layered JAR 적용 (Docker build cache 최적화)
- Distroless 이미지 적용
- Kubernetes readiness/liveness 연계

관련 작업 후보: `docs/backlog/PHASE2.md`의 `PRE-C3`.
