# AI Workflow Harness 리팩터링 리뷰 요청서

작성일: 2026-05-15
상태: 리뷰 요청
범위: AI 워크플로우 하네스, 문서 체계, command/rule/prompt 정합성

## 1. 리뷰 목적

이 문서는 Phase 1 종료 후 진행한 AI Workflow Harness 리팩터링 결과를 외부 전문가가 검토할 수 있도록 정리한 리뷰 요청서다.

이번 리팩터링의 목적은 Spring Boot MSA 템플릿 자체 기능을 변경하는 것이 아니라, Claude Code, Cursor, Codex 같은 Agent가 여러 세션에 걸쳐 작업을 시작하고, 선택하고, 계획하고, 검증하고, 종료하고, 다시 재개할 수 있는 운영 구조를 정비하는 것이다.

리뷰어에게 확인받고 싶은 핵심 질문은 다음과 같다.

- 현재 구조가 실제 반복 세션에서 상태 손실과 컨텍스트 드리프트를 충분히 줄이는가?
- `STATUS.md`, backlog, TODO, DR, archive, protocol 문서의 역할이 명확하게 분리되었는가?
- Claude, Cursor, Codex 간 작업 인계와 규칙 정합성이 충분한가?
- 수동 우선 하네스로서 적절한 수준인가, 아니면 지금 단계에서 더 강한 자동화/hook이 필요한가?
- 문서가 너무 많거나 중복되어 오히려 Agent 사용성을 해치지 않는가?

## 2. 전체 결과 요약

이번 작업의 결과는 완전 자동화된 워크플로우 엔진이 아니라 다음 성격의 하네스다.

> 경량 수동 우선 AI Workflow Harness v1

즉, 현재 구조는 hook/CI가 강제하는 운영급 하네스는 아니지만, Agent가 따라야 할 상태 머신, 문서 라우팅, 작업 기록 위치, 검증 조건, 실패 복구 규칙을 문서·command·rules·prompts에 명시한 운영 프로토콜이다.

핵심 운영 모델:

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

가장 중요한 운영 원칙:

- 세션은 `docs/STATUS.md`에서 시작한다.
- 모든 구현 또는 문서 변경은 plan과 approval을 거친다.
- `docs/STATUS.md`는 Agent 메모장이 아니라 승인된 현재 상태 기록이다.
- `docs/STATUS.md` 변경은 `STATUS Update Proposal` 보고와 사용자 승인 후에만 수행한다.
- `Done` 작업은 계속 수정하지 않고, 후속 보정은 신규 작업으로 분리한다.
- 상세 하네스 규칙의 기준 문서는 `docs/harness-protocol/*.md`다.
- 회고는 backlog를 대체하지 않고, 작업 선택/계획/아이디어 도출 시 조건부 의사결정 보조 맥락으로만 사용한다.

## 3. 기존 대비 변경 요약

| 영역 | 기존 | 변경 후 |
| --- | --- | --- |
| 현재 상태 | `STATUS.md`에 Phase 1 완료 이력, PRE/P2 후보, HRN 후보가 섞여 있었음 | `STATUS.md`를 현재 상태판으로 축소하고 Phase 1 상세는 archive/backup으로 분리 |
| 백로그 | 제품 작업과 하네스 개선 작업이 같은 흐름에 섞일 위험이 있었음 | `docs/backlog/PHASE2.md`와 `docs/backlog/HARNESS.md` 분리 |
| 하네스 프로토콜 | `WORKFLOW-MANUAL.md`가 사용자 매뉴얼과 Agent 실행 규칙을 함께 담는 성격이 강했음 | `HARNESS-PROTOCOL.md`와 `docs/harness-protocol/`를 Agent 실행 프로토콜 기준으로 분리 |
| 빠른 실행 참조 | 일상 작업 중 참고할 짧은 규칙 카드가 불명확했음 | `docs/HARNESS-QUICK-REFERENCE.md` 생성 |
| 세션 복구 | 세션 종료와 재개 조건이 느슨했음 | `/done`, `/resume`, `STATUS Update Proposal`, `Done` 작업 신규 분리 규칙 보강 |
| 도구 간 정합성 | Claude 중심. Cursor/Codex는 일부 prompt/rules 수준 | Claude commands/rules, Cursor rules, Codex bootstrap prompt를 같은 상태 모델로 정렬 |
| Codex 지원 | Codex 전용 세션 시작 절차가 없었음 | `prompts/codex-session-start.md` 추가, `AGENTS.md` 검토를 HRN-008로 등록 |
| 컨텍스트 제어 | "필요 시 읽기"가 있었지만 기준 문서가 불명확했음 | context loading 기준 문서와 protocol 문서 역할 명시 |
| 문서 생명주기 | 문서 생성/갱신/참조/보관 기준이 약했음 | `docs/harness-protocol/04-document-lifecycle.md`와 trigger/cascade 규칙 도입 |
| 강제 수단 | 대부분 권장/수동 규칙 | 아직 수동 우선 구조. HRN-001/002에 hook/hard enforcement 후보 등록 |

