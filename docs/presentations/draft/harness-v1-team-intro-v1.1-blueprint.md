# Presentation Blueprint

```
Title:      AI와 함께 개발하기: Vibe Coding & AI Workflow Harness 실전 입문
Version:    v1.1
Author:     박경서 <Kyungseo.Park@gmail.com>
Date:       2026-05-16
Target:     29 slides / 30 min
Audience:   발표자의 개인 프로젝트 과정과 AI Workflow 전파 시도를 이해할 개발팀 내부 구성원
Final Deck: docs/presentations/harness-v1-team-intro-v1.1.pptx
```

---

## Brief Alignment

| Attribute | Decision |
| --- | --- |
| Purpose | 개인적 Vibe Coding 실험에서 출발한 프로젝트 여정을 공유하고, 그 과정에서 만들어진 AI Workflow Harness v1을 팀에도 적용 가능한 baseline으로 설명한다. |
| Audience | 기본적인 AI chat 또는 code assistant 사용 경험은 있으나, Agentic Coding, Context Engineering, Harness Engineering에는 익숙하지 않은 개발자. |
| Format | PPTX, 16:9, 30분 발표. 초안은 템플릿 없이 자체 visual system으로 구성하고, 추후 template 적용을 전제로 한다. |
| Source Context | `docs/STATUS.md`, `docs/AGENT-WORKFLOW.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-PROTOCOL.md`, `docs/harness-protocol/*.md`, `docs/decisions/DR-007-language-policy.md`, `docs/presentations/harness-v1-intro-polished-20260516.pptx`. |
| Tone & Style | Personal narrative + practical engineering. 개인적 시행착오에서 출발하되, 팀에 공유 가능한 구조로 어떻게 일반화했는지 설명한다. |
| Quality Bar | 초보자가 흐름을 놓치지 않도록 개념은 쉽게, 구조는 도식 중심으로, 적용 가이드는 따라 할 수 있는 manual 형식으로 구성한다. |

## Narrative Spine

1. 출발점은 개인적으로 AI와 빠르게 코딩해보려는 Vibe Coding 접근이었다.
2. 개인 실험을 반복하면서 prompt만으로는 맥락, 범위, 검증, 재개 문제가 해결되지 않는다는 것을 확인했다.
3. 그래서 Spring Boot MSA Template이라는 실제 개발 타겟을 두고, 개인 workflow를 검증 가능한 Harness로 발전시켰다.
4. Lightweight Manual-First AI Workflow Harness v1은 이 개인적 실험을 팀에 설명하고 공유 가능한 운영 기준으로 끌어올린 결과다.
5. v1은 나의 개인 workflow baseline이고, 팀 레벨로 전파하려면 v2에서 hook, CI, SSOT config 같은 강제력과 자동화를 더해야 한다.

## Concept Model

Vibe Coding을 순차 단계의 첫 칸으로 두지 않는다. Vibe Coding은 AI와 함께 빠르게 만들고 조정하는 상위 작업 방식이며, 아래 세 engineering 관점이 이를 실무적으로 안정화한다.

```text
                    Vibe Coding
        자연어로 빠르게 만들고, 실행하며, 조정하는 작업 방식
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
 Prompt Engineering   Context Engineering   Harness Engineering
 요청 품질 설계        맥락과 기준점 설계      승인·검증·복구 절차 설계
```

**Clarification**

- Prompt Engineering, Context Engineering, Harness Engineering은 Vibe Coding 이후에 순차적으로 지나가는 단계가 아니다.
- 세 관점은 Vibe Coding을 반복 가능한 개발 방식으로 만들기 위한 supporting layers다.
- Harness Engineering은 prompt와 context를 대체하지 않는다. 둘을 내가 반복해서 따를 수 있는 운영 절차, 승인 조건, 검증 루프 안에 넣는다.

## Source Traceability

| Topic | Source |
| --- | --- |
| 현재 상태 | `docs/STATUS.md` |
| 공통 workflow 규칙 | `docs/AGENT-WORKFLOW.md` |
| Protocol 구조 | `docs/HARNESS-PROTOCOL.md`, `docs/harness-protocol/*.md` |
| 사용자 매뉴얼 / 스캐폴딩 | `docs/WORKFLOW-MANUAL.md`, `create-harness.sh` |
| 언어 정책 | `docs/decisions/DR-007-language-policy.md` |
| External ecosystem reference | gstack, Superpowers, GSD / Get Stuff Done, Everything Claude Code. 방향성 context로 사용하며 검증되지 않은 순위/수치 증거로는 사용하지 않는다. |

