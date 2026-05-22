---
name: add-validation
description: 요청 DTO에 Bean Validation 추가 + 테스트
agent: agent
id: add-validation.v1
purpose: 컨트롤러 요청 DTO에 입력 검증을 추가하고, GlobalExceptionHandler 연계와 단위 테스트까지 완성하기 위한 프롬프트
portability: spring-boot-example
difficulty: beginner
inputs:
  - dto_class
  - validation_rules
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


`{{dto_class}}`에 Bean Validation을 추가해 줘.

검증 요구사항:
{{validation_rules}}

작업 범위:

1. DTO 필드에 `jakarta.validation.constraints.*` 어노테이션 추가
2. 컨트롤러 메서드 파라미터에 `@Valid` 추가 (이미 있으면 생략)
3. `GlobalExceptionHandler`의 `MethodArgumentNotValidException` 처리가 이미 있는지 확인 — 없으면 추가
4. 단위 테스트: 유효한 값과 각 위반 케이스에 대한 AssertJ 기반 테스트 작성

규칙:

- `@NotNull`, `@NotBlank`, `@Size`, `@Pattern`, `@Min`, `@Max` 우선 사용.
- 커스텀 validator는 표준 어노테이션으로 대체 불가능할 때만 추가.
- 에러 응답 형식은 `ApiResponse`와 기존 `ErrorCode` 체계를 따를 것.

출력 형식:

1. 변경할 DTO + 컨트롤러 코드
2. GlobalExceptionHandler 변경사항 (없으면 "변경 없음")
3. 테스트 케이스 (유효/위반 각각)
4. 검증 방법 (`./gradlew :services:<서비스명>:test`)
