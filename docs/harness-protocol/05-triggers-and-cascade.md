# 05. Triggers and Cascade

이 문서는 trigger와 cascade 규칙의 canonical source다.

## Trigger Summary

| ID | Trigger | Result |
| --- | --- | --- |
| T1 | DR-worthy decision accepted | DR 생성 제안 |
| T2 | DR 삭제/통합/Superseded | STATUS/backlog/summary 참조 정리 |
| T3 | Phase 완료 또는 새 Phase 시작 | STATUS/PLAN archive |
| T4 | 큰 작업 분해 필요 | TODO 생성 제안 |
| T5 | PLAN 영향 결정 | PLAN/summary/rules 관련 문서 확인 |
| T6 | 구조/흐름 구현 변경 | ARCHITECTURE/DEVELOPER-GUIDE 확인 |
| T7 | workflow rule/command 변경 | harness protocol 또는 workflow 상세 문서 업데이트 |

## Loop Safety

- T4는 STATUS 참조만 갱신하고 다른 trigger를 발동하지 않는다.
- T7 결과는 다시 T7을 발동하지 않는다.
- T5와 T6가 같은 문서를 건드릴 때는 한쪽은 수정, 다른 쪽은 확인만 한다.
- DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.

## Cascade Rule

Cascade는 자동 실행이 아니라 제안과 검증 대상이다.
파일 수정은 사용자 승인 또는 명시 요청 후 진행한다.
