---
name: minimal-diff
description: 지정한 위치만 수정 — 전체 파일 rewrite 방지
agent: agent
id: minimal-diff.v1
purpose: 명시한 위치만 최소한으로 수정하고 나머지는 절대 건드리지 않기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - target
  - change
output_contract:
  - 변경
---


아래 내용만 수정해 줘.

수정 대상: {{target}}
수정 내용: {{change}}

절대 금지:

- 다른 메서드 / 클래스 / 파일 변경 금지
- 변수명 또는 메서드명 변경 금지
- 코드 포맷 변경 금지 (들여쓰기, 공백 포함)
- 주석 추가 / 제거 금지
- import 정리 금지
- 구조 (레이어, 패키지) 변경 금지
- 리팩토링 금지

출력 형식:

- **수정된 부분만** 출력 (before / after 형식 또는 diff)
- 전체 파일 재출력 금지
