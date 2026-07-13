---
date: 2026-07-13
track: harness
type: evaluation
scope: agent 도구 발전 속 harness 구조의 장기 내구성 — 4축 retain/refactor/replace 판정과 revisit trigger
author: "agent:claude-fable-5"
related_work: [CHORE-20260713-001]
---

# Harness 장기 내구성 검토 — 4축 판정 (2026-07)

## 결론

**전면 rewrite는 불필요하다. 축별 판정: ① policy retain / ② upgrade·distribution refactor(provisional) / ③ tool projection refactor(rule surface 한정) / ④ enforcement refactor(보완).**

판정 전체를 관통하는 작업 가설(**bounded heuristic** — R1-Codex-F3에 따라 DR 승격 후보가 아니라 brief 가설로 유지하며, heterogeneous replay 후 재평가):

> **판단이 필요한 절차는 deterministic contract(경계 선언)와 verification(결정적 검증)이 갖춰져 있을 때 agent 위임을 기본 후보로 본다.** 단 deterministic scaffold, security gate, unattended/fleet 실행처럼 mechanism 자체가 load-bearing인 경우는 예외다.

"지난 복잡도 증가분의 대부분은 mechanism을 harness 측(script 절차·playbook·다층 온보딩 문서)에 축적한 비용"이라는 서술은 **inference**(문서·구조 검토에서의 유추)이며 실측 사실이 아니다. contract(manifest)·verification(`--check`, parity gate) 층의 실증 가치(리뷰 2라운드가 놓친 경계 위반 감지 — UF-01)는 **observed**다. 실측 근거와 실험 상세는 `docs/works/harness/CHORE-20260713-001-*.md` CP1~CP3 참조(이 brief에 중복 기재하지 않음).

## 질문/배경

3주 휴면 후 재가동 시점에 세 입력이 수렴했다: ⓐ adopter 4-repo 실측(backlog stale, version-skew), ⓑ reviewer(Codex)의 비공식 평가("harness를 위한 harness화"), ⓒ 사용자 방향 가설("절차 기계장치 없이 checklist+agent로 충분했던 것 아닌가"). 단일 rewrite-vs-refactor 판정 대신 4축 screening gate(임계값 R0b 확정) 통과 축만 분석했다.

**Evidence 3분류(R1-Codex-F4):** 이 brief의 서술은 다음으로 구분한다.
- **observed(실측):** adopter 4-repo inventory, upgrade 2건 동일 step 반복, rule surface block 복제, rfx 실험 결과·함정 재현, UF-01 감지 실적.
- **inferred(유추 — 사실로 승격 금지):** "복잡도 증가분 대부분 = mechanism 축적 비용", "scaffold와 upgrade는 같은 spec의 두 flow", "절차 위임이 upgrade logic의 유력 방향".
- **unobserved(미관측):** external manual adopter 경로, spring급 code/accepted-drift target replay, 비오염 operator replay, 최신 tool-native 기능(hook/plan mode/plugin marketplace/subagent) 현행 스펙(web 미검증, 2026-01 cutoff 지식 기준) — 축④ 실행 Work 착수 시 실측할 것.

## 축별 판정

### ① policy semantics — retain

Gate no-go(우회 실측 1건, 2026-05 Resolved 후 재발 없음, deadlock 0). Approval Matrix·state machine·manual-first 정체성이 작업을 막았다는 기록이 없다. "정책 과다" 인상(비공식 평가)은 실측 미지지로 기록한다. 신규 adopter 인지 부하는 별개 문제로 기존 P1(happy path/glossary)이 소유한다.

### ② distribution·upgrade — refactor (provisional → **해제됨 2026-07-13, 범위 한정**)

> **Amendment (CHORE-20260713-002):** heterogeneous replay(ai-deck-compiler — source-gitflow + accepted-drift 13 + code product)가 artifact 독립 재검증(`--check` 78/65/13, hash 78/78, 보존 13/13)을 통과해 provisional을 해제한다. **해제 범위는 "manifest 보유 heterogeneous target의 agent-first upgrade 방향"으로 한정** — 비오염 operator process 효율, external manual adopter, pre-manifest baseline acquisition은 unobserved residual로 유지한다. script/playbook 축소는 canary gate(비오염 operator 1건 또는 fresh-session canary 1건 재검증) 통과 전 default 전환·삭제 금지.

**유지(contract/verification):** manifest 계약(framework-owned 선언 + path/src 매핑), `--check` 검증, release tag baseline.
**방향(provisional — R1-Codex-F1):** playbook Phase 절차·shadow re-scaffold·수기 rebaseline → **agent-first 최소 체크리스트**. 근거는 rfx-hub 1.2.1→1.4.0 실험의 **feasibility**(generic/no-code target 1건, informed-driver 오염, 최종 artifact 동등성 71/72 in-sync는 공정 검증이나 process 비교는 비오염·재현 조건 아님). **heterogeneous replay(code/accepted-drift target 또는 비오염 operator) 1건 이상 전까지 provisional refactor direction으로 유지**하며, script/playbook 축소 실행 판정은 그 이후 gate로 남긴다.

