---
name: create-layer
description: Spring Boot 레이어별 코드 생성 (Controller / Service / Repository)
agent: agent
id: create-layer.v1
purpose: 지정한 레이어의 코드만 생성하고 다른 레이어는 건드리지 않기 위한 프롬프트
portability: base-msa-template
difficulty: beginner
inputs:
  - layer
  - domain
  - operations
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{domain}}`의 `{{layer}}` 레이어만 생성해 줘.

레이어: {{layer}} (controller / service / repository 중 하나)
도메인: {{domain}}
제공할 기능: {{operations}}

레이어별 규칙:

- **controller**: Base path 정의. Request/Response DTO 사용. `@Valid` 적용. `ResponseEntity` 반환. 비즈니스 로직 금지.
- **service**: interface + implementation 분리. HTTP/Controller 의존 없음. 예외 명확히 정의. `@Transactional` 범위 최소화.
- **repository**: MyBatis Mapper interface + XML. SQL 단순하게. N+1 방지. `#{}` 파라미터 사용 (`${}` 금지).

공통 제약:

- **이 레이어만 생성. 다른 레이어 코드 생성 금지.**
- 패키지: `io.kyungseo.msa.{{domain | lowercase}}`
- Lombok: `@Getter`, `@Builder`, `@RequiredArgsConstructor`, `@Slf4j` (필요한 것만 선택)
- `@Data` 사용 금지

출력 형식:

1. 생성할 파일 목록
2. 코드
3. 다음 단계 제안 (이어서 생성할 레이어)