## Validation Checklist

- [ ] v1.1 blueprint와 최종 PPTX version이 일치한다.
- [ ] Slide count는 29장으로 유지한다.
- [ ] Vibe Coding을 순차 단계가 아닌 상위 작업 방식으로 설명한다.
- [ ] Prompt / Context / Harness Engineering의 관계를 supporting layers로 도식화한다.
- [ ] 커밋 수 등 정량 지표를 headline으로 내세우지 않는다.
- [ ] 외부 Claude Code framework는 내 baseline 이후의 benchmark와 선택적 흡수 대상으로 설명한다.
- [ ] 구조와 flow는 줄글보다 diagram으로 설명한다.
- [ ] `/doc` 정책에 맞춰 final PPTX는 `docs/presentations/`, 작업 파일은 `outputs/`에 둔다.
- [ ] DR-007 Bilingual Rules를 적용한다.
- [ ] 최종 PPTX 렌더 preview와 layout quality check를 수행한다.

## Residual Risks

- 실제 발표 대상자의 AI tool 사용 경험 편차가 크면 Claude Code Basics를 더 쉬운 예시로 바꿔야 할 수 있다.
- 개인 프로젝트 서사를 유지하되, 팀에 공유 가능한 baseline으로 확장되는 흐름을 놓치지 않아야 한다.
- 최종 deck 제작 시 v1.0에서 보였던 text overflow와 과도한 ASCII 의존을 줄이고, editable diagram/card layout으로 재구성해야 한다.

---

## Slide 01 — Cover

**Action Title:** AI와 함께 개발하기

**Subtitle:** Vibe Coding & AI Workflow Harness 실전 입문

**Layout Intent:** Dark minimal cover. 왼쪽에는 대형 제목과 메타 정보, 오른쪽에는 Vibe Coding을 중심으로 Prompt, Context, Harness가 연결된 small layer diagram을 배치한다.

```text
┌──────────────────────────────────────────────────────────────┐
│ Internal Engineering Share                                   │
│                                                              │
│ AI와 함께 개발하기                                            │
│ Vibe Coding & AI Workflow Harness 실전 입문                   │
│ ─────────────────────────────────────────────                │
│ Document v1.1                                                │
│ 박경서 <Kyungseo.Park@gmail.com>                             │
│ 2026-05-16                                                   │
│                                                              │
│                                  ┌──────────────┐            │
│                                  │ Vibe Coding  │            │
│                                  └──────┬───────┘            │
│                         ┌───────────────┼──────────────┐     │
│                         ▼               ▼              ▼     │
│                       Prompt          Context        Harness  │
└──────────────────────────────────────────────────────────────┘
```

**Speaker Notes:** 오늘은 특정 도구 사용법만 소개하지 않는다. 내가 개인적으로 AI와 함께 개발해보며 겪은 시행착오가 어떻게 Harness v1이라는 반복 가능한 baseline으로 정리됐는지 공유한다.

**Source:** —

---

## Slide 02 — Agenda

**Action Title:** 오늘의 목표는 내가 AI와 함께 일하는 방식을 어떻게 구조화했는지 공유하는 것이다

**Layout Intent:** 5-part horizontal journey. 각 part를 카드로 두고, 하나의 발표 흐름처럼 이어지게 구성한다.

| Part | Title | Message |
| --- | --- | --- |
| 01 | Project Story | 왜 개인 프로젝트로 시작했는가 |
| 02 | AI Collaboration Basics | 내 Vibe Coding 접근을 어떻게 이해할 것인가 |
| 03 | Harness v1 Overview | Lightweight Manual-First Harness v1은 무엇인가 |
| 04 | Usage Manual | 개인 baseline을 어떻게 팀에 공유할 것인가 |
| 05 | Next Step | v2와 Public 전환까지 무엇이 남았는가 |

**Speaker Notes:** 초반은 개인적 출발점과 프로젝트 맥락, 중반은 AI 협업의 기본 개념, 후반은 Harness v1 구조와 이를 팀에 공유하는 방법으로 이어진다.

**Source:** —

---

## Section 01 — Project Story

## Slide 03 — Motivation

**Action Title:** 시작점은 팀 표준이 아니라 나의 개인적 Vibe Coding 실험이었다

**Layout Intent:** Personal trigger + trend context. 왼쪽에는 개인적 문제의식, 오른쪽에는 AI coding trend를 배치한다.

