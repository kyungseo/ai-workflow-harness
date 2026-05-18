# AI Workflow Complexity Review — 2026-05-18

## Purpose

HRF-002와 HRN-019 이후 AI Workflow가 충분히 안정화되었는지, 또는 규칙과 문서가 과도하게 복잡해지고 있는지 점검한 회고 기록이다.

이 문서는 새 실행 규칙이 아니다. 현재 운영 모델의 복잡도, Agent memory 부담, 향후 운영 방향을 평가하기 위한 참고 기록이다.

*2026-05-18 초안 작성 → 동일 일자 내부·외부 시각 통합 후 갱신.*

---

## Summary

현재 AI Workflow는 간단한 시스템은 아니다.
개인 프로젝트나 작은 toy project 기준으로는 복잡도가 높은 편이다.

다만 이 repository의 목표가 다음 조건을 동시에 만족하는 것임을 고려하면, 현재 복잡도는 아직 수용 가능한 범위에 있다.

- 여러 Agent가 세션을 넘겨가며 작업을 이어간다.
- 현재 상태와 과거 이력을 분리한다.
- Agent가 임의로 scope, STATUS, Work 상태를 변경하지 못하게 한다.
- Claude, Codex, Cursor의 실행 표면을 맞춘다.
- 완료, archive, decision, troubleshooting 이력을 세션 간 보존한다.

냉정한 평가는 다음과 같다.

> 현재 복잡도는 감당 가능하지만, 더 늘리면 위험하다.
> **그리고 이미 시스템이 자기 자신을 완전히 점검하지 못하는 임계점에 근접했다.**

---

## Complexity Assessment

현재 복잡도는 **7/10** 수준으로 본다.

구조 자체는 복잡하지만, 복잡도가 무작위로 쌓인 것은 아니다.
대부분의 규칙은 세션 복구, 상태 변경 통제, 이력 보존, tool surface drift 방지를 위해 도입되었다.

독립 규칙 체계 수는 현재 **16개** 수준이다:
State machine / Work lifecycle / Risk gate / Execution mode / State Update Gate 2계층 / Cascade 4계층 / Commit Gate / Scope And Commit Approval / Context Routing / Documentation Triggers / Intent Recognition / Language Policy / DR-worthy criteria / Quick Mode 예외 / Archive 경로 규칙 / Work item naming prefix

### 현재 구조의 장점

- 세션이 끊겨도 복구 가능하다.
- `docs/STATUS.md`가 current dashboard 역할에 집중한다.
- Work 파일이 작업 단위의 Plan, Done Criteria, Verification, Checkpoints, Discovery를 보존한다.
- `/close`와 `/done` 역할 분리로 Work 완료와 세션 종료가 분리되었다.
- State Update Gate 2계층이 실제로 마찰을 줄인다 — Layer 1(Work 파일)은 저마찰, Layer 2(STATUS.md)는 승인 필요.
- "필요한 문서만 조건부 로드" 원칙이 Agent memory를 방어한다.

### 현재 구조의 비용

- 작은 작업에도 절차 의식이 생길 수 있다.
- 문서 간 drift 관리가 계속 필요하다.
- 새 Agent가 처음 진입할 때 읽어야 할 개념이 많다.
- workflow 개선 작업이 product 작업을 밀어낼 위험이 있다.
- 규칙이 더 늘어나면 Agent가 작업보다 절차를 먼저 생각할 수 있다.

### cascade check의 실제 신뢰성

초안에서 cascade check를 장점으로 분류했지만, 이는 수정이 필요하다.

HRN-019에서 cascade audit을 수행했음에도 외부 검토에서 P0×1·P1×4 추가 drift가 발견되었다. `03-work-items-and-naming.md`, `STATUS.md` Recent Decisions, `HARNESS.md`, `DR-015/016` 모두 초기 감사를 통과했다. cascade check를 **시도할 수 있지만 현재 규모에서는 신뢰성이 낮다**는 것이 더 정확한 평가다.

이는 시스템이 이미 사람도 AI도 전체를 안정적으로 파악하기 어려운 수준에 진입했다는 신호다. `health.md`가 247줄인 것 자체가 같은 신호다 — 시스템을 점검하는 도구가 시스템만큼 복잡해졌다.

### L1 Quick Mode의 실질적 한계

"L1 Quick Mode는 workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check를 수행한다"는 예외가 harness 작업에서는 항상 해당된다. HRN-019, HRN-017, HRN-018 모두 이 예외 조건에 걸렸다. 실질적으로 harness 작업에 Quick Mode는 없다.

