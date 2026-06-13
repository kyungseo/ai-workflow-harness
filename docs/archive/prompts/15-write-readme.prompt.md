---
name: write-readme
description: README 작성
agent: agent
id: write-readme.v1
purpose: 프로젝트 README를 작성/개선하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - project_summary
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 프로젝트의 README를 작성해 줘.

필수 포함:

- 프로젝트 설명
- 설치 방법
- 실행 방법
- 환경변수
- 주요 기능
- 개발 메모

출력 형식:

1. README 초안
2. 필요한 보충 정보
