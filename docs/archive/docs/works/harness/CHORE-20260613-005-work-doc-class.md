# CHORE-20260613-005 — work-doc.md Class Recategorization

## Summary

`skills/workflow/work-doc.md`는 현재 `skills/workflow/*.md` glob으로 scaffold default에 포함돼 모든 target에 배포된다.
파일 내용(Design System, Tone & Manner, Presentation Deck Principles, Blueprint Format, PPTX 자동화)은 전형적인 product-track 산출물 생성 workflow이며, harness core 상태 관리와 무관하다.
이 Work에서 DR-021 A/B-class boundary 기준으로 class를 판정하고, 필요 시 scaffold wiring만 최소 조정한다.

## Metadata

| Field | Value |
| --- | --- |
| ID | CHORE-20260613-005 |
| Type | CHORE |
| Cluster | W3. Workflow IA Diet |
| Risk | L2 |
| Dependency | CHORE-20260612-010 (classification direction 완료, work-doc은 follow-up으로 지정) |
| Branch | `feature/chore-20260613-005-work-doc-class` |
| Status | Archived |
| actual_end | 2026-06-13 |

## Scope

**In scope:**

- `skills/workflow/work-doc.md` A/B-class 판정 (DR-021 기준)
- 판정 결과에 따른 `scripts/create-harness.sh` scaffold wiring 최소 조정
- adapter cascade (`.claude/commands/work-doc.md`, `.agents/skills/workflow-work-doc/SKILL.md`) 동일 tier 이동
- **[R0-F1 추가]** default shipped pointer 2종 정합 처리: `docs/HARNESS-QUICK-REFERENCE.md`, `skills/workflow/README.md`
- **[R0-F2 / R1-F1 반영]** `.cursor/rules/workflow.mdc` — scaffold conditional generation: default target에서 work-doc routing row 제거, optional/source는 원본 유지
- Work index 갱신, backlog 항목 완료 처리

**Non-goals:**

- `work-doc.md` 내용 수정 없음
- docs 물리 레이아웃 이동 없음 (DR-021 2026-06-10 note — reversal cost 큼)
- `/work-doc` workflow 기능·절차 변경 없음
- `.cursor/rules/workflow.mdc` source 파일 수정 없음 (net zero change). scaffold 조건부 생성만 사용
- broad W3 canonical restructure 미포함
- trigger family simplification 미포함

## Background

### 현재 배포 경로

```bash
# scripts/create-harness.sh line 534-536
for f in "${TEMPLATE_ROOT}"/skills/workflow/*.md; do
  adapt "$f" "${TARGET_ROOT}/skills/workflow/$(basename "$f")"
done
```

`work-doc.md`는 예외 처리 없이 모든 scaffold target에 기본 배포된다.

### 파일 내용 요약 (243줄)

| Phase | 내용 |
| --- | --- |
| Phase 1 | Brief Alignment — Purpose / Audience / Format / Template |
| Phase 2 | Targeted Context Loading + Web Research |
| Phase 3 | Deterministic Output Routing + Blueprint-First Policy |
| Phase 4 | **Design System & Typography / Tone & Manner / Presentation Deck Principles / Report & Brief Principles / PPTX Tooling** |
| Phase 5 | Verification Checklist (12개 항목, 프레젠테이션 품질 기준) |
| Phase 6 | Delivery Handshake |

Phase 4가 전체 분량의 절반을 차지하며, 내용은 "임원 보고 자료 제작"에 특화된 product-track 기준이다.

### DR-021 A/B-class 기준

- **A-class (scaffold default):** harness 세션 운영·상태 관리·workflow 실행에 필수인 canonical 절차
- **B-class (optional/source-only):** product-track 특화이거나 core 없이 선택적으로 사용

### CHORE-20260612-010 인계 내용

Decision Grid에서 명시: `work-doc.md` class recategorization = **"Follow-up, not this Work"**. prompt README / scaffold wording 보정과 무관하게 별도 Work로 처리.

## Plan

### Phase 1 — Class Judgment

DR-021 기준으로 A/B 판정한다.

**판정 기준:**

| 질문 | 평가 |
| --- | --- |
| harness 세션 운영에 필수인가? | No — status 관리, work tracking, 상태 기계와 무관 |
| 모든 adopter target에 기본 필요한가? | No — 발표 자료가 필요 없는 prod-only repo에는 dead weight |
| content가 core workflow surface인가? | No — Design System, Tone & Manner, PPTX는 product-track 특화 |
| source-only로 두면 adopter에게 가치가 사라지는가? | No — `--with-optional`로 opt-in 가능 |

**예비 판정: B-class**

**Tier 결정:**

| 옵션 | 설명 | 적합성 |
| --- | --- | --- |
| `--with-optional` | 기존 optional pack 플래그 재사용, target opt-in 가능 | **선호** — 가치는 있으나 모든 target에 불필요 |
| source-only | source에만 존재, target에 미배포 | 과도 — 일반적 유용성 있음 |

