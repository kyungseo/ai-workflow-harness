# AI Workflow Harness — 현재 상태 종합 리뷰

> 작성일: 2026-05-24  
> 작성자: Claude Sonnet 4.6  
> 범위: AI Workflow Harness v1.0.0 전체 — 설계·문서·도구·운영 관점 다각도 평가  
> 목적: 현재 harness의 있는 그대로를 여러 관점에서 평가하고, 강점·약점·채택 가능성을 정직하게 기술한다

---

## 결론

**종합 등급: A-**

AI Workflow Harness는 "AI 에이전트와 반복 작업할 때 왜 자꾸 같은 실수가 반복되는가"라는 문제에 대한 실용적이고 완결된 답을 제시한다. 특별한 인프라나 SDK 없이 문서와 명시적 gate만으로 세션 간 상태를 유지하고, scope drift를 차단하며, 결정 근거를 보존하는 운영 체계를 갖췄다.

완벽하지는 않다. 복잡도가 있고, 진입 장벽이 있으며, 자동화 강제가 없다. 하지만 이 트레이드오프는 의도적이며, v1.0 수준에서 수용 가능하다.

---

## 1. 설계 철학 평가

### 핵심 명제

**"워크플로우 엔진 없이 문서와 gate만으로 AI 세션을 제어한다."**

이 명제는 설계 전반에 일관되게 관철된다. 별도 서버, 데이터베이스, 자동화 파이프라인이 없다. 모든 상태는 repo-visible Markdown 파일에 있다. 이것은 약점이 아니라 강점이다.

| 철학 | 구현 방식 | 평가 |
| --- | --- | --- |
| Manual-first | Approval Matrix가 모든 실행·상태변경·commit에 gate를 요구 | ✅ 일관성 있음 |
| Context is limited | 조건부 로드 — 세션마다 필요한 파일만 읽음 | ✅ 실질적 token 절약 |
| State is repo-visible | STATUS.md + Work 파일로 세션 간 상태 복구 가능 | ✅ 검증됨 |
| Surgical changes | BEHAVIOR-PRINCIPLES.md에 명시, cascade 규칙이 강제 | ✅ 코드베이스 일관성 유지 |
| Plan before implement | 모든 L2/L3 작업에 plan → approval 선행 | ✅ scope drift 방지 효과 있음 |

**평가:** 철학과 구현 사이의 gap이 거의 없다. 설계 의도가 문서·도구·gate에 고르게 반영됐다.

---

## 2. 문서 아키텍처

### 계층 구조

```
BEHAVIOR-PRINCIPLES.md      ← 전역 행동 원칙 (최우선)
AGENT-WORKFLOW.md           ← 공통 실행 규칙
HARNESS-PROTOCOL.md         ← 상세 protocol 레퍼런스
HARNESS-QUICK-REFERENCE.md  ← 실행 quick reference
```

이 4계층은 명확하고 참조 빈도에 따라 분리됐다. 세션 시작 시 전부 읽지 않고 필요한 수준만 로드하는 원칙이 잘 지켜진다.

### 문서 크기 검토

| 문서 | 규모 | 비고 |
| --- | --- | --- |
| `HARNESS-PROTOCOL.md` | 602줄 | 상세 레퍼런스. 평시 로드 대상 아님 |
| `WORKFLOW-MANUAL.md` | 1,771줄 | 사용자 매뉴얼. AI 로드 대상 아님 |
| `AGENT-WORKFLOW.md` | 184줄 | 공통 규칙. 세션마다 로드 |
| `BEHAVIOR-PRINCIPLES.md` | 71줄 | 전역 원칙. 세션마다 로드 |

`AGENT-WORKFLOW.md`(184줄)와 `BEHAVIOR-PRINCIPLES.md`(71줄)가 매 세션의 필수 로드 대상인데, 합산 255줄은 세션 컨텍스트 부담으로서 수용 가능한 수준이다.

### 강점

- **문서 역할이 명확히 분리**됐다. "무엇을 읽어야 하는가"의 혼란이 없다.
- **조건부 로드 원칙**이 모든 entry point(CLAUDE.md, AGENTS.md, Cursor session prompt)에 공통으로 적용된다.
- **STATUS.md는 dashboard이고 backlog가 아니다**는 원칙이 명문화되어 있고, 실제 운영에서 지켜진다.

### 약점

