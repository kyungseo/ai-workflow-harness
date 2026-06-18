---
id: FEAT-20260618-001
priority: P1
status: Done
risk: L2
scope: Antigravity (Gemini 기반)를 4번째 지원 도구로 추가 — Codex .agents/ surface 재사용 piggyback
appetite: 3d
planned_start: 2026-06-18
planned_end: 2026-06-18
actual_end: 2026-06-18
related_dr: [DR-039]
related_troubleshooting: []
related_work: []
---

## Top Summary (결론 먼저)

- **목표:** 현재 Claude Code / Codex / Cursor 3개 도구를 대상으로 하는 harness에 **Antigravity (Gemini 기반)**를 4번째 지원 도구로 추가한다.
- **시발점:** 사용자가 Antigravity를 설치·사용 중이며 repo의 multi-agent 포지셔닝에 정식 편입을 요청. backlog `antigravity-support` candidate 착수.
- **통합 모델:** Antigravity는 Codex `.agents/skills/<name>/SKILL.md`(thin pointer 포함)를 자동 소비하므로 **command별 신규 어댑터 미러를 만들지 않고** Codex `.agents/` surface의 consumer로 올라탄다. 작업은 mechanically 가볍고 documentation-heavy.
- **비목표:** Antigravity 전용 per-command 어댑터 미러 생성, 구체 모델 버전(예: "Gemini 3.5 Flash") 문서 박제, parity 체크의 4자 확장(소비자라 불필요 예상).
- **역할/워크플로우:** A=Claude(author/driver), B=Codex(red team reviewer), C=Antigravity(reviewer). 사용자 지시 → A plan → B/C 검토(R라운드) → 합의 → A 구현 → B/C 결과 검토 → 사용자 최종 승인 → /work-close → commit → PR(--base develop) → merge.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `docs/backlog/HARNESS.md` | `antigravity-support` Details | 등록된 Task/Done Criteria/Verification |
| 2 | `CLAUDE.md`, `AGENTS.md` | Entry Contract | 진입점 도구 규정 — Antigravity 편입 지점 |
| 3 | `skills/workflow/*.md` | Tool adapter 테이블 | 도구 나열 SSoT (15개) |
| 4 | `docs/BEHAVIOR-PRINCIPLES.md` | §6 Harness Context Discipline | repo-外 self-audit scope에 Antigravity 경로 추가 |
| 5 | `scripts/create-harness.sh` | 도구 언급 | scaffold 생성물 정합 |
| 6 | `scripts/tests/check-surface-mirror-parity.sh` | — | parity 영향 검토(변경 없을 것으로 예상) |

Trigger: backlog candidate 착수 / user request: Antigravity 정식 지원 도구 편입

## Scope

통합 모델은 **Codex `.agents/` surface 재사용**이다. 신규 per-command 어댑터를 만들지 않는 이유: Antigravity가 `.agents/skills/<name>/SKILL.md`를 자동 검색·소비하고 thin pointer(Step 0 → canonical `skills/workflow/{name}.md`) 패턴을 동일 수행한다고 자체 답변. 따라서 작업의 본질은 "도구 나열 surface 전반에 Antigravity를 빠짐없이 추가 + 진입 경로 정합 + repo-外 self-audit 보강 + scaffold/README/GitHub description 정합 + DR 기록"이다.

정비 순서는 전 surface에서 **Claude → Codex → Antigravity → Cursor**로 통일한다.
라벨은 도구명 "Antigravity" 단독, 부연이 필요하면 generic "(Gemini 기반)". 구체 모델 버전은 stale 리스크로 미기재.

**실행 슬라이스 (R1 합의 반영):**

proof-gated 구조 — **S0(소비 증명)가 support 문구와 후속 scope를 gate한다.** commit staging: ① proof+Work 갱신 → ② docs/scaffold → ③ DR+GitHub desc.

- **S0 — Workflow consumption proof (선행 gate, commit ①):**
  - 진입 경로: **A안 확정(완료)** — root `AGENTS.md` fallback 정상, 추가 작업 0.
  - 잔여 증명: Step0→canonical 추적(≥1 command), 대표 workflow 2~3개 실측(연쇄 multi-step 1개 = `/work-plan` 또는 `/work-close`, async `run_command` 모델 하 블로킹/끊김 없이 완주하는지), 긴 canonical 문서의 800라인 `view_file` limit 영향 확인.
  - **gate 산출:** 결과로 support 문구 결정 — clean "supported" vs "supported (실행 모델 caveat 문서화 동반)".
