---
date: 2026-06-08
track: harness
type: process
scope: AI 도구 발전 속에서 이 harness의 정체성과 policy-first 방향성 재정의
author: "human"
related_work: [CHORE-20260604-001, CHORE-20260605-001]
---

# Harness 정체성 — Policy-First 방향성 재정의

> 원문 작성: 2026-06-06 (회고 정리: 2026-06-08)

---

## 시발이 된 질문들

> **Q1 (2026-06-06):** "claude code, codex 등 AI 도구들이 발전함에 따라 빠르게 자체적인 하네스 시스템이 강화되고 있는데, 과연 이렇게 별도의 harness workflow를 개발하는 것이 의미가 있을까? 개인적으로는 어찌되건 개인/회사에서 필요로 하는 작업 방식, git flow는 모두 고유하고 본질적인 것이므로 이것에만 집중하는 것은 의미가 있지 않을까 싶은데… 방향이 맞을까."

> **Q2 (2026-06-08):** "이 harness가 개인을 넘어 기업의 표준 harness로 자리잡기 위해서 agents orchestration, sub-agents 등에 대한 영역까지도 확장해야 하는지?"

두 질문은 같은 축에 있다: **harness의 경계를 어디에 그어야 하는가.**
Q1은 "도구가 잘 하는 것과 harness가 해야 하는 것을 어떻게 구분하는가"이고,
Q2는 "그 경계가 multi-agent, 기업 규모로 확장될 때도 유지되는가"다.

---

## 결론

**이 harness가 살아남는 경로는 하나다: 도구보다 "우리가 AI와 어떻게 일하는가"를 더 잘 아는 문서 시스템.**

- 도구는 "AI가 어떻게 동작하는가"를 정의한다.
- harness는 "우리가 AI와 어떻게 일하는가"를 정의한다.
- 그 경계가 명확한 한, harness는 도구가 발전할수록 더 필요해진다.

**orchestration 확장에 대한 답**: sub-agent가 무엇을 자율로 할 수 있고 무엇은 사람이 승인해야 하는가는 **정책 문제**다. 그 정책을 정의하는 것은 harness의 역할이고, orchestration 메커니즘 자체를 구현하는 것은 도구의 역할이다. 이 구분이 유지되는 한 harness는 orchestration 환경에서도 확장 가능하며, workflow engine으로 전락하지 않는다.

---

## 1. 우려가 맞는 부분 (Q1)

AI 도구들은 빠르게 다음을 내재화하고 있다:

- 프로젝트 컨텍스트 로딩 (CLAUDE.md, AGENTS.md)
- 메모리·세션 상태 관리
- hook/permission 시스템
- slash command scaffold

이 **인프라 레이어**는 실제로 commoditize되고 있다. 도구들이 잘 할 일을 harness가 직접 구현하면 유지 비용만 쌓인다.

---

## 2. 그래도 harness가 의미 있는 이유 — 정책 레이어

AI 도구들이 표준화하는 건 "AI가 어떻게 동작하는가"이지, **"이 팀/개인이 어떻게 일하는가"가 아니다.**

| 레이어 | 내용 | 소유자 |
|--------|------|--------|
| 인프라 | session scaffold, hook 구조, command loader, agent orchestration 메커니즘 | AI 도구 |
| **정책** | Approval Matrix (무엇이 L1/L2/L3인가), git topology, commit 언어 규칙, human sign-off 기준, **sub-agent 자율 범위** | **harness** |

"이 변경은 아키텍처급이므로 사람이 승인해야 한다"는 판단 기준은 팀마다 다르고, AI는 그 기준을 모른다. 이 기준을 **명문화하고 강제**하는 것이 harness의 본질적 역할이다.

---

## 3. Orchestration 확장 시 경계 재확인 (Q2)

### 확장이 필요한 것 — 정책 정의

sub-agent 환경이 되면 Approval Matrix가 계층화된다:

| 주체 | 자율 가능(L1) | 보고 후 진행(L2) | 사람 승인 필수(L3) |
|------|--------------|-----------------|------------------|
| **단일 agent** | 문서 수정, 로컬 테스트 | 기능 구현, 설정 변경 | 아키텍처, 보안, 인프라 |
| **sub-agent (위임받은 범위)** | 위임된 L1 범위 내 | 위임 범위 초과 시 primary agent에 보고 | primary agent도 승인 불가 → human escalation |

이 계층 정책을 정의하는 것은 harness가 해야 할 일이다. "sub-agent가 PR을 직접 열 수 있는가"는 orchestration 메커니즘이 아니라 **팀의 거버넌스 정책**이다.

Work tracking, DR 체계, commit gate도 동일하다 — multi-agent가 만든 결과물에도 같은 정책이 적용돼야 한다. 그 정책이 어디에 정의되어 있는가가 harness의 가치다.

### 확장이 필요하지 않은 것 — 인프라 구현

- 어떻게 sub-agent를 spawn하는가 → Claude Code sub-agent, Codex agent 등 도구가 처리
- agent 간 통신 프로토콜 → MCP, tool use 등 도구 레이어
- task 분배 알고리즘 → orchestration framework (LangGraph, CrewAI 등)