**예비 Tier: `--with-optional`**

**Adapter cascade 판단:**

adapter(`.claude/commands/work-doc.md`, `.agents/skills/workflow-work-doc/SKILL.md`)가 canonical 없이 target에 배포되면 `/work-doc` 호출 시 hard-stop이 발생한다.
따라서 **adapter도 canonical과 같은 tier로 이동**해야 일관성이 유지된다.

| Surface | 현재 | 이동 후 |
| --- | --- | --- |
| `skills/workflow/work-doc.md` | default | `--with-optional` |
| `.claude/commands/work-doc.md` | default (명시적 loop) | `--with-optional` |
| `.agents/skills/workflow-work-doc/SKILL.md` | default | `--with-optional` |
| `.cursor/rules/workflow.mdc` | source-only OR default pointer | pointer 유지 (conditional note 추가 가능) |

### Phase 2 — Scaffold Wiring

1. `scripts/create-harness.sh`의 `skills/workflow/*.md` loop에서 `work-doc.md`를 exclude한다.
2. `--with-optional` block에 `work-doc.md`와 adapter 2종을 추가한다.
3. generated README optional rows에 `/work-doc` 언급 추가 (필요시).

### Phase 3 — Cascade Verification

- `bash -n scripts/create-harness.sh` — syntax
- scaffold dry-run default: `work-doc.md` 및 `work-doc` command가 target에 없음 확인
- scaffold dry-run `--with-optional`: 세 파일 모두 target에 있음 확인
- `run-harness-checks.sh --tier0` (있으면)
- `check-shipped-dr-closure.sh` — work-doc adapter가 scaffold에서 빠지므로 shipped DR reference 영향 없는지 확인

## Files

| File | Change |
| --- | --- |
| `scripts/create-harness.sh` | work-doc 3종(canonical + 2 adapters)을 default에서 `--with-optional`으로 이동 |
| `docs/HARNESS-QUICK-REFERENCE.md` | `/work-doc` Command Taxonomy row에 `(optional)` 표시 추가 |
| `skills/workflow/README.md` | `/work-doc` row에 `(--with-optional)` 주석 추가 |
| `.cursor/rules/workflow.mdc` | source 변경 없음 (net zero). scaffold: default target에 filtered 버전 생성(work-doc row 없음), optional/source는 원본 그대로 |
| `docs/works/harness/CHORE-20260613-005-work-doc-class.md` | 이 파일 |
| `docs/works/harness/README.md` | Active row 추가 |
| `docs/backlog/HARNESS.md` | `work-doc class 재검토` 항목 완료/Done 처리 |

## Verification