## 4. 신규 또는 재정비된 하네스 구조

### 4.1 핵심 하네스 문서

| 파일 | 역할 |
| --- | --- |
| [`CLAUDE.md`](../../CLAUDE.md) | Claude Code 공통 운영 계약. 짧고 재사용 가능하게 유지 |
| [`docs/CLAUDE.md`](../CLAUDE.md) | 자동 로드되는 프로젝트 최소 운영 규칙 |
| [`docs/STATUS.md`](../STATUS.md) | 현재 상태판과 checkpoint 기준 |
| [`docs/HARNESS-PROTOCOL.md`](../HARNESS-PROTOCOL.md) | Agent 실행 프로토콜 허브 |
| [`docs/HARNESS-QUICK-REFERENCE.md`](../HARNESS-QUICK-REFERENCE.md) | 세션 중 빠르게 확인하는 실행 요약 |
| [`docs/HARNESS-REFACTOR-PLAN.md`](../HARNESS-REFACTOR-PLAN.md) | 이번 하네스 리팩터링 계획과 rollback 기준 |
| [`docs/WORKFLOW-MANUAL.md`](../WORKFLOW-MANUAL.md) | 사람용 워크플로우 매뉴얼 |

### 4.2 상세 프로토콜 기준 문서

상세 규칙의 기준 문서는 아래 문서들이다.

| 파일 | 기준 영역 |
| --- | --- |
| [`docs/harness-protocol/01-session-state-machine.md`](../harness-protocol/01-session-state-machine.md) | 세션 상태 머신 |
| [`docs/harness-protocol/02-context-loading.md`](../harness-protocol/02-context-loading.md) | 컨텍스트 로딩 |
| [`docs/harness-protocol/03-work-items-and-naming.md`](../harness-protocol/03-work-items-and-naming.md) | 작업 항목 위치와 네이밍 |
| [`docs/harness-protocol/04-document-lifecycle.md`](../harness-protocol/04-document-lifecycle.md) | 문서 생명주기 |
| [`docs/harness-protocol/05-triggers-and-cascade.md`](../harness-protocol/05-triggers-and-cascade.md) | 트리거와 연쇄 업데이트 |
| [`docs/harness-protocol/06-recovery-and-validation.md`](../harness-protocol/06-recovery-and-validation.md) | 복구와 검증 |

### 4.3 Backlog 분리

| 파일 | 목적 |
| --- | --- |
| [`docs/backlog/PHASE2.md`](../backlog/PHASE2.md) | Spring Boot MSA template 제품/Phase 2 backlog |
| [`docs/backlog/HARNESS.md`](../backlog/HARNESS.md) | AI workflow harness, command/rule, automation, documentation hygiene backlog |

주요 하네스 backlog:

- `HRN-001`: Stop hook reminder
- `HRN-002`: git hook / PostToolUse 기반 hard enforcement
- `HRN-006`: `docs/` 정보 구조와 legacy TODO 분리
- `HRN-007`: `prompts/`와 `.claude/commands/` 역할 경계 정리
- `HRN-008`: Codex `AGENTS.md` 도입과 ignore/permission 정렬
- `HRN-009`: DR-008 기준 `docs/` 파일명/디렉터리명 감사

