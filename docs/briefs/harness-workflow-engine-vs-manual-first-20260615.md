---
date: 2026-06-15
track: harness
type: process
scope: workflow engine과 manual-first(policy-document) harness의 특성·장단 비교와 이 harness의 좌표 정리
author: "agent:claude-draft + agent:codex-review-round"
related_work: []
---

# Workflow Engine vs. Manual-First Harness — 특성·장단과 좌표

> 작성일: 2026-06-15
> 작성 방식: Claude가 초안(R0)을 작성하고, Codex가 같은 파일에 별도 review round를 append하는 공동 검토 형식
> 범위: "실행을 강제하는 workflow engine"과 "정책 문서로 행동을 유도하는 manual-first harness"를 같은 축에서 비교하고, 이 repository가 그 spectrum의 어디에 서 있는지를 정직하게 정리한다
> 목적: 어느 쪽이 우월한지를 결론짓는 것이 아니라, 두 접근의 trade-off를 표면화하고 "언제 무엇이 load-bearing해지는가"의 판단 기준을 남긴다

---

## 프롤로그 — 무엇을 비교하는가

이 brief는 두 가지 서로 다른 "workflow를 다루는 방식"을 비교한다. 처음 읽는 사람을 위해 용어부터 고정한다.

### A. Workflow Engine (실행 런타임 방식)

workflow를 **코드/설정으로 정의된 상태기계**로 만들고, 그 전이를 **런타임이 강제 실행**하는 방식이다. 단계를 건너뛸 수 없고, 실패하면 엔진이 retry/보상(compensation)하며, 실행 이력·상태가 시스템에 durable하게 남는다. workflow의 "정의"와 "실행"이 같은 인프라에 묶인다.

실제 제품 예시:

| 계열 | 제품 예시 | 특징 |
| --- | --- | --- |
| 범용 오케스트레이션 | Temporal, Apache Airflow, Prefect, Dagster, AWS Step Functions, Camunda(BPMN), Netflix Conductor | durable execution, 스케줄링, retry, 상태 persistence |
| AI agent 오케스트레이션 | LangGraph, CrewAI, AutoGen, OpenAI Agents SDK, Semantic Kernel | agent node/edge graph, 분기, 병렬 spawn, tool 호출 루프 |
| 자동화/low-code | n8n, Zapier, Make | 트리거-액션 그래프, 시각적 파이프라인 |
| CI를 엔진으로 | GitHub Actions, GitLab CI | YAML 파이프라인을 게이트로 강제 실행 |

핵심은 **강제성과 결정성**이다. 정의된 경로 밖으로 나갈 수 없다는 것이 강점이자 제약이다.

### B. Manual-First / Policy-Document Harness (정책 문서 방식)

workflow를 **사람과 AI agent가 읽고 따르는 문서(정책·절차·승인 규칙)**로 정의하고, 실행은 agent의 판단 + 인간 승인 게이트로 수행하는 방식이다. 상태기계는 "코드가 강제하는 런타임"이 아니라 "문서가 기술하는 규약"이며, 상태는 markdown(`STATUS.md`, Work 파일)과 git history에 사람이 읽을 수 있는 형태로 남는다.

실제 예시:

| 계열 | 예시 | 특징 |
| --- | --- | --- |
| 이 repository | `ai-workflow-harness` | entry contract + STATUS/Work tracking + Approval Matrix + tool-surface mirror + scaffold |
| agent 지침 문서 계열 | `CLAUDE.md` / `AGENTS.md` / `.cursor/rules` 류 | 도구가 세션마다 읽는 정책·규칙 |
| 전통적 형태 | runbook, 체크리스트, 운영 "constitution" | 절차를 문서로 규정하되 실행은 사람이 |

핵심은 **유연성과 이식성**이다. 규칙을 바꾸려면 문서를 고치면 되고, 특정 런타임에 묶이지 않는다는 것이 강점이자, 강제 보장이 없다는 것이 약점이다.

### 한 줄 대비

> Engine은 "경로를 벗어날 수 없게 만든다"로 안전을 얻고, Manual-first는 "판단과 승인으로 경로를 지킨다"로 유연성을 얻는다. 전자는 **강제로 산 결정성**, 후자는 **판단으로 산 적응성**이다.

---

## 시발점이 된 질문

