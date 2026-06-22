---
id: CHORE-20260621-002
priority: P1
status: Archived
risk: L2
scope: ai-deck-compiler를 pre-manifest baseline-acquisition 재실측 대상으로 삼아 2026-06-11 simulation 대비 current source delta, shadow scaffold baseline, selective migration 분류, DR-034 promotion 조건, internal managed mode gate 보류/진입 조건을 실제 evidence로 정리한다. 구현 목표는 중앙 managed mode 자체가 아니라 External Adopter Mode의 현실 검증이다.
appetite: 1d
planned_start: 2026-06-21
planned_end: 2026-06-21
actual_end: 2026-06-21
related_dr: [DR-034]
related_troubleshooting: []
related_work: [CHORE-20260611-010, CHORE-20260621-001]
---

# CHORE-20260621-002: ai-deck-compiler Baseline-Acquisition Walkthrough

## Top Summary

현재 live backlog의 `ai-deck-compiler first real upgrade walkthrough + DR-034 acceptance judgment` 후보에서 출발했지만, R1 review 결과 이 Work의 정직한 이름은 **first real upgrade**가 아니라 **pre-manifest baseline-acquisition 재실측**이다. 목적은 "가장 오래된 adopter 세대"를 실제 대상으로 삼아, inventory-first / shadow scaffold baseline / selective migration / accepted drift 분류가 현재 source 기준에서도 재현 가능한지 확인하는 것이다.

핵심은 **internal managed mode 설계가 아니라 External Adopter Mode 검증**이다. `ai-deck-compiler`는 `.harness/manifest.json`이 없는 pre-manifest target이므로, 현 시점에서 DR-034가 가장 부담스럽게 적용되는 사례다. 다만 manifest baseline을 가진 adopter가 아직 없으므로 source→target version-delta migration, 즉 엄밀한 의미의 upgrade는 이 Work에서 검증할 수 없다.

이번 Work는 harness repo에서 tracking하고, 실제 실행은 pinned committed ref 기준 read-only probe → temp copy / shadow scaffold simulation → 2026-06-11 결과와 current source delta 비교 순서로 진행한다. source harness 쪽 새 메커니즘 구현, target direct write, internal managed mode 구체 설계로 넓히지 않는다.

## Collaboration Workflow

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Codex | author/driver. Work 파일, walkthrough plan, 구현/검증, Claude review response 작성 |
| B | Claude | red team reviewer. 방향 자체, target 선택 타당성, DR-034 과대 확정 위험, cross-repo execution risk를 의심 |
| Owner | User | 방향 승인, 구현 승인, 최종 승인, `/work-close`, commit, PR, merge 승인 |

절차: 사용자 지시 → Codex A가 Work 파일+plan 작성 → Claude B가 red-team review(R round) → 합의 → Codex A가 baseline-acquisition 재실측/기록 → Claude B 결과 검토 → 사용자 최종 승인 → `/work-close` → commit → PR(`--base develop`) → merge.

