---
name: add-resilience
description: RestClient 호출에 Resilience4j circuit breaker/retry 추가
agent: agent
id: add-resilience.v1
purpose: 서비스 간 RestClient 호출에 Resilience4j circuit breaker와 retry를 적용하여 장애 전파를 방지하기 위한 프롬프트
portability: spring-boot-example
difficulty: intermediate
inputs:
  - target_call
  - failure_threshold
  - fallback_behavior
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{target_call}}`에 Resilience4j circuit breaker와 retry를 추가해 줘.

설정:

- 실패 임계값: {{failure_threshold}}
- fallback 동작: {{fallback_behavior}}

작업 범위:

1. `libs.versions.toml`에 `resilience4j-spring-boot3` 의존성 확인 (없으면 추가)
2. `application.yml`에 circuit breaker / retry 설정 블록 추가
3. 대상 메서드에 `@CircuitBreaker(name = "...", fallbackMethod = "...")` 적용
4. fallback 메서드 작성 (원본과 동일한 시그니처 + `Throwable` 파라미터)
5. 실패 경로 테스트: Mockito로 원격 호출 실패 시뮬레이션 후 fallback 동작 확인

규칙:

- Phase 1에서는 서비스 간 직접 호출이 없었으므로 실제 호출 지점을 먼저 확인할 것.
- circuit breaker 이름은 `{서비스명}-{대상}` 형식으로 명명.
- fallback은 빈 결과 또는 캐시된 값을 반환하는 것을 우선 검토.

출력 형식:

1. 의존성 + 설정 변경
2. 어노테이션 적용 코드
3. fallback 메서드
4. 실패 경로 테스트
5. 리스크 (timeout 설정, bulkhead 필요 여부)