## 5. 주요 변경 묶음

### 5.1 상태 관리

변경 파일:

- [`docs/STATUS.md`](../STATUS.md)
- [`docs/archive/harness-refactor-20260514/`](../archive/harness-refactor-20260514/)
- [`docs/archive/phase1-status.md`](../archive/phase1-status.md)
- [`docs/archive/phase1-plan.md`](../archive/phase1-plan.md)

변경 내용:

- Phase 1 이후 상태, 작업, 예정 작업, 체크포인트, DR을 백업했다.
- `STATUS.md`를 현재 상태 중심 live board로 재정의했다.
- `STATUS.md` 직접 수정 금지와 `STATUS Update Proposal` 승인 게이트를 도입했다.
- CP-HRF-1부터 CP-HRF-18까지 하네스 리팩터링 체크포인트를 기록했다.

리뷰 포인트:

- `STATUS.md`가 너무 많은 이력을 다시 담기 시작하지 않았는가?
- `STATUS Update Proposal` 규칙이 현실적인가?
- 완료된 작업을 계속 수정하지 않고 신규 작업으로 분리하는 규칙이 충분히 명확한가?

### 5.2 프로토콜과 컨텍스트 로딩

변경/신규 파일:

- [`docs/HARNESS-PROTOCOL.md`](../HARNESS-PROTOCOL.md)
- [`docs/HARNESS-QUICK-REFERENCE.md`](../HARNESS-QUICK-REFERENCE.md)
- [`docs/harness-protocol/`](../harness-protocol/)
- [`docs/CLAUDE.md`](../CLAUDE.md)

변경 내용:

- Protocol hub와 상세 기준 문서를 분리했다.
- 세션 시작 시 harness protocol 전체를 읽지 않고, 조건이 생길 때만 상세 문서를 로드하도록 했다.
- `docs/HARNESS-QUICK-REFERENCE.md`를 요약 문서로 정의하고, 충돌 시 `docs/harness-protocol/*.md`를 우선하도록 했다.
- 회고 문서를 조건부 의사결정 보조 맥락으로 추가했다.

리뷰 포인트:

- 자동 로드 문서와 detailed protocol 사이의 중복이 적절한가?
- "조건이 생기면 읽는다"는 라우팅이 충분히 명확한가?
- `docs/CLAUDE.md`에 routing decision table을 더 강화해야 하는가?

### 5.3 Commands와 Rules

변경 파일:

- [`.claude/commands/start.md`](../../.claude/commands/start.md)
- [`.claude/commands/pick.md`](../../.claude/commands/pick.md)
- [`.claude/commands/work.md`](../../.claude/commands/work.md)
- [`.claude/commands/resume.md`](../../.claude/commands/resume.md)
- [`.claude/commands/debug.md`](../../.claude/commands/debug.md)
- [`.claude/commands/done.md`](../../.claude/commands/done.md)
- [`.claude/commands/record-decision.md`](../../.claude/commands/record-decision.md)
- [`.claude/commands/health.md`](../../.claude/commands/health.md)
- [`.claude/rules/docs-workflow.md`](../../.claude/rules/docs-workflow.md)
- [`.claude/rules/git-workflow.md`](../../.claude/rules/git-workflow.md)

변경 내용:

- `/pick`은 제품 backlog와 하네스 backlog를 분리하고, 조건이 맞을 때 회고를 확인하도록 정리했다.
- `/work`는 ID 접두어(`P2-*`, `PRE-*`, `HRF-*`, `HRN-*`) 기준으로 작업을 라우팅하도록 보강했다.
- `/resume`은 `Done` 또는 `Failed` 작업을 직접 재개하지 않고 신규 작업 항목 제안을 요구하도록 보강했다.
- `/done`은 검증 상태, checkpoint 상태, commit 상태, DR 필요 여부, STATUS 업데이트 필요 여부를 확인하도록 정리했다.
- `/debug`는 증거 기반 진단, 리스크, 검증, 상태 전이를 요구하도록 보강했다.
- `/record-decision`은 DR 파일 생성과 STATUS update proposal을 분리했다.
- `/health`는 `rg` 우선 점검을 사용하고 STATUS 변경은 proposal로만 보고하도록 정리했다.
- `git-workflow.md`와 Cursor git commit rule에 검증 및 STATUS 승인 게이트를 반영했다.