- **S1 — 도구 나열 surface 전수 정합 (commit ②):** grep으로 Codex/Cursor 언급 파일 enumeration → entry contract(`CLAUDE.md`/`AGENTS.md`), canonical adapter 테이블(`skills/workflow/*.md`), user-facing(`README.md`, `docs/AGENT-WORKFLOW.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/HARNESS-QUICK-REFERENCE.md` 등)에 Antigravity 추가 + 순서 Claude/Codex/Antigravity/Cursor 통일. **DR-007 준수:** English-only surface(`AGENTS.md`/`CLAUDE.md`)와 Korean-primary surface 구분 적용.
  - **migration note(경량):** 기존 adopter는 이미 보유한 `.agents/` surface로 기능상 자동 상속됨 — 부족한 건 도구명 문서화뿐. "기능 자동 상속, 문서 언급은 정규 harness upgrade로 도달"을 명시하고 본 Work의 Done scope는 source repo + 신규 scaffold로 한정.
- **S2 — self-audit (commit ②):** BEHAVIOR §6에 `~/.gemini/antigravity`, `~/.gemini/config` 추가.
- **S3 — scaffold/parity (commit ②):** `create-harness.sh` 생성물 정합. `check-surface-mirror-parity.sh` **실분석** → 3-tool 하드코딩 여부 확인, false-positive 방지. invariant 결정: 최소 "supported-tools-list parity = judgment-only" 명시, 과하지 않으면 grep 자산 1개. PARALLEL-WORK-CONTROLS가 tool-enumerated면 Antigravity 추가, 아니면 한계 1줄만 기록(C-4 downgrade).
- **S4 — 외부 (commit ③, proof 후행):** GitHub description (`gh repo edit --description`).
- **S5 — DR (commit ③, proof 후행):** 통합 결정(Codex surface 재사용, 진입 경로 A안) + **decoupling/exit trigger**(Codex/Antigravity 파싱 규칙 분화 시 격리 조건) 기록. shipped surface에서 DR 인용 시 shipped-DR closure 확인.

## Done Criteria

- [x] S0-entry: 진입 경로 검증 — A안 확정(root `AGENTS.md` fallback, 추가 작업 0)
- [x] S0-proof: Step0→canonical ✓ / async run_command 단절 없음(reactive wakeup) ✓ / 800라인 무관 ✓ → **support 문구 = clean "supported"**
- [x] S1: entry contract(CLAUDE/AGENTS)·canonical adapter 표 12개·skills/workflow/README·README·AGENT-WORKFLOW·WORKFLOW-MANUAL·HARNESS-ARCHITECTURE·HARNESS-PROTOCOL·HARNESS-MAINTAINER-GUIDE·SCAFFOLD-ONBOARDING-GUIDE·SOURCE-REPO-OPERATIONS·prompts·cursor role rule·backlog에 Antigravity 추가, 순서 통일. **DR-007 준수**(English-only surface는 영어로 기재)
- [x] S1-migration: DR-039 Consequences에 "기존 adopter 기능 자동 상속 + 문서는 정규 upgrade 도달, Done scope=source+신규 scaffold" 명시
- [x] S2: BEHAVIOR §6 self-audit에 `~/.gemini/config`, `~/.gemini/antigravity` 추가 (§1 서두 도구 나열도 갱신)
- [x] S3: scaffold(create-harness.sh 생성물) 정합 + parity 스크립트 invariant 주석 명문화(코드 무변경, false-positive 0 실행 확인). PARALLEL-WORK-CONTROLS는 DR-039 Exit Trigger에 한계로 흡수(신규 룰 불필요 — C-4 downgrade)
- [x] S4: GitHub description — 문구 확정·사용자 승인 완료. 실행은 PR merge 직후 외부 meta action(`gh repo edit --description`)으로 수행 (git 파일 변경 아님)
- [x] S5: DR-039 기록 — decoupling/exit trigger + migration 포함, decisions/README 인덱스 추가, shipped-DR closure 통과
- [x] Cross-agent review(B=Codex, C=Antigravity) R1~R3 합의 + 사용자 최종 승인 완료

