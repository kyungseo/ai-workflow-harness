---
name: scaffold-project
description: 새 프로젝트 뼈대 생성
agent: agent
id: scaffold-project.v1
purpose: 신규 프로젝트 뼈대와 초기 구조를 설계/생성하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - goal
  - stack
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


너는 시니어 풀스택 개발자다.

목표:
{{goal}}

요구사항:

- 디렉터리 구조를 먼저 제안할 것.
- 기술 스택은 {{stack}}을 기준으로 할 것.
- 실행 가능한 최소 구조를 만들 것.
- 불필요한 복잡성은 피할 것.

출력 형식:

1. 구조 제안
2. 생성할 파일 목록
3. 코드
4. 실행 방법