- `HARNESS-PROTOCOL.md`(602줄)는 상세 레퍼런스로서 필요한 크기지만, 특정 섹션을 찾는 것이 불편하다. 내부 섹션 앵커나 인덱스가 없다.
- DR이 10개 있지만 "현재 어떤 결정이 살아있는가"를 빠르게 파악할 수 있는 active DR 요약이 없다. `docs/decisions/README.md`가 인덱스 역할을 하지만 각 DR의 핵심을 한 줄로 요약한 quick-scan 형태가 아니다.

---

## 3. Approval Matrix & State Machine

### Approval Matrix

```
L1 Product track   → 간단 plan 승인, Quick Mode 가능
L2 harness/설정    → 상세 plan 승인, Work 파일 기본값
L3 아키텍처/보안   → AS-IS/TO-BE + rollback 포함 승인
```

이 3단계 분류는 직관적이고 실용적이다. 특히 "harness/workflow surface를 건드리면 기본 L2"라는 규칙이 AI의 선의의 scope expansion을 효과적으로 차단한다.

### State Machine

```
INIT → PLAN → APPROVAL → EXECUTE → VALIDATE → CHECKPOINT → END
                ^              |
                |              v
             RECOVER ← FAIL ←─┘
```

단순하고 명확하다. 검증 실패 시 checkpoint와 commit을 금지하는 규칙이 명시적이어서 반쪽짜리 완료를 방지한다.

### 강점

- **멀티 Active Work 지원**: 작업 단위 SSoT(Work 파일)로 컨텍스트를 분리해 여러 작업 병렬 추적이 가능하다.
- **`/close`와 `/done` 분리**: Work 완료와 세션 마무리를 명확히 구분해 Done 처리 없는 세션 종료를 방지한다.

### 약점

- **강제 없음**: Approval Matrix 준수는 전적으로 AI의 자율에 의존한다. 실제로 AI가 gate를 건너뛰어도 기계적 검증 수단이 없다. `/health --cascade`와 commit diff 리뷰가 유일한 사후 감지 수단이다.
- **Quick Mode 경계 판단**: L1 Quick Mode와 L2의 경계가 명문화됐지만, 경계선 근처 작업에서 AI가 잘못 분류할 가능성이 있다.

---

## 4. Tool Surface 정렬

### 현황

| 도구 | Entry point | Workflow 실행 | 규칙 적용 |
| --- | --- | --- | --- |
| Claude Code | `CLAUDE.md` | `.claude/commands/` (11개) | `.claude/rules/` |
| Codex | `AGENTS.md` | `.agents/skills/workflow-*` (11개) | `.codex/hooks.json` |
| Cursor | session prompt | `.cursor/rules/workflow.mdc` | `.cursor/rules/` (10개) |
| (공통) | — | `prompts/` (27개) | — |

**4방향 정렬이 완료됐다.** Claude command와 Codex skill의 1:1 대응이 유지되고, Cursor는 rule 기반으로 같은 원칙을 따른다.

### 강점

- `prompts/`가 portable fallback으로 작동해 도구에 의존하지 않는 공통 기반을 제공한다.
- Canonical 문서(`BEHAVIOR-PRINCIPLES`, `AGENT-WORKFLOW`)가 모든 도구의 상위 계층에 위치해 도구별 drift를 구조적으로 억제한다.
- Codex skill의 `workflow-*` prefix가 일반 programming skill과 명확히 구분되어 trigger ambiguity가 낮다.

### 약점

- **Cursor 실행 품질**: Claude Code나 Codex에 비해 Cursor에서의 harness 실행이 session prompt와 `.mdc` rule의 조합에 의존하는데, 이 조합이 실제 운영에서 얼마나 일관되게 작동하는지는 경험 데이터가 부족하다.
- **`java-spring.md` / `java-spring.mdc`**: Claude rules와 Cursor rules에 Spring Boot 관련 파일이 있다. harness 자체와 무관한 example pack 잔재로, 신규 채택자에게 혼란을 줄 수 있다.

---

## 5. Work 파일 & STATUS 시스템

### STATUS.md

현재 dashboard 역할을 잘 수행한다. `Active Work`, `Blockers/OQ`, `Recent Decisions`, `Next Actions` 섹션이 각각 명확한 역할을 가지며, 무거운 이력을 담지 않는다는 원칙이 실제로 지켜지고 있다.

### Work 파일

`Active → Done → Archived` lifecycle이 명확하고, `/close`와 `/start`의 상호작용이 자연스럽다. Archive는 path-mirror(`docs/archive/docs/works/...`) 구조로 되어 있어 이력 추적이 용이하다.