리뷰 포인트:

- Commands가 여전히 prompt text 수준인데, 이 정도면 충분한가? 아니면 일부는 scripts/hooks로 구현해야 하는가?
- `/work`와 `/debug`가 일상 사용에는 너무 무거운가?
- `/health`가 과도하게 읽지 않으면서 충분히 점검하는가?

### 5.4 Cursor와 Codex 정렬

변경 파일:

- [`.cursor/rules/coding.mdc`](../../.cursor/rules/coding.mdc)
- [`.cursor/rules/execution.mdc`](../../.cursor/rules/execution.mdc)
- [`.cursor/rules/output-format.mdc`](../../.cursor/rules/output-format.mdc)
- [`.cursor/rules/git-commit.mdc`](../../.cursor/rules/git-commit.mdc)
- [`prompts/cursor-session-start.md`](../../prompts/cursor-session-start.md)
- [`prompts/codex-session-start.md`](../../prompts/codex-session-start.md)

변경 내용:

- Cursor rules를 상태 머신, STATUS update proposal, 제품/하네스 backlog 분리, 검증 흐름과 정렬했다.
- 이 저장소에는 아직 `AGENTS.md`가 없기 때문에 Codex용 fallback bootstrap prompt를 추가했다.
- Codex `AGENTS.md` 도입은 HRN-008에서 추적하도록 했다.

리뷰 포인트:

- `AGENTS.md` 도입 전까지 Codex fallback prompt만으로 충분한가?
- Codex 초기 진입 마찰을 줄이기 위해 `AGENTS.md`를 더 빨리 도입해야 하는가?
- Cursor rules가 Claude rules와 충분히 정렬되어 있는가? 중복은 과하지 않은가?

### 5.5 Ignore, 권한, 컨텍스트 위생

변경 파일:

- [`.claudignore`에서 `.claudeignore`로 변경](../../.claudeignore)
- [`.cursorignore`](../../.cursorignore)
- [`.claude/settings.json`](../../.claude/settings.json)
- [`.gitignore`](../../.gitignore)
- [`.dockerignore`](../../.dockerignore)

변경 내용:

- `.claudignore` 파일명을 `.claudeignore`로 수정했다.
- `.cursorignore`가 `.claude/rules/`뿐 아니라 `.claude/commands/`도 인덱싱하도록 허용했다.
- `.claude/settings.json`에서 `.env`, `.env.*`, `.claude/settings.local.json`, `secrets/**`, key/cert 파일 읽기를 차단하도록 설정했다.
- `.claudeignore`에 `permissions.deny`가 더 강한 강제 수단이라는 점을 명시했다.

리뷰 포인트:

- `.claudeignore`가 예상한 Claude Code 환경에서 실제로 적용되는가?
- `permissions.deny` 패턴이 충분한가?
- `.dockerignore`가 `scripts/`, `docs/`, `prompts/`를 계속 제외하는 것이 맞는가?

### 5.6 언어와 파일명 정책

변경 파일:

- [`docs/decisions/DR-007-language-policy.md`](../decisions/DR-007-language-policy.md)
- [`docs/decisions/DR-008-docs-filename-standard.md`](../decisions/DR-008-docs-filename-standard.md)
- [`docs/WORKFLOW-MANUAL.md`](../WORKFLOW-MANUAL.md)
- [`docs/CODING-CONVENTIONS.md`](../CODING-CONVENTIONS.md)

변경 내용:

- DR-007에서 settings JSON 구조와 사용자에게 보이는 hook 출력 메시지를 구분했다.
- Hook 출력 메시지는 사용자/session에 직접 보이므로 한국어를 유지하도록 했다.
- `.cursor/rules/*.mdc`는 영어 instruction file로 명시했다.
- Java inline comment는 `한국어 이유 + English technical term` 방식을 따른다.
- DR-008은 accepted 상태를 유지하되, 확장된 docs tree에 대한 더 넓은 naming audit이 필요하므로 HRN-009를 추가했다.