```text
2022            2023                  2024                    2025+
Copilot         ChatGPT               Cursor / Claude Code     Workflow Harness
자동완성 중심    Prompt 기반 코드 생성   Agentic Coding          상태·승인·검증·복구
```

**Body Points:**

- 출발은 개인적으로 AI와 더 빠르게 개발해보고 싶은 욕구였다.
- Vibe Coding은 빠른 탐색에는 강했지만, 세션이 길어질수록 맥락과 완료 기준이 흔들렸다.
- 이 개인적 시행착오를 정리하다 보니 팀에도 공유 가능한 workflow baseline이 필요하다는 문제의식으로 확장됐다.

**Caption:** 개인 실험에서 시작했지만, 반복 가능한 방식으로 만들려면 상태와 기준이 필요했다.

**Speaker Notes:** 처음부터 팀 표준을 만들려고 시작한 것은 아니다. 개인적으로 AI와 함께 빠르게 개발하는 방식을 실험했고, 그 과정에서 반복 세션의 맥락 유실과 검증 기준 부재가 계속 드러났다.

**Source:** `docs/STATUS.md § Current State`, general personal context

---

## Slide 04 — Two Axes

**Action Title:** 나는 실전 프로젝트 위에서 개인 workflow를 동시에 검증하는 구조를 선택했다

**Layout Intent:** 2-column split. 왼쪽: Product Axis(Spring Boot MSA), 오른쪽: Harness Axis(AI Workflow). Hub-and-spoke 확인 가능하도록 화살표로 연결.

```text
┌──────────────────────────────────────────────────────┐
│            base-msa-template                         │
│                                                      │
│  PRODUCT AXIS            HARNESS AXIS                │
│  Spring Boot MSA  ◄────► AI Workflow Harness v1      │
│                                                      │
│  · Gradle multi-module   · STATUS.md (상태 추적)      │
│  · JWT Auth              · Commands (workflow 실행)   │
│  · API Gateway           · State Machine              │
│  · Testcontainers        · 3-Tool 정렬                │
│  · K8s (Phase 2)         · Scaffolding                │
│                                                      │
│    제품 개발과 Harness 구축을 동시에 검증               │
└──────────────────────────────────────────────────────┘
```

**Caption:** 단순 실험이 아닌 실전 타겟 위에서 Harness를 검증하면, 이론이 아니라 실제 세션 마찰로 문제를 발견한다.

**Speaker Notes:** 내가 실제로 개발하는 Spring Boot MSA 프로젝트를 개발하면서 workflow도 함께 만들었다. 개발이 잘 되면 workflow가 실용적이라는 증거고, 워크플로우가 버벅이면 어디가 문제인지 실제 마찰로 발견할 수 있었다.

**Source:** `docs/PLAN-SUMMARY.md`, `docs/ARCHITECTURE.md`

---

## Slide 05 — Project Structure

**Action Title:** 이 repo는 Product 코드와 Harness 문서가 하나의 저장소에 공존한다

**Layout Intent:** 4-column card layout. 각 영역을 카드로 구분한다.

| Product Runtime | Harness Docs | Tool Surfaces | Scaffolding |
| --- | --- | --- | --- |
| `services/` | `docs/STATUS.md` | `CLAUDE.md` | `create-harness.sh` |
| `gateway/` | `docs/AGENT-WORKFLOW.md` | `AGENTS.md` | `--profile generic` |
| `common/` | `docs/HARNESS-PROTOCOL.md` | `.claude/commands/` | `--profile spring-boot` |
| | `docs/backlog/` | `.cursor/rules/` | `--existing` |
| | `docs/decisions/` | | |

**Caption:** Product와 Harness는 다른 폴더에 있지만, 같은 세션에서 함께 발전한다.

**Source:** `docs/ARCHITECTURE.md`, `create-harness.sh`

---

## Slide 06 — Journey

**Action Title:** 이 프로젝트는 12일 동안 제품과 Harness를 병렬로 발전시켰다

**Layout Intent:** Iteration timeline. 왼쪽에서 오른쪽으로 진행, 각 단계를 마일스톤으로 표시한다.

```text
Phase 1 시작         Context Docs          STATUS / Backlog / DR     Command Workflow
May 05 ──────────── May 07 ────────────── May 11 ────────────────── May 12
MSA Block 3~5       CLAUDE.md / AGENTS.md  Live Board               /start /work /done
기능 구현 시작        AGENT-WORKFLOW.md     Backlog + DR 도입         Approval gate 도입

Manual-First 확정    Scaffolding           v1 완성 + 발표 준비
May 14 ──────────── May 15 ──────────────  May 16
HRF 리팩토링         create-harness.sh     blueprint + PPTX
HRN 하드닝          WORKFLOW-MANUAL.md    발표 산출물 생성
```

