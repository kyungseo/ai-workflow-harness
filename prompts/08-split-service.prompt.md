---
name: split-service
description: 기존 모듈/기능을 새 마이크로서비스로 분리
agent: agent
id: split-service.v1
purpose: 하나의 서비스에 있는 기능을 독립 마이크로서비스로 안전하게 분리하기 위한 프롬프트
portability: base-msa-template
difficulty: advanced
inputs:
  - source_service
  - feature_to_extract
  - new_service_name
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{source_service}}`에서 `{{feature_to_extract}}` 기능을 `{{new_service_name}}`으로 분리해 줘.

작업 순서:

1. **의존성 분석**: `{{source_service}}`에서 `{{feature_to_extract}}`가 사용하는 도메인 모델, Repository, 공통 모듈 파악
2. **DB 소유권 확인**: 분리할 기능이 사용하는 테이블과 그 소유권 결정 (Phase 1은 공유 DB)
3. **신규 서비스 스캐폴딩**: `scripts/create-service.sh {{new_service_name}} <port>` 계획 수립
4. **코드 이전**: 최소한의 변경으로 기능 이전 (공통 모듈은 `common-core`로)
5. **서비스 간 통신**: `{{source_service}}`에서 `{{new_service_name}}`으로의 RestClient 호출 추가
6. **Gateway 라우팅**: 신규 서비스 경로 추가
7. **점진적 전환**: 기존 코드를 즉시 삭제하지 말고 동작 확인 후 제거

규칙:

- 한 번에 전부 이전하지 말고, 단계별로 검증할 것.
- `common-core`에 서비스 특화 로직을 추가하지 말 것.
- 분리 전후 동작이 동일한지 통합 테스트로 검증할 것.

출력 형식:

1. 분리 계획 (단계별)
2. 파일별 변경 범위
3. 검증 시나리오
4. 리스크와 되돌리기 비용
