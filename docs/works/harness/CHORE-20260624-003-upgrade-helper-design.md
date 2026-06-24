---
id: CHORE-20260624-003
priority: P3
status: Done
risk: L2
scope: 구버전 manifest-target을 새 release tag로 올릴 때의 반복 위험(파일만 복사 시 source-updated 잔존·manifest rebaseline 필요·accepted-drift가 invariant [5] 깨짐·--check 분해 한계·shadow profile/workflow/name 일치)을 일반화해 줄이는 방안을 **설계·결정 경계까지만** 정리한다. 구현은 하지 않는다(helper/schema로 가면 L3 후속 분리). 후보(--upgrade-plan / manifest-rebaseline / accepted-drift schema·sidecar / --check output 개선 / playbook-only)를 비교하고 채택/보류 경계를 둔다. cross-agent review(Claude driver/Codex reviewer).
appetite: 0.5d
planned_start: 2026-06-24
planned_end: 2026-06-24
actual_end: 2026-06-24
related_dr: [DR-034, DR-043, DR-028]
related_troubleshooting: []
related_work: [CHORE-20260624-001, CHORE-20260624-002]
---

# CHORE-20260624-003: Manifest-target upgrade helper / accepted-drift handling 설계

## Top Summary

CHORE-20260624-001(spring upgrade)에서 구버전 manifest-target 업그레이드의 반복 위험이 드러났다:

- 파일만 복사해도 `source-updated`가 남는다(manifest recorded hash 신호) → rebaseline 필요
- accepted-drift가 있으면 scaffold invariant `[5]`가 실패한다
- `--check`는 `source-updated`/`locally-modified` 분해에 한계가 있다
- shadow scaffold는 profile/workflow/project-name이 target manifest와 일치해야 한다

이 Work는 위 반복 위험을 줄이는 방안을 **설계 + 결정 경계까지만** 정리한다. **바로 구현하지 않는다** — helper/schema 구현이 정당화되면 L3 후속 Work로 분리한다.

**중요(red-team 대상):** CHORE-20260624-002(DR-043)가 가장 구체적인 반복 case였던 `docs/AGENT-WORKFLOW.md` accepted-drift를 **이미 닫았다**. 따라서 이 Work의 첫 질문은 "그래서 일반 메커니즘이 아직도 필요한가, 아니면 playbook 보강(이미 한 것)으로 충분한가"다. evidence-bounded로 판단하고, 도구를 만들기 위해 문제를 부풀리지 않는다.

## Scope

**모드:** design note + decision boundary. 구현·도구 추가·DR 승격 없음(이번 Work).

**잔여 위험 2축 분리 (R0-Codex-F2):**
- **ⓐ procedure/ergonomics:** manifest rebaseline·`source-updated` 수동 처리의 불편함(아직 잔존). 저비용 완화 가능.
- **ⓑ policy/schema:** accepted-drift first-class 표현. **DR-043 이후 근거 크게 약화**(가장 구체적 case였던 AGENT-WORKFLOW가 닫힘). 두 축을 묶지 않는다 — ⓐ 불편함을 ⓑ schema 변경 명분으로 승격 금지.

**비교할 선택지 (R0-Codex-F4: monitor-only 1급 추가):**

| 후보 | 축 | 개요 | 비용 | 기본 판정 |
| --- | --- | --- | --- | --- |
| **no new mechanism / monitor-only** | — | 보강 완료로 보고 residual closeout + numeric future trigger만 남김 | 최저 | **기본 결론(default)** |
| playbook-only | ⓐ | 절차 보강 유지, 도구 없음 | 최저 | 채택(이미 완료) |
| `--check` output 개선 | ⓐ | source-updated=manifest hash 신호 / locally-modified=rendered drift 설명 hint | 낮음 | **유일한 live future candidate** (trigger 시) |
| `--upgrade-plan`(report-only) | ⓐ | classification table 초안 출력만 | 중간 | defer(trigger gated) |
| `manifest-rebaseline` helper | ⓐ | shadow manifest 생성·splice 명령화 | 중상(write 회귀) | defer(trigger gated) |
| accepted-drift schema/sidecar | ⓑ | per-path accepted 표식 | 높음(L3 cascade) | **defer(근거 약화, 강한 trigger 필요)** |

**Future trigger (numeric, R0-Codex-N2):** DR-043 이후 실제 adopter upgrade **2건 이상**에서 동일 manual rebaseline operator 오류 반복, **또는** AGENT-WORKFLOW 외 framework file에서 accepted-drift 보존 필요가 반복 관측 → 해당 축의 후속 Work를 연다.

**비목표:** 도구/schema 구현, DR 승격, 실제 adopter 적용, standalone brief(후속 helper Work 개설 시에만).

## Plan