**Source:** `git log --oneline`, `docs/STATUS.md § Active Work`

---

## Slide 07 — Current State

**Action Title:** Phase 1과 Harness v1이 완료됐고, Phase 2와 v2가 남아 있다

**Layout Intent:** Now/Next split table + repo note.

| | Now (완료) | Next (계획) |
| --- | --- | --- |
| **Product** | Phase 1 ✅ — Gradle multi-module, JWT Auth, API Gateway, Testcontainers | Phase 2 — K8s, Security Hardening, Prometheus, DB per Service |
| **Harness** | v1 ✅ — Manual-First Protocol, 3-Tool, STATUS.md, Scaffolding | v2 — Hook 기반 auto-block, CI Gate, SSOT config, drift detection |

**Repo Note:** `github.com/kyungseo/base-msa-template` — Private. 검증 후 Public 전환 예정.

**Source:** `docs/STATUS.md § Current State`, `docs/backlog/PHASE2.md`

---

## Section 02 — AI Collaboration Basics

## Slide 08 — Tool Landscape

**Action Title:** AI 코딩 도구는 3단계로 발전했고, 이 프로젝트는 3번째 단계를 다룬다

**Layout Intent:** 3-level ladder. 아래에서 위로 상향하는 사다리 구조.

| Level | Category | Tools | Characteristic |
| --- | --- | --- | --- |
| 3 | Workflow Harness | Claude Code + Harness, Codex + workflow | 상태·승인·검증·복구 포함 |
| 2 | IDE Agent / Agentic Coding | Cursor, Claude Code (기본), Codex | 파일 탐색·수정 자율 수행 |
| 1 | Chat UI / Code Assistant | ChatGPT, Claude.ai, GitHub Copilot | 요청 → 응답 단방향 |

**Caption:** 오늘 주제는 Level 3. Level 2와 어떻게 다른지가 핵심이다.

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`, general industry context

---

## Slide 09 — Claude Code Basics

**Action Title:** Claude Code는 강력하지만, 팀이 제공해야 하는 것이 있다

**Layout Intent:** 2-column table. Agent Can vs Team Must Provide.

| Agent Can | Team Must Provide |
| --- | --- |
| 파일 탐색 · 편집 | 현재 상태 기준점 (STATUS.md) |
| 코드 생성 · 수정 | 작업 범위와 우선순위 (Backlog) |
| 빠른 반복 실행 | 결정 근거와 이력 (DR) |
| 문서 초안 작성 | 승인 조건과 검증 기준 |
| 명령 자동 실행 | FAIL/RECOVER 경로 정의 |

**Caption:** Agent의 자유도가 높을수록, 팀이 제공하는 기준점의 품질이 결과를 결정한다.

**Speaker Notes:** Claude Code는 정말 빠르다. 하지만 "빠르게 잘못된 방향으로 가는" 것도 Claude Code다. 그래서 STATUS.md, Backlog, DR, Approval gate 같은 기준이 필요하다.

**Source:** `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`

---

## Slide 10 — Vibe Coding

**Action Title:** Vibe Coding은 AI와 함께 빠르게 만들고 조정하는 작업 방식이다

**Layout Intent:** Definition + 2-column Without Workflow vs With Workflow 비교.

**정의:**

> Vibe Coding: 자연어 대화로 AI에게 의도를 전달하고, 생성된 코드를 빠르게 실행·피드백·조정하는 작업 방식.

| Without Workflow | With Workflow |
| --- | --- |
| 세션마다 맥락 초기화 | STATUS.md로 세션 간 상태 유지 |
| 결정 이유 휘발 | DR에 결정 근거 + 되돌리기 비용 기록 |
| AI가 임의로 scope 확장 | Plan → Approve 게이트로 scope 통제 |
| 완료 기준 불명확 | Done Criteria + Validation 필수 |
| 재개 불가 | Checkpoint 생성, RECOVER 경로 명시 |

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`

---

## Slide 11 — Three Engineering Layers

**Action Title:** Vibe Coding을 안정화하는 세 가지 관점이 있다

**Layout Intent:** Hub-and-spoke diagram. 중앙에 Vibe Coding, 세 방향으로 supporting layers.

