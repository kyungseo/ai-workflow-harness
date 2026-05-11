---
name: write-tests-first
description: 테스트 우선 작성
agent: agent
id: write-tests-first.v1
purpose: 테스트를 먼저 작성하고 구현을 보완하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - target_behavior
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


아래 대상에 대한 테스트를 먼저 작성해 줘.

대상:
{{target}}

기술 스택:

- JUnit 5 (`@ExtendWith(MockitoExtension.class)`)
- Mockito (`given/willReturn` 방식 선호)
- AssertJ (`assertThat`, `assertThatThrownBy`)
- 외부 의존성은 mock 처리

케이스 구성:

- **Success case** — 정상 입력, 기대 결과 확인
- **Failure case** — 에러 조건, 예외 타입 및 메시지 확인
- 경계값 (필요한 경우)

네이밍:

- 메서드명: `methodName_scenario_expectedBehavior` (영어)
- `@DisplayName`: 한국어 (`"성공 시 결과를 반환한다"`)

출력 형식:

1. 테스트 코드 (Success + Failure 케이스)
2. 테스트 통과를 위한 최소 구현 스텁
3. 이 테스트가 검증하는 핵심 동작