1. (done) feature branch `feature/chore-20260624-003-upgrade-helper-design`, Work 파일
2. R0 plan review (/cross-review): Codex red-team — **첫째, DR-043 이후 이 Work가 still needed인가**(downscope/defer 후보) + 후보 비교 누락·DR-034 연결 적정성
3. EXECUTE: Work 내부 `Disposition` section 작성 — 후보 비교 + 채택/보류 + 트리거 + evidence boundary + backlog residual 갱신. (standalone brief는 후속 helper Work 개설 시에만)
4. R1 result review (/cross-review)
5. Finalization: STATUS/backlog/Work Done, commit/PR gate

## Done Criteria

- [x] **기본 결론 = defer(monitor-only/playbook-only)** 설정 (R0 conditional)
- [x] Work 내부 `Disposition` section 작성 — 2축 분리 + 후보 판정 + numeric future trigger (standalone brief 아님, F1)
- [x] backlog residual **update/downscope** — DR-043 반영, monitor-only + trigger로 축소 (F3)
- [x] DR-034 연결 = **non-promotion rationale만** (Disposition에 기록, F5)
- [x] cross-review R0·R1 종료 — R0 closed(conditional/accept), R1 closed(approve)
- [x] (trigger 미충족 → 후속 Work 미등록) 본 Work에서 구현 안 함 — trigger 충족 시 등록

## Verification

Work 내부 Disposition 일관성, backlog residual 갱신, (trigger 시) 후속 Work 등록. 코드 변경 없음 → `--check`/invariant 회귀 N/A(구현 시 후속 Work). Surface: Work · backlog · maintainer.

## Risk And Reversal

- 주 위험 = **over-engineering**: 실제 반복 빈도(현재 adopter upgrade 2건: ai-deck·spring)에 비해 도구/schema를 과대 설계. → 이번 Work를 design 경계로 제한하고 트리거로 gate.
- DR-034 성급한 승격 → evidence boundary로 차단.
- Reversal: 문서 only → **Low**.

## Discovery

backlog residual "Adopter upgrade accepted-drift 표현 + upgrade helper (CHORE-20260624-001 residual)" 착수. CHORE-001 evidence + CHORE-002(DR-043) 후속 landscape 변화 반영.

**landscape 변화:** DR-043이 `AGENT-WORKFLOW.md`(가장 구체적 `[5]` 반복 case)를 framework-pure화로 닫음. 남은 일반 case = adopter가 customize하는 다른 framework 파일(entry `CLAUDE.md`/`AGENTS.md`, `.gitignore`, session-start prompts = playbook `merge` class). 이들이 여전히 accepted-drift→`[5]`를 만드는지가 Work B 필요성의 핵심 evidence.

## Disposition (결론: defer / monitor-only)

cross-review R0(Codex conditional) 합의 + evidence-bounded 판단. **현재 결정: 새 helper/schema를 만들지 않는다.**

**잔여 위험 2축 평가:**

| 축 | 내용 | DR-043 이후 상태 | 현재 결정 |
| --- | --- | --- | --- |
| ⓐ procedure/ergonomics | manifest rebaseline·`source-updated` 수동 처리 불편 | 잔존(저강도). playbook(rebaseline/adapt-render/profile-match)·Layer T로 절차는 닫힘, 노동만 남음 | **monitor-only.** 유일 live future candidate = `--check output 개선`(저비용), trigger gated |
| ⓑ policy/schema | accepted-drift first-class 표현(schema/sidecar) | **근거 크게 약화** — 가장 구체적 case(AGENT-WORKFLOW)가 DR-043으로 제거됨 | **defer.** 강한 trigger 없이는 L3 schema cascade 비용 부당 |

**증거 경계:** adopter upgrade 실측 2건(ai-deck, spring). DR-043이 spring의 단일 accepted-drift를 닫았고, 다른 framework 파일의 반복 accepted-drift는 **아직 미관측**. 표본 2건으로 도구/schema를 정당화하지 않는다.

**Future trigger (이것이 충족되면 후속 Work):**
1. DR-043 이후 adopter upgrade **2건 이상**에서 동일 manual rebaseline operator 오류가 반복, 또는
2. AGENT-WORKFLOW **외** framework 파일에서 accepted-drift 보존 필요가 반복 관측.
→ 충족 시 해당 축의 후속 Work를 backlog에 등록(축 ⓐ면 `--check output 개선`부터, 축 ⓑ면 schema DR 검토).

**trigger 기록 기준 (R1-Codex residual):** "동일 manual rebaseline operator 오류 반복"은 모호하게 세지 않는다. 관측 시 Work/STATUS에 **path · command · 원인**을 남겨야 trigger가 과잉 발동하지 않는다(예: 같은 파일·같은 `--check` 오해·같은 rebaseline 누락이 2회 이상).