## Verification

- **S0-proof 실측:** Antigravity 세션에서 대표 workflow 2~3개 완주(특히 async run_command 하 연쇄 command 블로킹/끊김 여부), Step0→canonical 로드 추적, 800라인 limit에 걸리는 canonical 문서 유무 확인
- canonical → tool-specific → user-facing → scaffold cascade 점검
- 도구 나열 grep 전수: Codex/Cursor 언급 파일 대비 Antigravity 누락 0 확인
- **DR-007 점검:** English-only surface(`AGENTS.md`/`CLAUDE.md`)와 Korean-primary surface 언어 정책 정합
- `check-surface-mirror-parity.sh` 실행 결과 false-positive 0 확인
- `bash -n scripts/create-harness.sh`, `git diff --check`, stale phrase/link 점검
- DR 생성 시 `bash scripts/tests/check-shipped-dr-closure.sh`

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | Work 파일 생성, branch/STATUS 정합 | ✓ 완료 |
| 2  | S0 진입 경로 검증 (A안 확정) | ✓ 완료 |
| 3  | plan B/C 검토 라운드 R1 + 합의 반영 | ✓ 완료 |
| 4  | S0-proof: workflow consumption 실측 (gate) | ✓ 완료 (clean) |
| 5  | S1~S3 구현 (commit ②) | ✓ 완료 |
| 6  | S5 DR-039 + 선재 drift fix (사용자 결정: 이번 PR 포함) | ✓ 완료 |
| 7  | R2~R3 결과 검토 + 사용자 최종 승인 + /work-close | ✓ 완료 (S4는 merge 후 외부 action) |

## Next Actions

- ✓ S0-proof 완료(clean) / S1~S3 구현 완료 / S5 DR-039 완료
- ✓ R2 결과 검토: C(통과), B(P1/P2/P3 지적) 수용·반영 완료
- → B+C consensus 확정 → 사용자 최종 승인 대기
- ○ 승인 후: S4 GitHub description → `/work-close` → commit(② docs/scaffold + ③ DR 묶음) → PR(--base develop)
- ○ 선재 drift(`default-template-parity workflow_mdc`, work-brief row 누락) 별도 PATCH 등록

## Discovery

- **Backlog candidate 착수:** `docs/backlog/HARNESS.md`의 `antigravity-support` (Antigravity 4번째 지원 도구 추가) candidate 착수. backlog row에는 Work ID를 기입하지 않는다(병렬 NNN 충돌 방지). Active 표시는 develop merge 후 tracking-only commit으로 처리.
- **Antigravity 자체 규약 답변 (세션 기록):**
  - 진입: 전용 진입 파일 불요, `.agents/AGENTS.md` 자동 로드(Workspace Customizations Root)라고 답변 → 단, 본 repo는 root `AGENTS.md` 사용. **S0에서 실측 검증 필요.**
  - rules: 전용 `.mdc` 포맷 없음. `.agents/AGENTS.md` 내 텍스트 규칙 해석. global(repo-外): `~/.gemini/antigravity`(app data), `~/.gemini/config`(global customizations root).
  - skills: `.agents/skills/<name>/SKILL.md` Codex 포맷 그대로 자동 소비 + thin pointer 동일 수행.
  - 차이점: `view_file` 1회 최대 800라인 제한; `run_command` propose→사용자 승인→sandbox 비동기 실행 모델.
  - 라벨: "Antigravity" 권장, 모델은 부연.

### 선재 이슈 발견 (out-of-scope, 별도 보고)

`run-harness-checks.sh --all`에서 `default-template-parity (workflow_mdc)` FAIL 발견 — **이 Work과 무관한 develop 선재 drift**. 본질: source `.cursor/rules/workflow.mdc`의 `work-brief` routing row가 template default(`scripts/templates/default/.cursor/rules/workflow.mdc`)에 누락(work-brief 추가 시 template 미동기화). 두 workflow.mdc 모두 본 작업에서 미변경(HEAD 동일)이고 parity 체크 입력이 그 둘뿐임을 확인해 인과 분리 확정. surgical 원칙상 본 Work에서 수정하지 않고 별도 PATCH로 등록 제안.