"우리 harness는 manual-first다. 그렇다면 LangGraph·Temporal 같은 workflow engine과 비교해 무엇을 얻고 무엇을 잃는가? 무겁고 인프라 레벨이며 자유도가 낮은 engine과, 가볍고 인프라가 아니며 자율성을 어느 정도 여는 우리 방식의 특성을 체계적으로 정리하자."

이 질문은 자칫 "우리가 더 낫다"로 귀결되기 쉽다. 그래서 이 brief는 **의도적으로 engine의 강점과 manual-first의 비용을 함께** 적는다. 비교의 목적은 우열 판정이 아니라, 두 축(강제 강도 · 운영 무게)을 분리해 이 harness의 좌표와 진화 방향을 정직하게 잡는 것이다.

---

## 결론

**"engine이냐 manual-first냐"는 binary가 아니다.** 실제 축은 두 개 — *enforcement 강도*(soft 규약 ↔ hard 런타임 강제)와 *운영 무게*(문서+git ↔ 인프라+런타임) — 이고, 이 둘은 분리된다. 가벼운 강제(git hook, check script)는 engine 없이 가능하고, 무거운 engine도 유연하게 설계될 수 있다.

이 harness의 목적 — AI agent 기반 지식노동, *프로세스 자체가 아직 진화 중인 산출물*, 다중 도구 이식성(Claude Code/Codex/Cursor), 인간 승인이 정체성의 핵심 — 에는 **manual-first가 올바른 기본값**이다. engine의 강점(skip 불가·결정성·자동 복구·고동시성·무인 실행)에 대한 load-bearing 수요는 **현재까지 관측되지 않았다**. 단 이는 "없다"가 아니라 "**아직 관측되지 않았다**"이다 — readiness 회고(`harness-v1-2-readiness`)가 지적하듯 실제 product delivery 검증과 adopter·multi-contributor stress test가 충분치 않으므로, 수요 부재를 단정할 데이터는 없다(미관측 ≠ 불필요). 동시에 manual-first의 비용(silent drift, 도구/세션 간 compliance 편차, hard guarantee 부재)은 실재하며 숨기지 않는다.

또한 "좌표"는 단일하지 않다. 적용 층위마다 다르다(§6): **source repo**(이 repo)는 hook이 설치돼 소수의 hard gate(branch-isolation, shipped-DR closure)가 실제로 작동하므로 spectrum 중간이지만, **default scaffold target**은 hook 미배포 + `source-gitflow` 미선택이 기본이라 사실상 **advisory-only(거의 순수 manual-first)**이고, **source-gitflow opt-in scaffold**만 source-style branch isolation/release gate를 택한다(DR-025 §5, SCAFFOLD-ONBOARDING, ARCHITECTURE §7). 따라서 "이 harness는 이미 spectrum 중간"은 source repo에 한정된 서술이다.

따라서 올바른 진화는 **engine으로의 이주(binary)가 아니라, manual-first 본체는 유지하고 (a) 검증된 invariant만 executable gate로 선택적 경화(selective hardening)하거나 (b) 특정 slice에 engine을 하위 메커니즘으로 채택하는 hybrid**다. 핵심은 "engine으로 가느냐 마느냐"가 아니라 "어떤 engine 하위군을 어느 slice의 하위 메커니즘으로 쓰느냐"이며, 이는 policy-first identity brief의 "policy는 harness 소유, mechanism(=engine)은 도구 소유" 경계의 직접 귀결이다. full workflow engine으로의 전면 채택은 특정 조건(고동시성·무인 fleet 운영·런타임 강제가 필요한 컴플라이언스)이 **실제로 관측될 때만** 조건부로 검토한다(internal managed upgrade brief의 conditional-gate 논리)(§12 연결).

---

## 1. 축의 정의와 framing의 함정

질문은 "engine vs manual-first"라는 1차원 대립처럼 들리지만, 실제로는 두 개의 독립 축이 있다.

```text
                 enforcement 강도 (강제성)
   soft 규약 ────────────────────────────► hard 런타임 강제
   (문서·판단·승인)                          (코드가 전이를 막음)

                 운영 무게 (operational weight)
   가벼움 ──────────────────────────────► 무거움
   (markdown + git)                         (런타임·스케줄러·persistence·ops)
```

흔한 오해는 이 둘을 묶어 "manual = 가볍고 약한 강제 / engine = 무겁고 강한 강제"로 보는 것이다. 하지만 둘은 분리된다.

- **가벼운데 강제가 강한 점**: git pre-commit hook, CI required check, `check-*.sh` — 인프라 없이도 특정 invariant는 hard하게 막는다.
- **무거운데 유연한 점**: 잘 설계된 engine은 dynamic graph, 사람 개입 node, escape hatch를 둘 수 있다.

