---
name: performance-fix
description: Java 백엔드 성능 개선 (쿼리·JVM·스레드)
agent: agent
id: performance-fix.v2
purpose: 병목을 식별하고 백엔드 서비스의 성능을 최소 변경으로 개선하기 위한 프롬프트
portability: spring-boot-example
difficulty: advanced
inputs:
  - symptom
  - measurement
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


아래 증상을 분석하고 Java 백엔드 성능 문제를 개선해 줘.

증상: {{symptom}}
측정값: {{measurement}}

분석 우선순위:

- **DB 쿼리**: N+1 문제, 인덱스 누락, 불필요한 전체 조회, 불필요한 반복 쿼리
- **JVM**: 과도한 객체 생성, GC 압력, 불필요한 직렬화/역직렬화
- **스레드**: Virtual Thread blocking 지점, 동기 I/O 대기, 불필요한 락
- **캐시 미스**: Caffeine/Redis 캐시 적용 가능 여부

제약:

- 외부 동작(API 응답, 데이터 정합성) 변경 금지.
- **가장 작은 변경부터 제안할 것.** 대규모 리팩토링 금지.
- 측정 가능한 근거를 먼저 제시할 것.

출력 형식:

1. 병목 원인 (코드 위치 + 근거)
2. 개선 코드 (최소 수정)
3. 기대 효과 (정량 또는 정성)
4. 리스크
