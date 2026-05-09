---
name: accessibility-fix
description: 접근성 개선
agent: agent
id: accessibility-fix.v1
purpose: 접근성 문제를 진단하고 개선하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - a11y_issue
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 UI의 접근성을 개선해 줘.

확인 항목:

- 키보드 탐색
- aria 속성
- 대비
- 포커스 표시

출력 형식:

1. 문제점
2. 수정 코드
3. 체크리스트
