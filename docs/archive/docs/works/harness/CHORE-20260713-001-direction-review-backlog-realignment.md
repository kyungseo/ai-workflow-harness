---
id: CHORE-20260713-001
priority: P1
status: Archived
risk: L2
scope: 3주 휴면 후 재가동 점검. ① adopter evidence intake(spring UF-01~08 문제 분류 triage + 4-repo 실측 inventory — rfx-hub 재구축/1.2.1, toolstead 신규/1.4.0, upgrade 노동·drift·cascade defect 측정), ② S1→S2 structural trigger screen(go/no-go gate) 통과 축에 한해 4축(policy semantics / distribution·upgrade / tool projection / enforcement·runtime) retain/refactor/replace 판정, ③ backlog 재우선순위화로 이어 착수 가능한 상태 확보. 실제 리팩토링 실행은 별도 gated 후속 Work로 분리. cross-agent review(Claude driver / Codex red-team reviewer, R0 request-changes 반영).
appetite: 1.5d
planned_start: 2026-07-13
planned_end: 2026-07-14
actual_end: 2026-07-13
related_dr: [DR-021, DR-023, DR-028, DR-034, DR-042, DR-043]
related_troubleshooting: []
related_work: [CHORE-20260624-001, CHORE-20260624-003, CHORE-20260620-001]
---

# CHORE-20260713-001: Harness direction review + adopter evidence intake + backlog 재정렬

## Top Summary

source repo가 6/24 이후 3주간 휴면하는 동안 adopter 지형이 실질적으로 바뀌었다:

- `spring-modular-template`이 Upstream Harness Feedback **UF-01~08** 8건을 누적(6/25~7/4). source backlog는 6/24 정렬이 마지막 → **열흘치 adopter evidence만큼 stale**.
- `rfx-hub`가 재구축되어 살아 있다(backlog의 "finding 수집 후 삭제" 기록은 stale). harness **1.2.1** — 2개 minor 뒤처져 **실제 upgrade 수요** 발생. CHORE-20260624-003의 numeric trigger("adopter upgrade 2건+") 재평가 입력.
- `toolstead`(Skillstead, SessionCue 멀티 product)가 신규 adopter로 합류(1.4.0). adopter evidence set은 3개가 아니라 **4개**(ai-deck-compiler, spring-modular-template, rfx-hub, toolstead).

동시에 사용자 지시로 점검 관점을 확장한다: **기존 계획/DR/구조/upgrade 모델을 "결정됐으니 당연"하게 보지 않고**, agent 도구 발전(hooks, plan mode, plugin/marketplace, subagent, native memory) 속에서 장기적으로 버티는 구조가 되기 위해 **교정할 것 / 버릴 것 / 보완할 것**을 식별한다.

**중요(R0 반영):** driver의 사전 가설 "manual-first 유지 + 국소 개선, rewrite 불필요"는 R0에서 **단일 판정 축이 섞였다는 지적(F1)과 실측 근거 부족(F2)** 으로 기각됐다. 확정 결론이 아니라 **S1 실측 → gate → 축별(policy/upgrade·distribution/tool projection/enforcement) retain/refactor/replace 판정**으로 검증한다. 이 Work는 검토·정렬 Work이며, 전 축 no-go로 끝나도 UF intake + stale 해소만으로 가치가 성립하도록 scope를 bound한다.

## Scope

**모드:** Full Work (docs/backlog/brief 산출 중심, 코드/scaffold 변경 없음). 실행 리팩토링은 전부 후속 Work로 분리.

### S1. Adopter evidence intake + 실측 inventory

- **UF triage (문제 분류 우선, 해결책 선결정 금지 — R0-Codex-F4):** spring UF-01~08을 각각 **기존 row merge / 신규 row / dependency 연결 / defer(trigger 명시)** 로 disposition 기록 후 `docs/backlog/HARNESS.md` 반영. 각 UF는 먼저 "무슨 문제인가"로 분류하고 해결책은 후보로만 나열:
  - UF-01 = **product-owned CI seam 부재** 문제(starter stub는 해결 후보 중 하나이지 채택 결론 아님).
  - UF-02 = review 경계 점검 문제 — checklist 추가(문서 무게 증가) vs manifest-aware deterministic guard를 후속 Work에서 비교하도록 문제만 등록.
  - UF-06 = **canonical branch policy 변경**(auto-merge/deferred sync). thin-adapter화 후보(= projection 중복 제거)와는 파일만 겹치는 별개 문제 — **merge하지 않고 dependency로 연결**(같은 표면을 순차 변경하므로 착수 순서 조율만).
  - UF-08 = scaffold permission 결함 — 검토 결론과 무관하게 **quick-fix 후속 Work로 분리하되, deny 축소이므로 secret-file negative fixture + sanitized `.env.example` positive fixture를 필수 gate로 명시**.
  - UF-04→Spring option-pack feed-in(기존 명시), UF-03/05/07→P3 등록 또는 기존 항목 연계.
- **Adopter inventory 확장 매트릭스 (R0-Codex-F2):** 4 repo × (harness version · baseline 유형 pre-manifest/manifest · **실제 upgrade 횟수·소요 노동·수동 개입 스텝** · accepted/custom drift 수 · 실패/재작업 이력 · 사용 tool 표면 · evidence 채널). backlog "Adopter evidence set" 문단과 rfx-hub stale 기록 정정.
- **Mirror/projection 비용 실측:** tool 수가 아니라 **adapter 중복 양(라인/블록), cascade 누락·defect 이력(git log·troubleshooting 실측), surface별 실사용률**로 측정.
- rfx-hub 1.2.1→1.4.0 upgrade를 독립 후속 Work 후보로 등록할지 판단(CHORE-20260624-003 defer trigger 재평가 포함).
- **Agent-first upgrade 실험 (user-approved amendment, post-R0b):** rfx-hub 1.2.1→1.4.0 upgrade를 **최소 체크리스트 + "agent에게 현재 버전으로 upgrade" 방식**으로 수행하고, 소요 노동(수동 개입 스텝 수)·실패/재작업·결과 품질을 spring의 manifest-절차 upgrade(CHORE-20260624-001)와 대조해 축② evidence로 기록한다. 비교 한계(rfx-hub는 no-code로 spring보다 단순) 명시. rfx-hub repo 측 변경은 해당 repo의 branch/approval flow를 따르고, 이 Work는 측정 결과만 소유한다.

### S1→S2 Gate: structural trigger screen (go/no-go — R0-Codex-F3)

S1 실측치를 아래 사전 임계값에 대조해 **축별로** go/no-go를 기록한다. (임계값은 R0b에서 reviewer 확정 — 아래는 확정본.)

| 축 | go 조건(R0b 확정) |
| --- | --- |
| ① policy semantics | **독립 사례 2건+**(가능하면 2 repo 또는 2 session)에서 Approval/state machine 우회·단축이 material rework 유발, **또는** 정상 절차를 따랐음에도 policy 자체가 Work 완료를 막는 **재현 가능한 deadlock 1건+** |
| ② distribution·upgrade | **2건+ actual adopter upgrade에서 동일 manual step/operator error 반복**, **또는** upgrade model 자체에 기인한 material 실패·재작업 1건+ — 단 후자는 본 Work의 분석 gate만 열고 CHORE-20260624-003 helper/schema future trigger를 자동 충족하지 않음 |
| ③ tool projection | **독립 cascade 누락/defect 2건+**, **또는** 같은 tool-neutral normative block(3줄/불릿 이상)이 2개+ adapter에 복제, **또는** 어느 한 adapter의 non-boilerplate·tool-neutral normative line이 대응 canonical의 **25% 초과**(frontmatter·Step 0 pointer·entry mechanism·tool-specific hard stop은 비율에서 제외) |
| ④ enforcement·runtime | 같은 유형의 gate 부재 위반이 **분기당 2건+**, **또는** security/data loss/irreversible state change/protected-surface bypass에 해당하는 **material incident 1건+** |