후속 Work에서 비교·결정할 축(해결책 선결정 금지 — R1-Codex-F2):

1. **manifest parser/format** — single-line JSON은 semantic contract가 아니라 현행 `grep` parser의 구현 제약이며, **entry-format 계약화는 선택지에서 제외한다(R1b)** — 결함을 공식 API로 고정하지 않고 **tolerant JSON parser로 교정할 대상**으로 다룬다. 기존 `hash_algorithm`/`hash_mode` 필드의 충분/부족 정의 포함. 실험 교훈(observed): 문서화만으로는 함정을 못 막는다(알고도 밟은 pretty-print 함정).
2. **source ref metadata(별도 축)** — scaffold/upgrade 시 source `git describe` 기록으로 version-skew(rfx·toolstead 2건 observed) 구조 해소. DR-028 amendment 방향의 완성. `generated_at`의 의미(최초 scaffold 시점 vs rebaseline 시점) 계약 정의 포함 — rfx 실험에서 미정 상태 발견.
3. **scaffold/pack 동일 가설** — scaffold rewrite는 비목적(4~5회 무고통 observed). 신규 투자만 선언적 spec + agent flow 방향으로. "scaffold와 upgrade는 같은 spec의 두 flow"는 **inferred**(shadow re-scaffold 절차 구조에서 유추).

DR 영향 후보: DR-034 amend(upgrade 절차 방향 — provisional 해제 후), DR-028 정합(source ref). bounded heuristic의 DR 승격은 heterogeneous replay 전 비대상. Reversal cost: Low~Medium(manifest 표면 변경은 `--check` parser 변경 동반).

### ③ tool projection — refactor (rule surface 한정)

**canonical(`skills/`) + thin adapter 모델 자체는 retain** — workflow adapter 실측 15%(대부분 Step 0 boilerplate), 설계 의도대로 동작. cascade defect 2건은 모두 DR-040 parity gate 배선 이전이며 이후 재발 없음.

문제는 rule surface에 국한: commit-format normative block이 canonical+2 adapter에 복제, `.claude/rules/git-workflow.md`가 canonical 대비 32%. **신규 방향 불요** — 기존 backlog 후보 3건(thin-adapter화, UF-06 auto-merge canonical 변경, safety rule 축 A 정규화)이 이미 커버하므로 S3에서 우선순위 상향으로 처리한다. Reversal cost: Low.

### ④ enforcement·runtime — refactor (보완)

UF-01(문서 rule 위반이 실행 gate 부재로 review 2라운드 통과)이 screening 충족(material 해석은 R1 부기). 방향: 문서 rule을 **저비용 in-repo deterministic guard로 이중화**하되 §6 경계 기준(R0-Codex-F5) 준수 — guard는 canonical policy를 재정의하지 않고, repo 밖 persistent 저장은 금지.

후보(우선순위 순): ⓐ manifest-tracked 파일 수정 감지(UF-01/02 계열 — 기존 git hooks·repo-health 확장 우선), ⓑ UF-08 scaffold permission quick-fix(fixture gate 동반), ⓒ Claude PreToolUse hook 검토는 4-tool 비대칭이므로 보조 수단으로만(trigger-gated). Reversal cost: Low.

## Revisit Triggers

| Trigger | 재개방 대상 |
| --- | --- |
| ~~heterogeneous replay 1건+~~ **충족(2026-07-13, ai-deck replay)** — 축② 해제됨(manifest-target 한정) | 잔여 trigger: **비오염 operator 1건 또는 fresh-session canary 1건** → script/playbook 축소 default 전환 gate + bounded heuristic의 DR 승격 재평가 |
| 외부 manual adopter 첫 등장 또는 adopter ≥ 6 | 축② distribution(script 유지 필요성, plugin/marketplace 표면) |
| 다음 신규 프로젝트 adopt 시점 | scaffold-as-skill을 CP2 방식 실험으로 검증 |
| 축① 우회·단축 독립 2건+ 재관측 | 축① policy 재개방 |
| tool-native enforcement 지형 변화 실측(web 검증) | 축④ 수단 재평가 |
| go 축 후속 Work 2건+에서 canonical/adapter 구조가 장애로 관측 | 축③ 모델 재평가 |

## 연결

- Evidence·측정·gate 판정: `docs/works/harness/CHORE-20260713-001-direction-review-backlog-realignment.md`
- `harness-identity-policy-first-20260608.md` — "harness=policy layer" 방향과 일치. 이 brief는 그 위에 mechanism/contract 경계를 추가
- `harness-workflow-engine-vs-manual-first-20260615.md` — engine화가 아니라 "절차의 agent 위임"이라는 제3의 경로 확인
- `harness-distribution-plugin-model-20260608.md` — "배포 방식보다 upgrade logic 선행" 판단 유지. upgrade logic의 유력 방향이 절차 자동화가 아니라 절차 위임일 수 있다는 것은 **inferred/provisional**(heterogeneous replay 전 확정 금지)