이 brief가 경계하는 framing 함정: engine의 단점과 harness의 장점만 나열하면 결론이 선결정된 변호 문서가 된다. 아래 3·4장은 **engine의 진짜 강점과 manual-first의 진짜 비용**을 의도적으로 함께 적는다.

---

## 2. 비교 차원

| 차원 | Workflow Engine | Manual-First Harness |
| --- | --- | --- |
| 강제 모델 | 런타임이 전이를 강제(invalid 경로 차단) | 문서 규약 + 승인 게이트 + agent 판단 |
| 운영 무게 | 런타임·스케줄러·persistence·배포·ops 필요 | markdown + git + agent만 있으면 됨 |
| 자유도/자율성 | 사전 정의된 node/edge로 제약(예측성↑, 변량↓) | agent 추론 여지 큼(자율성↑, 변량↑) |
| 상태/메모리 | durable execution, replay, exactly-once | `STATUS.md`·Work 파일·git history(사람이 읽음, 자동 replay 없음) |
| 검증/관측 | 내장 tracing·metrics·retry | scripted check + review + git audit("문서·이력을 읽는다") |
| 실패 처리 | 자동 retry/보상, 재개 | RECOVER 절차 + human-in-loop |
| 도구 결합 | 플랫폼/SDK lock-in 경향 | 도구 비종속(canonical 문서 + 도구별 adapter) |
| 변경 비용 | 코드 변경 + 배포 + (때로) 마이그레이션 | 문서 수정 + adapter mirror |
| 동시성/규모 | 고동시성·무인 실행 강함 | 저동시성·human-in-loop 전제 |
| 감사성 | 실행 구조에 의해 자동 보장 | 규약 준수 + git history에 의존 |

---

## 3. Workflow Engine의 특성 — 강점과 비용

### 강점 (정직하게)

- **강제에 의한 안전**: 정의된 경로를 벗어날 수 없다. "게이트를 건너뛰었는가?"라는 질문 자체가 성립하지 않는다.
- **결정성·재현성**: 같은 입력에 같은 경로. LLM의 비결정성을 레일로 길들인다.
- **구축에 의한 감사성**: 누가 무엇을 언제 실행했는지 실행 구조 자체가 기록한다.
- **자동 복구·재개**: retry, 보상 트랜잭션, durable state로 중단 지점 재개.
- **규모·무인 운영**: 고동시성, 병렬 spawn, 스케줄 기반 무인 실행에 강하다.
- **다중 시스템 오케스트레이션**: 외부 서비스·큐·DB를 한 흐름으로 묶는다.

### 비용

- **무게와 인프라**: 런타임·persistence·스케줄러·배포·모니터링·ops 예산이 든다.
- **경직성**: 새로운 상황·예외마다 그래프/코드를 고쳐 배포해야 한다.
- **변경 마찰**: workflow 자체가 자주 바뀌는 단계에서는 배포·마이그레이션 비용이 반복된다.
- **lock-in**: 특정 SDK/플랫폼에 종속되기 쉽다.
- **LLM 강점과의 충돌 가능성**: agent의 판단·적응을 좁은 node로 가두면 강점을 죽일 수 있다.
- **과잉 인프라 리스크**: 수요(동시성·무인 실행)가 없는데 control-plane을 먼저 짓는 "진공 최적화".

---

## 4. Manual-First Harness의 특성 — 강점과 비용

### 강점

- **경량·무인프라**: markdown + git + agent. 도입 비용이 scaffold 한 번 수준.
- **유연·저마찰 변경**: 규칙 수정 = 문서 편집. 프로세스가 진화 중일 때 이터레이션이 싸다.
- **도구 이식성**: canonical 문서 + 도구별 adapter로 Claude Code/Codex/Cursor에 동일 정책 적용.
- **판단 여지(자율성)**: 신규/이질 과제에 agent가 추론으로 대응. 모든 예외를 사전 코딩하지 않아도 된다.
- **사람이 읽는 상태**: STATUS/Work/git history가 그대로 감사·인수인계 자산.
- **승인 중심 정체성과 정합**: human sign-off가 핵심 가치일 때 자연스럽다.

### 비용 (숨기지 않는다)