```text
                    Vibe Coding
        자연어로 빠르게 만들고, 실행하며, 조정하는 작업 방식
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
 Prompt Engineering   Context Engineering   Harness Engineering
 요청 품질 설계        맥락과 기준점 설계      승인·검증·복구 절차 설계

 - 명확한 지시문       - STATUS.md            - State Machine
 - 역할 정의          - Backlog/DR            - Plan/Approve gate
 - 범위 한정          - 아키텍처 문서          - FAIL/RECOVER 경로
```

**Caption:** 세 레이어는 순차 단계가 아니다. Vibe Coding을 반복 가능하게 만드는 supporting layers다.

**Source:** Concept Model (이 blueprint의 Concept Model 섹션), `docs/HARNESS-PROTOCOL.md`

---

## Slide 12 — Prompt-to-Harness Example

**Action Title:** 같은 요청도 어느 레이어를 적용하느냐에 따라 결과의 품질이 달라진다

**Layout Intent:** 4-row progression table. Raw Vibe → Prompt Engineering → Context Engineering → Harness Engineering.

| Layer | 요청 방식 | 결과 특성 |
| --- | --- | --- |
| Raw Vibe | "로그인 기능 만들어줘" | 빠르게 생성, repo 스타일·기존 Auth 무관 |
| + Prompt Engineering | "Spring Security + JWT, 기존 UserService 재사용, 단위 테스트 포함" | 방향 명확, 기술 스택 일치 |
| + Context Engineering | STATUS.md의 현재 Phase / ARCHITECTURE.md의 모듈 구조 / DR-002의 Auth 결정 로드 | repo 맥락과 정렬, 이전 결정 준수 |
| + Harness Engineering | `/work AUTH-003` → Plan 확인 → 승인 → 구현 → `./gradlew test` → `/done` | 범위 통제, 검증 기준 충족, STATUS 갱신 |

**Speaker Notes:** 이 예시는 초보자가 가장 쉽게 이해할 수 있는 다리다. 같은 "로그인 기능" 요청도 prompt, context, harness 조건이 추가될수록 결과가 repo의 기존 구조와 내 완료 기준에 맞아진다.

**Source:** `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/*.md`

---

## Slide 13 — Why Harness

**Action Title:** Harness는 Agent의 자유도를 줄이는 것이 아니라 나의 작업 재현성을 높인다

**Layout Intent:** Problem-to-mechanism matrix.

| Problem | Harness Mechanism |
| --- | --- |
| Context loss | STATUS.md and context routing |
| Scope drift | Plan and approval gate |
| Silent failure | Validation and FAIL/RECOVER loop |
| Decision drift | DR and Recent Decisions |
| Onboarding cost | Workflow manual and scaffolding |

**Caption:** 개인 작업에서 재현성이 생기면, 그때부터 팀에 설명하고 공유할 수 있다.

**Source:** `docs/HARNESS-PROTOCOL.md`

---

## Slide 14 — Why Build From Basics

**Action Title:** 검증된 framework가 많아도, 내 workflow의 baseline은 직접 이해하고 소유해야 한다

**Layout Intent:** External landscape + adoption strategy. 왼쪽에는 community reference를 두고, 오른쪽에는 이 프로젝트의 선택 기준을 둔다.

```text
Community Reference                 My Adoption Strategy
────────────────────                ─────────────────────────────
gstack                              1. 원리를 이해할 수 있는 baseline부터 만든다
Superpowers                         2. repo 안에서 상태와 gate를 소유한다
GSD / Get Stuff Done                3. 내가 쓰는 Claude, Cursor, Codex에 공통 적용한다
Everything Claude Code              4. 검증된 외부 skill은 선택적으로 흡수한다
기타 skills / harness 사례          5. v2에서 자동화와 ecosystem 연계를 넓힌다
```

**Body Points:**

- 이미 검증된 Claude Code skill, plugin, guide repository는 많다.
- 하지만 바로 가져오면 내가 왜 이 절차가 필요한지 이해하기보다 무엇을 설치해야 하는지에 집중하게 된다.
- 이 프로젝트의 목적은 외부 framework를 대체하는 것이 아니라, 내가 이해하고 검증할 수 있는 최소 운영 기준을 만드는 것이다.
- manual-first baseline이 있어야 외부 skill을 가져와도 어떤 부분을 채택하고 어떤 부분을 버릴지 판단할 수 있다.

**Positioning Statement:** Build my first-principles baseline, then adopt proven ecosystem selectively.