리뷰 포인트:

- 언어 분리 정책이 multi-agent 사용에 실용적인가?
- 향후 docs filename policy를 lowercase-hyphenated 방향으로 개정해야 하는가?
- 이미지 파일과 archive snapshot 파일명은 예외로 둬도 되는가?

### 5.7 루트 README와 제품 문서

변경 파일:

- [`README.md`](../../README.md)
- [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md)
- [`docs/DEVELOPER-GUIDE.md`](../DEVELOPER-GUIDE.md)
- [`docs/DOCKERFILE-GUIDE.md`](../DOCKERFILE-GUIDE.md)
- [`docs/PLAN.md`](../PLAN.md)
- [`docs/CODING-CONVENTIONS.md`](../CODING-CONVENTIONS.md)

변경 내용:

- Root README를 GitHub 관례에 가까운 entry point와 link hub 형태로 축소했다.
- Product docs를 현재 CI/Testcontainers/Dockerfile/license 설명과 정렬했다.
- `docs/PLAN.md`에서 Phase 1 TODO 파일을 현재 active plan이 아니라 legacy/migration target으로 표시했다.

리뷰 포인트:

- README가 너무 얇아졌는가, 아니면 적절히 간결해졌는가?
- Product docs가 현재 하네스 구조와 충분히 정렬되었는가?
- 남아 있는 legacy TODO 참조는 HRN-006 처리 전까지 허용 가능한가?

## 6. 반복 세션 시뮬레이션 요약

최종 시뮬레이션은 Claude, Cursor, Codex에서 여러 세션을 반복하는 상황을 가정해 점검했다.

### Claude Code

예상 흐름:

```text
CLAUDE.md -> docs/CLAUDE.md -> docs/STATUS.md -> /pick or /work -> plan -> approval -> execute -> validate -> /done
```

평가:

- 가장 안정적인 경로다.
- Commands와 rules가 정렬되어 있다.
- STATUS update gate가 명시적이다.
- 제품/하네스 routing이 명확하다.

잔여 리스크:

- 아직 manual-first 구조다.
- Hooks가 `/done`, validation, STATUS freshness를 아직 강제하지 않는다.

### Cursor

예상 흐름:

```text
prompts/cursor-session-start.md + .cursor/rules/*.mdc -> docs/STATUS.md -> backlog -> plan -> execute -> validate -> summary
```

평가:

- Claude rules와 대부분 정렬되어 있다.
- Commit gate가 업데이트되었다.
- `.cursorignore`가 `.claude/commands/`를 인덱싱하도록 조정되었다.

잔여 리스크:

- Cursor는 Claude slash commands를 실행하지 않는다.
- prompts와 rules가 따로 진화하면 일부 drift risk가 남는다.

### Codex

예상 흐름:

```text
prompts/codex-session-start.md -> CLAUDE.md -> docs/CLAUDE.md -> docs/STATUS.md -> manual command-equivalent flow
```

평가:

- Fallback prompt가 존재한다.
- Codex 전용 automatic instruction discovery는 아직 없다.

잔여 리스크:

- `AGENTS.md`가 아직 도입되지 않았다.
- Codex는 사용자 또는 Agent가 bootstrap prompt 사용을 기억해야 한다.

## 7. 수행한 검증

리팩터링 중 수행한 대표 명령/점검:

```bash
git diff --check
python3 -m json.tool .claude/settings.json
rg -n "STATUS Update Proposal|canonical source|retrospectives|AGENTS.md|HRN-009" ...
rg -n "WORKFLOW-MANUAL-V2|.claudignore|.codexignore|docs/backlog/*|TODO/PHASE{n}/{ID}" ...
find docs -maxdepth 3 -type f | sort
git status --short --ignored
```

주요 검증 결과:

