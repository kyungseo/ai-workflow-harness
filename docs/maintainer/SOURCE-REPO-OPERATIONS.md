# SOURCE-REPO-OPERATIONS.md (source-only)

`ai-workflow-harness` **source repo 전용** 운영 runbook이다.
source repo maintainer / AI driver가 변경 lifecycle에서 **어떤 문서·스크립트를 어느 순서로 실행·해석하는지**를 엮는 진입 문서다.

> **이 문서의 성격 (복제 금지 원칙):**
> 이것은 **순서축(runbook)** 이다. 검증 *기준*·*명령*·*정책*의 SSoT가 아니다. 각 단계는 해당 SSoT를 **pointer로 위임**한다.
> - 검증 **기준(무엇을 어느 깊이로)**: `docs/maintainer/HARNESS-TEST-TAXONOMY.md`
> - 검증 **명령 카탈로그(HOW)**: `docs/maintainer/VERIFICATION-COMMANDS.md`
> - **판단·정책(실패 처리/commit gate)**: `docs/HARNESS-RECOVERY-VALIDATION.md`
> - **orchestration(통합 점검)**: `skills/workflow/repo-health.md` (`/repo-health`)
> - **setup·convention·tool-surface alignment**: `docs/HARNESS-MAINTAINER-GUIDE.md`
>
> 위 SSoT의 내용을 이 문서에 재서술하지 않는다. 충돌 시 SSoT가 우선한다.

> **경계 (`docs/maintainer/README.md` audience×distribution 직교축):**
> 이 문서는 **source-only(미배포)** + audience=source maintainer/AI driver다.
> - `docs/WORKFLOW-MANUAL.md`(user/adopter-facing)와 섞지 않는다.
> - scaffolded **product/adopter repo 운영**과 섞지 않는다(그쪽 = product pack 검증 = `VERIFICATION-COMMANDS.md` Layer U).
> - 진입점은 `docs/maintainer/README.md`다(이 문서는 배포 surface에서 참조되지 않는다).

---

## A. 작업 lifecycle (순서축, tool-neutral)

source repo 변경의 표준 흐름이다. **review 단계는 도구 중립**이다 — single-agent self-review 또는 cross-agent review 모두 가능하다.

```text
work-select → work-plan → review → 구현 → result review → work-close → commit → PR(--base develop) → squash merge → develop sync
```

| 단계 | 무엇 | SSoT pointer (절차 본문은 여기) |
| --- | --- | --- |
| work-select | 다음 작업 선택 (idle/Active 분기) | `skills/workflow/work-select.md` |
| work-plan | Work 파일 + plan(Scope/Files/Verification/Risk/Reversal) 작성, 3 pre-check | `skills/workflow/work-plan.md` |
| review | plan/결과 검토 | **단일 또는 cross-agent.** cross-agent로 진행 시 Work 파일 `Cross-Agent Review` 섹션에 **Round Log / Consensus Log**를 누적한다 |
| 구현 | 승인된 scope 내 변경 | Approval Matrix: `docs/AGENT-WORKFLOW.md` |
| result review | 변경 결과 검토 | review와 동일 패턴 |
| work-close | Work Done 처리 + 선택적 archive | `skills/workflow/work-close.md` |
| commit | validation → diff summary → message 승인 후 | `docs/GIT-WORKFLOW.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`(Commit Approval) |
| PR | feature → develop (`--base develop`) | `docs/GIT-WORKFLOW.md` §2 |
| merge / sync | squash merge + develop sync | `docs/GIT-WORKFLOW.md` §2-5 / §3-4 |

> **review 패턴 주의:** 특정 도구를 고정 역할(예: 작성자/리뷰어)로 박지 않는다. 이 repo는 Claude/Codex/Cursor를 함께 전제한다. cross-agent review를 쓸 때만 Round/Consensus Log 관례를 적용한다. `.claude/commands/*`는 adapter이므로 진입 pointer로 쓰지 않고 canonical `skills/workflow/*`를 본다.

---

## B. 변경 유형별 검증 경로 (매트릭스)

"지금 이 변경이 어느 유형인가 → 무엇을 어느 순서로 본다"의 라우팅이다. **명령 본문은 `VERIFICATION-COMMANDS.md`의 해당 Layer**, 기준은 taxonomy다.

| 변경 유형 | runner tier (C절) | catalog Layer (`VERIFICATION-COMMANDS.md`) | cascade / 추가 |
| --- | --- | --- | --- |
| **docs-only** | `--tier0` (또는 doc 검사) | E(canonical 최신성)·H(stale/source-only 누수)·P(언어정책 DR-007)·N(STATUS↔Work↔index) | `git diff --check` |
| **workflow / protocol / tool-surface** | `--tier0` + 관련 catalog Layer(기본). scaffold/generated output 영향 시 `--tier2`/`--all`. 기존 target 정합 검증이 필요할 때만 `--tier1 <target-dir>` | E·F(tool-specific surface 정렬)·G(user-facing 정합), gate 표면이면 **Q-static**(gate path-list parity) | canonical→tool-specific→user-facing→scaffold cascade (`HARNESS-MAINTAINER-GUIDE.md` §7) |
| **scaffold / template change** | `--tier2` 또는 `--all` | A(syntax)·B(write_text 패턴)·C(실물 생성+invariant)·D(manifest drift)·J/J-OB(simulation) | `bash -n scripts/create-harness.sh` + dry-run + temp/ 실생성(D절) |
| **maintainer verification taxonomy / catalog change** | `--all` | self-check(M계열) + 변경한 Layer 자체 재실행 | taxonomy(기준) ↔ catalog(명령) ↔ runner(실행) 3자 정합 확인. 이 runbook의 B/C 매핑도 갱신 |
| **release prep** | `--all` | **Release Full Sweep 프리셋**(`VERIFICATION-COMMANDS.md` 상단) + H(stale identity/secret)·R(VERSION↔manifest) | `HARNESS-MAINTAINER-GUIDE.md` §9 Public Release Checks |