**Speaker Notes:** Superpowers, gstack, GSD, Everything Claude Code 같은 레퍼런스는 무시할 대상이 아니다. 오히려 v2와 이후 확장 단계에서 비교하고 흡수할 benchmark다. 다만 내 workflow를 이해하지 못한 채 외부 framework부터 가져오면 무엇을 채택하고 버릴지 판단하기 어렵다.

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`

---

## Section 03 — Harness v1 Overview

## Slide 15 — Positioning

**Action Title:** v1은 나의 manual-first baseline이고, v2는 enforcement layer를 더한다

**Layout Intent:** Maturity spectrum. 왼쪽(No Rules)에서 오른쪽(Harness v2)으로 진행하는 가로 스펙트럼.

```text
No Rules       Prompt Library       Command + STATUS       Harness v1        Harness v2
────────       ──────────────       ────────────────       ──────────        ──────────
개인별 방식     재사용 요청          상태/명령 일부 도입      state machine     hook/CI enforced
불안정          품질 개선            세션 연속성 개선          manual gates      automated gates
```

**Completeness Claim:** v1은 완전 자동화가 아니라 반복 가능한 운영 기준을 제공하는 단계다.

**Speaker Notes:** v1을 과장하지 않는다. 강제력 있는 자동화는 아직 부족하다. 대신 v1은 내가 반복 세션을 같은 방식으로 운영하고, 그 방식을 팀에 설명할 수 있게 해주는 기준이다.

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`

---

## Slide 16 — Design Principles

**Action Title:** 내가 반복 세션을 견디기 위해 세운 원칙은 네 가지다

**Layout Intent:** Four principle cards.

| Principle | Meaning |
| --- | --- |
| Deterministic | 같은 상태에서 같은 절차로 재개 |
| Stateful | STATUS.md로 현재 상태 유지 |
| Controlled | Plan, Approval, Validation gate |
| Failure-first | 실패를 숨기지 않고 RECOVER 경로로 전환 |

**Speaker Notes:** 네 원칙은 v1의 성격을 가장 간결하게 설명한다. 특히 Failure-first는 실패를 예외로 숨기지 않고 명시적 상태로 다루는 것이 핵심이다.

**Source:** `docs/AGENT-WORKFLOW.md § State Machine`

---

## Slide 17 — Document Ecosystem

**Action Title:** 문서는 많아 보이지만 다음 세션의 나를 위해 각자 하나의 역할만 가진다

**Layout Intent:** Document ecosystem map. STATUS.md 중앙, 연결 구조 방사형.

```text
                 STATUS.md
                 Live Board
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
    backlog/     decisions/   AGENT-WORKFLOW.md

HARNESS-PROTOCOL.md ── harness-protocol/*.md
        ▲
        └── WORKFLOW-MANUAL.md explains protocol for humans
```

**Body Points:**

- `STATUS.md`: 현재 상태의 live board
- `docs/AGENT-WORKFLOW.md`: 3-tool shared rules
- `docs/HARNESS-PROTOCOL.md`: protocol hub
- `docs/WORKFLOW-MANUAL.md`: 사람이 읽는 manual

**Caption:** 내가 이해하는 manual과 Agent가 따르는 operating rules를 분리한다.

**Source:** `docs/HARNESS-PROTOCOL.md`, `docs/harness-protocol/04-document-lifecycle.md`

---

## Slide 18 — State Machine

**Action Title:** Plan → Approval → Execute → Validate가 나의 기본 실행 루프다

**Layout Intent:** State machine diagram. 선형 흐름 + FAIL/RECOVER 분기.

```text
INIT → PLAN → APPROVAL → EXECUTE → VALIDATE → CHECKPOINT → END
                              │
                              ▼
                             FAIL → RECOVER → PLAN
```

**Rule Highlights:**

- plan 없이 구현하지 않는다.
- scope가 바뀌면 approval로 되돌아간다.
- validation이 실패하면 checkpoint나 commit으로 가지 않는다.

**Speaker Notes:** 핵심은 빠르게 실행하는 것이 아니라, 실행 전에 계획과 검증 기준을 합의하는 것이다.

**Source:** `docs/AGENT-WORKFLOW.md § State Machine`

---

## Slide 19 — STATUS.md

**Action Title:** STATUS.md는 Agent와 내가 공유하는 현재 상태의 single source다

**Layout Intent:** Annotated STATUS.md mock screenshot. 실제 screenshot에 의존하지 말고, 4개 섹션을 카드형 mock으로 보여준다.

| Section | Role |
| --- | --- |
| Current State | 현재 phase, focus, 참조 문서 |
| Active Work | 진행 또는 완료된 주요 작업과 verification |
| Recent Decisions | 후속 행동을 바꾸는 최근 결정 |
| Next Actions | 다음 세션의 우선순위 |

