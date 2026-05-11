---
name: add-metrics
description: Micrometer counter/timer/gauge 추가
agent: agent
id: add-metrics.v1
purpose: 서비스 메서드에 Micrometer 메트릭을 추가하고 Prometheus 수집 가능하도록 노출하기 위한 프롬프트
portability: base-msa-template
difficulty: beginner
inputs:
  - target_class
  - metric_name
  - metric_type
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{target_class}}`에 Micrometer `{{metric_type}}` 메트릭 `{{metric_name}}`을 추가해 줘.

메트릭 유형별 용도:

- **Counter**: 이벤트 발생 횟수 (로그인 시도, 에러 발생 등)
- **Timer**: 작업 소요 시간 (DB 쿼리, API 호출 등)
- **Gauge**: 현재 상태값 (큐 길이, 활성 세션 수 등)

작업 범위:

1. `MeterRegistry`를 생성자 주입으로 추가
2. 메트릭 등록 (빌더 방식 권장: `Counter.builder(...)`, `Timer.builder(...)`)
3. 측정 지점 추가 (메서드 내 적절한 위치)
4. `management.endpoints.web.exposure.include`에 `prometheus` 포함 여부 확인
5. `/actuator/metrics/{{metric_name}}` 엔드포인트로 동작 확인 방법 명시

규칙:

- 메트릭 이름은 `msa.{service}.{action}` 형식 사용 (예: `msa.auth.login.success`).
- 태그는 `service`, `status`, `method` 등 최소 식별자만 사용.
- Actuator 포트(8099)가 외부에 노출되지 않는지 확인.

출력 형식:

1. 변경 코드 (MeterRegistry 주입 + 메트릭 등록)
2. application.yml 변경사항
3. 검증 커맨드 (`curl localhost:8099/actuator/metrics/...`)
4. Phase 2 P2-007 (Prometheus/Grafana) 연동 시 추가 고려사항
