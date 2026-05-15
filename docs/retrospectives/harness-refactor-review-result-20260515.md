# AI Workflow Harness 리팩터링 리뷰 결과

작성일: 2026-05-15
리뷰 대상: [`docs/retrospectives/harness-refactor-review-request-20260515.md`](harness-refactor-review-request-20260515.md)
관련 커밋: `0c34748 refactor: align AI workflow harness`
관련 계획: [`docs/HARNESS-REFACTOR-PLAN.md`](../HARNESS-REFACTOR-PLAN.md)
리뷰어: Claude Sonnet 4.6

---

## 1. 전반적 평가

계획(`HARNESS-REFACTOR-PLAN.md`)에서 정의한 5개 문제(상태 혼재, backlog 혼재, status drift, 과중한 manual, 약한 강제)는 실제로 해결되었다. Step 1~5 전부 Done 처리되고 CP-HRF-1~19 검증까지 완료된 것은 L3 작업치고 체계적인 실행이다. 계획 대비 이탈이 없고, 백업-먼저 원칙도 지켜졌다.

단, 리뷰 요청서가 스스로 인정한 것처럼 **"수동 우선 구조"라는 한계**가 지배적이며, 이 하네스의 품질은 에이전트 준수도에 전적으로 의존한다. 이것이 이번 리뷰의 핵심 판단 기준이다.

---

## 2. 잘 된 것

### 2.1 문서 모델 분리

`HARNESS-PROTOCOL.md` → `docs/harness-protocol/*.md`의 허브-스포크 구조는 컨텍스트 로드 비용을 통제하면서도 상세 규칙의 권위 있는 출처를 명확히 한다. "충돌 시 `harness-protocol/*.md` 우선"이라는 해소 규칙도 명시되어 있어 drift 발생 시 어디를 수정해야 하는지 분명하다.

### 2.2 STATUS Update Proposal gate

에이전트가 `STATUS.md`를 메모장처럼 쓰는 것이 state drift의 주된 원인이다. 승인 전 직접 수정 금지는 실질적인 방어선이다. `docs/AGENT-WORKFLOW.md`, Quick Reference, commands, Cursor rules에 일관되게 반영된 것도 적절하다.

### 2.3 Product/Harness backlog 분리

두 backlog는 생애주기가 다르다. 제품 기능은 사용자 가치 전달 기준으로 우선순위가 정해지고, 하네스 개선은 운영 안정성 기준이다. 같은 테이블에 섞이면 항상 한쪽이 희생된다. 이 분리는 구조적으로 옳다.

---

## 3. 문제와 우려

### 3.1 STATUS.md가 이미 길어지고 있다

현재 `STATUS.md`는 117줄이며 Recent Decisions가 20개 행을 차지한다. 이 섹션은 `docs/decisions/DR-*.md`와 내용이 중복된다. Phase 2가 시작되면 이 섹션이 계속 늘어나 결국 "live board"가 아니라 변경 이력 로그가 된다.

**권고:** Recent Decisions를 STATUS.md에서 제거하거나, 직전 세션 결정 3건으로 상한을 두고 나머지는 DR 파일로만 유지한다. HRN-006 착수 전에 이 규칙을 먼저 정해야 한다.

### 3.2 단일 커밋 71 파일 — 롤백 경로가 사실상 전부-아니면-전무

`HARNESS-REFACTOR-PLAN.md §7 Rollback Plan`은 `STATUS.md`와 `PHASE2.md` 복구만 언급한다. 그러나 이 커밋에는 9개 이상의 신규 문서(`HARNESS-PROTOCOL.md`, `HARNESS-QUICK-REFERENCE.md`, 6개 `harness-protocol/*.md` 등)가 포함된다. 부분 롤백은 커밋 단위로는 불가능하고 파일별 수동 복구가 필요하다.

백업이 `docs/archive/harness-refactor-20260514/`에 존재하므로 실용적 피해는 낮지만, 계획 문서의 롤백 섹션이 현실을 과소평가하고 있다. 다음 L3 작업에서는 논리적 단계별 커밋을 권고한다.

### 3.3 Codex가 구조적으로 가장 약한 링크

도구별 자동 진입 경로 비교:

| 도구 | 자동 로드 경로 | 강도 |
| --- | --- | --- |
| Claude | `CLAUDE.md` 자동 로드 → commands → rules | 강제 |
| Cursor | `.cursor/rules/*.mdc` 자동 적용 | 자동 |
| Codex | `prompts/codex-session-start.md`를 사용자 또는 에이전트가 기억 | 수동 |