## Cross-Agent Review And Discussion

역할: A=Claude (author/driver), B=Codex (red team reviewer), C=Antigravity (reviewer).
리뷰어는 내적 정합성을 넘어 **계획 방향 자체의 정당성**과 더 나은 대안, 필요 시 backlog 요구 자체를 비판적으로 검토한다.

### Round Log

#### R1 — plan review (2026-06-18)

**S0 실측 (C=Antigravity):** **A안 확정.** Antigravity가 세션 시작 시 자동 로드한 entry 파일은 root `AGENTS.md`(`.agents/AGENTS.md` 부재에도 fallback 정상). 인용: "Codex entry point for this repository." → **진입 경로 추가 작업 0.**

**S0-proof 실측 (C=Antigravity, 2026-06-18) — 전부 통과:**
- (a) Step0→canonical: `workflow-session-summary`/`workflow-work-plan` 모두 SKILL.md Step 0에서 canonical `skills/workflow/{name}.md`를 우선 `view_file` 로드 확인. ✓
- (b) async run_command 연쇄: propose→승인→sandbox 실행 중 idle 후 결과 도착 시 **reactive wakeup**으로 컨텍스트 유지·연쇄 절차(Pre-check 판정 등) 단절 없음. **C-2 리스크 불발.** ✓
- (c) 800라인 limit: canonical 문서 전부 200줄 미만(session-start 52 / session-summary 64 / work-plan 129) → 단일 `view_file` 정상. ✓
- **gate 산출: support 문구 = clean "supported" (실행 모델 caveat 불요).**

**B=Codex 지적:**
- (B-1, P1) 통합 모델 가정이 약함. S0가 entry auto-load만 검증하고 실제 workflow 소비 품질 미검증. `/session-start` 1개 인식으로 "정식 지원" 선언은 과함. Step0→canonical 추적·대표 workflow 2~3개·800라인 limit·command approval UX까지 보거나 "experimental consumer support"로 낮출 것.
- (B-2, P1) 기존 adopter migration 경로 누락. scaffold 정합만으론 source+신규 scaffold만 지원되고 기존 target은 미반영 → repo family 전체에서 support claim 불균등. migration note 추가 또는 Done Criteria에 "new scaffolds only, existing adopters deferred" 명시로 scope 축소.
- (B-3, P2) DR-007 언어 정책이 Done Criteria/Verification에 없음. English-only(`AGENTS.md`/`CLAUDE.md`)와 Korean-primary(docs/DR/GitHub desc) 동시 편집 → 누락 시 rework.
- (B-4, P2) 회귀 방지가 "parity 영향 확인" 수준으로 약함. 4자 parity 비목표는 이해되나 대체 불변식 필요: "supported tools list parity = judgment-only" 명시 또는 grep 검증 자산 추가, DR 생성 시 shipped-DR closure를 Verification에 포함.
- (B open Q) 2단계(compatibility proof → support scope 확정 → docs/scaffold/DR) 분리 권고. GitHub desc·DR는 discovery 통과 후 2차 commit으로.

**C=Antigravity 지적:**
- (C-1) 엔진 분화(drift) 위험. 향후 Codex/Antigravity 엔진 업데이트로 SKILL.md 파싱·interpolation·lookup 정책 어긋날 수 있음. DR에 "언제 격리(decouple)하는가" Exit Trigger 명시 권고. (Antigravity-specific override 룰 신설도 제안)
- (C-2) 실행 모델 차이로 인한 validation 실패가 최대 현실 리스크. `run_command` propose→승인→sandbox 비동기 모델 → 연쇄 command workflow(/work-plan, /work-close)에서 승인 지연·세션 끊김 가능. Done Criteria에 "비동기 루프 하 연쇄 command fail-safe 실측" 추가.
- (C-3) `check-surface-mirror-parity.sh` 영향 "변경 없을 것"은 가정. 스크립트가 3자 하드코딩이면 piggyback 예외 주석/검증 누락. S3에 스크립트 실분석 + false-positive 방지 포함.
- (C-4) 병렬 제어 부재. 동일 workspace에서 Codex+Antigravity 병렬 시 `.agents/`/상태 파일 공유 race condition 가이드 없음. HARNESS-PARALLEL-WORK-CONTROLS.md 보강 또는 한계 명시.