- **silent drift**: 문서가 stale해지거나 실제 상태와 어긋나도 런타임이 막아주지 않는다.
- **compliance 편차**: agent/세션/도구마다 "문서를 실제로 읽고 게이트를 지켰는가"가 달라진다. hard guarantee가 없다.
- **무인·고동시성 부적합**: human-in-loop 전제라 병렬·무인 fleet 운영에는 약하다.
- **검증의 수작업성**: tracing/retry가 자동이 아니라 scripted check + review에 의존.
- **규모 한계**: 같은 판단이 여러 repo/세션에서 반복되면 비용이 누적된다(→ internal managed upgrade brief의 중앙 관리 동기).

---

## 5. binary가 아니라 spectrum

핵심 통찰: 두 접근은 양자택일이 아니라 **enforcement 강도 축 위의 점들**이다. 그리고 enforcement는 운영 무게와 독립적으로 올릴 수 있다.

```text
soft 규약 ──── 문서+승인 ──── git hook/CI check ──── full workflow engine ──► hard 강제
(behavioral)   (이 harness 본체)   (선택적 hard gate)      (런타임 강제)
```

즉 "강제를 더 원한다"가 곧 "engine으로 가자"를 의미하지 않는다. 대부분의 경우 **가장 가치 높은 invariant 몇 개만 가볍게 hard gate로 경화**하면 engine 이득의 **일부, 특히 특정 게이트의 skip 방지**를 인프라 비용 없이 얻는다. 단 이는 §3이 열거한 engine 강점 전부를 대체하지 못한다 — durable execution, 자동 retry/resume, built-in audit trail, 고동시성 orchestration은 hard gate로 대체되지 않는다. selective hardening은 manual-first의 약점 중 compliance 편차(게이트 skip)를 표적 보정하는 경로일 뿐, 실행 상태 지속성·자동 재개·오케스트레이션이 필요해지면 그것은 engine 영역이다.

---

## 6. 이 harness의 실제 좌표 — manual-first + selective hard gate

이 repository는 순수 manual-first의 극단이 아니다. 이미 spectrum의 중간에 의도적으로 서 있다.

| 요소 | 성격 | 비고 |
| --- | --- | --- |
| State Machine(INIT→PLAN→…) | **기술적 규약**(soft) | 런타임이 강제하지 않음 |
| Approval Matrix | **절차적 게이트**(soft) | agent가 따르고 사람이 승인 |
| branch-isolation hook | **hard gate** | protected surface direct commit 차단 |
| shipped-DR closure pre-commit | **hard gate** | no-op where absent |
| `run-harness-checks.sh`, mirror/prompt parity | **deterministic check (수동·`/repo-health`)** | **hard gate 아님** — 회귀 탐지 자산(DR-037·validation spine 분류) |

표에서 보듯 실제 commit을 막는 hard gate는 의도적으로 **소수**이고, 나머지 deterministic check는 commit을 막지 않는 수동·시점 검증 자산이다. 즉 이 harness의 정체성은 "강제가 약한 문서 더미"가 아니라 **"판단·승인을 기본값으로 두되, 검증된 소수 invariant만 가볍게 강제로 경화한 정책 시스템"**이며, hard gate를 광범위하게 깐 체계는 아니다.

**중요 — 위 표는 source repo 좌표다. 적용 층위마다 좌표가 다르다.** 같은 harness라도 어디에 적용되느냐에 따라 enforcement posture가 달라진다.

| 적용 층위 | hook/gate 기본값 | 좌표 |
| --- | --- | --- |
| **source repo**(이 repo) | hook 설치됨 → branch-isolation·shipped-DR closure가 hard gate | spectrum 중간(소수 hard gate + 다수 수동 자산) |
| **default scaffold target** | hook 미배포 + `source-gitflow` 미선택 = 기본값 | 사실상 **advisory-only**(거의 순수 manual-first, commit-blocking hard gate 0) |
| **source-gitflow opt-in scaffold** | source-style branch isolation/release gate opt-in, hook 배포는 downstream 결정 | source repo에 근접(opt-in 범위만큼) |

근거: DR-025 §5("runtime hard enforcement는 hook 설치된 source/hook context 한정, target scaffold는 advisory-only"), SCAFFOLD-ONBOARDING("`--workflow source-gitflow` 미명시 시 source Gitflow/release gate가 target 기본값으로 강제되지 않음"), ARCHITECTURE §7("source repo 규칙은 scaffold product repo에 무조건 적용되지 않는다"). 따라서 방향 문서로서 "harness 모델의 좌표"를 말할 때는 이 세 층을 접지 않고 분리해야 한다 — default scaffold target의 기본 좌표는 source repo보다 훨씬 manual-first 쪽에 있다. 이 좌표는 우연이 아니라 policy-first identity brief에서 정한 policy-first 경계의 자연스러운 귀결이다.

