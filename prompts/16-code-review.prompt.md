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


이 변경사항을 시니어 엔지니어 관점에서 리뷰해 줘.

일반 관점:

- 버그 가능성
- 보안 (injection, 토큰/secret 노출, 민감 정보 로깅)
- 유지보수성
- 성능 (불필요한 I/O, 반복 쿼리/요청, 과도한 객체 생성)

프레임워크/아키텍처 안티패턴 체크:

- 트랜잭션, 비동기, 캐시, retry 정책의 오용
- 레이어 위반: presentation/API 계층에 비즈니스 로직, persistence 계층에 외부 호출
- 반복 I/O: 루프 안 DB/API 호출, 불필요한 네트워크 round-trip
- DTO/domain/entity 경계 혼합
- 공통 모듈 오염: shared/common 영역에 기능 특화 로직 추가

출력 형식:

1. 주요 지적 사항 (심각도: High/Medium/Low + 위치)
2. 프레임워크/아키텍처 안티패턴 발견 여부
3. 수정 제안