이 비대칭이 가장 큰 실용적 리스크다. Codex 세션 하나가 잘못 시작되면 STATUS에 승인 없는 변경을 만들거나 plan gate를 건너뛸 수 있다. `AGENTS.md`를 HRN-008에 P2로 두는 것은 낮게 평가된 것이다.

**권고:** `AGENTS.md` 도입을 Phase 2 착수 조건으로 올린다. 모든 에이전트가 같은 출발점을 가져야 제품 작업 중 상태 손실을 막을 수 있다.

### 3.4 HRN-001/002 우선순위 불일치

HARNESS.md의 Priority Guide에서 P0는 "Phase2 본격 착수 전에 처리해야 하는 운영 기반"으로 정의한다. 그런데 HRN-001(Stop hook reminder)과 HRN-002(git hook + PostToolUse hard enforcement)는 P1이다.

Stop hook 없이는 에이전트가 `/done` 없이 세션을 끝내도 아무 알림이 없다. 검증 없이 STATUS가 굳어지는 가장 흔한 시나리오다. 리뷰 요청서 §8에서도 이 항목을 심각도 "높음"으로 분류했는데, backlog에서는 P1이다. 불일치다.

**권고:** HRN-001을 P0로 올리고 Phase 2 착수 전 구현을 조건으로 설정한다.

### 3.5 Quick Reference와 상세 protocol 간 drift 감지 메커니즘 없음

"충돌 시 `harness-protocol/*.md` 우선"이라는 규칙은 있지만, 두 문서가 서로 다른 내용을 말하고 있음을 **발견하는 방법**이 없다. `/health`가 `rg` 기반 점검을 하지만 의미적 일관성까지는 검사하지 못한다.

지금 당장 해결할 수 없는 구조적 한계이나, HRN-009 naming audit 이후 내용 정합성 점검 규칙 추가가 적절하다.

### 3.6 `HARNESS-REFACTOR-PLAN.md`를 archive로 이동해야 한다

현재 `STATUS.md` Current State 테이블의 `Active plan` 항목이 `docs/HARNESS-REFACTOR-PLAN.md`를 가리킨다. 그런데 HRF-001은 Done이다. 이 파일이 "active plan"으로 남아 있으면 다음 에이전트가 현재 진행 중인 계획으로 오해할 수 있다.

**권고:** `STATUS.md`의 `Active plan` 항목을 비우거나 제거하고, `HARNESS-REFACTOR-PLAN.md`는 archive로 이동하거나 참고 문서 상태임을 명시한다.

---

## 4. 리뷰 체크리스트 항목별 응답

리뷰 요청서 §9의 6개 항목에 직접 응답한다.

### 4.1 상태 모델

| 질문 | 판단 |
| --- | --- |
| `STATUS.md`가 현재 상태판으로 적절한가? | 구조는 맞다. Recent Decisions 섹션이 곧 부담이 된다. 상한 규칙 필요. |
| STATUS update approval gate가 실무적인가? | 예. 현재 구조에서 가장 강력한 방어선. 유지한다. |
| Done 작업 immutable 분리 규칙이 현실적인가? | 예. `/resume` 보강과 함께 충분히 명확하다. |

### 4.2 컨텍스트 로딩

| 질문 | 판단 |
| --- | --- |
| routing condition이 충분히 명확한가? | 라우팅 테이블은 명확하다. 에이전트가 올바른 "need"를 판별하는지는 실제 세션 검증이 추가로 필요하다. |
| quick reference / protocol hub / canonical detail 분리가 효과적인가? | 예. 조건부 로딩 모델이 컨텍스트 비용을 통제한다. |
| 회고 조건부 로딩이 의사결정을 개선하는가? | 예. 다만 회고 로드 조건("우선순위 동점, 반복 리스크")이 에이전트마다 다르게 해석될 수 있다. |

### 4.3 도구 간 정렬

| 질문 | 판단 |
| --- | --- |
| Claude/Cursor/Codex가 같은 상태 모델을 보는가? | Claude와 Cursor는 그렇다. Codex는 아직 아니다. |
| `AGENTS.md` 없이도 Codex 사용성이 충분한가? | 아니다. Phase 2 이전에 도입해야 한다. |
| `AGENTS.md` 도입 우선순위를 올려야 하는가? | 예. P2 → P1으로 상향 권고. |