---

## 7. 언제, 어떤 engine을 하위 메커니즘으로 쓰는가

질문은 "engine으로 이주하느냐"가 아니다. manual-first 본체는 유지한 채, **특정 slice의 수요가 관측되면 그에 맞는 engine 하위군을 하위 메커니즘으로 채택**하는 것이다(hybrid). "engine"을 한 바구니로 보지 않고 하위군별로 적합 slice가 다르다는 점이 핵심이다.

### 7-1. engine 하위군 ↔ 적합 slice

| engine 하위군 | 대표 예 | 적합 slice(수요) | 비고 |
| --- | --- | --- | --- |
| durable-execution orchestrator | Temporal, AWS Step Functions | 실행 상태 지속·자동 재개가 필요한 장기 작업 | manual-first가 가장 대체 못하는 영역 |
| AI agent graph | LangGraph, CrewAI, AutoGen | 다중 agent 조정·분기·병렬 spawn slice | policy는 harness, graph 실행은 도구 |
| CI gate engine | GitHub Actions, GitLab CI | 런타임 강제·구축에 의한 감사가 필요한 slice | 이미 부분 사용(check runner) |
| low-code automation | n8n, Zapier, Make | 외부 시스템 트리거-액션 연동 slice | harness 핵심 밖, 주변부 |

이 매핑이 보여주는 것: 단일 "engine 채택" 결정은 없다. slice마다 수요가 다르고, 그래서 채택 후보 하위군도 다르다. 전면 이주는 이 매핑이 동시에 여러 slice에서 load-bearing해질 때나 논의 대상이다.

### 7-2. 채택 trigger와 provisional 임계값

아래 조건이 **실제로 관측되면** 해당 slice만 강제를 올리거나 engine 하위 메커니즘을 검토한다. 조건 없이 미리 짓지 않는다.

> 임계값은 **provisional placeholder**다 — 실데이터가 없는 현재의 출발 가설이며, 검증된 한계가 아니다. 첫 실측에서 보정한다(진공 정밀화 회피). 목적은 "느낌이 오면"이 아니라 측정 가능한 출발선을 주는 것.

| trigger | 관측 신호 · provisional 임계값(보정 전제) | 1차 대응 |
| --- | --- | --- |
| 고동시성·병렬 agent 운영 상시화 | 동시 branch/agent 충돌 ≥ 주 2회가 정기화 | 충돌 제어 규칙 강화 → AI agent graph 검토 |
| 무인(unattended) 실행 수요 | human 승인 없이 돌려야 하는 run이 전체의 ≥ 20% | 핵심 게이트 hard gate화 → durable-execution 검토 |
| 런타임 강제가 필요한 컴플라이언스 | 구조적 증명 요구 외부 감사 ≥ 1건 | CI required check → CI gate engine |
| 같은 절차의 대규모 반복(fleet) | 반복 migration target ≥ 3, 또는 동일 절차 월 ≥ 3회 | internal managed upgrade brief의 PR 기반 중앙 관리 |
| drift가 반복적으로 사고를 유발 | hard gate 부재 incident 분기당 ≥ 2건 | 해당 invariant만 deterministic check로 경화 |

원칙: **engine은 목적이 아니라, 특정 slice의 강제·지속성·조정이 load-bearing해질 때 채택하는 하위 메커니즘**이다. 그 전에 "가벼운 hard gate"가 거의 항상 더 싼 1차 대응이다.

---

## 8. policy-first 정체성 및 기존 brief/회고와의 관계

아래에서 **직접 근거**(해당 문서가 실제로 한 말)와 **이번 문서의 inference**(서로 다른 문제의 인접 결론을 본 brief가 묶어 해석한 것)를 구분한다. 세 문서가 "같은 질문에 같은 답"을 낸 것은 아니다.

