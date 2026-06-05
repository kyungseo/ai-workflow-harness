---
id: CHORE-20260605-005
priority: P1
status: Done
risk: Medium
scope: DR-021(source/target boundary) 적용 — Optional source pack(HARNESS-ARCHITECTURE·HARNESS-MAINTAINER-GUIDE·WORKFLOW-MANUAL·확장 prompt)을 default scaffold에서 제외하고 opt-in flag로 전환. D4 heavy-doc dangling(MAINTAINER-GUIDE→DR-020, WORKFLOW-MANUAL→DR-001) 해소. core→optional 참조 정합성 보존. PQ-5/OQ-7(scaffold PLAN Roadmap Lifecycle propagate) 판단. canonical+adapter·command rename·breaking 변경은 제외(slice #13)
appetite: 2d
planned_start: 2026-06-05
planned_end: 2026-06-07
actual_end: 2026-06-05
related_dr: [DR-021, DR-023]
related_troubleshooting: []
---

# CHORE-20260605-005: Scaffold Minimal Output (DR-021 적용)

## Top Summary (결론 먼저)

- **목표:** DR-021 "Optional source pack = default 제외"를 scaffold에 실제 적용. default output을 A-class core + B-class seed로 축소해 target context weight를 줄이고, D4 heavy-doc dangling을 근원 제거.
- **핵심은 "복사 중단"이 아니라 "참조 정합성":** optional 3 docs를 단순 제외하면 core 문서가 그 docs를 가리키는 **31곳 경로 참조**(HARNESS-PROTOCOL ×16, health.md ×14, AGENT-WORKFLOW ×1)가 minimal target에서 dead link가 된다. 같은 copied 문서가 source(optional 있음)와 minimal target(optional 없음) 양쪽에서 valid해야 한다.
- **3축:** ① **flag + 제외** — optional pack을 opt-in(`--with-optional` 등)으로, default 제외. ② **참조 정합성** — 31곳을 "Optional pack에 속하며 minimal scaffold에 없을 수 있음" 규약으로 흡수(per-row 개별 수정 vs marker 한 줄, 결정 필요). ③ **companion DR** — opt-in 시 optional docs가 부르는 DR-001/DR-020 동반 복사(아니면 1b 테스트 FAIL).
- **PQ-5/OQ-7:** 생성 target PLAN.md seed에 §7-a Roadmap Lifecycle를 propagate할지 판단(slice 4가 이 slice로 미룸).
- **비목표:** canonical+adapter 전환, command rename, manifest.json schema, breaking 변경(slice #13). 물리 디렉토리 분리(DR-021이 보류).
- **enforcement:** scaffold 출력 변경은 generated surface를 바꾸는 breaking 가능성 → temp 실제 생성 + 1b 불변식 테스트로 양쪽 모드(default/`--with-optional`) green 확인.

## Context Manifest

| 순서 | 파일 | 섹션/라인 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-021-source-target-boundary.md` | Decision 표(A/B/Optional), Consequences | 적용 대상 방향, "default 제외 — source link 또는 명시 flag" |
| 2 | `scripts/create-harness.sh` | optional docs 복사(`:206-208`), prompt 루프(`:360-371`), Spring 조건(`:373-388`), 생성 README(`:392-420`), 생성 PLAN seed(`:660-715`) | 실제 제외·flag 삽입 지점 |
| 3 | `scripts/tests/check-scaffold-invariants.sh` | `core_files()`/`optional_files()`/[1r] REPORT 분기 | 모드별 불변식 재정의 |
| 4 | `docs/HARNESS-PROTOCOL.md` | cascade matrix(`:166`,`:325`,`:353`), Context Routing(`:7`,`:168`,`:177`) | optional 참조 16곳 — 정합성 대상 |
| 5 | `.claude/commands/health.md` | cascade audit | optional 참조 14곳 — 정합성 대상 |
| 6 | `docs/AGENT-WORKFLOW.md` | Context Routing `:68`(WORKFLOW-MANUAL 줄) | optional 참조 1곳 |
| 7 | `docs/PLAN.md` | §5 Scope(Optional/Kept As Core), §7-a Roadmap Lifecycle | source는 optional을 "Kept As Core"로 유지 — target만 제외라는 비대칭 근거 |

## Defect/Scope Inventory (실측)

| # | 항목 | 근거 |
| --- | --- | --- |
| S1 | optional 3 docs가 default 복사됨 | `create-harness.sh:206-208` (ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL 무조건 adapt) |
| S2 | 확장 prompt(session-start 외 ~20종)가 generic에도 복사됨 | `create-harness.sh:360-371` copy_prompt 루프(PROFILE 무관) |
| S3 | D4 dangling: MAINTAINER-GUIDE→DR-020, WORKFLOW-MANUAL→DR-001 (둘 다 미복사) | `grep DR- optional docs`; 1b 테스트 [1r] REPORT 항목 |
| S4 | core→optional 경로 참조 31곳 → minimal target dead link 위험 | HARNESS-PROTOCOL 16, health.md 14, AGENT-WORKFLOW 1 |
| S5 | 생성 README 파일표가 ARCHITECTURE/MAINTAINER-GUIDE/WORKFLOW-MANUAL/BOOTSTRAP를 나열 | `create-harness.sh:392-420` |
| S6 | 생성 target PLAN seed에 §7-a Roadmap Lifecycle 없음(slice 4 soft ref와 비대칭) | `create-harness.sh:660-715` |
| H1 | (housekeeping) Work index README에 CHORE-20260605-004 Active/Done 중복 row | `docs/works/harness/README.md:10` vs `:16` |

## Plan

### A. Optional pack flag + 제외 (S1·S2)

1. `--with-optional`(opt-in, default OFF) flag 추가. DR-021 "default 제외" → minimal이 default, full은 명시.
2. optional 3 docs 복사(`:206-208`)를 flag 조건부로.
3. 확장 prompt 복사(`:360-371`)를 session-start 3종 + README는 항상, 나머지는 flag 조건부로 분리.
4. Spring profile은 이미 `PROFILE==spring-boot` 조건부 → 변경 없음(이미 default 제외).

### B. 참조 정합성 (S4·S5) — **R17 확정: A2 + fallback marker**

- 31곳을 per-row 수정하지 않고, **각 copied surface 블록 상단마다** 2-part marker 1개씩 삽입(한 문서에만 넣으면 다른 surface는 여전히 dead처럼 보임):
  - (1) optional pack 대상(`HARNESS-ARCHITECTURE`/`HARNESS-MAINTAINER-GUIDE`/`WORKFLOW-MANUAL`)은 minimal scaffold에 없을 수 있음
  - (2) 없으면 해당 cascade/참조는 N/A이며, 필요 시 `--with-optional` 또는 source repo 문서를 참조
- marker 위치: ① `HARNESS-PROTOCOL.md` cascade matrix + Context Routing, ② `.claude/commands/health.md` cascade 블록, ③ `docs/AGENT-WORKFLOW.md` Context Routing — 3개 surface 각각.
- 생성 README 파일표(S5)는 default에서 optional row 제거 또는 "(opt-in)" 표기.

### C. companion DR 복사 (S3) — opt-in 모드 한정

- `--with-optional` 시 DR-001, DR-020도 복사 + decisions/README seed에 행 추가(아니면 1b [3] closure FAIL). → PQ-C.

### D. 생성 PLAN Roadmap Lifecycle propagate (S6) — **R17 확정: propagate 안 함**

- 생성 target PLAN seed는 B-class project-state seed 골격 그대로 유지(Roadmap Lifecycle 미주입). slice 4가 copied 문서에 심은 PLAN lifecycle 참조는 generic("if present")이라 target에서 dead가 아님 → 검증만. target-local PLAN lifecycle 도입은 OQ-7로 별도 scaffold PLAN/template slice에서 결정. → PQ-D.

### E. 1b 불변식 테스트 갱신 (S3)

- default 모드: optional 미존재 → [1r] REPORT 항목 자연 소멸 확인.
- `--with-optional` 모드: optional 존재 + DR-001/020 동반 → [1]·[1r]·[3] 모두 green.
- 테스트가 두 모드를 모두 도는지(인자/env) 결정.

### F. housekeeping (H1)

- Work index README의 stale CHORE-20260605-004 Active row 1줄 제거.

### 결정 필요 (Codex) — 아래 Plan-Level Open Questions PQ-A~D

## Done Criteria

- [x] `--with-optional` flag 추가, default scaffold가 optional 3 docs·확장 prompt 제외 (S1·S2)
- [x] core→optional 참조가 minimal target에서 dead link 아님 — active cascade surface에 marker(blockquote: PROTOCOL·AGENT-WORKFLOW·health cmd+skill / inline: QUICK-REFERENCE·record-decision cmd+skill). 예시·이미 conditional ref는 유지 (S4·PQ-A·D-3)
- [x] 생성 README 파일표·footer가 default output과 일치 ([4] 검사 PASS) (S5·D-5)
- [x] `--with-optional` 시 DR-017/DR-020 동반 복사(transitive closure) + decisions/README seed 정합; default minimal에는 미포함 (S3·PQ-C·D-1·D-2)
- [x] PQ-D(R17): 생성 PLAN seed에 Roadmap Lifecycle 미주입 유지 (변경 없음 확인)
- [x] 1b 불변식 테스트가 default·`--with-optional` 양쪽 PASS (E)
- [x] Work index README H1 drift 정리(STATUS/dashboard 무변경)
- [x] `rg` minimal target — active cascade 참조는 marker 아래, 잔여는 예시/conditional로 분류 (D-3)
- [x] cascade 점검: canonical(PROTOCOL·AGENT-WORKFLOW·QUICK-REFERENCE)→tool-specific(health·record-decision cmd+skill mirror pair)→user-facing(README §10)→scaffold(create-harness·1b test) 정합. R18 Codex 재검증 PASS

## Verification

- `bash -n scripts/create-harness.sh` + `sh -n` (pre-commit)
- default temp 생성 → `scripts/tests/check-scaffold-invariants.sh <target>` PASS, optional 3 docs·확장 prompt 부재 확인
- `--with-optional` temp 생성 → 같은 테스트 PASS(DR-001/020 동반으로 dangling 0)
- `git diff --check`, 링크/stale phrase 점검

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Work 파일 + plan 작성, Codex 검토 대기 | Done |
| CP1 | PQ-A~D 합의(Codex round R17) | Done |
| CP2 | A(flag+제외) + C(companion DR closure DR-017/020) 구현 | Done |
| CP3 | B(참조 정합성 marker) + D(PLAN propagate 안 함) + S5 README 반영 | Done |
| CP4 | E(1b 테스트 양쪽 모드 PASS) + F(housekeeping) + 검증 | Done |
| CP5 | Codex 결과 검토(R18) → /close → commit → PR | Done |

## Cross-Agent Review And Discussion

이 섹션은 Claude↔Codex가 이 slice 계획을 검토/논쟁/합의하는 SSoT다.
각 round는 아래 Round Log에 누적하고, 합의는 Consensus Log에, 미해결은 Plan-Level Open Questions에 둔다.

### Round Log

| Round | 주체 | 요지 | 반영 |
| --- | --- | --- | --- |
| R16 | Claude | slice #9 plan 초안: flag+제외 / 참조 정합성 / companion DR / PLAN propagate 4축, PQ-A~D 제기 | 본 문서 |
| R17 | Codex | PQ-A/B/C 동의, PQ-D 조건부 반대(propagate 안 함). marker는 surface별 상단 + 2-part(부재+fallback), companion DR은 opt-in 한정·default 미포함, H1은 Work index만 | Plan B/D·PQ status·Consensus Log |
| R18 | Codex | 구현 결과 검토: D-1~D-5 전면 동의. P2 1건(header comment companion DR stale: DR-001/020→DR-017/020) 지적. 양쪽 모드 1b·bash -n/sh -n·diff --check 재검증 PASS 확인 | header comment 수정, Consensus Log |

(R-번호는 Phase 2 cross-agent 연속 카운터를 잇는다. slice 4가 R15에서 종료.)

### Codex Plan Review (R17)

- **PQ-A:** A2 동의. marker에 (1) "minimal scaffold에 없을 수 있음" + (2) "없으면 N/A, 필요 시 `--with-optional`/source repo 참조" 둘 다 필수. stub 파일 생성은 B-class seed를 늘려 minimal 목적 약화 → 금지. marker는 **3개 surface 각각 블록 상단**(한 곳만 넣으면 다른 surface dead).
- **PQ-B:** opt-in 동의. `--with-optional` 채택(`--full` 과넓음, `--optional-pack` 명사라 flag 의미 약함).
- **PQ-C:** 동의. opt-in 한정 DR-001/DR-020 동반 + seed row. **default minimal에는 미포함**(companion DR만 남으면 surface 재팽창). ARCHITECTURE는 DR 참조 0 → 동반 없음. 원칙: "optional pack closure에 필요한 companion DR"이지 "관련 DR 무더기 복사" 아님.
- **PQ-D:** 조건부 반대. target `docs/PLAN.md`는 scaffold project-state seed(`create-harness.sh:660`), DR-021 B-class = target 소유·seed 골격만(`DR-021:17`). Roadmap Lifecycle은 source harness 운영 규칙 성격 → 이번 minimal slice에서 주입 시 경계 흐려짐. copied 참조는 generic("if present / PLAN lifecycle rule if configured") 유지. target-local 도입은 OQ-7로 별도 scaffold PLAN/template slice.
- **추가 risk:** marker 위치(3 surface 각각), 양쪽 모드 테스트 필수(default 부재 / opt-in 존재+DR closure / README 표 양쪽 일치), `rg "HARNESS-MAINTAINER-GUIDE|WORKFLOW-MANUAL|HARNESS-ARCHITECTURE"`로 minimal target 참조가 모두 marker 아래인지 확인. H1은 Work index만, STATUS/dashboard로 번지지 않게.

### Plan-Level Open Questions

| ID | Question | 결정 | Status |
| --- | --- | --- | --- |
| PQ-A | core→optional 31곳 참조를 minimal target에서 valid하게 만드는 전략 | **A2 + fallback marker**(R17): per-row 미수정, 3개 surface(HARNESS-PROTOCOL / health.md / AGENT-WORKFLOW) 블록 상단마다 2-part marker(부재 가능 + `--with-optional`/source fallback). stub 파일 금지 | Resolved(R17) |
| PQ-B | flag 이름/방향 | **`--with-optional`** opt-in, default minimal(R17) | Resolved(R17) |
| PQ-C | opt-in 시 companion DR 범위 | **DR-001·DR-020만**, `--with-optional` 한정 동반 + seed row. default minimal 미포함. ARCHITECTURE 동반 없음(R17) | Resolved(R17) |
| PQ-D | 생성 target PLAN seed에 Roadmap Lifecycle propagate (=OQ-7) | **propagate 안 함**(R17): target PLAN은 B-class seed 골격 유지. copied 참조는 generic 유지(검증만). target-local 도입은 OQ-7로 별도 slice | Resolved(R17) |

### Consensus Log

- **R17 합의:** PQ-A=A2+fallback marker(3 surface 각각), PQ-B=`--with-optional` opt-in, PQ-C=DR-001/020 opt-in 한정 companion, PQ-D=propagate 안 함(OQ-7 별도 slice). H1 housekeeping은 Work index README만(STATUS/dashboard 무변경). 양쪽 모드(default/`--with-optional`) 1b 테스트 필수.
- **R18 합의(구현 결과):** Codex가 D-1~D-5 전면 동의. D-2로 PQ-C companion이 DR-001/020 → **DR-017/020**(transitive closure)로 정정됨. D-3 marker 범위(active cascade만, 예시·conditional 유지) 동의. P2 1건(script header comment companion DR stale) 수정 완료. Codex 측 재검증(양쪽 모드 1b, bash -n/sh -n, diff --check) 모두 PASS.

## Discovery

- **D-1 (PQ-C 수정): DR-001은 false positive.** WORKFLOW-MANUAL의 `DR-001`은 cross-reference가 아니라 파일명 형식 예시(`ex. DR-001-token-storage.md`, 실제 DR-001은 archive됨)였다. 실제 companion은 MAINTAINER-GUIDE→**DR-020**뿐. → 예시를 `DR-013-work-file-spec.md`(항상 복사)로 교체.
- **D-2 (transitive closure): DR-020 → DR-017.** DR-020이 DR-017을 참조하고 DR-017은 자기참조만 → companion closure = **{DR-017, DR-020}**. opt-in 시 둘 다 복사해야 1b [1] hard-fail 통과.
- **D-3 (참조 범위 재측정): 초기 31곳 grep이 불완전.** minimal target에서 optional doc 경로를 참조하는 surface는 PROTOCOL/health/AGENT-WORKFLOW 외에도 QUICK-REFERENCE, NAMING-RULES, RECOVERY-VALIDATION, DR-014, record-decision(cmd+skill), debugging.mdc, claude-session-start까지 존재. 성격별 분류:
  - active cascade pointer(부재→breakage 오인 위험): HARNESS-PROTOCOL·AGENT-WORKFLOW·health(cmd+skill)는 blockquote marker, QUICK-REFERENCE·record-decision(cmd+skill)은 경량 inline marker.
  - filename example(live link 아님): NAMING-RULES·DR-014 — 유지.
  - 이미 conditional("기본 미포함"/"if"/"선택"): RECOVERY-VALIDATION·debugging.mdc·claude-session-start — 유지.
  - 판단 기준: "agent가 능동 cascade 감사 중 부재를 breakage로 오인할 수 있는가" → marker. 단순 예시·이미 optional 표기 → 무marker. (Codex 검토 대상)
- **D-4 (자기 함정 재발): "(DR-021)" 인용이 새 dangling 유발.** marker에 "(DR-021)"을 달았더니 target 미복사 DR-021을 가리켜 1b [1] FAIL — slice 4의 DR-022/024 인용과 동일 패턴. provenance는 Work/DR에만 두고 copied runtime 문구에서 DR 번호 인용 제거.
- **D-5 (README footer dangling): 생성 README footer가 `docs/WORKFLOW-MANUAL.md`로 링크.** minimal에서 dead → `HARNESS_DOC_LINK` 변수로 default는 `HARNESS-QUICK-REFERENCE.md`, opt-in은 `WORKFLOW-MANUAL.md`. [4] 검사가 포착.