**Anti-pattern:** STATUS.md를 건너뛰고 작업을 시작하면 Agent도, 다음 세션의 나도 현재 상태를 추측하게 된다.

**Source:** `docs/STATUS.md` (live capture)

---

## Slide 20 — Three Tool Alignment

**Action Title:** Claude Code, Cursor, Codex는 같은 규칙을 다른 방식으로 따른다

**Layout Intent:** Three-column architecture. 상단에 공통 규칙 레이어, 하단에 3개 도구.

| Tool | Entry Point | Execution Style |
| --- | --- | --- |
| Claude Code | `CLAUDE.md`, `.claude/commands/` | slash command 중심 |
| Cursor | `.cursor/rules/*.mdc` | editor workflow 중심 |
| Codex | `AGENTS.md` | command mapping을 수동 절차로 수행 |

**Caption:** 도구별 UX는 달라도 공통 운영 규칙은 `docs/AGENT-WORKFLOW.md`로 정렬한다.

**Speaker Notes:** 이 repo는 Claude Code만을 위한 규칙이 아니다. 내가 쓰는 여러 도구에서 같은 방식으로 시작하고 끝낼 수 있도록 Codex, Cursor까지 정렬했다.

**Source:** `docs/AGENT-WORKFLOW.md § Context Routing`

---

## Slide 21 — Scaffolding

**Action Title:** create-harness.sh는 Harness를 다른 repo에 이식하기 위한 장치다

**Layout Intent:** Input-to-output diagram. CLI command → 생성 파일 목록.

```text
create-harness.sh
  --profile generic
  --profile spring-boot
  --existing
        │
        ▼
docs/STATUS.md
docs/HARNESS-PROTOCOL.md
docs/HARNESS-QUICK-REFERENCE.md
docs/harness-protocol/*.md
.claude/commands/*.md
.cursor/rules/*.mdc
CLAUDE.md / AGENTS.md
```

**Key Message:** v1은 내 개인 프로젝트에만 붙어 있는 규칙이 아니라, 다른 프로젝트와 팀에도 옮길 수 있는 구조를 지향한다.

**Source:** `create-harness.sh`, `docs/WORKFLOW-MANUAL.md § 8`

---

## Slide 22 — v1 Completeness And Limits

**Action Title:** v1의 완성도는 자동화 수준이 아니라 반복 가능성으로 평가해야 한다

**Layout Intent:** Capability / Limit table.

| v1 Provides | v1 Does Not Yet Enforce |
| --- | --- |
| Manual state machine | Hook 기반 hard block |
| STATUS Update Proposal | 자동 stale detection |
| Context routing | SSOT config |
| DR and recovery rules | CI-level policy gate |
| Scaffolding baseline | template upgrade automation |

**v2 Direction:** hook, CI, `.harness/config.json`, drift detection을 통해 manual-first 규칙을 enforceable workflow로 발전시킨다.