> taxonomy Tier(0/1/2)와 runner 모드의 매핑은 C절. Layer 선택 깊이의 SSoT는 taxonomy의 Surface×Depth 표다.

---

## C. runner tier 선택 기준

`scripts/tests/run-harness-checks.sh` (CHORE-20260611-005). **기준 자체는 `HARNESS-TEST-TAXONOMY.md`가 SSoT**, 아래는 선택 가이드다.

| 모드 | 언제 | 생성 |
| --- | --- | --- |
| `--tier0` | syntax / script 무결성만 빠르게 | 없음 |
| `--tier1 <target-dir>` | **기존** target에 deterministic 검사(closure + invariants). target 인자 필수 | 없음 |
| `--tier2` | scaffold 실물 생성 포함 검증 | temp/에 생성 |
| `--all` | tier0 + source-level tier1(closure) + tier2 누적. release/대형 변경 | 생성 포함 |

> exit: `0`=전부 PASS/SKIP, `1`=하나 이상 FAIL, `2`=usage error.

---

## D. temp/ 실테스트 운용

- scaffold 실물 생성·inject-revert 등 파괴적 검증은 **`temp/`** 에서 한다. `temp/`는 gitignored다.
- **`/tmp` 대신 `temp/`인 이유:** repo 내부 경로라 상대 경로·cleanup·권한이 일관되고, 검증 산출물이 repo 컨텍스트에서 추적된다(taxonomy temp/ 정책이 SSoT).
- **inject-revert 주의:** drift 검출을 증명할 때 **working file이 아니라 temp 복사본**에 bad line을 주입한다. working file에 `git checkout`을 쓰면 uncommitted 변경이 clobber될 수 있다(CHORE-20260611-008 실사례).
- cleanup: gitignored이므로 잔여 artifact는 commit에 영향 없다. 강제 삭제(`rm -rf`)는 권한 gate를 유발할 수 있으니 무리해서 정리하지 않는다.

---

## E. 네 검증 자산 역할 구분

"어느 것을 언제 펴나"의 구분이다. **복제가 아니라 라우팅**이다.

| 자산 | 역할 | 언제 |
| --- | --- | --- |
| `HARNESS-TEST-TAXONOMY.md` | 검증 **기준 SSoT** (Surface×Depth·Tier·temp/ 정책) | "무엇을 어느 깊이로 검사할지" 판단 |
| `VERIFICATION-COMMANDS.md` | 검증 **명령 카탈로그** (Layer별 grep·simulation) | "어떻게 실행할지" 명령이 필요할 때 |
| `HARNESS-RECOVERY-VALIDATION.md` | **판단·정책** (failure state·Validation Checklist·Commit Approval) | 검증 실패·recovery·commit gate 판단 시 (conditional-load) |
| `skills/workflow/repo-health.md` (`/repo-health`) | **orchestration** (통합 surface 점검, Required Surface Matrix) | 변경 전후 어느 surface가 걸리는지 한눈에 볼 때 |

---

## F. PR 전 최소 검증 → 실패 → enforcement 해석

**PR 전 최소 checklist:**

1. 변경 유형 식별 → B절 매트릭스로 라우팅.
2. 해당 tier(C절) 또는 catalog Layer 실행.
3. `git diff --check` + branch isolation(`develop`/`main`에서 protected 파일 stage 금지, `docs/GIT-WORKFLOW.md` §0 / `.claude/rules/git-workflow.md`).
4. STATUS Finalization / Tracking Finalization 보고 (`docs/AGENT-WORKFLOW.md` State And Closeout Rules).
5. commit 승인(validation 결과 + diff summary + message) → PR(`--base develop`).

**실패 시:** `docs/HARNESS-RECOVERY-VALIDATION.md`의 failure state / Validation Checklist로 이동. VALIDATE 실패 상태에서는 checkpoint·commit을 만들지 않는다.

**CI/hook/hard-gate 미적용 항목 해석:** 일부 규칙은 문서로만 기술되고 기계 강제(CI/hook/hard-gate)가 없다. 이때는 **수동 점검이 곧 gate**다 — 자동 신호 부재를 "통과"로 해석하지 않는다. 기계 강제 후보의 backlog는 `docs/backlog/HARNESS.md` "문서-only 규칙 강제화". source-gitflow hook의 commit gate 정책은 `docs/HARNESS-RECOVERY-VALIDATION.md`(Commit Approval).

---

## Update Triggers

- CHORE-20260611-005 후속 F1~F4(runner→repo-health deep 통합 등) 완료 시 B/C절 갱신.
- 새 catalog Layer 추가·runner 모드 변경 시 B/C절 매핑 갱신.
- lifecycle command(`skills/workflow/*`)·`docs/GIT-WORKFLOW.md` 절차 변경 시 A절 pointer 갱신.