#### R2 — result review (2026-06-18)

**C=Antigravity 결과 검토 — 5개 관점 전부 통과:**
- ① 통합 표현("Codex surface 재사용") 정합: 진입 문서 + 12개 canonical 전반 일관, IA diet 유지. ✓
- ② supported-tools surface 누락 없음: maintainer guide/protocol/prompts/cursor rules/scaffold/troubleshooting/backlog까지 순서(Claude→Codex→Antigravity→Cursor) 동기화, parity 주석으로 회귀 방지. ✓
- ③ DR-039 Exit Trigger/Migration 합당: 3개 격리 트리거로 premature optimization 차단, migration scope surgical 통제. ✓
- ④ DR-007 준수: English-only/Korean-primary 혼재 없음. ✓
- ⑤ 선재 drift 별도 분리 타당: PATCH 격리 등록이 형상관리 원칙 부합. ✓
- **결론: 사용자 최종 승인 → commit/PR 진입 준비 완료.**

**C 추가 제안 (consensus 판단 대기):**
- (C-a) 실행 모델 차이(async run_command propose-approval) 명시를 향후 에이전트 편입 시 표준 템플릿화 — 칭찬성 방향 제안, 즉시 액션 없음.
- (C-b) Exit Trigger에 정량 임계치 메모 제안: 핵심 workflow(`work-plan` 등) 2회 연속 validation 실패 시 격리 DR 자동 개시 — backlog 메모 후보.

**B=Codex 결과 검토 — 3건 지적 (대체로 타당, 안 바뀐 live spec 포착):**
- (B-P1, P1) DR-039 "기존 adopter 기능 자동 상속"이 과잉. pre-DR-023/selective-migration target은 `.agents/skills/` 구조 부족 → 잘못된 지원 claim 위험.
- (B-P2, P2) "supported tools 빠짐없이"와 달리 live source 일부가 3도구 잔존: PLAN.md L22/L43, troubleshooting README L9/L18, agent-scope-approval-drift L13, DR-027 L26. scaffold/template은 4도구로 올렸는데 source live spec이 뒤처지면 새 drift.
- (B-P3, P2) Work 파일 Done/Checkpoints(완료)와 Next Actions(대기)가 충돌 → closeout 근거 약화.
- Notes: 바뀐 파일들의 "Codex surface 재사용" 표현·DR-007은 일관/정확. 선재 drift 별도 분리 타당.

#### R3 — targeted recheck (2026-06-18)

**B=Codex:** (P2) DR-027 L26 `environment` 예시가 아직 3도구 — README L18은 4도구로 올렸으니 spec SSoT(DR-027)도 맞춰야 정합. (P3) `agent-scope-approval-drift.md` Environment는 historical snapshot이면 유지 OK, 판단만.
- **author 판정:** R2-2 pushback **부분 정정 수용.** DR-027의 `{e.g. ...}`는 historical 기록이 아니라 forward-looking spec 예시 → README만 고치고 DR-027을 두면 내가 새 drift를 만든 것. **DR-027 L26 4도구로 수정.** `agent-scope-approval-drift.md`(L13/L86)는 사건 당시 snapshot이라 유지(반려 유지).

### Consensus Log