**DR-034(Draft) 연결 — non-promotion rationale only:** 이번 Work는 DR-034 Accepted 승격 근거가 **아니다**. CHORE-001/002가 "shadow scaffold baseline 절차가 유효함"을 보여줬을 뿐, spring은 manifest/agent-mediated 경로였고 다음 release 이후 정식 target apply가 남아 있다. 승격은 추가 adopter evidence 또는 정식 apply까지 대기. DR-034는 Draft 유지가 더 건강하다.

## Cross-Agent Review And Discussion

Model: `/cross-review` manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. Max rounds: plan R0 + result R1.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** Work plan `CHORE-20260624-003` (manifest-target upgrade helper / accepted-drift 설계)

**Current State:**
- branch `feature/chore-20260624-003-upgrade-helper-design`, Work 등록만(구현 미착수)
- evidence: CHORE-001(rebaseline/adapt-render/profile-match/[5] accepted-drift) + CHORE-002 DR-043(AGENT-WORKFLOW 닫힘) + playbook/VERIFICATION 보강 이미 반영됨
- adopter upgrade 실측 표본: ai-deck-compiler, spring-modular-template (2건)

**Delta Since Last Round:** R0 (first)

**Review Objective:** design 착수 전 **방향·필요성·scope** red-team.

**Must Check:**
1. **Still-needed check (최우선):** DR-043 + playbook 3종 보강 이후, 일반 helper/schema가 아직 정당한가. 아니면 이 Work를 "design note + defer triggers"로 더 줄이거나, 아예 playbook-only로 closeout해야 하나? over-engineering 위험을 직접 봐줘.
2. 후보 5개가 충분/과한가. 빠진 후보(예: upgrade 전용 Layer 문서화, manifest schema versioning)는?
3. accepted-drift schema/sidecar(L3)와 `--check` output 개선(L1) 사이의 결정 경계가 합리적인가.
4. DR-034(Draft) 연결 방식 — 이 Work 결과가 DR-034 promotion condition을 건드리나? evidence boundary가 충분한가.
5. design 산출물을 brief vs Work-내로 두는 기준이 맞나.

**Do Not Re-litigate:**
- 이번 Work는 design 경계까지(구현·DR 승격 없음) — 사용자 확정
- v1.4.0 apply와 current develop 변경 비혼합 원칙 — 확정
- 역할(Claude driver/Codex reviewer) — 확정

**Reviewer Posture:** 도구를 만들기 위해 문제를 부풀리는지 의심. 실제 반복 빈도(2 adopter) 대비 비용, defer가 정답일 가능성, DR-034 성급 승격 위험을 봐줘. speculation 표시.

**Output Contract:** Verdict(approve/conditional/request-changes/reject) · must-fix · nice-to-have · residual risk · suggested wording.

### R0 — Reviewer Findings (Codex)

Verdict: **conditional**. helper/schema 설계 Work로는 정당성 약함 → "post-DR-043 잔여 위험 disposition note + defer trigger"로 진행하되 **기본 결론 = playbook-only / helper defer**.

| ID | Severity | Finding |
| --- | --- | --- |
| R0-Codex-F1 | must | EXECUTE 산출물 기본값을 standalone brief → **Work 내부 disposition section**으로 낮춤. brief는 후속 helper를 실제로 열 때만 |
| R0-Codex-F2 | must | 잔여 위험 2축 분리: ⓐ manifest rebaseline/source-updated = **ergonomics/procedure**(잔존), ⓑ accepted-drift schema = **policy/schema**(DR-043 후 근거 약화). 묶으면 불편함이 schema 명분으로 과대 승격 |
| R0-Codex-F3 | must | backlog residual(HARNESS.md:92) stale — `AGENT-WORKFLOW.md 등 매 upgrade마다 [5]` 설명 갱신 필요. Done Criteria에 residual **supersede/downscope/update** 명시 |
| R0-Codex-F4 | must | 후보에 **"no new mechanism / monitor-only"**를 1급으로 추가(playbook-only보다 더 작은 결론: 보강 완료→closeout+future trigger만) |
| R0-Codex-F5 | must | DR-034 연결 = **non-promotion rationale**로 제한. 표본 2건 + 다음 release 후 정식 apply 남음 → 승격 조건 충족 주장 금지 |
| R0-Codex-N1 | nice | `--check output 개선`이 가장 현실적 future candidate(write helper보다 저비용) |
| R0-Codex-N2 | nice | future trigger를 숫자로: "DR-043 후 adopter upgrade 2건+ 동일 manual rebaseline 오류 반복" 또는 "AGENT-WORKFLOW 외 framework file에서 accepted-drift 보존 반복" |