```bash
# 1. Syntax
bash -n scripts/create-harness.sh

# 2. dry-run output 검사 (dry-run은 파일을 생성하지 않으므로 "create:" 목록으로 판정)
# default: work-doc 3종이 create 목록에 없음
bash scripts/create-harness.sh --dry-run work-doc-def /tmp/awh-def 2>&1 \
  | grep "create:.*work.doc" \
  && echo "FAIL: work-doc in default" || echo "PASS: work-doc absent from default"

# optional: work-doc 3종이 create 목록에 있음
bash scripts/create-harness.sh --dry-run --with-optional work-doc-opt /tmp/awh-opt 2>&1 \
  | grep "create:.*work.doc"
# 위 출력에 skills/workflow/work-doc.md, .claude/commands/work-doc.md, workflow-work-doc/SKILL.md 3줄이 나와야 함

# 3. Cursor routing — source-side logic 검증
# default filtered: work-doc row 없음
grep -v "work-doc" .cursor/rules/workflow.mdc | grep "work-doc" \
  && echo "FAIL: row survived filter" || echo "PASS: default filter removes work-doc row"
# source/optional: work-doc row 존재
grep "work-doc" .cursor/rules/workflow.mdc && echo "PASS: source/optional has work-doc row"

# 4. Pointer annotation 확인 (source 파일)
grep "work-doc" docs/HARNESS-QUICK-REFERENCE.md
grep "work-doc" skills/workflow/README.md

# 5. shipped DR closure
bash scripts/tests/check-shipped-dr-closure.sh 2>/dev/null || echo "N/A"
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — scaffold wiring + tool surface cascade |
| Reversal cost | Low — scaffold 1~2줄 수정. 파일 자체는 source에 남아 있어 revert = loop 복원 |
| 기존 adopter 영향 | 이미 scaffold한 target은 work-doc.md가 남아 있음. 신규 scaffold만 영향 (breaking only for new installs) |
| Adopter upgrade 영향 | DR-021 adopter upgrade 메커니즘(CHORE-20260611-010)에 따라 drift로 표시되나 functional regression 없음 |
| workflow 기능 | source에서 `/work-doc` 계속 사용 가능. target optional 적용 시 동일 |

## Open Questions

| ID | Question | Default |
| --- | --- | --- |
| OQ-1 | `.cursor/rules/workflow.mdc`의 work-doc pointer를 conditional note로 보강할 것인가? | **결정: scaffold conditional generation** (R1-F1 반영). source는 work-doc row 유지. scaffold default target에는 `grep -v work-doc` filtered 버전 생성. optional은 원본. source repo는 항상 원본 |
| OQ-2 | `--with-optional` generated README에 `/work-doc`를 언급할 것인가? | Codex R0-OQ-3: nice-to-have, not gate-worthy. `HARNESS-QUICK-REFERENCE.md` / `skills/workflow/README.md` annotation으로 충분 |
| OQ-3 | `.agents/skills/workflow-work-doc/`의 scaffold copy path 확인 필요 — commands loop와 같은 방식인가? | **확인 완료** — `for skill_dir in .agents/skills/*/` 별도 loop, commands와 동일한 glob 방식. 두 loop 모두 exclude 필요 |

## Done Criteria

- [x] DR-021 기준 B-class 판정 완료. 판정 근거가 Round Log에 기록됨
- [x] scaffold wiring 수정 완료: default에서 제거, `--with-optional`에 추가 (canonical + 2 adapters)
- [x] shipped pointer 2종 정합 처리: `HARNESS-QUICK-REFERENCE.md` `(optional)` 표시, `skills/workflow/README.md` `(--with-optional)` 주석
- [x] `.cursor/rules/workflow.mdc` scaffold 조건부 생성: default는 filtered(work-doc row 없음), optional/source는 원본 유지
- [x] dry-run output verification: default PASS (3종 create 목록 없음 + Cursor row absent), optional PASS (3종 create 목록 있음 + Cursor row present)
- [x] backlog `work-doc class 재검토` 항목 Done 처리 완료
- [x] Codex R0 plan review + R1 result review 기록

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-005-work-doc-class` |
| State machine | END |

## Codex R0 Review Request

Codex R0 plan review 요청: CHORE-20260613-005 work-doc.md Class Recategorization

Plan 최소 포함 항목 체크:

- Scope / Non-goals: 위 참조
- Files: 위 참조
- Verification: 위 참조
- Risk / Reversal Cost: 위 참조
- Open Questions: OQ-1~3

Review focus:

1. B-class + `--with-optional` tier 판정이 DR-021 기준에 비추어 타당한가?
2. adapter cascade (commands + agents/skills) 동일 tier 이동 결정이 적절한가? source에 남기는 다른 선택지와 비교.
3. `.cursor/rules/workflow.mdc` pointer를 이번 Work에서 건드리지 않는 결정이 타당한가?
4. Scope가 scaffold wiring 수정 + cascade 확인으로 충분히 좁은가? broad W3 restructure로 번질 위험이 있는가?
5. Verification이 default / optional / adapter cascade를 모두 커버하는가?
6. Open Questions가 빠뜨린 결정 지점이 있는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Open Questions
- OQ-...

Review Questions
| Question | Answer |
| --- | --- |
| B-class + --with-optional 판정이 DR-021 기준에 타당한가? | ... |
| adapter 동일 tier 이동 결정이 적절한가? | ... |
| .cursor/rules/workflow.mdc 미변경 결정이 타당한가? | ... |
| scope가 충분히 좁은가? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | **Conditional Hold → 반영 완료** | B-class + `--with-optional` 방향 타당. Must-fix 3개: F1(shipped pointer 2종 stale ref — HARNESS-QUICK-REFERENCE/skills README 미포함), F2(.cursor/rules/workflow.mdc always-shipped → missing-file route 설계 필요), F3(verification depth 부족 — Codex skill/Cursor/pointer surface 누락). | F1: Files에 HARNESS-QUICK-REFERENCE.md, skills/workflow/README.md 추가. F2: workflow.mdc work-doc row 제거(Option A)로 초기 반영. F3: verification에 absent/present 검증 4항목 추가. OQ-1/2 결정 완료 |
| R1 | Codex | **Hold → 반영 완료** | F1: Cursor routing 회귀 — workflow.mdc row 삭제가 source/optional 모두 깨뜨림. Claude/Codex 경계는 정확. F2: optional target positive Cursor routing 검증 누락(F1 슬립 원인). F3(NTH): backlog line 156 stale follow-up 문구. | F1: workflow.mdc row 복원 + scaffold에서 default용 filtered 생성(grep -v) / optional용 원본 분기. F2: Work file verification에 positive Cursor routing 검증 추가. F3: backlog line 156 갱신 |
| R1b | Codex | **Conditional Hold → 반영 완료** | F1(Must-fix): Work SSoT(Scope line 28, Non-goals line 36, Files line 134)가 "row 제거"로 기록되어 실제 conditional generation과 불일치. F2(Must-fix): Verification block이 dry-run 후 ls/grep on disk — dry-run은 파일을 생성하지 않아 항상 PASS. | F1: Scope/Non-goals/Files/OQ-1을 conditional generation 설계로 갱신. F2: Verification을 dry-run output 검사 + source-side logic 검증으로 교체 |
