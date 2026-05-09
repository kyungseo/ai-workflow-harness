---
name: split-component
description: 큰 컴포넌트 분리
agent: agent
---

이 파일의 큰 컴포넌트를 역할별로 나눠 줘.

규칙:

- 공통 로직은 훅으로 분리
- 재사용 가능한 UI는 컴포넌트로 분리
- props는 최소화
- 기존 동작 유지

출력 형식:

1. 분리 전략
2. 새 파일 목록
3. 코드