### R0 — Driver Response (Claude)

코드 검증: backlog residual(HARNESS.md:92)이 `AGENT-WORKFLOW.md 등 매 upgrade마다 [5]`로 stale 확인. 5 must-fix 전부 사실·scope 축소 방향 — **전부 accept**.

| Finding | Decision | Response |
| --- | --- | --- |
| F1 | **accept** | 산출물 = Work 내부 `Disposition` section. brief는 후속 helper Work 개설 시에만 |
| F2 | **accept** | 잔여 위험을 ⓐ procedure/ergonomics ⓑ policy/schema 2축으로 분리(Scope/Disposition) |
| F3 | **accept** | Done Criteria에 backlog residual update/downscope 추가. residual 문구를 DR-043 반영해 갱신 |
| F4 | **accept** | 후보에 "no new mechanism / monitor-only" 1급 추가, **기본 결론으로 설정** |
| F5 | **accept** | DR-034는 non-promotion rationale만("shadow baseline 절차 유효" 수준). 승격은 다음 release 후 spring 정식 apply/추가 adopter까지 대기 |
| N1 | **accept** | `--check output 개선`을 유일한 low-cost future candidate로 표시 |
| N2 | **accept** | numeric trigger 명시 |

**Default decision (suggested wording 반영):**
- helper/schema 지금 구현 안 함.
- DR-043 + playbook/Layer T 보강을 알려진 AGENT-WORKFLOW accepted-drift case에 충분한 것으로 간주.
- low-cost 문서/output-hint 후보만 유지. 단, DR-043 후 adopter upgrade에서 동일 operator 오류 반복 또는 AGENT-WORKFLOW 외 framework file accepted-drift 반복이 관측되면 그때 후속 Work.

R0 verdict: conditional → **전부 accept로 해소**. 기본 결론 = **defer(playbook-only/monitor-only)**. Work를 disposition note로 축소.

### Round Log

| Round | Driver | Reviewer | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Codex | plan review | conditional(전부 accept, defer-default) | closed |
| R1 | Claude | Codex | result review | approve | closed |

### R1 — Reviewer Findings (Codex) + Driver Response

Verdict: **approve**. must-fix 없음. Disposition이 실제 defer/monitor-only로 읽히고, 2축 분리·residual downscope·DR-034 non-promotion 모두 보수적, doc-only(코드 0) 확인.

| ID | Decision | Response |
| --- | --- | --- |
| R1-Codex-N1 (brief 흔적) | **accept** | Plan/Verification의 `docs/briefs/`·`(design)brief` 흔적을 "Work 내부 Disposition만"으로 정리 |
| R1-Codex-RR (trigger 기록) | **accept** | trigger 기록 기준(path·command·원인) 명시해 과잉 발동 방지 |

R1 verdict: **approve**. cross-review(R0/R1) 종료.

### R1 — Result Review Relay Packet

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** Disposition 결과 (Work 내부) + backlog residual downscope. branch `feature/chore-20260624-003-upgrade-helper-design`, uncommitted.

**Delta Since R0:** R0 must-fix 5 + nice 2 전부 accept. 산출물 = Work 내부 `Disposition`(brief 아님), 2축 분리, monitor-only 기본 결론, residual downscope, DR-034 non-promotion.

**Current State (doc-only, 코드 변경 0):**
- Work `Disposition` section: 2축(ⓐ procedure/ergonomics ⓑ policy/schema) 평가, monitor-only 기본 결론, numeric future trigger, DR-034 non-promotion
- `docs/backlog/HARNESS.md` residual: monitor-only/defer로 downscope + DR-043-stale 문구 갱신 + trigger 명시
- DR 신규/승격 없음, 도구/schema 없음

**Validation:** doc-only — `git diff --check`, 링크/일관성. `--check`/invariant N/A(코드 변경 없음).

**Must Check:**
1. 결론이 실제로 "defer/monitor-only"로 읽히는가, 아니면 도구 정당화처럼 보이는가(R0 residual risk).
2. 2축 분리가 명확한가 — ⓐ 불편함이 ⓑ schema 명분으로 새지 않는가.
3. backlog residual downscope가 stale 없이 정합한가(DR-043 반영).
4. DR-034 non-promotion 문구가 충분히 보수적인가(승격 암시 없는가).
5. future trigger(numeric)가 실행 가능한가 — 무엇이 충족되면 누가 후속 Work를 여는지 명확한가.

**Do Not Re-litigate:** defer 기본 결론, design-only scope, DR-034 Draft 유지 — 확정.

**Reviewer Posture:** 결론이 보수적인지, 도구 명분이 새는지 의심. speculation 표시.

**Output Contract:** Verdict(approve/conditional/request-changes/reject) · must-fix · nice-to-have · residual risk.