- `git diff --check` 통과.
- `.claude/settings.json`은 유효한 JSON이다.
- `.claudignore`는 `.claudeignore`로 이름이 변경되었다.
- `.codexignore`는 존재하지 않는다. Codex follow-up은 HRN-008에서 추적한다.
- `docs/.DS_Store`는 존재하지만 ignore 대상이다. cleanup candidate로 남아 있다.

## 8. 알려진 잔여 리스크

| 리스크 | 심각도 | 추적 |
| --- | --- | --- |
| `/done`, validation, STATUS freshness에 대한 hard enforcement 부재 | 높음 | HRN-001, HRN-002 |
| Codex 자동 프로젝트 instruction 부재 | 중간 | HRN-008 |
| Legacy Phase 1 TODO 파일이 live `docs/TODO/PHASE1/`에 남아 있음 | 중간 | HRN-006 |
| Docs filename/directory case policy에 대한 더 넓은 audit 필요 | 낮음/중간 | HRN-009 |
| Prompt와 command 역할 경계 정리 필요 | 중간 | HRN-007 |
| `.harness/config.json` SSOT 미도입 | 중간 | HRN-FUT-001 |
| `docs/.DS_Store`가 ignore 대상이지만 로컬에 남아 있음 | 낮음 | HRN-009 또는 cleanup task |

## 9. 리뷰어 체크리스트

리뷰어는 다음 항목을 중심으로 검토하면 된다.

1. 상태 모델:
   - `STATUS.md`가 현재 상태판으로 적절한 형태인가?
   - STATUS update approval gate가 실무적으로 작동 가능한가?
   - 완료된 작업을 immutable하게 두고 후속 보정을 신규 작업으로 분리하는 방식이 현실적인가?

2. 컨텍스트 로딩:
   - Agent가 필요한 문서를 찾아갈 routing condition이 충분히 명확한가?
   - quick reference, protocol hub, canonical detail의 분리가 효과적인가?
   - 회고 조건부 로딩이 과도한 비용 없이 의사결정을 개선하는가?

3. 도구 간 정렬:
   - Claude, Cursor, Codex가 충분히 같은 상태 모델을 바라보는가?
   - `AGENTS.md` 없이도 Codex 사용성이 충분한가?
   - `AGENTS.md` 도입 우선순위를 P2가 아니라 P1로 올려야 하는가?

4. 강제 수단:
   - 어떤 규칙을 가장 먼저 hook으로 전환해야 하는가?
   - HRN-001/002를 Phase 2 제품 작업 전에 먼저 처리해야 하는가?
   - pre-commit이 검사할 것과 Claude/Cursor hooks가 검사할 것은 어떻게 나눌 것인가?

5. 문서 구조:
   - 문서 수가 너무 많아졌는가?
   - 기준 문서가 명확한가?
   - `WORKFLOW-MANUAL.md`은 사람용 매뉴얼로 여전히 유용한가?

6. Backlog 정리:
   - HRN 우선순위가 적절한가?
   - HRN-006, HRN-008, HRN-009의 우선순위를 올려야 하는가?
   - 하네스 backlog를 분리한 후에도 제품 Phase 2 준비 작업이 충분히 잘 보이는가?

## 10. 권장 다음 단계

리뷰 이후 권장 순서는 다음과 같다.

1. 업데이트된 health command로 `/health --full`을 실행한다.
2. startup/routing/STATUS safety에 영향을 주는 리뷰 지적사항을 먼저 처리한다.
3. 최소 hard enforcement를 위해 HRN-001 또는 HRN-002를 구현한다.
4. Phase 2 제품 작업 전에 Codex `AGENTS.md`를 도입할지 결정한다.
5. 문서가 더 커지기 전에 HRN-006과 HRN-009를 수행한다.

## 11. 리뷰 참고 사항

이번 리팩터링은 의도적으로 완전 자동화 엔진 생성을 목표로 하지 않았다.

현재 목표는 여러 세션에 걸친 Agent 동작을 예측하고 복구하기 쉬운 안정적인 수동 우선 하네스를 만드는 것이다. 다음 품질 상승은 문서를 더 늘리는 방식이 아니라, 선택적 자동화에서 나와야 한다.