**Screening boundary (R0b):** 이 임계값은 bounded S2 분석을 여는 **screening threshold**이지 `refactor / replace`를 승인하는 decision threshold가 아니다. 실제 판정은 S2의 근거·Reversal Cost·후속 gate를 따라 별도로 내린다. 기존 fleet 선례(`target ≥ 3` 또는 `동일 절차 월 ≥ 3회`)는 internal-managed mechanism 채택 재검토 임계이므로 이 진단 screen보다 높게 유지한다.

- **no-go 축:** S2에서 제외하고 "no-action + 근거(실측치)"만 Work에 기록 → S3 직행.
- **go 축:** 해당 축만 bounded S2 진행. **DR 전수 재논의 금지** — evidence가 있는 판정 축에 연결된 DR만 로드(R0-Codex-F7: Work spec·Approval Matrix granularity·언어 정책은 실패·유지비·mismatch evidence가 있을 때만 포함; 언어 정책은 mirror 불일치·adopter UX 부담 관측 시에만).

### S2. (조건부) Direction & structure review — 4축 분리 판정 (R0-Codex-F1)

go된 축에 한해 수행. 단일 rewrite-vs-refactor 판정이 아니라 **축별 `retain / refactor / replace`** 판정:

| 축 | 판정 대상 | 연결 DR/표면 |
| --- | --- | --- |
| ① policy semantics | manual-first policy layer 정체성, Approval Matrix/state machine | DR-021, DR-043, BEHAVIOR-PRINCIPLES |
| ② distribution·upgrade | manifest 기반 scaffold/upgrade 모델, versioning, plugin/marketplace 대비 | DR-028, DR-034, DR-042, create-harness.sh |
| ③ tool projection | canonical SSoT → 4-tool adapter/mirror/prompt 구조 | DR-023, skills/·.claude/·.cursor/·.agents/ |
| ④ enforcement·runtime | 문서 rule ↔ hook/CI gate 배선(Claude PreToolUse 등 native 기능 포함) | DR-024, DR-025, DR-040, tools/git-hooks |

- **§6 평가 기준(R0-Codex-F5):** `document canonical SSoT + in-repo bounded projection/enforcement + parity/fallback`. in-repo hook·adapter·setting은 §6 위반이 아니다. **repo 밖 persistent memory/global customization에 repo-specific 지시를 저장하는 안은 reject.** hook이 canonical policy를 재정의하거나 tool 없이 이해 불가능한 단일 진실이 되면 실질 충돌로 판정.
- 각 판정에 근거(실측치)·Reversal Cost·후속 Work 후보+gate 연결. **관측 시점 명시 + observed/unobserved 분리 기록**(미실측 항목을 사실처럼 쓰지 않음).
- **산출물 위치(R0-Codex-F6):** S1 disposition·evidence·round history는 Work에. go 축이 1개 이상일 때만 brief(`docs/briefs/harness-longterm-durability-review-20260713.md`) 생성 — 재사용할 내구성 판정과 revisit trigger만 담고 Work와 매트릭스 중복 금지. 생성 시 `docs/briefs/README.md` index 갱신 필수. 전 축 no-go면 brief 미생성, Work 내 기록으로 종결.

### S3. Backlog 재우선순위화 + 재가동 상태 확보

- S1+S2 결과로 `docs/backlog/HARNESS.md` Summary/Portfolio View 재정렬(P 재조정, stale 문구 제거, 신규/병합 row 반영).
- `docs/STATUS.md` Next Actions 갱신 + PLAN §4 milestone(AWH-004) 영향 판단(T5) — 필요시 PLAN/PLAN-SUMMARY stale 보정 제안.
- 종료 시점에 "다음에 착수할 Work가 무엇인지"가 backlog만 읽고 결정 가능한 상태.

### 비목표

- 리팩토링/코드/scaffold/rule 실행 변경(전부 후속 Work).
- DR amend/supersede 실행(후보 식별까지만).
- toolstead upgrade 실행. rfx-hub는 **agent-first 실험에 한해 예외**(user-approved amendment) — 실험 외 추가 정비는 후속 Work.
- UF 항목의 원 repo(spring) 측 backlog 수정.

## Plan

1. (done) feature branch `feature/direction-review-20260713`, Work 파일 작성
2. (done) **R0 plan review**: Codex request-changes(F1~F7) → driver 전부 수용, plan 수정
3. **R0b consensus 확인** (cross-agent relay): 수정된 plan(4축 분리, gate 임계값, UF 재분류)에 대한 reviewer 확인 — 특히 gate 임계값 제안치 확정
4. EXECUTE: S1(intake+실측) → **gate 판정 기록** → 조건부 S2(go 축만) → S3. 각 slice 종료 시 Work Checkpoints 기록
5. **R1 result review** (cross-agent relay): 산출물(backlog diff, gate 판정, 조건부 brief, STATUS 제안) 검토
6. 사용자 최종 승인 → `/work-close` → commit(STATUS/tracking finalization 동봉) → PR `--base develop` → merge

## Done Criteria

- [x] UF-01~08 각각의 disposition(merge/신규/dependency/defer + **문제 분류 + 근거**)이 기록되고 backlog에 반영된다. UF-06은 thin-adapter 후보와 dependency로 연결(merge 금지), UF-08 quick-fix 후보에 positive/negative fixture gate가 명시된다
- [x] adopter inventory 확장 매트릭스(4 repo × baseline 유형·upgrade 노동·drift·실패·tool 표면)와 mirror/projection 비용 실측이 기록된다 (CP1·CP2)
- [x] **S1→S2 gate가 축별 go/no-go + 실측 근거와 함께 기록된다** (CP3 — ① no-go/no-action, ②③④ go)
- [x] go 축에 한해 축별 retain/refactor/replace 판정이 근거·Reversal Cost·observed/unobserved 분리와 함께 기록된다 (brief `harness-longterm-durability-review-20260713.md`)
- [x] DR amend/supersede 후보 목록(있다면)이 후속 gate와 함께 정리된다 (brief — 신규 DR 후보·DR-034 amend·DR-028 정합)
- [x] backlog 재우선순위 + STATUS Next Actions 갱신으로 다음 착수 Work가 명확하다 (CP5 + STATUS 승인 반영 — 첫 착수 추천: ai-deck agent-first replay)
- [x] cross-agent R0/R0b(plan)·R1/R1b(result)이 Cross-Agent Review 섹션에 기록되고 합의로 닫힌다
- [x] 사용자 최종 리뷰 후 Done 처리 (2026-07-13 사용자 close 승인 — "rfx PR #12 merge하고 close까지 진행해")

## Verification

- `git diff --check`
- backlog/STATUS/Work 상호 정합(신규 row·제거 row·pointer), stale phrase 재검색(`rfx-hub`, "3개로 본다" 등)
- brief 생성 시: frontmatter 스펙 준수 + `docs/briefs/README.md` index 행 추가 확인 (R0-Codex-F6)
- doc-only 변경이므로 scaffold/tool-surface cascade는 Not Applicable — 단 S3에서 backlog가 tool-surface 후속을 만들면 해당 후속 Work의 Verification으로 이월
- Surface: canonical(backlog/STATUS/brief) · README/GUIDE/MANUAL 영향 없음 확인

## Risk / Reversal Cost

- **리스크:** ① 검토 범위가 넓어 결론이 총론에 그칠 위험 → 3분류 매트릭스에 항목별 "후속 Work 후보 or 명시적 no-action"을 강제해 완화. ② reviewer와 방향 이견 시 라운드 증가 → max R0+R2로 bound, 미합의 항목은 사용자 arbiter 결정. ③ 도구 native 기능 정보의 시점 오차 → brief에 관측 시점 명시.
- **Reversal Cost: Low** — 산출물이 backlog/brief/STATUS 문서뿐. 실행 변경 없음.

## Checkpoints

### CP1 — S1 desk 실측 + UF triage 완료 (2026-07-13)