### DR(Decision Record)

현재 10개의 DR이 active 상태다. DR이 "과거 결정"을 보존하는 역할을 충실히 한다. 단, DR이 작성된 시점 이후 구현이 변경됐을 때 DR과 현실 사이의 drift를 정기적으로 감사하는 메커니즘이 없다.

### 강점

- Work 파일 단위 SSoT가 "다음 Agent가 기억 없이 이어받을 수 있어야 한다"는 원칙을 실현한다.
- `/register` → backlog → `/work` → Work 파일 → `/close` → archive의 흐름이 완결됐다.

### 약점

- Done 상태에서 archive까지의 절차가 `/close` 이후 수동 승인이 필요하다. archive 지연이 발생하면 Work 인덱스에 Done (Archive Pending) 항목이 누적된다. (이번 세션에서도 5개가 누적됐던 사례가 있었다.)

---

## 6. Scaffold & 신규 채택자 관점

### `scripts/create-harness.sh`

`generic`과 `spring-boot` 두 프로파일을 지원하며, `--existing` 플래그로 기존 프로젝트에도 적용할 수 있다. shell syntax 검증(`bash -n`)과 실제 생성 검증이 완료됐다.

### BOOTSTRAP.md 온보딩 흐름

Product Definition → Project Initialization → Phase 1 Backlog 도출의 9단계 흐름이 구조적으로 잘 설계됐다. Implementation Baseline gate가 feature candidate을 조기에 제안하는 것을 방지한다.

### 신규 채택자 진입 장벽 평가

솔직하게 말하면 **진입 장벽이 높다.** 이것은 결함이 아니라 트레이드오프다.

| 요소 | 부담 수준 | 이유 |
| --- | --- | --- |
| 파악해야 할 문서 수 | 높음 | BEHAVIOR-PRINCIPLES / AGENT-WORKFLOW / STATUS / HARNESS-PROTOCOL / BOOTSTRAP 등 |
| 초기 설정 작업량 | 중간 | scaffold 후 core doc fill이 필요 |
| Approval Matrix 내면화 | 중간 | L1/L2/L3 구분이 처음에는 직관적이지 않을 수 있음 |
| 외부 채택 실증 | 없음 | 실제 외부 사용자가 이 harness로 프로젝트를 운영한 사례가 아직 없다 |

`HARNESS-MAINTAINER-GUIDE.md`와 `HARNESS-QUICK-REFERENCE.md`가 진입 장벽을 낮추는 역할을 하지만, 실제 "처음 보는 사람이 30분 만에 운영을 시작할 수 있는가"는 미검증 상태다.

---

## 7. 운영 관점 — 이 harness가 실제로 작동하는가

이 harness는 이 저장소 자체에 적용되어 340여 개의 commit을 통해 검증됐다. 실제 운영 경험에서 확인된 사항:

**동작이 검증된 것:**

- 세션이 중단됐다가 재개될 때 STATUS.md + Work 파일로 상태 복구가 가능하다.
- Approval Matrix가 AI의 scope expansion을 실제로 차단한다.
- `/close`와 `/done` 분리가 Work 완료 추적을 명확히 한다.
- cascade 규칙이 문서 변경 시 tool surface 정렬을 유지한다.
- Multi-tool(Claude Code + Codex + Cursor)에서 동일 원칙이 적용된다.

**아직 검증이 부족한 것:**

- 완전히 새로운 외부 채택자가 이 harness를 처음 적용하는 경험
- harness를 적용한 Product track 프로젝트가 실제 delivery까지 완주한 경험
- 팀(2인 이상) 환경에서의 Multi Active Work 운영

---

## 8. 비교 관점 — 대안과의 차이

| 대안 | 차이 |
| --- | --- |
| 아무 harness 없이 사용 | 세션 반복 설명, scope drift, 결정 소실 문제를 방치 |
| GitHub Issues + PR만 사용 | 상태 추적은 되지만 AI 세션 context 연속성 없음 |
| 자동화 workflow 도구(LangChain 등) | infrastructure 의존성이 높고, 도구 교체 시 전체 재작업 |
| 다른 GitHub AI workflow 저장소 | 대부분 특정 도구(Claude/GPT)에 종속. multi-tool 정렬 없음 |