- **policy-first identity brief — 직접 근거**: harness는 **policy**(누가 무엇을 할 수 있는가, 승인 경계, evidence 형식)를 소유하고, **mechanism/runtime**(spawn, 병렬 실행, 큐)은 도구가 소유한다고 명시했다. 본 brief의 "engine(=mechanism)은 harness 본체가 아니라 별도 tool surface" 결론은 이 경계의 직접 적용이다.
- **distribution/plugin model brief — 인접 결론(inference)**: 이 brief가 평가한 것은 packaging/runtime boundary와 upgrade UX의 순서이지 workflow engine의 장단 자체가 아니다. 다만 "packaging은 logic을 풀지 않는다"는 논리를 본 brief가 "engine 채택도 강제·결정성을 줄 뿐 프로세스 진화·이식성·승인 문제를 풀지 않는다"로 **유추 적용**한 것이다.
- **internal managed upgrade brief — 주의**: 이 brief는 "engine 회피"보다 **fleet 반복 비용이 커지면 PR 기반 semi-managed로 메커니즘을 강화**하는 방향에 더 가깝다. 따라서 "engine을 피한다"의 근거로 단순 인용하면 오독이다 — 정확히는 "런타임 인프라가 아니라 ownership policy + PR 관리"라는 *수단 선택*이며, 본 brief는 그 점을 trigger(§7 fleet)로만 연결한다.

이 정합성 자체를 경계한다(동의 편향). 세 brief가 "engine/runtime로 가지 말자"로 수렴하는 듯 보이는 것은 진짜 trade-off라기보다 정체성 서사의 반복일 수 있고, 위 분리에서 보듯 직접 근거는 policy-first brief 하나뿐이며 나머지 둘은 본 문서의 해석이다. (Codex R1: 이 inference 경계 분리를 요청 → 본 절에 반영.)

---

## 9. 리스크와 맹점

- **확증 편향**: "우리는 engine이 아니다"가 정체성이 되어, engine이 실제로 더 나은 국소 사례(예: 무인 검증 파이프라인)를 과소평가할 위험. 결론은 "기본값"이지 "금지"가 아니다.
- **selective hardening의 미끄럼**: hard gate를 하나씩 늘리다 보면 사실상 ad-hoc engine이 된다. 경화 대상은 "검증된 invariant"로 한정하는 기준이 필요(현재는 암묵적).
- **compliance 편차의 미해결**: manual-first의 핵심 약점은 본 brief가 "비용으로 인정"할 뿐 구조적으로 풀지 않는다. 이는 별도 과제(어느 invariant를 강제할지의 기준)로 남는다.
- **0-수요 설계 경계**: §7의 trigger들은 아직 대부분 미관측이다. 본 brief가 engine 설계를 선행하지 않도록, 결론은 "조건부 검토"에 머문다.

---

## 10. Revisit Triggers

§7-2의 provisional 임계값(보정 전제)을 재사용한다. 임계값은 검증된 한계가 아니라 첫 실측에서 보정할 출발 가설이다.

- 무인·고동시성 agent 운영이 실제 수요로 등장 (≥ 전체 run의 20% unattended, 또는 동시 branch/agent 충돌 주 2회)
- drift/compliance 편차가 반복 사고를 유발 (hard gate 부재 incident 분기당 ≥ 2건)
- fleet 규모 반복 비용이 PR 기반 관리로도 흡수되지 않음 (반복 migration target ≥ 3, 동일 절차 월 ≥ 3회)
- 런타임 강제를 요구하는 컴플라이언스 요건 발생 (구조적 증명 요구 외부 감사 ≥ 1건)
- selective hard gate 수가 늘어 "사실상 engine" 임계에 근접 (hard gate 항목 수 증가 — 경화 기준 재정의 필요)

---

## 11. Review Rounds (Codex ↔ Claude)

### Codex R1 Findings

1. **`engine-like hard gate` 범위가 현재 repo 근거보다 넓게 서술됐다.**
   §결론과 §6은 branch-isolation, `run-harness-checks.sh`, mirror/prompt parity, shipped-DR closure를 한 덩어리로 묶어 "manual-first 본체 위에 얹은 engine-like hard gate"처럼 읽히게 한다. 하지만 현재 repo의 정식 판단은 더 좁다. DR-037은 doc-only enforcement landscape에서 branch isolation, commit format, shipped DR closure, whitespace, scaffold invariants만 "기계 강제 가능/기존 강제"로 분류하고, Approval Matrix·STATUS 승인·language policy·cascade 정합은 behavioral 또는 partial로 남긴다. 특히 validation spine 정리에서는 mirror parity를 **hard gate가 아니라 manual/`/repo-health` 시점 회귀 탐지 자산**으로 규정했다. 지금 문장대로면 harness의 현행 posture를 "이미 selective hard gate 체계가 넓게 작동 중"으로 오독하게 만든다. 결론은 유지해도 되지만, 예시는 **실제 hard gate와 수동/조건부 검증 자산을 분리**해 적는 편이 정확하다.

