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
| T8 | 비자명 이슈 해결 | `docs/troubleshooting/` 기록 제안 |
| T9 | 발표/보고 산출물 생성 | source traceability, output path, STATUS/backlog 참조 필요 여부 확인 |

## Loop Safety

- T4는 STATUS 참조만 갱신하고 다른 trigger를 발동하지 않는다.
- T7 결과는 다시 T7을 발동하지 않는다.
- T9 결과물은 source 문서를 수정하지 않는다. source 변경이 필요하면 별도 작업으로 분리한다.
- T5와 T6가 같은 문서를 건드릴 때는 한쪽은 수정, 다른 쪽은 확인만 한다.
- DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.

## Cascade Rule

Cascade는 자동 실행이 아니라 제안과 검증 대상이다.
파일 수정은 사용자 승인 또는 명시 요청 후 진행한다.

## STATUS.md 섹션별 삭제 Cascade 체크리스트

STATUS.md 항목 삭제 또는 이동 전 해당 섹션의 체크리스트를 확인한다.
모든 STATUS.md 변경은 STATUS Update Proposal → 사용자 승인 후 수행한다.

| 섹션 | 삭제/이동 전 확인 사항 |
| --- | --- |
| Active Work | 연결된 backlog 항목(`PHASE{n}.md` 또는 `HARNESS.md`) 상태 업데이트 필요 여부 확인 |
| Checkpoints | 해당 Phase 전체 Done 시 T3(Phase 완료) 트리거 — `docs/archive/`로 이동 제안 |
| Blockers / Open Questions | Closed OQ에 연결된 DR이 있으면 DR Status → Accepted 처리 여부 확인 |
| Next Actions | 연결된 backlog 항목이 있으면 항목 완료 상태 일치 여부 확인 |
| Recent Decisions | **삭제 금지** — rolling window(최근 8개) 초과분은 drop. DR-worthy였으면 DR이 canonical. |
