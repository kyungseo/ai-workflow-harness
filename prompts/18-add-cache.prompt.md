---
name: add-cache
description: Caffeine 또는 Redis 캐싱 추가 (TTL + invalidation 근거 포함)
agent: agent
id: add-cache.v1
purpose: 서비스 메서드에 Caffeine 또는 Redis 캐싱을 적용하고 TTL, invalidation 전략, Pod 스케일 아웃 제약까지 문서화하기 위한 프롬프트
portability: spring-boot-example
difficulty: intermediate
inputs:
  - target_method
  - cache_type
  - ttl
  - invalidation_trigger
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{target_method}}`에 `{{cache_type}}` 캐싱을 추가해 줘.

설정:

- TTL: {{ttl}}
- 무효화 트리거: {{invalidation_trigger}}

캐시 유형 선택 기준:

- **Caffeine**: 변경 빈도 낮음 + Pod 간 불일치 허용 가능 (예: 권한 목록, 공개 설정값)
- **Redis**: 무효화가 즉시 전파되어야 하거나 세션/토큰 관련 데이터 (예: 사용자 정보, 인증 상태)

작업 범위:

1. `{{cache_type}}` 선택 근거 확인 (위 기준으로 적합한지 검토)
2. `application.yml`에 캐시 설정 추가
3. `@Cacheable`, `@CacheEvict`, `@CachePut` 적용
4. TTL 설정 명시
5. Pod 스케일 아웃 시 캐시 불일치 가능성 문서화 (Caffeine 선택 시)
6. 캐시 hit/miss 동작 확인 테스트 작성

규칙:

- **Caffeine** 선택 시: TTL을 짧게 유지하고 Pod 간 불일치 허용 설계를 명시할 것.
- **Redis** 선택 시: 기존 `rt:`, `bl:`, `rl:` 키 스키마와 충돌하지 않는 키 네이밍 사용.
- 캐시 적용 후 stale data 시나리오를 테스트할 것.

출력 형식:

1. 캐시 유형 선택 근거
2. 설정 + 어노테이션 코드
3. invalidation 전략
4. Pod 스케일 아웃 시 제약 사항
5. 캐시 테스트 케이스