**Inventory (전 adopter manifest baseline, pre-manifest 없음 — DR-034 #1 조건은 구조적으로 계속 UNMET일 가능성):**

| Repo | version | profile | files | 상태 |
| --- | --- | --- | --- | --- |
| ai-deck-compiler | 1.3.0 | generic | 78 | 1 minor behind |
| spring-modular-template | 1.4.0 | spring-boot | 82 | 현행, UF 채널 보유 |
| rfx-hub | 1.2.1 | generic | 72 | 2 minor behind, 실험 대상 |
| toolstead | 1.4.0 | generic | 83 | 현행, 멀티 product |

**Projection 실측:** canonical `skills/workflow/` 1,919줄(15개) vs Claude adapter 295줄(13)·Codex/AG 288줄(13) ≈ 15%, 대부분 excluded boilerplate(Step 0 pointer) → workflow adapter는 thin 유지 양호. 단 **rule surface**: commit-format normative block이 canonical(`docs/GIT-WORKFLOW.md` 396줄) + `.claude/rules/git-workflow.md`(128줄, canonical 대비 32%) + `.cursor/rules/git-commit.mdc`(67줄)에 복제 — **③ block-replication 기준 충족**.

**Cascade defect 이력:** git log 실측 2건(#164 workflow core layering drift, FEAT-20260527-001 branch isolation drift) — 모두 DR-040 parity gate 배선(2026-06-19) **이전**, 이후 재발 관측 없음.

**축별 잠정 gate 판독 (확정은 실험 + R1):**

| 축 | 실측 | 잠정 |
| --- | --- | --- |
| ① policy | troubleshooting 1건(2026-05-17 scope approval drift, Resolved·규칙 보정 완료), 이후 재발·deadlock 관측 없음 | **no-go** |
| ② upgrade | actual upgrade 2건(ai-deck, spring) 모두 동일 manual step(shadow re-scaffold·adapt-render·manifest rebaseline) 반복, operator 함정 2종(raw-copy drift 잔존/hook identity leak)이 cross-review로만 차단됨 | **go(잠정)** — 실험으로 보강 |
| ③ projection | workflow adapter thin 양호. rule surface에서 normative block 2+ adapter 복제 + 32%>25% | **go(잠정)** — 범위는 rule surface에 한정될 가능성 |
| ④ enforcement | UF-01(manifest-tracked 파일 직접 수정이 review 2R 통과, 사용자 질의로 발견 — protected-surface bypass) + UF-08(deny mis-design → cross-tool 우회) — 동종 2건 아님, material 해석 borderline | **borderline** — R1에서 reviewer와 확정 |

**UF triage:** 8건 disposition 완료, `docs/backlog/HARNESS.md` 반영(신규 row 7 + UF-04 기존 흡수 + adopter evidence set 4-repo 매트릭스 정정).

**Agent-first upgrade 실험 설계 (rfx-hub 1.2.1→1.4.0, R1 검토 대상):**

- **방법:** manifest 절차(playbook/shadow re-scaffold/`--check` 분류) **불사용**. agent에게 주는 것은 아래 최소 체크리스트뿐:
  1. source repo release tag(`ai-workflow-v1.4.0`) 기준으로 target의 framework-owned 파일을 식별·비교하라 (identity 치환 감안)
  2. target의 로컬 수정(product-owned 내용, 의도적 커스텀)은 보존하라 — 애매하면 목록으로 보고
  3. 완료 후: 변경 파일 목록, 보존 판단 목록, 확신 없는 항목을 보고하라
  4. feature branch에서 작업하고 commit은 사용자 승인 후
- **측정:** 수동 개입 횟수(사용자/절차 문서 참조 없이 진행된 비율), 소요 스텝, 오류(spring 절차 upgrade의 F1/F2 함정 재현 여부), 결과 품질(manifest-절차 결과와 파일 단위 대조 — 대조에만 `--check` 사용 허용, 실험 중은 금지)
- **비교 한계 명시:** rfx-hub는 no-code·generic으로 spring(code product·spring-boot·accepted-drift 보유)보다 단순. 2-minor 누적 delta는 오히려 spring(1-minor)보다 큼.
- **manifest 처리:** 실험 중 agent가 manifest를 어떻게 다루는지 자체가 관측 대상(수기 갱신 시도/방치/삭제 제안). 실험 후 rebaseline 여부는 결과 보고에서 결정.

### CP2 — Agent-first upgrade 실험 완료 (2026-07-13, rfx-hub 1.2.1→1.4.0)

**결과: feasibility 실증 (R1-Codex-F1 교정: "명제 검증"이 아니라 rfx generic/no-code target 1건에서의 가능성 증거).** 체크리스트 4항목 + 계약(manifest) + source script의 spec 열람 3회로 manifest-절차와 동등한 **최종 artifact 품질** 달성. process 비교는 informed-driver 오염 상태라 비오염·재현 조건이 아님. 상태 현행화(R1-Codex-F7): rfx-hub `feature/harness-upgrade-140-agent-first`에 **commit 완료(99260f5), PR #12 생성, merge는 사용자 대기**.

**검증 provenance (R1-Codex-F7):** post-hoc `--check`는 source tag `ai-workflow-v1.4.0`(commit 8595176) worktree에서 `bash scripts/create-harness.sh --check ~/dev-home/rfx-hub`로 실행, 출력 `summary: 72 tracked, 71 in-sync, 1 drifted` + `[locally-modified] .gitignore`. PR check run은 0개(rfx-hub는 generic mode, CI 없음).

**generated_at 관측 (R1-Codex-F2):** manifest `generated_at: 2026-06-17`(최초 scaffold 시점)을 rebaseline 시 갱신하지 않고 유지 — 이 필드의 의미(scaffold 시점 vs rebaseline 시점) 계약이 미정임을 발견. 실험에서는 "최초 scaffold 시점 기록"으로 해석해 보존. 계약 정의는 후속 Work 비교 축에 포함.

**품질 (post-hoc `--check`, v1.4.0 clean worktree):** `72 tracked / 71 in-sync / 1 drifted` — 유일 drift는 rfx 의도적 로컬 `.gitignore`(advisory, 정확히 보존). 23개 파일 교체(구버전 잔재 포함), 신규/폐기 0개(released 1.4.0 기준), DR-043 migration은 rfx PLAN-SUMMARY가 이미 값 전체를 커버해 **값 유실 없음** 확인만으로 종결.

**노동 측정:** 전체 ~12 스텝(상태 확인→branch→worktree 2개→3-way 분류 스크립트→리뷰 파일 10개 diff→spec 참조 3회→적용→형식 복구 1회→검증 2회). playbook/shadow re-scaffold/절차 문서 사용 0회. cross-review 라운드 사용 0회(R1 사후 검토 예정). spring 절차 upgrade(playbook Phase 절차+shadow re-scaffold+splice+리뷰 3라운드) 대비 현저히 가벼움.

**함정 재현 여부 (spring F1/F2 대조):**
- F1(rebaseline 누락): **안 밟음** — hash 규칙(치환 전 source raw sha256)을 script에서 spec으로 읽고 직접 재계산. 계약이 명확하면 자명한 작업.
- F2(identity leak): **안 밟음** — adapt가 단일 sed 치환임을 spec에서 확인.
- **신규 함정 1회 밟음:** manifest를 indent=2로 재직렬화 → `--check` single-line entry parser 전면 파손(72개 전부 source-missing 오판). 원본 형식 확인 후 1스텝 복구. spring 기록에 문서화된 함정("pretty-print 금지")을 **알고도** 절차 밖에서 재현 — 교훈: 문서화는 함정을 못 막고, serialization format이 계약에 명시되거나 parser가 관용적이어야 함.

**부수 발견 (version-skew 2건 실증):** rfx 실제 baseline = 1.2.1+develop 스냅샷(1.2.1 tag에 없는 work-brief 보유), toolstead = 1.4.0+develop(cross-review·docs/user는 1.4.0 tag에 없음). manifest는 자기 version을 그대로 기록하므로 machinery로도 안 잡히던 문제 — DR-028 amendment가 경고한 source-ref baseline 문제의 실물 2건.

**명제(user prior #3) 판정 (R1 교정 반영):** rfx generic target에서 **feasible** — 이 범위에서만 지지. 절차(mechanism) 없이 계약(manifest path/src + hash 규칙)과 검증(`--check`)으로 동등 artifact 품질을 얻었으나, **계약이 script 코드 안에 묻혀 있어 3회 코드를 spec으로 읽어야 했음**. agent-first를 default upgrade path로 승격하거나 script/playbook을 축소하는 판정은 **heterogeneous replay(code/accepted-drift target 또는 비오염 operator) 전까지 provisional** — 후속 gate로 남긴다. parser/format 처리 방향(tolerant parser vs 계약 명시)은 선결정하지 않고 후속 Work 비교 축(R1-Codex-F2).

**측정 오염 한계:** driver는 본 세션에서 spring 기록을 읽어 함정 존재를 인지한 상태 — naive agent 측정으로는 오염. 단 pretty-print 함정은 인지 상태에서도 밟았음(문서가 아니라 형식 관용성이 해법이라는 역증거). 비교 한계: rfx는 no-code·generic(spring은 code product·accepted-drift 보유), 단 delta는 2-minor로 spring(1-minor)보다 큼.

### CP3 — S1→S2 Gate 판정 (2026-07-13)

R0b 확정 임계값 대조 결과. Screening 판정이며 교체 승인이 아니다.

| 축 | 판정 | 실측 근거 |
| --- | --- | --- |
| ① policy semantics | **no-go** | 우회·단축 실측 1건뿐(2026-05-17 troubleshooting, Resolved·규칙 보정 완료, 이후 재발 관측 없음). deadlock 0건. 임계(독립 2건+ 또는 deadlock 1건+) 미충족. **no-action** — Codex 비공식 평가의 "정책 과다" 인상은 실측 미지지로 기록 |
| ② distribution·upgrade | **go** | actual upgrade 2건(ai-deck, spring)에서 동일 manual step(shadow re-scaffold·adapt-render·rebaseline) 반복 — 임계(2건+ 동일 step 반복) 충족. 보강: CP2 실험이 rfx generic/no-code target의 agent-first **feasibility 증거** 제공(R1b — target-state 실증 아님, heterogeneous replay 전 provisional 경계 유지) |
| ③ tool projection | **go** | 동일 tool-neutral normative block(commit format)이 canonical + 2 adapter(`.claude/rules/git-workflow.md`, `.cursor/rules/git-commit.mdc`)에 복제 — block-replication 기준 충족(R1-Codex-F5 확정). raw 32% 수치(excluded 미차감)는 **threshold 근거에서 제외**, 참고 수치로만 유지. cascade defect 2건은 모두 DR-040 gate 배선 이전 — defect 기준으로는 미충족, block-replication 기준 단독 go |
| ④ enforcement·runtime | **go** | UF-01: 문서 rule(GIT-WORKFLOW 경계)이 있었으나 실행 gate 부재로 위반이 review 2라운드 통과, 사용자 개입으로 발견·재작업. R1-Codex-F5 확정: **contained material near-miss** — manifest-tracked protected surface 실제 수정 + material rework로 bounded analysis gate는 열리나, merge 전 통제됐으므로 shipped incident로 서술하지 않음 |

**Gate 종합:** ①은 S2 제외(no-action 기록으로 종결), ②③④ bounded S2 진행. brief 생성 조건(go 축 1개+) 충족.

### CP4 — S2 완료 (2026-07-13)

- 산출: `docs/briefs/harness-longterm-durability-review-20260713.md` + briefs README index 갱신.
- 판정(R1 교정 반영): ① retain(no-action) / ② **refactor(provisional** — heterogeneous replay 전까지, parser/format·source ref·generated_at은 후속 비교 축) / ③ refactor(rule surface 한정 — 기존 후보 3건 우선순위 상향으로 처리, 신규 방향 없음) / ④ refactor(보완 — in-repo deterministic guard 이중화, §6 기준 준수).
- 작업 가설(R1-Codex-F3로 하향): "판단이 필요한 절차는 deterministic contract·verification이 있을 때 agent 위임을 기본 후보로 본다"(bounded heuristic, load-bearing mechanism 예외) — DR 승격 후보 아님, brief 가설 + revisit trigger로 유지. DR 영향 후보: DR-034 amend(provisional 해제 후), DR-028 정합(source ref).
- rfx-hub 실험 branch는 commit 완료, PR #12 생성(merge는 사용자 대기).
- 잔여: R1 findings 반영(완료) → R1b consensus → S3(backlog 재우선순위 + STATUS 제안) → 사용자 최종 리뷰 → close.

### CP5 — S3 backlog 재우선순위 완료 (2026-07-13)

- Portfolio View에 **W6. Durability Follow-up** cluster 추가 — 4축 판정의 실행 후속을 evidence-gated로 관리.
- 신규 후보 2건 등록(per-candidate details 포함): ⓐ ai-deck 1.3.0→1.4.0 agent-first replay(축② provisional 해제 gate, P2), ⓑ manifest contract 정비(tolerant parser·source-ref·generated_at, P2 — entry-format 계약화는 R1b에서 선택지 제외 반영).
- `.claude/rules/git-workflow.md` thin adapter화 P3→**P2** 상향(축③ block-replication 실측 근거, UF-06 뒤 착수).
- 기존 P1 3건(happy path/glossary, planning-pack evidence review, safety rule 축 A)은 우선순위 유지.
- STATUS 갱신은 Approval Matrix에 따라 제안 후 승인 대기(아래 제안). PLAN T5 판단: AWH-004 maintenance 범위 내 후속 추가 수준 — PLAN 본문 변경 불요, PLAN-SUMMARY stale 없음.

## Discovery

- Archived: 2026-07-13 — 1.5.0 release 전 §3-1 Public Clean Baseline gate 충족을 위한 batch archive (CHORE-20260713-004 R1-Codex-F3).

- 2026-07-13 착수. backlog의 P1 후보들("happy path/glossary", "planning-pack evidence review")보다 이 재가동 점검을 선행하는 이유: backlog 자체가 adopter 현실 대비 stale이므로, stale한 우선순위 위에서 P1을 고르는 것이 순서 오류.
- 실측(착수 시): `~/dev-home/rfx-hub` 존재, manifest `harness_version: 1.2.1` (no-code, engagements/knowledge 구조). `~/dev-home/vibe/toolstead` 존재, manifest `harness_version: 1.4.0` (Skillstead/SessionCue). UF buffer는 spring에만 존재(8건). rfx-hub/toolstead는 UF 채널 자체가 없음 → evidence 채널 표준화 여부도 S1 판단 대상.
- backlog "Adopter evidence set ... 3개로 본다" + "rfx-hub는 finding 수집 후 삭제" 문구는 실제와 불일치 확인.
- Needs-Triage: adopter upstream feedback 채널 표준화 — UF buffer가 spring에만 있고 rfx-hub/toolstead에는 없어 adopter evidence가 비대칭으로 유실될 수 있음. S1에서 판단 대상으로 명시했으나 disposition 미결 — 다음 adopter 작업 또는 `/work-select`에서 표준화(scaffold seed 포함 여부) 판단 가치.
- **User prior (2026-07-13, 축② 방향 가설 — S2-② 대조용):** spring-modular 진행 중 사용자 소회 — "upgrade/migration에 규칙·스크립트 기계장치 없이, 기본 체크리스트 + 'agent에게 현재 버전으로 올려줘'로 충분했던 것 아닌가". 지지 증거: rebaseline 노동은 manifest 존재가 만든 일(CHORE-20260624-001), upgrade 2건 대비 기계장치 구축 비용 과다, agent의 3-way diff 능력. 반증: UF-01에서 manifest hash 추적이 agent review 2라운드가 놓친 경계 위반을 잡음 → **upgrade 절차(replace 유력)와 경계 감지기(retain 후보)를 분리 판정**해야 함. 검증 경로 후보: rfx-hub 1.2.1→1.4.0을 agent-first(체크리스트만) 실험으로 수행해 spring manifest-절차와 노동·품질 대조(no-code라 비교 한계 명시). R0-Codex-F1의 "upgrade·projection 하위 시스템 선택적 교체 가능성"과 수렴.
- **User prior #2 (2026-07-13, 축②·③ target-state 가설 — S2 대조용):** "script가 가져가는 규칙을 skill로 구성했다면 source에서 target 계획 수립부터 진행 가능했고, scaffold 후 온보딩 프로세스도 간략화됐을 것. pack 구성도 마찬가지." 지지 증거(기존 기록): intake hook·no-code depth·planning-pack prepared-brief·pack resolver route-out·UF-01 — 전부 script가 못 하는 판단을 agent-side shim으로 메꾼 패치. 수렴 통찰: upgrade가 shadow **re-scaffold**를 쓴다는 사실이 scaffold/upgrade가 같은 spec의 두 flow임을 증명 → target-state 후보 = "선언적 file-set spec(framework-owned 목록+identity 규칙+manifest 계약)을 skill로, scaffold=첫 적용/upgrade=delta 적용/pack=조합 단위". **제약:** ⓐ 산출물 결정성 유지(계획·조합은 agent, 파일 내용은 tag verbatim copy+기계 치환 — manifest 감지기 보존), ⓑ tool-neutral(skills/ canonical+adapter 패턴 재사용, DR-023과 오히려 정합). **교정:** scaffold 자체는 4~5회 무고통 실측 — rewrite가 목적이 아니라 S2-② target-state 후보로만 평가. script는 외부 manual adopter(미검증) 경로용 유지/thin화. user prior #1(agent-first upgrade)과 하나의 target-state로 수렴.
- **User prior #3 (2026-07-13, 정제 명제 — S2 공통 기준선 후보):** "agent에게 시키면 될 일을(기본 규칙·검증 보강은 필요했겠지만) 돌아서 만들어 복잡도만 증가한 것 아닌가." Driver 정리: 경계 오설정 진단 — **mechanism(절차 실행)은 agent에게, contract(경계 선언: manifest/gate)와 verification(결정적 검증: parity/invariant)은 harness에.** 복잡도 증가분의 대부분은 mechanism을 harness 측에 축적한 비용(shadow re-scaffold·rebaseline 절차·playbook·3중 온보딩 문서 + 그 위의 agent-side shim 이중화). contract/verification 층은 실증 가치 보유(UF-01)로 유지. 이 명제는 S2 brief 핵심 결론 후보이며 채택 시 DR-worthy.
- **Reviewer prior (2026-07-13, 비공식 평가 — S2 대조용):** Codex의 harness 총평 — 내부 운영 도구 8/10, 범용 배포 제품 5/10. 진단: "harness를 위한 harness화(문서·절차 과다)", "manual-first지만 실신뢰성은 모델의 긴 규칙 준수에 의존", "canonical/4-tool projection/scaffold/manifest upgrade 유지비 누적", "일반 adopter 인지 부하 높음". 처방: 전면 rewrite보다 핵심 정책 축소 + projection 자동화 + upgrade UX 개선 우선, **표면 추가 증설 경계**. 이 평가는 무실측 인상이므로(R0-Codex-F2와 동일 기준) S1 실측 후 축별 판정과 대조한다. "표면 순증(net-new surface)" decision rule은 R0b에서 **기본 억제(presumption against)** 로 확정: 신규 표면 후보는 owner·lifecycle·projection/upgrade 비용·기존 표면 통합 불가 근거를 입증해야 통과(절대 reject는 UF-01·08처럼 실제 seam/defect 해소에 필요한 최소 표면까지 막으므로 비채택).

## Cross-Agent Review And Discussion

Model: manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. Max rounds: plan R0 + result R1 (+필요시 R2, 초과 시 사용자 결정).

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 이 Work 파일 전체 (`docs/works/harness/CHORE-20260713-001-direction-review-backlog-realignment.md`) — 특히 Scope S1~S3, Top Summary의 잠정 결론.

**Current State:** branch `feature/direction-review-20260713`, Work 등록만(EXECUTE 미착수). 입력 evidence: spring UF-01~08(`~/dev-home/vibe/spring-modular-template/docs/backlog/HARNESS.md` §Upstream Harness Feedback), adopter 4-repo 실측(Discovery), source backlog/PLAN/DR 43건/brief 8건.

**Delta Since Last Round:** R0 (first)

**Review Objective:** EXECUTE 착수 전 **방향·필요성·scope** red-team. 내적 정합성 검사가 아니라 방향 자체를 의심할 것.

**Must Check:**
1. **잠정 결론 반박 시도(최우선):** "manual-first 유지 + 국소 개선, rewrite 불필요"가 driver의 현상 유지 편향은 아닌가. adopter 4개·멀티 product(toolstead) 시대에 구조적 한계(예: manifest upgrade 모델, 4-tool mirror 유지비)가 rewrite급인지 독립 판단해줘.
2. **Work 필요성 자체:** 이 재가동 점검 Work가 과잉인가? 대안(UF만 quick triage하고 바로 기존 P1 착수)이 더 나은가?
3. **S1 UF mapping 가설 타당성:** 특히 UF-08 quick-fix 분리, UF-06↔thin-adapter 병합이 성급한지.
4. **S2 재검토 대상 선정:** 성역 없이 본다면서 빠진 결정/구조는 없는가(예: Work file spec 자체, Approval Matrix granularity, 언어 정책). 반대로 열거만 넓고 판정 불가능한 항목은 없는가.
5. **산출물 위치:** direction review 산출을 brief로 두는 것 vs Work 내부 disposition — 어느 쪽이 후속 소비에 유리한가.
6. **§6 충돌 여부:** 도구 native 기능(hook 등) 이중화 방향이 BEHAVIOR-PRINCIPLES §6("harness 문서만으로 행동 유도 검증")과 충돌하는지.

**Do Not Re-litigate:**
- cross-agent 역할(Claude driver / Codex reviewer / User arbiter) — 사용자 확정
- 검토(이 Work)와 실행 리팩토링(후속 Work)의 분리 — 사용자 지시 취지
- adopter 4-repo 실측 사실 자체

**Reviewer Posture:** red team. 검토 Work가 "검토를 위한 검토"로 비대해지는지, 반대로 진짜 구조 문제를 국소 개선으로 눙치는지 양방향 의심. speculation은 명시 표기.

**Output Contract:**
1. Verdict(approve / conditional / request-changes / reject) + finding table(ID·severity(must/nice)·finding)
2. **이 Work 파일의 이 섹션 아래에 `### R0 — Reviewer Findings (Codex)` 제목으로 직접 기록**
3. 기록 후, 사용자가 driver(Claude)에게 relay할 수 있도록 **판정·must-fix 요지·residual risk를 5줄 이내 요약으로 별도 출력**

### R0 — Reviewer Findings (Codex)

**Verdict: request-changes**

백로그가 adopter 현실과 어긋나 있어 S1·S3 재가동 점검은 필요하다. 다만 현재 S2는 서로 다른 문제를 하나의 `rewrite-vs-refactor` 판정으로 접고, 그 판정을 받침할 실측 지표와 중단 gate를 두지 않았다. adopter 4개와 multi-product 사실만으로 전면 rewrite는 정당화되지 않지만, 동일한 근거로 `manual-first 유지 + 국소 개선`도 확정할 수 없다.

| ID | Severity | Finding |
| --- | --- | --- |
| R0-Codex-F1 | must | **판정 대상의 축이 섞였다.** `manual-first` policy/runtime 선택, manifest 기반 distribution/upgrade, canonical→tool projection, hook/CI enforcement는 서로 다른 교체 단위다. S2를 최소 `policy semantics / distribution·upgrade / tool projection / enforcement·runtime`의 4개 축으로 나누고, 전체에 대한 단일 rewrite 판정이 아니라 축별 `retain / refactor / replace`를 허용해야 한다. 현 근거로는 manual-first 정체성의 폐기보다 upgrade·projection 하위 시스템의 선택적 교체 가능성이 더 크다. |
| R0-Codex-F2 | must | **현 inventory로는 구조적 한계를 판정할 수 없다.** `repo × version/상태/evidence 채널`에 `baseline 유형(pre-manifest/manifest)`, 실제 upgrade 횟수·소요 노동·수동 개입, accepted/custom drift, 실패/재작업, 사용 tool 표면을 추가해야 한다. 4-tool mirror 비용도 tool 수가 아니라 adapter 중복 양, cascade 누락/defect, 실사용률로 측정해야 한다. 기존 brief의 fleet/repetition trigger와 비교할 판정 임계값을 먼저 명시하지 않으면 결론은 서사적 인상비평에 머물게 된다. |
| R0-Codex-F3 | must | **재가동 점검은 필요하지만 S2 전수 실행은 조건부여여야 한다.** 1.5d에 UF 8건, adopter 4개, 구조 DR, tool-native 변화, backlog/STATUS까지 모두 평가하면 검토를 위한 검토가 된다. S1 quick triage·inventory 후 `structural trigger screen` go/no-go checkpoint를 두고, trigger 미충족 시는 stale 정정 + 기존 P1 직행, 충족 시만 bounded S2 brief로 진행해야 한다. 43개 DR 전수나 도구 기능 나열은 evidence가 있는 판정 축으로만 제한해야 한다. |
| R0-Codex-F4 | must | **UF mapping이 문제 분류 전에 해결책을 선결정한다.** UF-01은 product-owned CI seam 문제이지 starter stub 채택 결론이 아니며, UF-02는 checklist 추가가 또 다른 문서 무게가 될 수 있어 manifest-aware deterministic guard와 비교가 필요하다. UF-06은 thin-adapter와 파일만 겹친다. 전자는 canonical branch policy 변경, 후자는 projection 중복 제거이므로 merge하지 말고 dependency로 연결해야 한다. UF-08의 별도 quick-fix 분리는 타당하지만, deny 축소이므로 secret-file negative fixture + sanitized-example positive fixture를 필수 gate로 두어야 한다. |
| R0-Codex-F5 | must | **tool-native 이중화와 §6의 경계를 반대로 읽지 말아야 한다.** §6은 repo 밖 persistent memory/profile에 harness 운영 지시를 복제하는 것을 금지하지, in-repo hook·adapter·setting을 금지하지 않는다. 따라서 평가 기준은 `document canonical SSoT + in-repo bounded projection/enforcement + parity/fallback`여야 하며, native memory/global customization에 repo-specific 지시를 저장하는 안은 reject해야 한다. hook이 canonical policy를 재정의하거나 tool 없이 이해할 수 없는 단일 진실이 될 때만 실질 충돌이다. |
| R0-Codex-F6 | nice | **brief 위치는 조건부로 타당하다.** S1 disposition·evidence·round history는 Work에, 다른 Work가 재사용할 내구성 판정과 revisit trigger는 brief에 두는 경계가 맞다. 단 F3의 go 후에만 brief를 생성하고, 같은 3분류 매트릭스를 Work와 brief에 중복하지 말며 `docs/briefs/README.md` index update를 파일 목록·Verification에 명시해야 한다. |
| R0-Codex-F7 | nice | **“성역 없이”를 전수 재논의로 해석하지 말아야 한다.** Work spec, Approval Matrix granularity, 언어 정책도 실패·유지비·tool-native mismatch evidence가 있을 때만 평가 대상에 포함한다. 특히 언어 정책은 번역 취향이 아니라 mirror 불일치·adopter UX 부담이 관측된 경우에만 연다. |

**Residual Risk:** 최신 tool-native 기능과 4개 adopter의 실제 upgrade 비용은 R0에서 아직 전수 실측되지 않았다. F1~F5를 plan에 반영해도 S2 결론은 관측 시점·evidence 분류·미관측을 분리해 기록해야 하며, driver가 must finding을 `defend`하면 user decision gate로 올려야 한다.

### R0 — Driver Response (Claude)

전 finding 수용(defend 없음). 반영 내역:

| Finding | 반영 |
| --- | --- |
| F1 (must) | S2를 4축(policy semantics / distribution·upgrade / tool projection / enforcement·runtime)으로 분리, 축별 retain/refactor/replace 판정으로 재구성. Top Summary의 단일 잠정 결론을 "gate로 검증할 가설"로 격하 |
| F2 (must) | S1 inventory를 baseline 유형·upgrade 노동·drift·실패·tool 표면으로 확장. mirror 비용을 adapter 중복 양·cascade defect 이력·실사용률로 측정. gate 임계값 표를 plan에 사전 명시(R0b 확정 대상) |
| F3 (must) | S1→S2 structural trigger screen(go/no-go gate) 신설. no-go 축은 no-action+근거 기록 후 S3 직행. DR 전수 재논의 금지 명시 |
| F4 (must) | UF mapping을 문제 분류 우선으로 재작성. UF-06은 thin-adapter와 dependency 연결(merge 금지), UF-08 quick-fix에 secret negative + sanitized example positive fixture 필수 gate, UF-01 stub 선결정 제거, UF-02 checklist vs deterministic guard 비교 등록 |
| F5 (must) | §6 평가 기준을 "document canonical SSoT + in-repo bounded projection/enforcement + parity/fallback"으로 명시. repo 밖 persistent 저장안 reject 기준 포함 |
| F6 (nice) | brief는 go 축 1개 이상일 때만 생성, Work/brief 매트릭스 중복 금지, briefs README index 갱신을 Verification에 추가 |
| F7 (nice) | "성역 없이" 해석 bound: evidence 있는 축 연결 항목만. 언어 정책은 mirror 불일치·adopter UX 관측 시에만 |

### R0b — Consensus Confirmation Request (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 수정된 이 Work 파일 — Scope(S1 확장, S1→S2 Gate, S2 4축), Plan, Done Criteria, Top Summary.

**Delta Since Last Round:** R0 F1~F7 전부 수용·반영(위 Driver Response 표). 구조 변경: ① 단일 rewrite 판정 → 4축 retain/refactor/replace, ② go/no-go gate + 임계값 표 신설, ③ UF 문제 분류 재작성, ④ §6 평가 기준 명문화, ⑤ brief 조건부 생성.

**Review Objective:** consensus 확인. 특히 **gate 임계값 제안치(4축 표)가 fleet/repetition trigger 선례와 정합하는지, 축별 go 조건이 과소/과대하지 않은지** 확정해줘. 신규 쟁점이 없으면 approve로 닫고 EXECUTE 진입.

**Output Contract:** Verdict + (있다면) 임계값 수정안. 이 파일 `### R0b — Reviewer Findings (Codex)` 섹션에 기록 후, driver relay용 3줄 요약 별도 출력.

### R0b — Reviewer Findings (Codex)

**Verdict: conditional**

R0 F1~F7은 모두 취지대로 반영됐다. S1 inventory 확장, 축별 gate, 4축 `retain / refactor / replace`, UF 문제 분류, §6 경계, 조건부 brief 위치에서 누락이나 과잉 보정은 보이지 않는다. 다만 현 gate는 ③ 수치가 미정이고 ④이 단일 경미 사례에도 과민하게 열리며, ②이 CHORE-20260624-003의 정확한 trigger보다 넓으면서 "정합"으로 표기됐다. 아래 수정을 반영하는 조건으로 EXECUTE 진입을 승인한다.

**Threshold Revision:**

| 축 | 확정 권고 go 조건 |
| --- | --- |
| ① policy semantics | **독립 사례 2건+**(가능하면 2 repo 또는 2 session)에서 Approval/state machine 우회·단축이 material rework를 유발, **또는** 정상 절차를 따랐음에도 policy 자체가 Work 완료를 막는 **재현 가능한 deadlock 1건+** |
| ② distribution·upgrade | **2건+ actual adopter upgrade에서 동일 manual step/operator error 반복**, **또는** upgrade model 자체에 기인한 material 실패·재작업 1건+; 단 후자는 본 Work의 분석 gate만 열고 CHORE-20260624-003 helper/schema future trigger를 자동 충족하지 않음 |
| ③ tool projection | **독립 cascade 누락/defect 2건+**, **또는** 같은 tool-neutral normative block(3줄/불릿 이상)이 2개+ adapter에 복제, **또는** 어느 한 adapter의 non-boilerplate·tool-neutral normative line이 대응 canonical의 **25% 초과**. frontmatter, Step 0 pointer, entry mechanism, tool-specific hard stop은 비율에서 제외 |
| ④ enforcement·runtime | 같은 유형의 gate 부재 위반이 **분기당 2건+**, **또는** security/data loss/irreversible state change/protected-surface bypass에 해당하는 **material incident 1건+** |

**Boundary:** 이 임계값은 bounded S2 분석을 여는 **screening threshold**이지 `refactor / replace`를 승인하는 decision threshold가 아니다. 실제 판정은 S2의 근거·Reversal Cost·후속 gate를 따라 별도로 내린다. 기존 fleet 선례(`target ≥ 3` 또는 `동일 절차 월 ≥ 3회`)는 internal-managed mechanism 채택 재검토 임계이므로, 이 진단 screen보다 높게 유지하는 것이 정합하다.

**Additional Note:** Discovery의 `표면 순증(net-new surface) 기본 reject`는 `기본 억제(presumption against) + owner·lifecycle·projection/upgrade 비용·기존 표면 통합 불가 근거 입증`으로 낮춘다. 절대 reject는 UF-01·08처럼 실제 seam·defect 해소에 필요한 최소 표면까지 막을 수 있다.

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target (산출물 전체):**
1. Work 파일 CP1(S1 실측)·CP2(agent-first upgrade 실험)·CP3(gate 판정)·CP4(S2 요약)
2. `docs/backlog/HARNESS.md` diff — UF-01~08 intake disposition + adopter evidence set 4-repo 정정
3. `docs/briefs/harness-longterm-durability-review-20260713.md` — 4축 판정 + 지도 원칙 + revisit triggers
4. rfx-hub PR #12 (실험 결과물, merge 대기)

**순서 참고:** S3(backlog 재우선순위 + STATUS 제안)는 arbiter 결정으로 R1 **이후** 수행 — R1 findings를 재우선순위에 반영하기 위함. 따라서 이 R1은 S3 산출물을 포함하지 않으며, S3 결과는 close 전 사용자 최종 리뷰에서 확인된다.

**Delta Since R0b:** gate 임계값 확정본 반영 → S1 실측 → arbiter-approved 실험 수행 → gate 판정(① no-go, ②③④ go) → S2 brief.

**Review Objective:** 산출물 red-team. 특히:
1. **실험 설계·결과 (reviewer 첫 검토 — R0b 이후 arbiter 승인 amendment):** 오염 한계(driver가 spring 함정 기록을 인지한 상태)를 감안해도 축② go/refactor 근거로 충분한가. 사후 `--check` 품질 대조는 공정한가. 결론 과확장 여부(no-code 1건 → 일반화).
2. **Gate 판정 검증:** ④ UF-01의 material 해석 확정(go 유지 vs no-go 정정). ③이 cascade defect 기준 미충족·block-replication 기준만으로 go인 판정의 타당성.
3. **Brief 판정:** 축② "refactor + 계약 선언화"가 실험 1건 기반으로 과속인지. 지도 원칙("mechanism은 agent에게, contract·verification은 harness에")의 DR 승격 후보 적정성. observed/unobserved 분리 준수 여부.
4. **Backlog UF intake:** disposition 8건(신규 7 + UF-04 흡수)과 dependency 연결(UF-06↔thin-adapter)의 적정성.

**Do Not Re-litigate:** R0/R0b 합의사항(4축 구조, gate 임계값, screening boundary, net-new surface 기본 억제), 실험 포함 자체(arbiter 승인), cross-agent 역할.

**Output Contract:** Verdict(approve/conditional/request-changes) + finding table(ID·must/nice·내용)을 이 파일 `### R1 — Reviewer Findings (Codex)` 섹션에 직접 기록하고 Round Log 갱신. 기록 후 사용자가 driver에게 relay할 수 있게 **판정·must-fix 요지·residual risk 5줄 이내 요약** 별도 출력.

### R1 — Reviewer Findings (Codex)

**Verdict: request-changes**

축① no-go, 축②·③·④ go라는 screening 결과의 큰 골격은 유지할 수 있고, UF disposition과 PR #12 artifact도 대체로 유효하다. 하지만 현 CP2·brief는 한 번의 오염된 no-code 실험이 보여준 **가능성과 최종 artifact 품질**을, 범용 upgrade mechanism 교체·manifest 계약 확장·DR 원칙의 검증으로 과확장했다. 백로그 risk/구조 결함도 함께 보정하기 전에는 S3·close로 넘어가지 않는다.

| ID | Severity | Finding |
| --- | --- | --- |
| R1-Codex-F1 | must | **CP2는 agent-first 가능성은 보였지만 `manifest 계약만으로 명제 검증`은 아니다.** 실제 과정은 driver의 spring 함정 사전 인지, source script를 spec으로 3회 열람, 3-way 분류 script, post-hoc `--check`를 사용했다. `--check`는 최종 artifact 동등성 검증으로는 공정하지만, 비오염·재현 가능한 process 비교가 아니다. 축② `go`는 ai-deck+spring의 동일 manual step 반복으로 유지하되, CP2가 지지하는 결론을 `rfx generic target에서 feasible`로 낮추고 서로 다른 target 1건 이상(코드/accepted-drift 또는 비오염 operator) replay 전까지 agent-first 교체를 **provisional refactor direction**으로 표기해야 한다. |
| R1-Codex-F2 | must | **실험이 발견한 parser 취약성을 새 계약으로 고정하지 말아야 한다.** single-line JSON은 semantic contract가 아니라 `grep` parser의 구현 제약이다. brief §②의 `entry format을 manifest 필드로 명시`는 해결책을 선결정하고 결함을 공식 API로 ossify한다. 후속은 ① tolerant JSON parser, ② 기존 `hash_algorithm/hash_mode`의 충분성·부족 정의, ③ exact source-ref metadata를 별도 축으로 비교해야 한다. PR #12에서 `generated_at` 이전 값을 유지한 것도 초기 scaffold 시점인지 rebaseline 시점인지 계약이 미정임을 보여주므로, 의도를 기록해야 한다. |
| R1-Codex-F3 | must | **지도 원칙은 현재 형태로 DR 승격하기에 너무 절대적이다.** `mechanism은 agent에게`는 deterministic scaffold, security gate, unattended/fleet 실행처럼 mechanism 자체가 load-bearing인 반례를 포함하지 못한다. `판단이 필요한 절차는 deterministic contract·verification이 있을 때 agent 위임을 기본 후보로 본다`는 **bounded heuristic**으로 낮추고, 추가 heterogeneous replay 전에는 DR 승격 후보가 아니라 brief 가설/revisit trigger로 남겨야 한다. |
| R1-Codex-F4 | must | **observed / inferred / unobserved 분리가 불완전하다.** brief의 `복잡도 증가분의 대부분은 mechanism 축적 비용`, `scaffold와 upgrade는 같은 spec의 두 flow`, `upgrade logic의 정답이 절차 위임으로 갱신`은 실측 사실이 아니라 현 문서의 inference다. 이를 명시 분리하고, external manual adopter·spring-급 code/accepted-drift target·비오염 operator replay는 unobserved로 남겨야 한다. |
| R1-Codex-F5 | nice | **Gate ③·④은 go를 유지한다.** ③은 R0b에서 합의한 block-replication 기준을 문자 그대로 충족하며 rule-surface 한정 refactor는 비례적이다. 단 excluded 항목을 빼지 않은 raw `32%`는 threshold 근거에서 제외하거나 재계산한다. ④ UF-01은 merge 전 통제됐지만 manifest-tracked protected surface를 실제로 수정했고 2개 review round를 통과해 material rework를 만들었으므로 bounded analysis gate를 열 정도의 **contained material near-miss**로 본다. shipped incident로 서술하지는 말아야 한다. |
| R1-Codex-F6 | must | **Backlog intake의 risk와 2-layer 구조를 바로잡아야 한다.** UF-03은 `docs/GIT-WORKFLOW.md`, UF-08은 scaffold `.claude/settings.json` 표면을 변경하므로 Approval Matrix상 둘 다 **L2**다(L1 아님). 또 Summary에 7개 candidate를 추가했지만 Details에는 disposition 표 1개만 있어 각 candidate의 Task·Dependencies·Done Criteria·Verification이 없다. 7개를 독립 row로 유지하려면 detail block을 보충하고, 아니면 Summary를 cluster candidate로 축소해 1:1 구조를 맞춘다. UF-06→thin-adapter의 `canonical 정책 먼저, projection 정리 후`라는 dependency는 타당하다. |
| R1-Codex-F7 | nice | **PR #12는 실험 artifact로 유효하지만 검증 provenance를 더 남겨야 한다.** GitHub에서 `develop`→`feature/harness-upgrade-140-agent-first`, 24 changed files(manifest + framework 23), 의도적 `.gitignore` drift 보존을 확인했고 local `git diff --check` 도 통과했다. 다만 PR check run은 0개이므로 CP2/PR body에 post-hoc `--check`의 정확한 source tag/commit·command·output artifact를 남겨 재현 가능하게 한다. CP2의 `commit은 사용자 승인 대기`는 현재 commit·PR 상태와 맞지 않으므로 현행화한다. |

**Residual Risk:** 위 보정 후에도 PR #12는 `generic/no-code + informed driver` 1건의 가능성 증거다. agent-first를 default upgrade path로 승격하거나 script/playbook을 축소하는 실행 판정은 heterogeneous replay와 external manual adopter 경로 검증 전까지 후속 gate로 남겨야 한다.

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R0 | 2026-07-13 | Claude (plan 작성) | Codex (plan review) | request-changes | F1~F7 기록 |
| R0-resp | 2026-07-13 | Claude (전부 수용, plan 수정) | — | — | 4축 분리·gate 신설·UF 재분류·§6 기준 명문화 |
| R0b | 2026-07-13 | Claude (packet 발행) | Codex (consensus 확인) | conditional | F1~F7 addressed, 임계값 수정안·screening boundary 반영 대기 |
| R0b-resp | 2026-07-13 | Claude (조건 전부 반영) | — | **consensus** | gate 임계값 확정본 반영, screening boundary 명문화, net-new surface 기본 억제로 하향. **Arbiter(User) amendment 승인:** rfx-hub 1.2.1→1.4.0 agent-first upgrade 실험을 S1 축② evidence로 포함(비목표 완화) — R0b packet 발행 후 승인이라 reviewer 미검토, R1 result review에서 실험 설계·결과 함께 검토 |
| R1 | 2026-07-13 | Claude (packet 발행 — S1·실험·gate·S2 산출물) | Codex (result review) | request-changes | F1~F7 기록, S3 전 driver response 대기 |
| R1-resp | 2026-07-13 | Claude (전부 수용, 산출물 교정) | — | — | 아래 Driver Response 표 |
| R1b | 2026-07-13 | Claude (packet 발행) | Codex (consensus 확인) | conditional | F3~F7 addressed, F1/F2 잔여 문구 2건 교정 후 S3 진입 consensus |
| R1b-resp | 2026-07-13 | Claude (잔여 2건 반영) | — | **consensus — R1 closed** | CP3 축② "feasibility 증거"로 하향, brief §② entry-format 계약화 선택지 제거(tolerant parser 교정 대상으로 한정). S3 진입 |

### R1 — Driver Response (Claude)

전 finding 수용(defend 없음). 반영 내역:

| Finding | 반영 |
| --- | --- |
| F1 (must) | CP2를 "명제 검증"→"rfx generic target feasibility"로 하향, brief 축②를 **refactor(provisional)** 로 변경 — heterogeneous replay(code/accepted-drift target 또는 비오염 operator) 1건+ 전까지 script/playbook 축소 실행 판정은 후속 gate. revisit trigger에 heterogeneous replay 행 추가 |
| F2 (must) | brief §②의 "entry format 계약 명시" 선결정 제거 → 후속 비교 축으로 재구성(ⓐ tolerant parser vs 계약 명시, hash 필드 충분성 / ⓑ source-ref metadata 별도 축 / `generated_at` 의미 계약 정의). CP2에 generated_at 미정 계약 관측 기록 |
| F3 (must) | 지도 원칙을 **bounded heuristic**으로 하향("판단이 필요한 절차는 deterministic contract·verification이 있을 때 agent 위임을 기본 후보로" + load-bearing mechanism 예외) — DR 승격 후보에서 제외, brief 가설+revisit trigger로 유지. brief 결론·CP4·briefs README index 모두 수정 |
| F4 (must) | brief에 observed/inferred/unobserved 3분류 블록 신설 — "복잡도=mechanism 비용"·"scaffold=upgrade 동일 spec"·"절차 위임 방향"을 inferred로 명시, external adopter·spring급 replay·비오염 operator를 unobserved로 등재 |
| F5 (nice) | CP3 ③에서 raw 32%를 threshold 근거에서 제외(참고 수치화), ④를 "contained material near-miss"로 재서술(shipped incident 아님) |
| F6 (must) | backlog UF-03·UF-08 risk L1→**L2** 수정, Summary 신규 7행에 1:1 대응하는 per-candidate detail block(Task/Dependencies/Done Criteria/Verification) 보충 |
| F7 (nice) | CP2 상태 현행화(commit 99260f5·PR #12) + 검증 provenance(tag/commit/command/output) 기록, rfx PR #12에 provenance comment 추가 |

### R1b — Consensus Confirmation Request (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** R1 교정 반영본 — Work CP2·CP3·CP4, brief(`harness-longterm-durability-review-20260713.md`), backlog per-candidate details, briefs README index, rfx PR #12 comment.

**Delta Since R1:** F1~F7 전부 수용·반영(위 Driver Response 표).

**Review Objective:** 교정 충실성 확인 + **S3 진입 consensus**. 신규 쟁점 없으면 approve로 닫는다. S3 산출물(backlog 재우선순위·STATUS 제안)은 close 전 사용자 최종 리뷰가 확인한다.

**Output Contract:** Verdict. 이 파일 `### R1b — Reviewer Findings (Codex)` 섹션 기록 + Round Log 갱신 + 3줄 요약 별도 출력.

### R1b — Reviewer Findings (Codex)

**Verdict: conditional**

F3~F7은 취지대로 반영됐고 F1의 핵심 결론도 feasibility/provisional로 하향됐다. CP2의 한계 표기, bounded heuristic, evidence 3분류, Gate ③·④ 부기, backlog L2 risk·1:1 per-candidate details, briefs README index, PR #12 provenance comment(tag `ai-workflow-v1.4.0` commit `8595176`, 명령·출력·한계)를 모두 확인했다. 다만 아래 F1/F2 잔여 문구 두 건은 R1 교정 취지를 아직 완전히 닫지 못한다.

1. CP3 축②의 `CP2 실험이 target-state 실증 제공`은 `rfx generic/no-code target의 agent-first feasibility 증거 제공`으로 낮춘다. target-state 실증은 heterogeneous replay 전 provisional 경계와 충돌한다.
2. brief §②의 `tolerant JSON parser 채택 vs entry-format 계약 명시`에서 **single-line entry-format 계약화를 target option으로 제거**한다. 현 형식은 `grep` parser 제약으로 기록할 수 있지만 새 semantic contract로 고정하지 않고, 후속 비교는 tolerant parser 구현 방식·호환성 + 기존 `hash_algorithm/hash_mode`의 충분성으로 제한한다.

이 두 항목을 반영하면 R1 finding은 닫힌 것으로 보고 **S3(backlog 재우선순위 + STATUS 제안) 진입에 consensus**한다. S3 산출물은 예정대로 close 전 arbiter 최종 리뷰 대상으로 남는다.
