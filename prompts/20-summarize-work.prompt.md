---
name: summarize-work
description: 작업 요약
agent: agent
id: summarize-work.v1
purpose: 작업 결과를 간결하게 요약하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - change_scope
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이번 변경사항을 간단히 요약해 줘.

포함:

- 수정 파일 목록
- 핵심 변경점
- 남은 리스크
- 다음 작업 제안

제약:

- 5줄 이내로 간결하게