**Speaker Notes:** v1은 충분히 쓸 수 있지만, Agent가 규칙을 어겨도 기술적으로 막지는 못한다. v2는 이 지점을 보강한다.

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`

---

## Section 04 — Usage Manual

## Slide 23 — Apply To New Project

**Action Title:** 내 개인 baseline을 신규 프로젝트에도 세 단계로 붙일 수 있다

**Layout Intent:** Three-step manual cards.

| Step | Command / Action | Output |
| --- | --- | --- |
| 1. Scaffold | `bash create-harness.sh --profile generic ./my-project` | Harness file structure |
| 2. Review | 생성된 `STATUS.md`, entrypoints, rules 확인 | project-specific adjustment |
| 3. Commit | `chore: AI Workflow Harness 초기 구성` | baseline checkpoint |

**Note:** 기존 프로젝트는 `--existing`으로 overlay하고, 기존 파일 overwrite는 피한다.

**Source:** `create-harness.sh`, `docs/WORKFLOW-MANUAL.md`

---

## Slide 24 — First Session Routine

**Action Title:** 첫 세션 10분 루틴은 STATUS에서 시작한다

**Layout Intent:** Checklist flow. 8단계를 2-row grid로 구성한다.

```text
1. /start
2. Current State 확인
3. Active Work / Next Actions 확인
4. /pick 또는 /work <ID>
5. plan, risk, verification 확인
6. 승인 후 실행
7. 검증 결과 확인
8. /done
```

**Caption:** 처음부터 많은 규칙을 외우는 것이 아니라, 내가 매 세션 같은 방식으로 시작하고 끝내는 것이 핵심이다.

**Speaker Notes:** 이 루틴은 팀 전파 이전에 내 개인 작업을 안정화하기 위한 것이었다. 하지만 /start와 /done 같은 작은 습관은 팀원에게도 설명하기 쉽고 재사용하기 쉽다.

**Source:** `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`

---

## Slide 25 — Command Map

**Action Title:** 8개 command는 내가 반복하는 작업 lifecycle을 나눠 맡는다

**Layout Intent:** Command reference grid.

| Command | Role |
| --- | --- |
| `/start` | 현재 상태 확인 |
| `/pick` | 다음 작업 후보 추천 |
| `/register` | 새 작업 등록 |
| `/work <ID>` | 작업 계획 수립 |
| `/resume <ID>` | 중단 작업 재개 |
| `/doc` | 발표·보고 산출물 workflow |
| `/health` | workflow 상태 점검 |
| `/done` | 완료 보고와 상태 갱신 제안 |

**Source:** `docs/HARNESS-QUICK-REFERENCE.md`, `.claude/commands/`

---

## Slide 26 — Practical Scenario

**Action Title:** 실제 한 사이클은 스스로 계획을 확인하고 검증한 뒤 종료한다

**Layout Intent:** Conversation transcript. User와 Agent를 좌우 또는 색상으로 구분한다.

```text
User:  /work HRN-013
Agent: scope, risk, files, verification을 보고합니다. 진행할까요?
User:  진행
Agent: 구현 후 validation 실행
Agent: 검증 결과와 STATUS Update Proposal 보고
User:  승인
Agent: /done summary와 commit readiness 보고
```

**Speaker Notes:** 이 흐름을 답답하게 느끼는 순간이 있지만, 개인 프로젝트에서도 이 작은 마찰이 scope drift와 silent failure를 막는다. 팀에 공유할 때도 같은 장점이 있다.

**Source:** `docs/STATUS.md § Active Work` (HRN-013)

---

## Slide 27 — Common Mistakes

**Action Title:** 내가 반복해서 겪은 실수는 대체로 네 가지였다

**Layout Intent:** Mistake / Symptom / Fix table.

| Mistake | Symptom | Fix |
| --- | --- | --- |
| STATUS.md skip | Agent가 엉뚱한 작업을 시작 | `/start`로 시작 |
| Plan 없이 구현 | scope drift | `/work`로 plan 승인 |
| Validation 생략 | 조용한 회귀 | Done 전 test/report |
| DR 생략 | 결정 이유 상실 | reversal cost가 있으면 DR |

**Caption:** Harness는 복잡한 규칙 모음이 아니라 내가 반복해서 겪은 실수를 막는 최소 운영 장치다.

**Source:** `docs/retrospectives/harness-evaluation-20260514.md`

---

## Section 05 — Next Step

## Slide 28 — Summary

**Action Title:** 오늘 가져갈 메시지는 세 가지다

**Layout Intent:** Dark summary slide with three horizontal takeaway cards.

1. 출발은 개인적 Vibe Coding 실험이었다.
2. Harness v1은 그 실험을 반복 가능한 manual-first baseline으로 정리한 결과다.
3. 다음 단계는 이 baseline을 팀에 공유하고, v2에서 강제력과 자동화를 높이는 것이다.

**Repo Note:** `github.com/kyungseo/base-msa-template`는 Private이며, 검증 후 Public 전환 예정이다.

**Source:** Synthesized from entire presentation

---

## Slide 29 — Q&A

**Action Title:** Q & A

**Layout Intent:** Minimal dark closing slide.

**Text:**

- 박경서
- Kyungseo.Park@gmail.com
- Repo: `github.com/kyungseo/base-msa-template` (Private, 검증 후 Public 전환 예정)

**Source:** —

---

## Production Spec

### Visual System

| Element | Direction |
| --- | --- |
| Palette | Light technical base, dark cover/summary/Q&A slides, blue/teal/green accent. Red only for risk/failure. |
| Typography | Korean-readable sans serif. Title 30-34pt, subtitle 18-22pt, body 13-16pt, caption 11-12pt. |
| Layout | Diagram-first. Cards are used for repeated items only. Avoid empty hero slides except cover and closing. |
| Diagrams | State machine, hub-and-spoke, lifecycle flow, directory map, maturity spectrum. |
| Density | 각 slide는 하나의 action title과 하나의 proof object(table, diagram, map, scenario)를 가진다. |
