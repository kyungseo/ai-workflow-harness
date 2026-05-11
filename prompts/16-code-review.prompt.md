---
name: code-review
description: 코드 리뷰
agent: agent
id: code-review.v1
purpose: 변경사항의 결함/리스크를 검토하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - diff_or_scope
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 변경사항을 시니어 Spring Boot 개발자 관점에서 리뷰해 줘.

일반 관점:

- 버그 가능성
- 보안 (SQL injection, 토큰 노출, 민감 정보 로깅)
- 유지보수성
- 성능 (N+1, 불필요한 객체 생성)

Spring 안티패턴 체크:

- `@Transactional` 오용: private 메서드 또는 Controller에 적용, 불필요한 `readOnly=false`
- 레이어 위반: Controller에 비즈니스 로직, Repository에 HTTP 참조
- N+1 쿼리: 루프 안 쿼리 호출
- `@Data` 사용: equals/hashCode 부작용 위험
- 공통 모듈 오염: `common-core`에 서비스 특화 로직 추가

출력 형식:

1. 주요 지적 사항 (심각도: High/Medium/Low + 위치)
2. Spring 안티패턴 발견 여부
3. 수정 제안
