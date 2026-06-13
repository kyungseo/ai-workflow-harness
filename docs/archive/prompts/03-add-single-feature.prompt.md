---
name: add-single-feature
description: 기존 코드에 기능 하나 추가
agent: agent
id: add-single-feature.v1
purpose: 기존 코드에 단일 기능을 안전하게 추가하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - feature
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


현재 코드에 {{feature}} 기능만 추가해 줘.

**단계를 반드시 분리해서 진행할 것:**

Step 1 — 설계만 (코드 생성 금지):
- API 스키마 또는 인터페이스 설계
- 검증 규칙과 에러 케이스 정의
- 영향받는 파일 목록

Step 1 출력 후 "계속할까요?"로 대기. 승인 후 Step 2 진행.

Step 2 — 구현:
- Step 1 설계 기반으로만 구현
- 설계 범위를 벗어난 변경 금지

규칙:

- 기존 동작은 유지할 것.
- 관련 없는 코드는 건드리지 말 것.
- 변경 범위는 최소화할 것.

출력 형식:

1. [Step 1] 설계 (API 스키마, 에러 케이스, 영향 파일)
2. [Step 2] 구현 코드
3. 변경 요약 + 검증 방법
