---
name: responsive-fix
description: 반응형 개선
agent: agent
id: responsive-fix.v1
purpose: 반응형 레이아웃 깨짐을 수정하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - screen_sizes
  - issue
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 레이아웃을 반응형으로 바꿔 줘.

대상:

- 모바일
- 태블릿
- 데스크톱

제약:

- 작은 화면에서 깨지는 부분 우선 수정
- 기존 레이아웃 의도 유지

출력 형식:

1. 깨지는 지점
2. 수정 코드
3. 확인 기준