### 4.4 강제 수단

| 질문 | 판단 |
| --- | --- |
| 어떤 규칙을 가장 먼저 hook으로 전환해야 하는가? | Stop hook(`/done` reminder) → PostToolUse STATUS freshness check 순서. |
| HRN-001/002를 Phase 2 제품 작업 전에 먼저 처리해야 하는가? | HRN-001은 예. HRN-002는 manual 안정화 후 진행이 적절. |
| pre-commit과 Claude/Cursor hooks의 역할 분리 기준은? | pre-commit: 코드 정적 검사(checkstyle, lint). Claude/Cursor hooks: STATUS freshness, `/done` reminder. 역할이 겹치지 않아야 한다. |

### 4.5 문서 구조

| 질문 | 판단 |
| --- | --- |
| 문서 수가 너무 많아졌는가? | 조건부 로딩 덕분에 현재는 허용 범위다. Phase 2 이후 증가 속도를 모니터한다. |
| 기준 문서가 명확한가? | 예. `harness-protocol/*.md`가 canonical source로 지정되어 있다. |
| `WORKFLOW-MANUAL.md`가 사람용 매뉴얼로 여전히 유용한가? | 예. 단, protocol 문서와 내용 drift를 주기적으로 확인해야 한다. |

### 4.6 Backlog 정리

| 질문 | 판단 |
| --- | --- |
| HRN 우선순위가 적절한가? | HRN-001을 P0로, HRN-008을 P1로 올려야 한다. 나머지는 현행 유지. |
| HRN-006, HRN-008, HRN-009 우선순위를 올려야 하는가? | HRN-008만 P1으로 상향. HRN-006과 HRN-009는 Phase 2 초기 P2 유지 적절. |
| 하네스 backlog 분리 후 Phase 2 준비 작업이 충분히 잘 보이는가? | 예. `docs/backlog/PHASE2.md`가 독립적으로 관리된다. |

---

## 5. 권고 우선순위

| 순위 | 항목 | ID | 근거 |
| --- | --- | --- | --- |
| 즉시 | `STATUS.md`의 `Active plan` 항목 정리 | — | Done 계획을 active로 오인할 수 있음 |
| Phase 2 전 | Stop hook 구현 | HRN-001 (P0로 상향) | 세션 종료 gate 없으면 state drift 가장 빠름 |
| Phase 2 전 | `AGENTS.md` 도입 | HRN-008 (P1으로 상향) | Codex 비대칭이 가장 큰 실용 리스크 |
| Phase 2 초기 | Recent Decisions 상한 규칙 정의 | — | `STATUS.md` 길이 통제 |
| Phase 2 안정화 후 | git hook + PostToolUse hard enforcement | HRN-002 (P1 유지) | L2 작업, manual 안정화 후 도입이 맞음 |
| HRN-009 이후 | Quick Reference ↔ protocol 내용 정합성 점검 규칙 | — | drift 발견 메커니즘 부재 보완 |

---

## 6. 종합

이번 리팩터링은 계획한 범위 안에서 성실하게 실행되었다. "경량 수동 우선 하네스 v1"이라는 자기 평가는 정직하며 적절하다.

핵심 약점은 구조 자체가 아니라 **에이전트 준수를 강제할 수단이 아직 없다**는 점이다. 특히 Codex 비대칭(`AGENTS.md` 부재)과 Stop hook 부재가 Phase 2 착수 전에 가장 먼저 메워야 할 구멍이다.

문서 수 증가는 현재 조건부 로딩 모델로 수용 가능하지만, Recent Decisions 섹션 상한 규칙을 정하지 않으면 `STATUS.md`가 반년 뒤 다시 과거 상태로 돌아갈 가능성이 높다.

다음 품질 상승은 문서를 더 늘리는 방식이 아니라 **선택적 자동화(HRN-001, HRN-008)** 에서 나와야 한다. 이것이 이번 리뷰의 핵심 권고다.

---

## 부록: 세션 시뮬레이션 리뷰

작성일: 2026-05-15
대상: Claude Code, Cursor, Codex 반복 세션 시나리오
방법: 하네스 전체 파일 검토 후 5개 시나리오 시뮬레이션

---

### 시뮬레이션 1 — Claude Code: 정상 세션 (신규 작업)