이 harness의 차별점은 **도구 중립성**과 **zero infrastructure**다. Markdown 파일과 shell script만으로 동작하기 때문에 어떤 AI 도구로 교체해도 운영 구조가 유지된다.

---

## 9. 강점 요약

1. **설계 철학의 일관성**: 모든 구성 요소가 "manual-first, approval-gated" 원칙을 동일하게 구현한다.
2. **Zero infrastructure**: 별도 서버, DB, SDK 없이 repo만으로 완결된다. git clone 하면 바로 사용할 수 있다.
3. **Multi-tool alignment**: Claude Code / Codex / Cursor가 같은 canonical 문서를 참조해 도구 전환 시 drift가 최소화된다.
4. **State continuity**: STATUS.md + Work 파일 + archive lifecycle이 세션 중단 복구를 보장한다.
5. **Scope control**: Approval Matrix L1/L2/L3이 AI의 선의의 범위 확장을 구조적으로 차단한다.
6. **Scaffold**: `create-harness.sh`로 신규/기존 프로젝트 모두에 적용 가능하다.
7. **Naming hygiene**: `workflow-*` Codex skill prefix, DR/Work ID 체계, 파일명 규칙이 일관됐다.

---

## 10. 약점 및 미해소 리스크

| 약점 | 심각도 | 보완 방향 |
| --- | --- | --- |
| Rule compliance 강제 없음 | Medium | AI 자율 준수에 의존. git hook이나 CI 검사로 일부 보완 가능 |
| 신규 채택자 진입 장벽 | Medium | 실제 외부 채택 경험 없음. `HARNESS-QUICK-REFERENCE.md` 개선 여지 있음 |
| Cascade 관리 비용 | Medium | workflow 변경 시 4-layer cascade가 필요. 변경을 억제하는 관성으로 작용 가능 |
| DR drift 감사 부재 | Low/Medium | 구현이 변경돼도 DR은 업데이트되지 않을 수 있음 |
| `java-spring.md/mdc` 잔재 | Low | harness와 무관한 example pack. 신규 채택자 혼란 유발 가능 |
| Product track 실전 미검증 | Medium | harness를 적용한 실제 delivery 경험 없음 |
| Archive 지연 누적 | Low | Done Work가 archive 승인 대기로 인덱스에 잔류하는 패턴 |

---

## 11. 향후 방향

이 시점에서 harness를 더 크게 만드는 것은 옳지 않다. v1.0이 해결하려던 문제는 충분히 해결됐다.

앞으로의 보정 기준:

- **동일 실패 3회 이상 관측 시에만** 규칙 추가를 검토한다.
- cascade surface 확장 금지. 추가 전 "정말 cascade 해야 하는가?" 먼저 질문한다.
- 외부 채택자가 겪는 마찰을 관찰해 진입 장벽 낮추기에 집중한다.
- Rule compliance 강제는 git hook 또는 CI로 점진적으로 보완할 수 있다.

---

## 12. 최종 판단

| 관점 | 등급 | 비고 |
| --- | --- | --- |
| 설계 철학 일관성 | A | 구현과 철학 사이의 gap이 거의 없다 |
| 문서 아키텍처 | A- | 계층 명확, HARNESS-PROTOCOL.md 내부 탐색 불편 |
| Approval Matrix & State Machine | A- | 구조는 탄탄하나 강제 수단 없음 |
| Tool surface 정렬 | A | Claude/Codex/Cursor/scaffold 4방향 완료 |
| Work 파일 & STATUS 시스템 | A- | lifecycle 완결, archive 지연 패턴 존재 |
| Scaffold & 온보딩 | B+ | 구조 완성, 외부 채택 실증 미완 |
| 신규 채택자 진입 장벽 | B | 높은 편. 의도된 트레이드오프 |
| 실전 운영 검증 | B+ | 이 repo에서 340+ commit으로 검증. 외부 적용 미검증 |
| **종합** | **A-** | |

> AI Workflow Harness v1.0은 "AI 에이전트와 반복 세션을 안전하게 운영하기 위한 최소 운영 체계"로서 완결된 첫 번째 버전이다.  
> 완벽하지 않지만, 가장 중요한 문제들 — context 반복, scope drift, 상태 소실, 결정 근거 소실 — 을 문서와 gate만으로 효과적으로 제어한다.  
> 이후의 과제는 구조를 키우는 것이 아니라, 실제 채택자가 더 쉽게 시작하고 더 자연스럽게 운영할 수 있도록 마찰을 줄이는 것이다.