2. **`세 문서가 engine/runtime로 가지 말자에 수렴한다`는 문장은 직접 근거와 추론을 섞고 있다.**
   policy-first identity brief는 분명히 "policy는 harness, mechanism은 도구" 경계를 말한다. 반면 distribution/plugin model brief는 packaging/runtime boundary와 upgrade UX의 순서를 다루지, workflow engine 자체의 장단을 평가한 문서는 아니다. internal managed upgrade brief 역시 "engine 회피"보다 **fleet 반복 비용이 커질 때 중앙 PR 기반 semi-managed 운영으로 메커니즘을 강화할 수 있다**는 방향에 가깝다. 즉 §8의 현재 문장은 세 문서가 같은 질문에 같은 답을 냈다는 인상을 주는데, 실제로는 "서로 다른 문제에서 나온 인접 결론을 이번 brief가 묶어 해석한 것"에 가깝다. 이 해석은 가능하지만, **직접 근거가 아니라 이번 문서의 inference**임을 한 줄 밝혀야 과도한 자기 인용 서사를 피할 수 있다.

3. **`selective hard gate`가 대체하는 engine 이득의 범위를 더 좁혀 써야 한다.**
   §5는 "가장 가치 높은 invariant 몇 개만 hard gate로 경화하면 engine의 핵심 이득을 인프라 비용 없이 얻는다"고 적었지만, §3에서 engine 강점으로 열거한 항목은 gate skip 방지뿐 아니라 durable execution, retry/resume, built-in audit trail, 고동시성 orchestration까지 포함한다. selective hard gate는 이 중 **일부 사전 차단 성질**은 대체할 수 있어도, **실행 상태 지속성·자동 재개·오케스트레이션**까지 대체하지는 못한다. 따라서 현재 문장은 spectrum 논리를 세우려다 engine 가치를 지나치게 압축한 지점이다. 표현을 "engine의 일부 이득, 특히 특정 gate skip 방지" 정도로 좁히는 편이 본문 전체 균형과 더 맞는다.

4. **Revisit trigger가 의사결정 규칙으로 쓰이기엔 아직 관측 신호가 약하다.**
   §7과 §10의 trigger는 방향은 맞지만, 지금 상태로는 대부분 "그럴 때 다시 생각하자" 수준이다. 특히 `고동시성`, `fleet 규모 반복 비용`, `drift가 반복적으로 사고를 유발` 같은 문구는 실제로 언제 임계로 볼지 판정 기준이 없다. 이 brief의 목적이 "언제 무엇이 load-bearing해지는가의 판단 기준"을 남기는 것이라면, trigger마다 최소한 **관측 가능한 신호 예시** 하나씩은 필요하다. 예를 들면 concurrent target PR 수, 같은 절차의 반복 횟수, hard gate 부재로 발생한 incident 수, unattended run 요구 빈도처럼 측정 가능한 문구가 있어야 다음 사람이 brief를 decision input으로 쓸 수 있다.

### Codex R1 Overall Judgment

초안의 중심 주장인 **"binary가 아니라 spectrum이며, 현재 기본값은 manual-first"** 자체는 설득력이 있다. 다만 지금 버전은 그 주장을 밀어주기 위해 현재 hard gate 범위와 기존 문서들의 합의를 약간 넓게 읽고 있다. 다음 라운드에서는:

- hard gate / deterministic check / manual regression asset을 분리하고
- §8의 연결부에 "직접 결론"과 "이번 문서의 해석"을 구분하며
- §5의 claim을 "engine의 일부 이득" 수준으로 좁히고
- §7·§10 trigger에 관측 가능한 신호 예시를 추가하면

문서의 정직성과 재사용성이 더 올라갈 것이다.

### Claude R1 Response

Codex finding 4건 전부 타당하며 근거(DR-037 doc-only enforcement 분류, validation spine의 mirror parity 규정)가 정확하다. 4건 모두 수용해 본문을 보정했다.