---

## Agent Memory Assessment

Agent memory 부담은 현재 수용 가능하다.
다만 routing discipline이 무너지면 빠르게 무거워질 수 있다.

### 권장 로드 경로

1. `AGENTS.md` 또는 `CLAUDE.md`
2. `docs/AGENT-WORKFLOW.md`
3. `docs/STATUS.md` current sections
4. 필요한 Work 파일 또는 command 파일 1개

이 정도면 Agent context 부담은 감당 가능하다.

### 위험한 패턴

- 세션 시작마다 `docs/retrospectives/` 전체를 읽는다.
- 세션 시작마다 `docs/archive/`를 뒤진다.
- `.claude/commands/*.md` 전체를 매번 읽는다.
- `docs/harness-protocol/*` 전체를 기본 로드한다.
- 불안하다는 이유로 backlog, DR, retrospective, archive를 모두 동시에 확인한다.

### 실제 누적 패턴의 부담

이론적인 가벼운 로드 경로와 달리, 실제 `/work` 흐름에서는 다음이 순서대로 쌓인다.

```
work.md(77줄) → 03-work-items-and-naming.md → 관련 DR → retrospective 1개
→ STATUS.md 갱신 제안 → Work 파일 → commit gate 확인
```

대형 세션에서는 context compaction이 발생한다. 이 시스템 자체가 compaction을 유발하는 구조이며, compaction 이후 이전 맥락 복원이 불완전할 수 있다는 점이 실질적 리스크다.

현재 workflow가 버티는 이유는 문서가 많아도 항상 다 읽지 않도록 설계되어 있기 때문이다.
따라서 앞으로도 "필요한 문서만 조건부 로드" 원칙을 유지해야 한다.

---

## Simplification Candidates

"수렴과 감량이 필요하다"는 방향만으로는 다음 세션에서 action이 없다. 구체 후보를 정리한다.

우선순위는 되돌리기 비용과 기대 효과 기준이다.

추천 실행 순서: **S4 → S2 → S5 → S1 → S3**. S6은 S1 이후 판단.

### S4 — Quick Mode 예외 조건 삭제 → harness는 기본 L2 [되돌리기 Low / 기대 효과 High]

현재 L1 Quick Mode의 예외 조항: "workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check를 수행한다". harness 작업에서는 이 예외가 항상 해당되므로 Quick Mode가 실질적으로 작동하지 않는다.

예외 조항을 삭제하고 범위를 명시한다.

- **harness·workflow surface**(command/rule/prompt/protocol/scaffold/status 파일): 기본 L2
- **product surface**(코드·테스트·일반 문서): L1 Quick Mode 적용 가능

규칙이 하나 줄고, "예외의 예외"가 사라진다. 즉시 실행 가능.

### S2 — 승인 gate 3종 → Approval Matrix 통합 [되돌리기 Low / 기대 효과 Medium]

현재 3개의 별도 승인 규칙이 "언제 멈춰서 확인받는가"를 규율한다.
- Scope And Commit Approval
- State Update Gate (Layer 1 / Layer 2)
- Commit Gate

이를 Risk gate와 정렬한 단일 Approval Matrix로 통합할 수 있다.

| 변경 유형 | 실행 전 | commit 전 |
|-----------|---------|-----------|
| L1 (product surface) | 실행 후 보고 | diff 보고 → 승인 |
| L2 (harness surface / STATUS.md) | 제안 → 승인 → 실행 | diff 보고 → 승인 |
| L3 (아키텍처·인프라·DB schema) | 계획 → 승인 → 실행 → 검증 | diff 보고 → 승인 |

Work 파일 변경(구 Layer 1)은 L1, STATUS.md 변경(구 Layer 2)은 L2로 매핑된다.
commit 전 승인은 risk level과 무관하게 항상 별도 행으로 남긴다 — commit은 history를 남기는 행위라서 L1이어도 diff 확인 후 진행한다.

### S5 — `docs/WORKFLOW-MANUAL.md` 역할 명시적 재정의 [되돌리기 Low / 기대 효과 Medium]

1,735줄짜리 WORKFLOW-MANUAL.md는 사용자용 레퍼런스이지 AI 실행 규칙이 아니다.

구분이 필요한 두 가지:
- **평소 AI 로드 대상**: 제외. Context Routing에서 명시적으로 배제한다.
- **user-facing workflow 변경 시 cascade 대상**: 유지. workflow 변경이 사용자 가이드와 어긋나면 안 되므로 `/health --cascade` 점검 대상은 그대로다.