```
사용자 → /start → /pick → /work HRN-001 → 구현 → /done → 다음 세션
```

**INIT (STATUS.md 읽기)**
`/start` 명령이 STATUS.md의 5개 섹션만 읽도록 명확히 제한되어 있다. ✓

**PLAN → APPROVAL**
`/pick`이 backlog 유형을 자동 분기하고 STATUS Update Proposal 게이트가 명시되어 있다. ✓
`/work`가 L1/L2/L3 리스크 선언, scope/files/verification/risk를 계획 항목으로 강제한다. ✓
`"진행할까요?"`로 끝내고 승인 대기한다. ✓

**EXECUTE → VALIDATE**
`settings.json` PostToolUse 훅이 `.java` 파일 수정 시 실행된다.

> **문제 발견 (S1-1): PostToolUse 훅의 nudge 역할은 적절하지만, 세션 종료 전 검증 누락을 감지하는 Stop hook이 없어 enforcement chain이 완성되지 않는다.**

```json
"command": "python3 -c \"...print('제안: ./gradlew test')\""
```

이 훅은 Java 파일 수정 시 검증 필요성을 상기시키는 nudge로는 적절하다. 다만 에이전트가 실제 검증을 건너뛰어도 세션 종료 전에 이를 다시 확인하는 Stop hook이 없으므로, 검증 누락을 막는 enforcement chain이 아직 완성되지 않았다.

**CHECKPOINT → END**
`/done` 명령이 9개 항목을 체계적으로 확인한다. commit gate, STATUS Update Proposal, DR-worthy 목록이 모두 포함된다. ✓

> **문제 발견 (S1-2): `Stop` 훅 배열이 비어 있다.**

```json
"Stop": []
```

세션이 `/done` 없이 종료될 때 아무 알림도 없다. 사용자가 단순히 창을 닫거나 세션이 만료되면 검증과 STATUS 갱신이 누락된 채 끝난다. HRN-001이 미구현 상태임을 직접 확인했다.

---

### 시뮬레이션 2 — Claude Code: 중단 후 재개 (STATUS drift 시나리오)

```
세션 A → 작업 중 중단 → 세션 B: /start → /resume <ID>
```

**세션 B 시작**
`/start`로 STATUS.md를 읽는다. ✓

**`/resume` 실행**
실제 파일·코드 상태와 STATUS.md의 일치 여부를 먼저 확인한다. ✓
Done/Failed 작업은 재개하지 않고 신규 작업 분리를 제안한다. ✓
STATUS Update Proposal을 통해서만 STATUS.md를 수정한다. ✓

**잠재 시나리오: 세션 A가 `/done` 없이 종료된 경우**

세션 A가 VALIDATE까지 진행했지만 Stop 훅 없이 종료되면 STATUS.md는 갱신되지 않는다. 세션 B는 STATUS.md를 보고 작업이 여전히 "In Progress" 상태라고 판단하고 다시 시작한다. 중복 작업 또는 충돌이 발생할 수 있다.

> **문제 발견 (S2-1): Stop 훅 부재로 인해 STATUS drift가 자동으로 누적된다.**

`/resume`의 "실제 파일을 기준으로 불일치를 확인한다"는 규칙이 이 drift를 사후에 잡을 수 있지만, 사전 예방 메커니즘이 없다.

---

### 시뮬레이션 3 — Cursor: Bootstrap 미로드 시나리오

```
사용자가 prompts/cursor-session-start.md를 로드하지 않고 Cursor 세션 시작
```

`.cursor/rules/execution.mdc` `alwaysApply: true`이므로 자동 적용된다.
`./gradlew test`, `./gradlew build`, 검증 범위, FAIL→RECOVER 흐름은 제공된다. ✓

그러나 bootstrap prompt 없이는:
- STATUS.md를 읽어야 한다는 안내가 없다.
- product/harness backlog 분기 기준이 없다.
- STATUS Update Proposal 규칙이 적용되지 않는다.
- 상태 머신 단계 선언 요건이 없다.

> **문제 발견 (S3-1): `execution.mdc`는 alwaysApply이지만 STATUS.md 읽기, backlog 분기, STATUS Update Proposal을 포함하지 않는다.**

`execution.mdc`는 빌드/검증 명령 규칙에 특화되어 있어, Cursor 에이전트가 bootstrap prompt를 잊으면 하네스의 핵심 규칙이 적용되지 않는 상태로 작업이 시작된다.