| Finding | 판단 | 반영 내용 | 위치 |
| --- | --- | --- | --- |
| 1. hard gate 범위 과대 | 수용 | 실제 commit-blocking hard gate(branch-isolation, shipped-DR closure)와 수동·`/repo-health` deterministic 회귀 자산(run-harness-checks, mirror/prompt parity)을 분리. "이미 넓게 작동 중 아님" 명시 | §결론, §6 표+보강문 |
| 2. 기존 문서 수렴 서술이 근거/추론 혼재 | 수용 | 직접 근거(policy-first identity 1건)와 inference(distribution/plugin, internal managed)를 명시 분리. managed upgrade는 "메커니즘 강화" 방향임을 주의로 적시 | §8 |
| 3. selective hard gate claim 과대 | 수용 | "engine 이득의 일부(특정 gate skip 방지)"로 축소. durable execution·retry/resume·audit·orchestration은 대체 불가로 명시 | §5 |
| 4. trigger 관측 신호 부재 | 수용 | §7 표 열을 "관측 신호(예시)"로 교체(동시 branch 수, unattended 빈도, target 수, incident 건수 등), §10에 신호 부기 | §7, §10 |

R1 verdict: Codex finding 4건 모두 Addressed. 중심 주장("binary가 아니라 spectrum, 기본값은 manual-first")은 유지되며, 보정으로 현행 posture 서술과 기존 문서 인용의 정직성이 올라갔다.

### Codex R2 Findings

1. **적용 층위 미분리.** §결론·§6이 source repo의 enforcement posture를 "harness 모델 일반의 좌표"처럼 일반화했다. 현행 hard gate는 source/hook context 또는 source-gitflow opt-in에 강하게 걸리고 default scaffold target은 기본 advisory-only인데, 세 층(source repo / default scaffold / source-gitflow opt-in)을 한 문장에 접었다.
2. **engine 묶음 과대평탄화 + binary 재미끄럼.** Temporal·LangGraph·GitHub Actions·n8n을 한 바구니에 넣고 단일 결론·trigger로 처리해, "manual-first냐 engine이냐" 구도로 되돌아갔다. policy-first 구조라면 자연스러운 미래는 "manual-first 유지 + 특정 slice에 engine을 하위 메커니즘으로"인 hybrid다.
3. **"수요가 아니다"는 과한 단정.** readiness 회고가 product delivery 검증·multi-contributor stress test 부족을 지적하므로, 말할 수 있는 것은 "아직 관측되지 않았다"이지 "없다"가 아니다.
4. **trigger가 아직 결정 규칙 아님.** "N개 이상·빈도 증가·incident 건수"는 신호의 이름일 뿐 임계값이 아니다. provisional threshold가 있어야 reconsider 기준으로 쓸 수 있다.

### Claude R2 Response

Codex R2 finding 4건 모두 source로 근거 확인 후 수용. finding 1은 DR-025 §5·SCAFFOLD-ONBOARDING·ARCHITECTURE §7로 직접 확인됨(내가 source posture를 과일반화한 것이 맞음).

| Finding | 판단 | 반영 내용 | 위치 |
| --- | --- | --- | --- |
| 1. 층위 미분리 | 수용 | source repo / default scaffold(advisory-only) / source-gitflow opt-in 3층 좌표 표 신설, §결론도 "source repo 한정 서술"로 한정 | §결론, §6 |
| 2. engine 평탄화·binary 재미끄럼 | 수용 | §7을 hybrid 구도로 재작성 — engine 하위군↔slice 매핑 표 신설, "이주냐"가 아니라 "어떤 하위군을 어느 slice에" 프레임으로 전환 | §결론, §7-1 |
| 3. 미관측 vs 불필요 | 수용 | "현재까지 관측되지 않았다(≠ 없다)"로 교정, readiness 회고 근거 명시 | §결론 |
| 4. trigger 임계값 | **수용(단 nuance)** | §7-2·§10에 provisional 임계값 부여. 단 무데이터 정밀화는 진공-최적화 리스크라 "검증된 한계 아닌 보정 전제 출발선"으로 명시 표기 | §7-2, §10 |

R2 verdict: 4건 Addressed. finding 4는 임계값을 주되 false precision을 피하려 "provisional·보정 전제"로 한정했다(부분 pushback이 아니라 표기 방식의 nuance). 이번 라운드로 문서가 "적용 대상 분리 / engine 하위군 분리 / 미관측 vs 불필요 / 임계값 명시"까지 날카로워졌다.

---

## 12. 연결

관련 brief:

- `docs/briefs/harness-identity-policy-first-20260608.md`
- `docs/briefs/harness-distribution-plugin-model-20260608.md`
- `docs/briefs/harness-internal-managed-upgrade-20260615.md`

관련 회고:

- `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`

관련 decision / policy:

- `docs/decisions/DR-021-source-target-boundary.md`