이 구분을 AGENT-WORKFLOW.md Context Routing 테이블과 `health.md` cascade layer 정의에 반영하면 "평소엔 읽지 않지만 변경 시엔 확인한다"는 기준이 명확해진다.

### S1 — `docs/harness-protocol/` 6개 파일 → HARNESS-PROTOCOL.md 단일 통합 [되돌리기 Low / 기대 효과 High]

현재 hub-and-spoke 구조:
```
HARNESS-PROTOCOL.md (hub) → 01~06 detail docs (spoke)
```

01~06 파일 전체를 열어야 하는 경우가 드물고, 개별 파일로 분리된 구조가 탐색 비용을 높인다.

통합 방향: 6개 파일을 HARNESS-PROTOCOL.md의 섹션으로 흡수. AGENT-WORKFLOW.md에는 인라인 통합하지 않는다 — 세션 시작 문서가 다시 무거워지는 것을 막는다. AGENT-WORKFLOW.md는 계속 얇게 유지하고, 상세 레퍼런스는 HARNESS-PROTOCOL.md 하나로 수렴한다.

### S6 — `/health --cascade` 판단 엔진 → checklist화 [되돌리기 Low / 기대 효과 Medium]

HRN-019에서 드러났듯 `/health --cascade`가 복잡한 판단 엔진으로 커지면 그 자체가 또 하나의 무거운 규칙 체계가 된다. 현재 health.md의 cascade 영역(247줄)은 AI에게 "판단"을 요청하는 구조다.

대안: "필수 grep + checklist + 발견 보고"로 낮춘다.

```bash
# 변경 파일 분류 후 아래 타깃만 확인
rg -l "대상 키워드" [cascade 필수 파일 목록]
```

자동 판정보다 "이 파일들을 grep해서 있으면 보고한다" 수준이 실제 drift를 더 안정적으로 잡는다. S1 이후 harness-protocol 통합이 완료된 시점에 함께 검토한다.

### S3 — Work lifecycle `Candidate` 상태 제거 [되돌리기 Low / 기대 효과 Low]

Candidate 상태는 backlog 항목과 역할이 중복된다. 큰 작업의 Work 파일 초안을 미리 만들어두는 용도가 있지만, backlog 항목에 "Work 파일: 초안 있음" 메모로 대체 가능하다. lifecycle 단순화(Active → Done → Archived)보다 gate/quick mode 정리가 복잡도 감량 효과가 크므로 우선순위를 낮춘다.

### 보류 후보 (지금 건드리지 않는 것)

- **DR 구조**: 현재 DR은 실질 결정에만 사용되고 있어 문제없다.
- **retrospective 구조**: append-only 유지, 검색 기반 접근으로 충분하다.
- **command 파일 구어체**: 스펙상 올바른 형식이며 변경 불필요.
- **STATUS.md dashboard**: 이미 최소화 방향으로 진행 중 (Active plan 제거 등).

---

## Operating Judgment

현재 시스템은 평이한 수준은 아니지만, 아직 운영 가능한 수준이다.
더 정교하게 만들기보다는 이제는 수렴과 감량이 필요하다.

향후 운영 원칙:

- 새 command는 웬만하면 추가하지 않는다.
- 새 규칙은 기존 규칙을 대체하거나 줄일 때만 추가한다.
- `docs/STATUS.md`는 더 줄이고 dashboard 역할에 집중한다.
- DR은 실제 decision에만 사용한다.
- retrospective는 실행 규칙으로 바로 승격하지 않는다.
- 일상 실행은 `docs/HARNESS-QUICK-REFERENCE.md` 1페이지 수준으로 유지한다.
- command, rule, prompt 변경은 자주 하지 말고 묶어서 정리한다.
- workflow 개선이 product 개발을 방해하기 시작하면 workflow 변경을 동결한다.
- simplification candidate는 product 작업 사이 냉각기에 1개씩만 실행한다.

---

## Conclusion

현재 AI Workflow는 복잡하지만 아직 설계된 복잡도다.

다만 HRN-019 cascade 실패가 보여주듯, 시스템이 자기 자신을 완전히 점검하지 못하는 임계점에 이미 근접했다. 규칙, command, gate를 계속 추가하면 절차가 작업을 잡아먹는 단계로 넘어갈 수 있다.

HRF-002 이후의 다음 방향은 확장이 아니라 안정화, 감량, 반복 사용을 통한 검증이어야 한다.
위 Simplification Candidates는 그 시작점이다. 한 번에 다 하지 않는다.