이것들을 harness가 직접 구현하면 다시 workflow engine이 된다. 위험 신호가 발동한다.

### 기업 표준 harness로의 확장

기업 환경에서 추가로 필요한 것은 대부분 **정책 강화**다:

- 더 엄격한 Approval Matrix (compliance, audit 요건)
- cross-team DR 체계 (여러 팀이 같은 기준으로 결정 기록)
- 더 세밀한 git topology (team별 branch 전략 변형 허용 범위)
- Work tracking의 external tracker 연계 정책 (Jira/Linear와의 관계)

이것들은 모두 policy 레이어에 속한다. harness가 기업 표준으로 자리잡는다는 것은 **더 많은 팀이 같은 policy framework를 채택한다**는 뜻이지, orchestration infrastructure를 제공한다는 뜻이 아니다.

---

## 4. 현재 harness의 위험 신호

| 신호 | 내용 | 현재 상태 (2026-06-08) |
|------|------|----------------------|
| **절차 중복** | AI 도구가 natively 지원하기 시작한 기능을 harness도 따로 구현 | Phase 2에서 canonical SSoT 1벌 + hybrid adapter 전환(DR-023)으로 개선. 하지만 prompt surface diet는 미완 |
| **유지 비용 누적** | command/skill/rule이 늘어날수록 sync 부담이 기하급수로 증가 | adapter cascade 문제 여전히 실존 |
| **정체성 혼선** | "workflow engine인가 policy document인가"가 불명확 | DR-021, DR-023으로 진전. scaffold가 여전히 "절차 파일 묶음"을 생성하는 구조는 그대로 |

---

## 5. Policy-First 리팩토링 방향

### Phase A — 인프라 레이어 축소

| 대상 | 방향 | 상태 |
|------|------|------|
| session-start/end scaffold | 최소화. "STATUS.md 읽고 요약" 수준으로 | ✓ canonical SSoT 전환 완료 (DR-023, Phase 2) |
| work 파일 생성 절차 | command 단일화, canonical inline화 | ✓ canonical adapter 구조로 전환 |
| status machine 절차 | 정책 판단 기준만 남기고 절차 서술 축소 | △ prompt surface diet 미완 |

### Phase B — 정책 레이어 강화

| 대상 | 방향 | 상태 |
|------|------|------|
| Approval Matrix | 판단 기준 정교화. L2 경계를 예시 중심으로 명확히. **sub-agent 자율 범위 정의 추가** | △ 기준은 있으나 예시 보강·sub-agent 확장 여지 |
| git topology | `docs/GIT-WORKFLOW.md`를 policy document로 격상 | ✓ source-gitflow 정책 문서화 완료 |
| DR 체계 | 결정 하나 = DR 하나 문화 강화 | ✓ DR-007~027 series, `/record-decision` 운용 중 |
| CLAUDE.md / AGENTS.md | policy injection point로 명확히 포지셔닝. 절차 서술 제거 | ✓ thin entry contract 구조로 정착 |

### Phase C — Scaffold 재정의 (중기)

`scripts/create-harness.sh`가 생성하는 것의 성격을 바꾼다:

- **지금**: 절차와 인프라를 담은 파일 묶음을 복사
- **목표**: 팀이 채워야 할 **policy template**을 생성

새 프로젝트에서 harness를 적용한다는 것 = "우리 팀의 Approval Matrix, git topology, DR 첫 번째를 작성하는 것"이 되어야 한다.

DR-021(source/target boundary)에서 framework-owned vs. project-owned 분류로 첫 발을 뗐지만, scaffold output 자체가 "policy template"으로 느껴지려면 추가 작업이 필요하다. 기업 표준화 경로에서는 Phase C가 가장 핵심 단계다.

---

## 6. Revisit Triggers

- AI 도구가 Work 파일·Approval Matrix에 해당하는 기능을 native로 지원하기 시작할 때 → 정책 레이어 경계 재조정
- Claude Code 또는 Codex에서 sub-agent 위임 기능이 실용 단계가 될 때 → Approval Matrix sub-agent 확장 착수 시점
- harness command/skill/rule sync 부담이 실측 비용으로 누적될 때 → Phase A 미완 항목 재점검
- scaffold를 적용한 팀이 "이게 workflow engine인가 policy document인가"를 혼동하는 피드백이 올 때 → Phase C 착수
- 두 번째 이상의 기업 adopter가 생길 때 → 기업용 Approval Matrix 확장·cross-team DR 체계 설계

---

## 연결

- 이 논의를 받아 실행된 Phase 2 작업: CHORE-20260604-001(Phase 2 기획), CHORE-20260605-001(방향 결정 DR 저작)
- 구조적 결론이 반영된 DR: DR-021(source/target boundary), DR-023(canonical SSoT + hybrid adapter)
- 미완 과제:
  - `docs/backlog/HARNESS.md` — "Prompt surface diet + optional pack 재정의" (Phase A 완결)
  - `docs/backlog/HARNESS.md` — "Project-state template pack 검토" (Phase C 첫 단계)
  - Approval Matrix sub-agent 자율 범위 정의 — 현재 미등록, 착수 시 신규 backlog 등록 필요