**`git-commit.mdc`는 `alwaysApply: false`**
커밋 요청 시에만 적용된다. STATUS Update Proposal 규칙이 커밋 gate에 포함되어 있으므로, 사용자가 커밋을 요청하지 않으면 이 규칙도 적용되지 않는다. Cursor 세션에서 STATUS 보호가 상대적으로 약하다.

---

### 시뮬레이션 4 — Claude Code → Cursor 인계

```
Claude Code 세션에서 HRN-001 절반 완료 → STATUS.md 갱신(승인) → Cursor 세션에서 이어받기
```

**인계 성공 조건**
Claude Code가 `/done`을 통해 STATUS.md에 현재 상태를 갱신하고, Cursor 세션이 `cursor-session-start.md`를 로드하고 STATUS.md를 읽으면 인계가 성립한다. ✓
단, Stop 훅 부재가 인계 신뢰도를 낮춘다.

**Cursor 세션 종료 요약(§7)과 Claude `/done` 항목 비교**

| 항목 | Claude `/done` | Cursor `§7` |
| --- | --- | --- |
| 완료한 작업 | ✓ | ✓ |
| 변경된 파일 | ✓ | ✓ |
| 실행한 검증 | ✓ | ✓ |
| 남은 리스크 | ✓ | ✓ |
| STATUS 업데이트 여부 | ✓ | ✓ |
| DR-worthy 결정 목록 | ✓ | ✓ |
| 상태 머신 종료 상태 | ✓ | ✓ |
| Commit 상태 | ✓ | ✗ |
| 다음 세션 시작 프롬프트 | ✓ | ✓ |

> **문제 발견 (S4-1): Cursor 세션 종료 요약에 Commit 상태 항목이 누락되어 있다.**

Claude에서는 commit을 수행하지 않은 경우 이유와 잔여 리스크를 명시적으로 요구한다. Cursor는 이 항목이 없어, 커밋 없이 세션을 끝내도 이유가 기록되지 않는다.

---

### 시뮬레이션 5 — Codex: 신규 세션 + 실패 복구

```
Codex 세션 → bootstrap 수동 로드 → 작업 중 VALIDATE 실패 → RECOVER
```

**Bootstrap 로드 후 INIT**
`prompts/codex-session-start.md`(182줄)를 수동으로 붙여넣는다.
CLAUDE.md → docs/AGENT-WORKFLOW.md → STATUS.md 순서로 읽도록 안내한다. ✓
`.claude/commands/*`는 직접 실행하지 않고 같은 절차를 수동으로 수행한다. ✓

**FAIL → RECOVER 흐름**
`harness-protocol/06-recovery-and-validation.md`의 복구 흐름이 명시되어 있지만, Codex는 이 문서를 자동으로 읽지 않는다. Bootstrap prompt에 실패 시 이 문서를 참조하라는 안내가 없다.

> **문제 발견 (S5-1): Codex bootstrap prompt가 실패/복구 경로를 명시하지 않는다.**

Codex가 VALIDATE 실패를 만났을 때 RECOVER 흐름을 올바르게 따를 보장이 없다. bootstrap prompt는 성공 경로만 안내하고 실패 대응은 에이전트의 기본 판단에 맡긴다.

---

### 일관성·정합성 점검 결과

**구조적 정합성**

| 항목 | 상태 | 비고 |
| --- | --- | --- |
| 상태 머신 canonical source → `01-session-state-machine.md` | ✓ | CLAUDE.md, Quick Reference, HARNESS-PROTOCOL 모두 동일 다이어그램 |
| STATUS Update Proposal 규칙 일관성 | ✓ | 6개 문서에 일관 반영 |
| `/work` ID 접두어 라우팅 (`P2-*`, `HRF-*`, `HRN-*`) | ✓ | backlog 분리와 정렬 |
| `docs/AGENT-WORKFLOW.md` 라우팅 테이블 ↔ `02-context-loading.md` | △ | 표현 차이 있음, canonical source 명시로 실질 문제 없음 |
| Done 작업 immutable 규칙 | ✓ | state machine + `/resume` + `/done` 에 반영 |

**명명 규칙 정합성**

| 위치 | 규칙 | 실제 상태 |
| --- | --- | --- |
| `docs/` root | UPPERCASE-HYPHENATED | ✓ |
| `docs/harness-protocol/` | `{NN}-{lowercase}.md` | ✓ |
| `docs/archive/` | lowercase-hyphenated | ✓ |
| `docs/retrospectives/` | DR-008 기준 미정 | △ HRN-009 추적 중 |

