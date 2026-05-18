# 05. Triggers and Cascade

이 문서는 trigger와 cascade 규칙의 canonical source다.

## Trigger Summary

| ID | Trigger | Result |
| --- | --- | --- |
| T1 | DR-worthy decision accepted | DR 생성 제안 |
| T2 | DR 삭제/통합/Superseded | STATUS/backlog/summary 참조 정리 |
| T3 | Phase 완료 또는 새 Phase 시작 | STATUS/PLAN archive |
| T4 | 큰 작업 분해 필요 | Work 파일 생성 제안 |
| T5 | PLAN 영향 결정 | PLAN/summary/rules 관련 문서 확인 |
| T6 | 구조/흐름 구현 변경 | ARCHITECTURE/DEVELOPER-GUIDE 확인 |
| T7 | workflow rule/command 변경 | harness protocol 또는 workflow 상세 문서 업데이트 |
| T8 | 비자명 이슈 해결 | `docs/troubleshooting/` 기록 제안 |
| T9 | 발표/보고 산출물 생성 | source traceability, output path, STATUS/backlog 참조 필요 여부 확인 |
| T10 | Work 파일 Done 상태 발견 | archive 승인 여부 제안 |
| T11 | tool surface 변경 | Claude/Codex/Cursor/prompts/README/scaffold 정렬 확인 |
| T12 | scaffold source 또는 canonical workflow 변경 | dry-run + temp scaffold 검증 |
| T13 | Quick Mode L1 변경 | no Work/no STATUS 기본, cascade-sensitive file 예외 확인 |

## Loop Safety

- T4는 STATUS 참조만 갱신하고 다른 trigger를 발동하지 않는다.
- T7 결과는 다시 T7을 발동하지 않는다.
- T9 결과물은 source 문서를 수정하지 않는다. source 변경이 필요하면 별도 작업으로 분리한다.
- T5와 T6가 같은 문서를 건드릴 때는 한쪽은 수정, 다른 쪽은 확인만 한다.
- DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.
- T10은 archive 제안만 수행한다. 사용자 승인 전 `git mv`를 실행하지 않는다.
- T11은 관련 tool surface를 확인 대상으로 추가하지만 자동 수정하지 않는다. 발견 → 제안 → 승인 순서를 따른다.
- T12는 temp target에서 검증하고 생성물을 live tree로 복사하지 않는다.
- T13은 작은 작업의 빠른 종료를 보호한다. 단, workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check를 수행한다.

## Cascade Rule

Cascade는 자동 실행이 아니라 제안과 검증 대상이다.
파일 수정은 사용자 승인 또는 명시 요청 후 진행한다.

| Level | Action | Meaning |
| --- | --- | --- |
| A | 확인만 | 관련 문서를 읽거나 검색해 영향 없음 확인 |
| B | 발견 보고 | drift 또는 누락을 보고하고 수정 필요 여부 제안 |
| C | 승인 후 수정 | 사용자가 승인한 범위에서 관련 파일 수정 |
| D | 별도 Work/DR 분리 | 범위가 커지거나 reversal cost가 Medium 이상이면 별도 추적 |

## Tool Surface Cascade Matrix

| 변경 대상 | 반드시 확인할 표면 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/*.md` | `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.claude/rules/`, `.cursor/rules/`, `prompts/`, `scripts/create-harness.sh` |
| `.claude/commands/*.md` | `AGENTS.md` command mapping, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md`, `docs/HARNESS-QUICK-REFERENCE.md` |
| `.claude/rules/*.md` 또는 `.cursor/rules/*.mdc` | 반대 tool rule, `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/05-triggers-and-cascade.md` |
| `prompts/*session-start.md` | `prompts/README.md`, `AGENTS.md`, `CLAUDE.md`, relevant command/rule |
| `scripts/create-harness.sh` | generic/spring-boot dry-run, temp scaffold 생성 결과, scaffold 내부 stale phrase 검색 |
| `docs/decisions/DR-*.md` Accepted | `docs/STATUS.md` Recent Decisions 필요 여부, 관련 backlog/Work 파일, PLAN 영향 여부 |
| developer-facing docs (`README.md`, `DEVELOPER-GUIDE.md`, `CODING-CONVENTIONS.md`) | 실제 config/script/source와 기술 내용 대조 |
| `docs/` 하위 디렉토리 신규 추가 또는 삭제 | T5(PLAN 영향 여부), T7(harness protocol 업데이트 필요 여부), Context Routing 갱신 여부, `scripts/create-harness.sh` 동기화 여부 확인 |

## STATUS.md Section Deletion Cascade Checklist

STATUS.md 항목 삭제 또는 이동 전 해당 섹션의 체크리스트를 확인한다.
모든 STATUS.md 변경은 State Update Gate에 맞는 제안 → 사용자 승인 후 수행한다.

| 섹션 | 삭제/이동 전 확인 사항 |
| --- | --- |
| Active Work | 연결된 Work 파일과 backlog 항목(`PHASE{n}.md` 또는 `HARNESS.md`) 상태 업데이트 필요 여부 확인 |
| Work files | 해당 Phase Work 파일 전체 Done 시 T3(Phase 완료) 트리거 — archive 이동 제안 |
| Blockers / Open Questions | Closed OQ에 연결된 DR이 있으면 DR Status → Accepted 처리 여부 확인 |
| Next Actions | 연결된 backlog 항목이 있으면 항목 완료 상태 일치 여부 확인 |
| Recent Decisions | **삭제 금지** — 최근 8개 rolling window 유지. 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부 확인. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둔다. 상세 근거는 DR-011. |