Cross-agent 라운드와 합의는 아래 `Cross-Agent Review And Discussion`에 누적한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `ai-deck-compiler first real upgrade walkthrough + DR-034 acceptance judgment` | live 후보 정의, Done Criteria, verification 기준 |
| 2 | `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | 전체 | Draft 정책과 promotion 조건, pre-manifest baseline 원칙 |
| 3 | `docs/briefs/harness-internal-managed-upgrade-20260615.md` | Candidate A, conclusion, R1 | walkthrough가 internal managed mode의 gate라는 prior reasoning |
| 4 | `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md` | §4.1, §4.2 | first real walkthrough가 fleet mode보다 선행해야 한다는 근거 |
| 5 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer T | 실제 walkthrough 절차와 판정 기준 |
| 6 | `docs/maintainer/migrations/manifest-check-baseline.md` | 전체 | pre-manifest target migration note와 기존 ai-deck 실측 |
| 7 | `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/docs/STATUS.md` | Current State, Active Work | target repo가 clean idle인지, 병행 active work가 있는지 확인 |
| 8 | `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/package.json` | `name` | shadow scaffold project-name 동등성 검증 |

Trigger: backlog W2 후보와 internal managed brief의 Candidate A가 모두 `ai-deck-compiler` actual upgrade walkthrough를 first real evidence로 지목했다. 사용자는 `ai-deck-compiler`가 `.harness` 이전 세대, `rfx-hub`는 1.2.1, `spring-modular-template`는 최신 scaffold라고 명시했다. R1 review 이후 이 Work는 `ai-deck-compiler`를 "first real upgrade" 대상이 아니라 "가장 오래된 pre-manifest baseline-acquisition 재실측" 대상으로 재정의한다.

## Scope

### Slice A — Target Probe And Starting Conditions

- `ai-deck-compiler`의 현재 상태를 read-only로 다시 확인한다.
- `.harness/manifest.json` 부재, target repo clean/active 여부, pinned committed ref, current STATUS idle 여부를 기록한다.
- working tree나 현재 feature branch를 probe input으로 삼지 않고, 특정 committed ref(SHA)를 pin한 read-only probe로 시작한다.
- "old scaffold"라는 기억을 실제 surface 기준으로 구체화한다. 예: pre-manifest, generator script 부재, source-gitflow marker 보유, 초기 adoption 흔적.

### Slice B — Inventory-First Replay

- Layer T/T1 기준으로 framework-owned / project-owned / customized / accepted drift 분류 표의 골격을 만든다.
- 기존 migration note의 2026-06-11 probe를 그대로 재사용할 수 있는지, 아니면 현재 source 기준 재실측이 필요한지 판정한다.
- walkthrough 산출물은 "upgrade 성공/실패"보다 먼저 **분류와 근거의 재현성**을 보여야 한다.

### Slice C — Shadow Scaffold Baseline Re-measurement

- 동일 project-name `ai-deck-compiler`로 shadow scaffold baseline을 만들고 manifest baseline을 심는 Layer T 흐름을 current source 기준으로 재실측한다.
- read-only probe → temp target copy → shadow scaffold → `--check` drift 관측 → selective migration → verify 순서를 유지한다.
- target repo 직접 write는 walkthrough 판단이 끝나기 전 기본 경로가 아니다.
- 2026-06-11 migration note의 `76 tracked, 76 in-sync, 0 drifted` 결과와 tracked-file count / drift distribution delta를 대조한다.

### Slice D — DR-034 Draft Reconfirmation

- current-source 재실측 결과를 바탕으로 DR-034를 계속 `Draft`로 둘 이유와 promotion 조건을 더 구체화한다.
- 같은 target + temp simulation만으로는 DR-034의 promotion 조건을 충족하지 못한다는 점을 명시한다.
- second adopter 필요성, 실제 target apply 필요성, helper 부재 신호를 분리해 기록한다.

### Slice E — Internal Managed Gate Verdict

- 이번 Work는 internal managed mode 설계를 하지 않는다.
- net-new evidence가 확인될 때만 Candidate B를 열 가치가 있는지 yes/no를 판정한다.
- 2026-06-11 simulation 재현에 그치면 gate verdict도 함께 defer한다.
- verdict는 "fleet mode가 유망한가"가 아니라 "baseline-acquisition 재실측이 다음 결정을 열 만큼 새 증거를 줬는가"에 초점을 둔다.

## Scope Guard

- `ai-deck-compiler` product feature 구현은 비범위다.
- source harness에 새 `manifest-init` / `--upgrade-plan` / `--upgrade` helper를 추가하지 않는다.
- internal managed registry/schema/runner 설계는 비범위다. Candidate B는 gate verdict까지만 본다.
- `rfx-hub` / `spring-modular-template` walkthrough로 확대하지 않는다.
- target repo 직접 patch/commit/PR은 walkthrough 결과와 owner 승인 없이 선행하지 않는다.

## Initial Direction (A 제안, B review 전 미확정)

| 항목 | 초기 입장 | B가 의심해볼 질문 |
| --- | --- | --- |
| first target 선택 | `ai-deck-compiler`가 가장 오래된 pre-manifest adopter라 first real walkthrough에 적합 | 너무 오래된 세대라 current upgrade UX의 대표성이 약한 것 아닌가 |
| walkthrough 목표 | "업그레이드 구현"보다 current source 기준 baseline-acquisition delta 재실측 | 계획이 06-11 procedural replay로만 흐르지 않는가 |
| DR-034 verdict | `Accepted` 검토가 아니라 Draft 재확인 + promotion 조건 구체화 | mixed-generation single target temp sim으로 promotion 논의를 끌어오는가 |
| target write strategy | read-only probe + temp copy 우선, target direct write는 후행 승인 | evidence가 temp simulation에만 머물면 실제 walkthrough라고 부를 수 있는가 |
| internal managed gate | same Work에서 yes/no만 판정, 설계는 deferred | verdict를 너무 일찍 끌어오지 않는가 |

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| 오래된 adopter 세대가 current upgrade UX와 다른 신호를 줄 수 있음 | Medium | "first real evidence"와 "current minor-path calibration"을 분리해 서술 |
| temp simulation이 실제 target apply와 혼동될 수 있음 | Medium | read-only / temp copy / target direct write 단계를 명시적으로 분리 |
| single target 결과로 DR-034를 과대 확정할 위험 | Medium | Accepted 승격 조건과 residual 불확실성을 분리 기록 |
| target repo 현재 로컬 branch 맥락이 walkthrough를 오염시킬 수 있음 | Medium | working tree가 아니라 pinned committed ref에서 read-only probe를 수행하고 SHA를 evidence에 기록 |
| internal managed mode 논의가 다시 scope를 잡아먹을 수 있음 | Medium | Candidate B는 gate verdict만, 설계는 별도 후속으로 고정 |

## Done Criteria

- [x] Claude B R1 red-team review가 기록된다.
- [x] R1 finding에 대한 Codex A response와 consensus가 기록된다.
- [x] `ai-deck-compiler`를 baseline-acquisition 재실측 target으로 쓰는 이유와 한계가 기록된다.
- [x] target repo의 starting conditions(pre-manifest, pinned committed ref, clean idle 상태)가 기록된다.
- [x] current-source tracked-file count와 drift count를 2026-06-11의 `76 tracked, 76 in-sync, 0 drifted` 결과와 대조해 기록한다.
- [x] Layer T 기반 inventory-first / shadow scaffold / selective migration 실행 계획과 측정 artifact가 정리된다.
- [x] DR-034 Draft 유지와 promotion 조건 구체화 판단이 명시된다.
- [x] internal managed mode gate verdict는 net-new evidence가 있을 때만 내리고, 없으면 defer한다.
- [x] 결과 산출물은 "upgrade 증명"이 아니라 "baseline-acquisition 경로 regression 재확인"으로 가치 한계를 명시한다.
- [x] 구현 시 수정/실행 대상 repo와 surface(harness source vs target temp copy vs target direct write)가 구분된다.
- [x] Claude B result review와 Codex A response가 기록된다. (B re-check Approved, P3 C1 close 부수 정렬 완료)
- [x] 사용자 최종 승인 후 `/work-close` 가능한 상태가 된다. (owner 승인 2026-06-21)

## Verification

- harness source: `git diff --check`
- walkthrough 기준: Layer T (`docs/maintainer/VERIFICATION-COMMANDS.md`)
- target probe: `.harness/manifest.json` 부재, STATUS idle, pinned committed ref 확인
- output framing: 결과는 "upgrade 증명"이 아니라 "baseline-acquisition 경로 regression 재확인"으로 표기
- scope self-check: helper 구현, internal managed 설계, target direct write가 비범위를 넘지 않았는지 확인

## Walkthrough Output

### Starting Conditions

| 항목 | 결과 |
| --- | --- |
| target repo | `/Users/kyungseo/dev-home/vibe/ai-deck-compiler` |
| target branch signal | `feature/ai-coding-tool-pilot-review-deck` |
| target working tree | clean (`git status --short --branch` 출력에 변경 파일 없음) |
| pinned committed ref | `7941585bbc6fba22e46ecf71909a0d0ec9fac379` |
| manifest state | pre-manifest (`.harness/manifest.json` 없음) |
| execution surface | harness source에서 실행, pinned ref archive 기반 temp copy와 shadow scaffold만 변경 |
| target direct write | 없음 |

### Measurement Artifacts

| Artifact | Purpose |
| --- | --- |
| `temp/chore-20260621-002/ai-deck-copy` | pinned target ref에서 만든 temp target copy. real target write 없음 |
| `temp/chore-20260621-002/ai-deck-shadow` | current source로 생성한 shadow scaffold baseline |
| `temp/chore-20260621-002/check-before.txt` | shadow manifest만 심은 직후 drift 측정 |
| `temp/chore-20260621-002/target-missing.txt` | `target-missing` path list, 39개 |
| `temp/chore-20260621-002/locally-modified.txt` | `locally-modified` path list, 32개 |
| `temp/chore-20260621-002/check-after-missing.txt` | missing path만 보충한 뒤 drift 측정 |
| `temp/chore-20260621-002/check-after-full-baseline.txt` | missing + modified path 모두 current baseline으로 맞춘 뒤 drift 측정 |
| `temp/chore-20260621-002/invariant-after-full-baseline.txt` | full baseline temp copy에 대한 scaffold invariant 결과 |

### 2026-06-11 대비 Current Source Delta

| Probe | Tracked | In-sync | Drifted | target-missing | locally-modified | 판정 |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 2026-06-11 note | 76 | 76 | 0 | 37 | 30 | 당시 full temp simulation 통과 |
| 2026-06-21 current manifest only | 78 | 7 | 71 | 39 | 32 | current source 기준 재실측 필요 |
| 2026-06-21 missing-only 보충 후 | 78 | 46 | 32 | 0 | 32 | missing path 39개 보충 효과 확인 |
| 2026-06-21 full baseline 보충 후 | 78 | 78 | 0 | 0 | 0 | overwrite-convergence 기준 0 drift 재현. adopter-safe apply 증거는 아님 |

핵심 delta는 `tracked +2`, `target-missing +2`, `locally-modified +2`, 총 drift `+4`다. 따라서 이번 실행은 2026-06-11 기록의 단순 재인용은 아니며, current source의 늘어난 tracked surface까지 포함해 baseline-acquisition 경로가 overwrite 기준으로 `0 drift`까지 수렴함을 재확인했다.

### Locally-Modified Classification

`78 tracked, 78 in-sync, 0 drifted`는 `temp/chore-20260621-002/locally-modified.txt`의 32개 파일을 shadow baseline으로 덮어쓴 뒤 얻은 값이다. 이 0 drift는 **overwrite-convergence**이며, customization 보존을 증명하지 않는다.

| 분류 | 파일 | 판단 |
| --- | --- | --- |
| customized-must-merge | `CLAUDE.md`, `AGENTS.md`, `.gitignore`, `prompts/claude-session-start.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md` | root entrypoint / ignore policy / session-start prompt는 framework-owned manifest path에 속하더라도 adopter identity와 local workflow가 섞이는 표면이다. 실제 apply에서는 blind overwrite 금지, manual merge 필요 |
| framework-update-candidate | `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-NAMING-RULES.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/decisions/DECISION-TEMPLATE.md`, `docs/decisions/DR-007-language-policy.md`, `docs/decisions/DR-008-docs-filename-standard.md`, `docs/decisions/DR-013-work-file-spec.md`, `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`, `.claude/commands/record-decision.md`, `docs/GIT-WORKFLOW.md`, `tools/git-hooks/pre-commit`, `tools/git-hooks/commit-msg`, `tools/git-hooks/install.sh`, `.agents/skills/workflow-record-decision/SKILL.md`, `.codex/hooks.json`, `.cursor/rules/coding.mdc`, `.cursor/rules/debugging.mdc`, `.cursor/rules/execution.mdc`, `.cursor/rules/git-commit.mdc`, `.cursor/rules/role-harness-maintainer.mdc`, `.cursor/rules/workflow.mdc`, `prompts/README.md` | current source 기준 framework update 후보. 다만 이 Work는 temp overwrite만 수행했으므로 실제 target apply 전 파일별 diff review가 필요 |
| accepted-drift | 없음 | 이번 temp simulation에서는 accepted drift를 결정하지 않았다. 실제 adopter migration에서는 target maintainer가 보존할 drift를 명시해야 함 |

따라서 이번 결과의 정직한 해석은 "manifest-tracked 파일을 current baseline으로 강제 정렬하면 0 drift까지 수렴한다"이지, "`ai-deck-compiler` customization을 보존하면서 안전하게 upgrade 가능하다"가 아니다. 특히 `CLAUDE.md`/`AGENTS.md`/`.gitignore`와 session-start prompt는 External Adopter Mode가 보호해야 하는 project-identity surface이므로, 0 drift 달성을 위해 이들을 덮어쓴 사실을 adopter evidence의 한계로 함께 남긴다.

### Invariant Result

`scripts/tests/check-scaffold-invariants.sh temp/chore-20260621-002/ai-deck-copy` 결과는 `FAIL`이다.

- `OK`: core A-class DR 참조 실재
- `OK`: source-only leakage 없음
- `FAIL`: `docs/decisions/README.md` 없음
- `OK`: root README와 optional docs 일치
- `OK`: manifest 형식 + `--check` 자기일관성(`0 drift`)

이 실패는 manifest-tracked framework file drift가 아니라 target-local decision index closure 문제다. shadow scaffold에는 `docs/decisions/README.md`가 존재하지만, current manifest-tracked baseline 보충만으로는 target-local accepted DR index가 자동 구성되지 않는다. 따라서 full baseline acquisition 이후에도 실제 adopter 전환으로 가려면 target-local `docs/decisions/README.md` 보강 또는 그 소유권 결정이 별도 필요하다.

### DR-034 And Managed Gate Verdict

- DR-034는 계속 `Draft`로 유지한다. 같은 target + temp simulation은 DR-034 promotion condition인 "두 번째 adopter 또는 실제 target migration"을 충족하지 못한다.
- 이번 결과는 promotion 충분조건이 아니라 promotion 조건을 더 선명하게 만든다. 다음 승격 증거는 실제 target apply 또는 두 번째 adopter에서 같은 baseline-acquisition/upgrade 경로가 재현되는 것이다.
- internal managed mode gate는 `defer`다. current source regression 재확인은 유효하지만, fleet mode 설계를 열 만큼의 multi-target evidence나 실제 migration evidence는 아니다.

### Value Limit

이번 산출물의 가치 상한은 **baseline-acquisition 경로 regression 재확인**이다. 이는 "upgrade 증명"이 아니며, manifest baseline 보유 adopter가 없는 현재 상태에서는 source-to-target version-delta upgrade를 검증했다고 주장할 수 없다. 또한 이번 `0 drift`는 overwrite로 얻은 수렴이며 customization 보존을 보장하지 않는다.

## Cross-Agent Review

### Cross-Agent Review And Discussion

Claude B는 red team reviewer로서 아래를 검토한다.

- **target 선택 자체:** `ai-deck-compiler`가 정말 first real walkthrough의 최적 타깃인가?
- **증거 품질:** temp simulation만으로 "first real"이라고 불러도 되는가?
- **정책 과대확정:** single target 결과로 DR-034 Accepted 또는 internal managed gate를 성급히 여는 위험은 없는가?
- **cross-repo execution risk:** harness repo Work와 target repo 실행 경계가 혼탁해지지 않는가?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 없음) + 각 finding별 accept/defend/revise 가능한 recommendation.

#### R1 Review Result — Claude B

**최종 판정: Request changes (walkthrough 실행 전).** scope·Scope Guard·cross-repo 분리는 견고하다. 그러나 (1) 이 target의 full temp simulation은 **이미 2026-06-11에 수행됐고**(`76 tracked, 76 in-sync, 0 drifted` + invariant PASS, migration note L48~71), (2) 이 Work가 표방한 "first real **upgrade** walkthrough"는 현재 fleet 조건상 **구조적으로 성립 불가**다. 근거를 직접 실측했다.

**Direction-level concern (구조적):** "upgrade walkthrough"라는 명명 자체가 과대 주장이다.
- `ai-deck-compiler`는 여전히 pre-manifest다(실측 확인). `rfx-hub`도 `.harness/manifest.json`이 없다(실측). 즉 **현재 manifest baseline을 가진 adopter가 하나도 없다.**
- manifest가 없으면 source→target **version-delta migration**(= 진짜 upgrade)을 테스트할 수 없다. 테스트 가능한 건 **baseline 취득 + selective migration**뿐이고, 그건 06-11에 이미 시뮬레이션됐다.
- 따라서 이 Work는 "first real **upgrade**"가 아니라 잘해야 "**baseline-acquisition을 current source로 재실측**"이다. 정직하게 (a) 목표를 baseline-acquisition 검증으로 rename하거나, (b) 진짜 net-new 가치인 **owner 승인 하의 실제 baseline plant**(한 adopter를 실제로 manifest 시대로 진입시켜 *다음* upgrade가 진짜 upgrade가 되게)를 선택하라. 이 Work는 (b)를 defer했으므로, 현 scope의 net-new 가치가 무엇인지부터 답해야 한다.

| ID | Severity | Finding | Basis | Recommendation | A 선택지 |
| --- | --- | --- | --- | --- | --- |
| F1 | P1 | 06-11 probe가 이 target의 full temp sim을 이미 끝냈다 — 현 scope는 그 재현 | migration note L48~71: shadow scaffold→`76/76/0`→invariant PASS가 동일 target에서 완료됨. 현 scope(read-only→temp copy→shadow sim)는 같은 경로다. 단, source는 06-11 이후 framework surface **79 commit**(core tracked surface **23 commit**) 변경 → 06-11 수치(tracked 76)는 stale일 가능성 큼(Antigravity `.agents/` 추가 등). | Slice B의 **첫 산출물**을 "06-11 대비 source drift 정량화 + net-new 질문 명시"로 둔다. tracked-file count가 76에서 바뀌었는지, 어떤 surface가 늘었는지부터 측정. drift가 미미하면 이 Work는 "06-11 재인용"으로 붕괴하므로 실행 부적합. | revise 권장 |
| F2 | P1 | "first real walkthrough → DR-034 Accepted 검토"가 promotion 조건상 불가능 | DR-034 Promotion Conditions: "**두 번째 adopter 또는 실제 target migration**에서 재현." 그런데 이 Work는 **같은 target(ai-deck) + temp simulation**이다 → 둘 다 아님. 게다가 manifest 보유 adopter 부재로 "실제 upgrade"도 불가. | Slice D에서 "Accepted 검토" framing 제거. 최대 산출은 **Draft 재확인 + promotion 조건 구체화**(무엇이 더 있어야 승격되는지)다. Accepted를 원하면 scope를 실제 apply 또는 진짜 2nd adopter로 owner 승인 하에 격상. | revise |
| F3 | P2 | target의 dirty feature branch가 inventory를 오염시킨다 | Discovery: target local branch가 `feature/ai-coding-tool-pilot-review-deck`(미완 feature), STATUS는 2026-06-02. working tree를 probe하면 half-done 변경이 framework/project 분류를 오염시킨다. Risk의 "기록한다" mitigation은 약하다. | working tree가 아니라 **특정 committed ref(SHA)에서 read-only probe**하고 그 SHA를 evidence에 pin. 재현성 확보. | revise |
| F4 | P2 | Slice E(internal managed gate verdict)가 약한 evidence에 올라탄다 | gate yes/no도 walkthrough evidence에 의존하는데, F1/F2가 맞으면 그 evidence는 재-sim이다. 재현 evidence로 managed-mode 결정을 유도하면 CHORE-20260621-001이 경계한 "약한 근거 위 결정"이 된다. | Slice E를 **조건부**로: 06-11 대비 net-new evidence가 있을 때만 gate verdict를 낸다. 없으면 gate도 함께 defer. | revise |
| F5 | P3 | Done Criteria가 전부 doc-only("기록된다/정리된다")라 측정 결과가 없다 | 경험적 walkthrough인데 "done"이 "계획을 썼다"로 충족된다. 측정 artifact가 하나도 강제되지 않는다. | 최소 1개를 측정 기준으로: "current-source `--check` drift count를 06-11의 76/0과 대조해 기록", "tracked-file count delta 기록". | revise lightly |

**정합성 확인(defend 가능):** Scope Guard는 강하고 DR-034 §6(신규 CLI 보류)과 일관. helper/managed design/타 repo/target write 비범위 고정 적절. cross-repo "harness에서 track, target에 대해 실행" 분리도 정확. Risk 표는 주요 위험을 덮으나 F3 mitigation이 얇다.

#### R1 A Response — Codex A

Claude B의 Request changes를 **전면 수용**한다. 이 리뷰의 핵심은 "이 target을 버리자"가 아니라, **Work의 이름과 성공 조건을 과장 없이 낮추자**는 것이다. 특히 `first real upgrade`라는 표현은 manifest baseline을 가진 adopter가 없는 현재 상태에서는 구조적으로 부정확하다. 이번 Work는 `ai-deck-compiler`를 "upgrade" 대상이 아니라 **current source 기준 baseline-acquisition 재실측 대상**으로 재정의한다.

따라서 실행 목표를 아래처럼 수정한다.

- 2026-06-11 simulation을 반복했다는 사실을 baseline으로 삼고, current source 기준 tracked-file count / drift distribution delta가 있는지 먼저 측정한다.
- DR-034는 `Accepted` 검토가 아니라 **Draft 재확인 + promotion 조건 구체화**까지만 다룬다.
- target repo의 현재 working tree/feature branch를 evidence로 삼지 않고, 특정 committed ref를 pin한 read-only probe로 시작한다.
- internal managed gate verdict는 net-new evidence가 있을 때만 내리고, 없으면 함께 defer한다.
- target direct write 또는 실제 manifest plant는 이번 Work의 기본 범위가 아니며, 필요하면 owner 승인 하에 별도 격상한다.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| Direction concern — `upgrade walkthrough` 명명 과대 | **Accept / revise** | Work title, Top Summary, scope를 `Baseline-Acquisition Walkthrough`로 재정의했다. "진짜 upgrade"는 manifest baseline 보유 adopter가 생긴 뒤의 다음 단계로 둔다. |
| F1 (P1) 06-11 simulation 재현 위험 | **Accept / revise** | Slice C와 Done Criteria에 06-11의 `76 tracked, 76 in-sync, 0 drifted` 대비 current-source delta 측정을 추가했다. delta가 작으면 net-new value가 낮다는 결론까지 허용한다. |
| F2 (P1) DR-034 promotion 조건 미충족 | **Accept / revise** | Slice D를 `DR-034 Draft Reconfirmation`으로 바꾸고, 같은 target + temp simulation은 promotion 조건을 충족하지 못한다고 명시했다. |
| F3 (P2) dirty target branch 오염 | **Accept / revise** | Done Criteria와 실행 계획을 `pinned committed ref` 기준으로 바꿨다. local working tree는 probe input이 아니라 risk signal로만 다룬다. |
| F4 (P2) internal managed gate 약한 근거 | **Accept / revise** | Slice E를 조건부로 바꿨다. net-new evidence가 없으면 gate verdict도 defer한다. |
| F5 (P3) doc-only Done Criteria | **Accept / revise lightly** | 측정 artifact를 Done Criteria에 추가했다: current tracked-file count와 drift count를 06-11 기준과 대조해 기록한다. |

**결론:** 이번 Work는 "first real upgrade"가 아니라 "oldest pre-manifest adopter에서 current source baseline-acquisition이 여전히 재현 가능한가"를 측정하는 작업으로 계속 진행한다. B가 이 downscope에 동의하면 CP3 실행으로 넘어간다.

#### R1 B Re-check — Claude B

**판정: Consensus (CP3 진입 동의), 단 P3 잔여 2건은 실행 시 정리.** rubber-stamp가 아니라 5개 finding + direction concern이 plan 본문에 실제 반영됐는지 대조했다. 모두 닫혔고, 단순 relabel이 아니라 행동 수준 변경이다.

- **Direction concern ✅** Title `Baseline-Acquisition Walkthrough`로 변경, Top Summary/scope가 "manifest 보유 adopter 부재 → 엄밀한 upgrade 검증 불가"를 명시. (b) 실제 plant는 owner 승인 하 별도 격상으로 정직하게 defer.
- **F1 ✅** Slice C에 "06-11 `76/76/0` 대비 tracked-file count / drift distribution delta 대조" 추가, Done Criteria에 측정 기준 박음. delta가 작으면 "net-new value 낮음" 결론 허용(정직한 exit).
- **F2 ✅** Slice D → `DR-034 Draft Reconfirmation`, "같은 target+temp sim은 promotion 조건 미충족" 명시.
- **F3 ◐** Done Criteria/Top Summary는 `pinned committed ref`로 전환. 단 잔여 있음(아래).
- **F4 ✅** Slice E 조건부화: net-new evidence 있을 때만 gate verdict, 없으면 defer.
- **F5 ✅** Done Criteria에 측정 artifact(tracked-file count·drift count 대조) 추가.

**P3 잔여(실행 시 정리, blocking 아님):**

| ID | 잔여 | 근거 |
| --- | --- | --- |
| N1 | Risk 표 row 4 mitigation이 아직 "current branch를 별도 **기록**"으로 남음 — F3에서 약하다고 지적한 그 문구. Done Criteria는 pin-ref로 올렸는데 Risk 표만 옛 mitigation 유지 → 내부 불일치 | L112 Risk 표 vs L120 Done Criteria. mitigation을 "pinned committed ref에서 probe"로 정렬 권장 |
| N2 | Slice A probe step이 여전히 "current branch ... 기록한다"로만 서술 — pinned ref에서 probe한다는 지시가 Slice 본문에 없음 | L55~59. Slice A에 "working tree 아닌 pinned ref read-only probe" 한 줄 추가 권장 |

**합의 결론:** baseline-acquisition 재실측 + DR-034 Draft 재확인 + 조건부 gate verdict shape에 동의한다. N1/N2는 실행(CP3) 중 정렬하면 되는 문구 일관성 nit이다. owner 승인 후 walkthrough 실행으로 진행 가능.

**가치 한계 명시(합의 일부):** 이 Work의 가치 상한은 "23-commit 이동 후 baseline-acquisition 경로 regression 재확인"이지 "first real upgrade 증명"이 아니다. adopter-transition cluster가 이 경로에 의존하므로 regression 재확인은 정당한 maintenance evidence이나, fleet mode/Accepted 승격의 충분조건은 아니다.

#### Result Review — Claude B

**최종 판정: Request changes (close 전).** 측정 scaffolding(pinned ref, no target write, 76→78 delta, invariant 분리)은 충실하다. 그러나 owner가 직접 제기하고 R1 중 (a)로 경고한 **customized framework-owned entrypoint 처리가 evidence에서 누락된 채, 정확히 그 위험 경로가 재현**됐다. artifact로 사실을 확정했다.

**(a) 기록 여부 — 직답: 기록 안 됨.** `temp/chore-20260621-002/locally-modified.txt` 실측: 32개 중 **L1 `CLAUDE.md`, L2 `AGENTS.md`, L3 `.gitignore`**가 포함된다. `Walkthrough Output`은 이 32개를 "full baseline 보충 후 → `78/78/0`"으로 **전부 overwrite**해 0 drift를 만들었고, 그 안에 customized entrypoint가 있다는 사실/분류/caveat이 어디에도 없다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| F-R1 | P1 | locally-modified 32개를 분류 없이 blind-overwrite해 0 drift를 만들었다 — 그 안에 customized entrypoint(`AGENTS.md`/`CLAUDE.md`/`.gitignore`)가 포함됨 | `locally-modified.txt` L1~3. `78/78/0`은 이들을 framework 원본으로 덮어야 도달. 실제 apply였다면 ai-deck의 프로젝트 identity가 소실. **게다가 DR-034 §3은 locally-modified를 `target-missing`/invariant-breaking/`manual-merge candidate`/`accepted drift`로 분류한 뒤 반영하라고 요구** — walkthrough는 이 분류를 건너뛰고 overwrite로 직행했으므로 절차적으로도 DR-034 미준수다. | 32개를 ① framework update-to-apply ② customized-must-merge(최소 `AGENTS.md`/`CLAUDE.md`/`.gitignore`) ③ accepted-drift로 분류 표기. `Walkthrough Output`에 "0 drift는 overwrite-convergence이며 customized entrypoint를 지웠다 → safe real apply 아님" caveat 추가. |
| F-R2 | P2 | DR-034 정책 공백: §4 preserve-list가 customized framework entrypoint를 누락 | DR-034 §4 보존 목록은 `STATUS/PLAN/backlog/Work/product DR/code/package/.harness/gate-config`만. `AGENTS.md`/`CLAUDE.md`/project `.gitignore`는 framework-owned이지만 adopter가 identity 보정하도록 scaffold가 권장(create-harness L982~984). 이 walkthrough가 그 공백이 실제로 문다는 evidence다. | DR-034 promotion condition 또는 backlog candidate에 "customized framework entrypoint merge-not-overwrite 규칙 필요"를 durable하게 등록(CHORE-20260621-001 anti-burial 기준 — Work 내부에만 두지 말 것). |
| F-R3 | P3 | `Value Limit`이 "upgrade 증명 아님"은 말하나 "0 drift = preservation-safe 아님"은 누락 | §Value Limit. | 한 줄 추가: "이 0 drift는 overwrite로 얻은 수렴이며 customization 보존을 보장하지 않는다." |

**정합성 확인(defend 가능):** pinned ref `7941585…` + target direct write 없음(F3/N1/N2 충족). 76→78 tracked delta 실측으로 06-11 단순 재인용 아님(F1/F5 충족). invariant FAIL을 decision-index closure로 분리한 판단 정확. DR-034 Draft 유지 + managed gate defer(F2/F4 충족). 측정 골격은 견고하고, 결함은 **단 하나의 가장 adopter-relevant한 cell(locally-modified 분류)**에 집중된다.

**Direction-level concern(자기지시적):** 이 Work는 "0 drift 달성 가능"을 headline로 내지만, 그 0은 External Adopter Mode가 보호하려는 바로 그 project-identity 파일(`AGENTS.md`/`CLAUDE.md`)을 지워서 산 값이다. caveat 없이 두면 future agent가 "adopter upgrade는 깨끗하다"고 오독할 수 있다. F-R1/F-R2는 둘 다 한 단락 수준 보강이며, 이걸 채워야 이 walkthrough가 정직한 adopter evidence가 된다.

#### Result A Response — Codex A

Claude B의 Request changes를 **전면 수용**한다. 측정값 자체(`78 tracked, 78 in-sync, 0 drifted`)은 맞지만, 그 값의 의미를 "adopter-safe convergence"로 읽으면 위험하다. 실제로 `locally-modified.txt`의 L1~L3에 `CLAUDE.md`, `AGENTS.md`, `.gitignore`가 포함되어 있었고, full baseline step은 이들을 shadow baseline으로 덮어쓴 temp-only 수렴이다.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| F-R1(P1) customized entrypoint blind-overwrite 미분류 | **Accept / revise** | `Locally-Modified Classification` 섹션을 추가했다. `CLAUDE.md`/`AGENTS.md`/`.gitignore`와 session-start prompt 3개는 `customized-must-merge`로 분류하고, 나머지는 `framework-update-candidate`로 두되 실제 apply 전 diff review가 필요하다고 명시했다. |
| F-R2(P2) DR-034 preserve-list 공백 | **Accept / revise** | DR-034 Draft Decision/Promotion Conditions/Consequences에 customized framework entrypoint merge-not-overwrite 규칙과 promotion 조건을 추가했다. Work 내부 caveat에만 묻히지 않도록 durable policy surface에 반영했다. |
| F-R3(P3) Value Limit caveat 누락 | **Accept / revise** | Value Limit에 "`0 drift`는 overwrite 수렴이며 customization 보존을 보장하지 않는다"를 추가했다. |

**결론:** 이 Work의 결과는 "current source baseline으로 강제 정렬하면 manifest drift 0까지 갈 수 있다"는 regression evidence다. 하지만 External Adopter Mode의 핵심 질문인 "project identity를 보존하면서 안전하게 적용할 수 있는가"는 아직 미해결이다. 실제 adopter migration으로 격상하려면 customized entrypoint manual merge와 accepted drift 기록이 선행되어야 한다.

#### Result B Re-check — Claude B

**판정: Approved, 단 P3 정합성 잔여 1건.** 3건 fix를 두 파일에서 실측 검증했다.

- **F-R1(P1) ✅** Work `Locally-Modified Classification` 섹션 착지. 32개 = `customized-must-merge` 3(`CLAUDE.md`/`AGENTS.md`/`.gitignore`) + `framework-update-candidate` 29 + `accepted-drift` 0(미결정 명시)로 분류 — `locally-modified.txt`와 개수·항목 정확히 일치. "0 drift = overwrite-convergence, preservation 아님" caveat 포함. DR-034 §3 분류 요구도 충족.
- **F-R2(P2) ✅** DR-034 §4 + Promotion Conditions + Consequences + Linked Work에 durable 반영. Work 내부가 아니라 **정책 본체**에 남아 anti-burial 기준 충족.
- **F-R3(P3) ✅** caveat가 Classification 섹션·Value Limit에 반영.

**P3 정합성 잔여(re-check 발견, blocking 아님):**

| ID | 잔여 | 근거 |
| --- | --- | --- |
| C1 | A가 같은 pass에서 쓴 **두 문서가 session-start prompt에서 어긋난다.** DR-034 §4 신규 문구는 "`CLAUDE.md`, `AGENTS.md`, `.gitignore`, **session-start prompt**처럼 ... customized framework entrypoint로 분류"라 명시했는데, Work `Locally-Modified Classification`은 `prompts/claude-session-start.md`/`codex-session-start.md`/`cursor-session-start.md`를 **framework-update-candidate**에 넣었다 → 정책과 evidence 분류 불일치 | DR-034 신규 §4 vs Work 표 184행 |

권고: 둘을 정렬. session-start prompt가 adopter-customizable이라는 DR-034 판단을 따르면 Work 표에서 이들을 `customized-must-merge`(또는 "per-file diff 필요 uncertain")로 올리고, 아니면 DR-034 예시에서 session-start prompt를 빼서 over-claim을 제거한다. 내 lean: adopter가 bootstrap prompt를 흔히 손대므로 DR-034 판단이 맞다 → Work 표를 올리는 쪽. close 부수로 처리 가능.

**합의 결론:** 핵심 결함(customized entrypoint 미분류 + 정책 공백)은 닫혔고, evidence가 이제 정직하다. C1은 두 문서 정합 한 줄 정리일 뿐이다. owner 최종 승인 → `/work-close` 가능 상태(C1은 close 시 정렬 또는 후속 분리).

### Round Log

| Round | Reviewer | Status | Request | Result | A Response |
| --- | --- | --- | --- | --- | --- |
| R1 | Claude B | Consensus (CP3 진입 동의) | Work file + walkthrough plan red-team review | Request changes: P1 2 / P2 2 / P3 1 + direction concern 1 → A 전면 수용 → B re-check 5건+direction closed, P3 잔여 N1/N2 확인 | 전면 수용. `first real upgrade`를 `baseline-acquisition 재실측`으로 downscope, DR-034는 Draft 재확인/조건 구체화로 제한, pinned ref와 06-11 delta 측정 추가. N1/N2 문구도 pin-ref 기준으로 정렬 |
| Result | Claude B | Approved (B re-check) | Walkthrough Output(`78/78/0`) + locally-modified 처리 검토 | Request changes: F-R1(P1) customized entrypoint(`AGENTS`/`CLAUDE`/`.gitignore`) blind-overwrite 미분류+DR-034 §3 미준수, F-R2(P2) DR-034 preserve-list 공백 durable 등록, F-R3(P3) Value Limit caveat. 측정 골격은 충족 → A 전면 수용 → B re-check 3건 closed, P3 정합성 잔여 C1(session-start prompt 분류 불일치) | 전면 수용. `0 drift`를 overwrite-convergence로 재분류하고, `CLAUDE.md`/`AGENTS.md`/`.gitignore`와 session-start prompt 3개를 customized-must-merge로 명시. DR-034에 durable policy gap 반영. C1 close 부수 정렬 완료 |

### Consensus Log

| Item | Status | Consensus / Remaining Disagreement |
| --- | --- | --- |
| target/명명: real upgrade vs baseline-acquisition | Consensus | baseline-acquisition 재실측으로 rename/downscope. (b) 실제 plant는 owner 승인 하 별도 격상. B re-check 동의 |
| F1 06-11 재현성 vs net-new | Consensus | current-source delta를 06-11 기준과 대조, delta 작으면 net-new 낮음 결론 허용. B re-check 동의 |
| F2 DR-034 promotion 가능 범위 | Consensus | Accepted 제거, Draft 재확인 + promotion 조건 구체화로 제한. B re-check 동의 |
| F3 dirty target branch 오염 | Consensus | pinned committed ref probe로 전환. N1/N2 문구 정렬 완료 |
| F4 Slice E gate 조건부화 | Consensus | net-new evidence 있을 때만 gate verdict, 없으면 defer. B re-check 동의 |
| 가치 한계 | Consensus | 상한은 baseline-acquisition regression 재확인, first real upgrade 증명 아님. 결과 산출물에도 이 한계를 명시 |
| customized entrypoint 처리 (Result F-R1) | Consensus | 32개를 must-merge 6 / framework-update-candidate 26 / accepted-drift 0으로 분류, caveat 포함. artifact와 정확 일치. B re-check C1까지 반영 |
| DR-034 preserve-list 공백 (Result F-R2) | Consensus | merge-not-overwrite 규칙을 DR-034 본체(§4/Promotion/Consequences/Linked Work)에 durable 등록. B re-check 검증 완료 |
| session-start prompt 분류 정합 (Result C1) | Consensus | DR-034 §4에 맞춰 Work 표에서도 `prompts/claude-session-start.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`를 customized-must-merge로 정렬 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Work 파일 + Active Work 포인터 + cross-agent review 틀 작성 | 완료 |
| 2 | Claude B R1 red-team review + A response + B re-check consensus | 완료 (N1/N2 문구 정렬 반영) |
| 3 | 합의된 walkthrough 실행/기록 (target probe → temp copy → baseline → drift classification) | 완료 |
| 4 | Claude B result review(Approved) + owner 승인 + `/work-close` 가능 상태 확인 | 완료 (owner 승인 2026-06-21, Done 처리) |
| 5 | `/work-close`: Work Done + backlog residual re-scope + Work Index + STATUS 번들 | 진행 중 (STATUS·commit gate 승인 대기) |

## Next Actions

- ✓ 다음 작업으로 `ai-deck-compiler first real upgrade walkthrough + DR-034 acceptance judgment` 선택
- ✓ feature branch 분리: `feature/chore-20260621-002-ai-deck-upgrade-walkthrough`
- ✓ Work 파일 생성 및 cross-agent review 틀 작성
- ✓ Claude B R1 red-team review 기록 (Request changes: P1 2 / P2 2 / P3 1 + direction concern)
- ✓ Codex A R1 response 작성: `first real upgrade` → `baseline-acquisition 재실측` downscope
- ✓ Claude B R1 re-check: 5건+direction closed, consensus 도달. P3 잔여 N1(Risk 표 mitigation)/N2(Slice A pin-ref 문구) 확인
- ✓ N1/N2 문구 정렬: Slice A와 Risk 표 모두 pinned committed ref 기준으로 수정
- ✓ owner 승인 → CP3 walkthrough 실행
- ✓ result 기록: current source 기준 `78 tracked, 78 in-sync, 0 drifted`까지 baseline-acquisition 경로 재확인
- ✓ Claude B result review 기록 (Request changes: F-R1 P1 customized entrypoint 미분류, F-R2 P2 DR-034 공백, F-R3 P3 caveat)
- ✓ Codex A result response: locally-modified 32개 ①update/②must-merge/③accepted-drift 분류 + caveat, DR-034 공백 durable 등록
- ✓ B re-check: Approved, P3 C1 정합성 잔여 확인
- ✓ C1 close 부수 정렬: session-start prompt 3개를 customized-must-merge로 이동
- ✓ owner 승인 → `/work-close` 실행: Work Done, backlog 후보를 real-apply residual로 re-scope, Work Index 이동
- → STATUS Active pointer 제거 + Recent Decisions 반영 (승인 후), commit(`--base develop` PR)
- ○ 후속: real adopter 마이그레이션(Stage 2)을 신규 Work로 등록 (role swap: Claude=author/driver)

## Discovery

- backlog와 brief 모두 `ai-deck-compiler` actual upgrade walkthrough를 internal managed mode보다 선행 gate로 둔다.
- `ai-deck-compiler`는 현재 `.harness` 디렉토리와 `manifest.json`이 없고, DR-034가 정의한 전형적인 pre-manifest target이다.
- target repo `STATUS.md`는 2026-06-02 기준 clean idle이며 Active Work가 없다. 다만 로컬 git branch는 `feature/ai-coding-tool-pilot-review-deck`이므로, walkthrough 실행 전 branch 의미와 direct-write 여부를 분리해서 다뤄야 한다.
- 기존 migration note는 2026-06-11 시점의 ai-deck-compiler probe/temporal simulation을 이미 담고 있다. 이번 Work는 그 기록을 단순 재인용하는 대신, 현재 source 기준에서 어떤 부분이 그대로 유효하고 어떤 부분은 재실측이 필요한지 판정해야 한다.
- current source 재실측 결과, manifest-tracked baseline acquisition은 `78 tracked, 78 in-sync, 0 drifted`까지 수렴했다. 다만 scaffold invariant는 target-local `docs/decisions/README.md` 부재로 실패하므로, 실제 adopter 전환은 decision index closure를 별도 보강해야 한다.
- `78 tracked, 78 in-sync, 0 drifted`는 `CLAUDE.md`/`AGENTS.md`/`.gitignore`와 session-start prompt 3개를 포함한 32개 `locally-modified` 파일을 shadow baseline으로 덮어쓴 temp-only overwrite-convergence다. 실제 adopter migration에서는 최소 이 6개 entrypoint/prompt를 customized-must-merge로 다뤄야 하며, 나머지 framework update 후보도 diff review 전 safe apply로 볼 수 없다.
- Closeout(2026-06-21): owner 승인 하 Work Done 처리. **5b Forward-Relevant Decision Triage 결과 `Needs-Triage: 없음`** — 이 Work의 deferred 결정(실제 adopter apply, upgrade 도구화, internal managed mode)이 모두 live backlog 후보에 매핑되므로 별도 triage 메모를 만들지 않는다(real apply는 재scope된 `ai-deck-compiler 실제 adopter 마이그레이션` 후보, 도구화는 `Packaging / distribution revisit`, managed는 `Internal managed mode` 후보). archive는 보류해 다음 `/session-start`에서 archive-pending으로 보고되게 둔다.

- 2026-06-22 archive: Done housekeeping(`/session-start` 배치 archive). Needs-Triage 없음 — deferred 결정(real apply/도구화/managed mode)이 모두 backlog 후보에 매핑됨.