**심각도 높음: `/work` 명령의 잘못된 계획 참조**

발견 당시 `/work` 명령은 완료된 `docs/HARNESS-REFACTOR-PLAN.md`를 현재 작업 계획처럼 참조했다. HRF-001은 Done 상태이므로 이 참조가 에이전트에게 리팩터링이 아직 진행 중이라는 오해를 줄 수 있다.

후속 보완 작업에서 이 참조는 "완료된 harness refactor의 배경 근거"로 재서술했다.

---

### 발견 항목 종합

| ID | 심각도 | 영역 | 내용 |
| --- | --- | --- | --- |
| S1-1 | 높음 | 강제 수단 | PostToolUse 훅은 적절한 nudge지만, Stop hook 부재로 검증 누락을 종료 전에 감지하지 못함 |
| S1-2 | 높음 | 강제 수단 | `Stop` 훅 배열이 비어 있음 — `/done` 없이 세션 종료 시 무알림 |
| S2-1 | 높음 | 상태 관리 | Stop 훅 부재로 인해 STATUS drift가 자동 누적됨 |
| S3-1 | 중간 | Cursor 정렬 | `execution.mdc`가 STATUS.md 읽기·backlog 분기·STATUS Update Proposal을 포함하지 않음 |
| S4-1 | 낮음 | 도구 간 정합성 | Cursor 세션 종료 요약에 Commit 상태 항목 누락 |
| S5-1 | 중간 | Codex 지원 | Codex bootstrap prompt에 실패/복구 경로 안내 없음 |
| B-1 | 높음 | 문서 정합성 | `STATUS.md` `Active plan` 필드가 Done인 `HARNESS-REFACTOR-PLAN.md`를 가리킴 |
| B-2 | 높음 | 문서 정합성 | `/work` 명령이 Done된 HARNESS-REFACTOR-PLAN.md를 "진행 중" 계획으로 참조 |
| B-3 | 중간 | backlog 우선순위 | HRN-001/002가 P1이지만 실제 심각도는 Phase 2 착수 전 P0 수준 |

---

### 개선 제안 우선순위

**즉시 처리 (L1, 문서 수정)**

1. `STATUS.md` `Active plan` 항목 제거 — Done된 계획을 live 참조에서 제거
2. `/work` 명령에서 HARNESS-REFACTOR-PLAN.md "진행 중" 참조 제거 또는 "(완료됨)" 표시
3. Cursor `cursor-session-start.md §7`에 Commit 상태 항목 추가 — Claude `/done`과 구조 동기화
4. Codex bootstrap prompt에 FAIL→RECOVER 경로 안내 추가

**HRN backlog 우선순위 조정 (STATUS Update Proposal 필요)**

5. HRN-001을 P1 → P0로 상향 — Stop 훅 없이는 세션 종료 gate가 존재하지 않음
6. HRN-008을 P2 → P1로 상향 — Codex가 Phase 2에서도 사용된다면 bootstrap 의존이 지속 리스크

**설계 검토 (HRN 신규 등록 후보)**

7. `execution.mdc` (alwaysApply)에 STATUS.md 읽기 안내 최소 1줄 추가 고려 — Cursor 세션에서 bootstrap prompt 없어도 최소 STATUS 확인을 유도

---

### 시뮬레이션 종합

**3개 도구 모두에서 "성공 경로"는 정상 작동한다.** Claude Code는 가장 완결된 구조이며, Cursor는 bootstrap prompt 의존도가 있으나 `execution.mdc` 자동 적용으로 검증 규칙은 보장된다. Codex는 bootstrap 의존이 전적이다.

**핵심 취약점은 "세션 종료 게이트"다.** Stop 훅이 없으면 정상 흐름 이탈이 감지되지 않는다. 이 단일 지점이 STATUS drift, 미검증 checkpoint, commit 누락을 야기할 수 있다. HRN-001 구현이 다른 모든 개선보다 선행되어야 한다.

**문서 정합성 측면에서 즉시 수정이 필요한 항목은 2건이다:** `STATUS.md`의 Active plan 필드와 `/work` 명령의 HARNESS-REFACTOR-PLAN.md 참조. 두 항목 모두 L1 수정이며 에이전트 오해를 방지하는 효과가 명확하다.