| # | 항목 | 판정 (author A) | 처리 |
|---|------|-----------------|------|
| 1 | S0 진입 경로 | **확정** | A안 — 진입 작업 0 (C 실측) |
| 2 | 소비 품질 증명 전 "정식 지원" 선언 (B-1, C-2) | **수용** | S0를 "workflow consumption proof"로 확장: entry✓ + Step0→canonical 추적 + 대표 workflow 2~3개(연쇄 multi-step 1개 포함, async run_command 모델 실측) + 800라인 limit 영향. 이 proof가 support 문구를 gate한다(clean "supported" vs "caveat 동반 supported"). |
| 3 | 2단계 분리 (B open Q) | **일부 수용** | 별도 2개 Work/PR로 쪼개지 않고 **단일 Work 내 proof-gated commit staging**으로: ① proof+Work 갱신 → ② docs/scaffold → ③ DR+GitHub desc. 사용자에게 full 2-stage 분리 선택지도 제시. |
| 4 | adopter migration (B-2) | **수용(경량)** | 핵심 관찰: Antigravity는 기존 adopter가 **이미 보유한** `.agents/` surface를 소비하므로 기능상 today 동작함 — 부족한 건 도구명 문서화뿐. → migration note로 "기존 adopter는 기능상 자동 상속, 문서 언급은 정규 harness upgrade로 도달"을 명시하고 Done Criteria scope를 source+신규 scaffold로 한정. |
| 5 | DR-007 언어 정책 (B-3) | **수용** | Done Criteria + Verification에 DR-007 점검 추가 (English-only vs Korean-primary surface 구분). |
| 6 | 회귀 불변식 (B-4, C-3) | **수용** | S3에서 `check-surface-mirror-parity.sh` 실분석. invariant 결정은 분석 후: 최소 "supported-tools-list parity = judgment-only" 명시, 과하지 않으면 grep 자산 1개. DR 생성 시 shipped-DR closure를 Verification에 포함. |
| 7 | decoupling/exit trigger (C-1) | **수용(DR 한정)** | DR에 "Codex/Antigravity 파싱 규칙 분화 시 격리 트리거" 명문화. **반려:** 지금 Antigravity-specific override 룰 신설은 premature(BEHAVIOR §2) — trigger 문서화로 충분. |
| 8 | 병렬 제어 (C-4) | **일부 수용 / downgrade** | push back: Antigravity는 신규 writable 공유 상태를 도입하지 않음(`.agents/skills/`는 read-only 소비; writable 공유 상태=STATUS/Work/branch는 이미 agent-agnostic으로 PARALLEL-WORK-CONTROLS가 커버). → HARNESS-PARALLEL-WORK-CONTROLS.md가 3-tool 하드코딩이면 Antigravity 추가, 아니면 신규 룰 없이 한계만 1줄 기록. |
| 9 | GitHub desc·DR 타이밍 (B open Q2) | **수용** | proof 통과 후로 후행 배치(commit ③). DR은 실측 결과를 반영해 작성. |
| R2-1 | DR-039 자동상속 과잉 (B-P1) | **수용** | DR-039 migration을 조건부로 한정: DR-023 구조 보유 adopter만 자동 상속, pre-DR-023/selective는 canonical/adapter inventory migration 선행 필요. "일괄 claim 아님" 명시. |
| R2-2 | live spec 3도구 잔존 (B-P2) | **부분 수용 + push back** | 수정: PLAN.md L22/L43(factual), troubleshooting README L18(environment **spec 예시**=forward-looking). **반려(history 보존):** agent-scope-approval-drift L13/L86·troubleshooting README L9(과거 incident 기록/인덱스)·DR-027 L26(Accepted immutable, live spec은 README). |
| R2-3 | Work tracking 충돌 (B-P3) | **수용** | Next Actions를 완료 상태로 갱신, Checkpoints/Done과 정합. |
| R2-4 | 실행모델 차이 템플릿화 (C-a) | **acknowledge, no-action** | AGENT-WORKFLOW §1에 이미 async run_command 명시. 향후 에이전트 편입 표준화는 별도 주제 — 즉시 액션 없음. |
| R2-5 | Exit Trigger 정량 임계치 (C-b) | **backlog 메모로 분리 (등록 완료)** | DR-039(Accepted)에 정량 임계치를 지금 박지 않음. HARNESS Deferred Ideas에 "Multi-agent Exit Trigger 정량 임계치" 등록 완료. |
| R3-1 | DR-027 spec 예시 3도구 잔존 (B-R3) | **수용 (R2-2 부분 정정)** | DR-027 L26 `environment` 예시를 4도구로 수정 — forward-looking spec 예시라 immutability/history 논리 비적용. README L18과 정합 복구. |
| R3-2 | 선재 drift fix 포함 (사용자 결정) | **이번 PR에 포함** | 사용자 승인하 scope 추가: `scripts/templates/default/.cursor/rules/workflow.mdc`에 `work-brief` routing row 추가 → `default-template-parity` PASS. `run-harness-checks --all` 전체 PASS(exit 0) 확인. |
