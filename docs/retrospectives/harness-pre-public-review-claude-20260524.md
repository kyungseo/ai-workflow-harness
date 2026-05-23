# AI Workflow Harness — 공개 전 최종 리뷰

> 작성일: 2026-05-24  
> 작성자: Claude Sonnet 4.6  
> 범위: AI Workflow Harness v1.0.0 — HRN-028 완료 시점  
> 목적: public release 전 harness 구조·완성도·공개 준비 상태 종합 평가

---

## 결론

**공개 준비 상태: 조건부 준비 완료 (B+)**

구조적 완성도는 높고, tool surface 정렬은 지금까지 중 가장 일관성 있는 상태다. 단 두 가지 조건이 남아 있다.

1. `bash -n scripts/create-harness.sh` 및 scaffold 실제 생성 검증 — 환경 제약으로 미완료
2. Codex 실환경에서의 `harness-*` skill trigger 동작 확인 — 이름 변경 후 미검증

이 두 검증이 통과하면 public release에 구조적 장애물은 없다.

---

## 1. 이번 라운드 완료 작업 (HRN-026 ~ HRN-028)

| Work | 핵심 변경 | 결과 |
| --- | --- | --- |
| HRN-026 | `.agents/skills/`, `.codex/hooks.json` cascade 반영 | Codex tool surface가 처음으로 모든 문서 계층에 명시됨 |
| HRN-027 | Backlog pruning 정책, DR/retrospective 인덱스, archive 정책 수립 | Done/Superseded 18개 항목 제거, 탐색 경로 명확화 |
| HRN-028 | `.agents/skills/source-command-*` → `harness-*` rename | trigger ambiguity 제거, harness 소유권 명시, suffix mapping 규칙 추가 |

---

## 2. 현재 Tool Surface 상태

| Surface | 파일 수 | 상태 |
| --- | --- | --- |
| `.claude/commands/` | 11 | 완료. slash command namespace, 변경 없음 |
| `.agents/skills/harness-*/` | 11 | 완료. `harness-{name}` prefix, SKILL.md 내부 정렬 |
| `.cursor/rules/` | 8 | 완료. `workflow.mdc`, `role-harness-maintainer.mdc` 핵심 |
| `.codex/hooks.json` | 1 | 완료. Stop hook reminder |
| `prompts/` | 12 | 완료. Claude/Codex/Cursor fallback + task template |
| `scripts/create-harness.sh` | 1 | 완료. generic/spring-boot profile, `harness-*` 동적 순회 |

**Claude ↔ Codex ↔ Cursor ↔ scaffold — 4방향 정렬 완료.**  
이 시점의 tool surface는 이전 어느 시점보다 일관성 있다.

---

## 3. 문서 계층 상태

| 계층 | 문서 | 상태 |
| --- | --- | --- |
| Canonical | `BEHAVIOR-PRINCIPLES.md`, `AGENT-WORKFLOW.md`, `HARNESS-PROTOCOL.md` | 안정. 변경 비용 높음 |
| Tool-specific | `CLAUDE.md`, `AGENTS.md`, `.claude/`, `.agents/`, `.cursor/`, `.codex/` | HRN-026~028 이후 정렬 완료 |
| User-facing | `WORKFLOW-MANUAL.md`, `README.md`, `HARNESS-QUICK-REFERENCE.md` | 갱신 완료 |
| Scaffold | `scripts/create-harness.sh` 산출물 | `harness-*` 동적 순회 확인 — 실행 검증만 미완료 |

---

## 4. 공개 준비 체크리스트

| 항목 | 상태 | 비고 |
| --- | --- | --- |
| Tool surface 4방향 정렬 | ✅ | HRN-026/028 완료 |
| Skill naming 일관성 | ✅ | `harness-{name}` 확정, suffix mapping 명시 |
| Backlog / DR / retrospective 정리 | ✅ | HRN-027 완료 |
| Cascade 문서 정합성 | ✅ | grep `source-command` 결과 없음 |
| Private-info 제거 | ✅ | AWH-001 migration 시 완료 |
| `bash -n scripts/create-harness.sh` | ❌ | 환경 권한 거부로 미검증 |
| Scaffold 실제 생성 검증 | ❌ | 동일 사유 |
| Codex 실환경 `harness-*` trigger 검증 | ❌ | 이름 변경 후 미검증 |
| README public front-door 품질 | ✅ | AWH-001 이후 단일 문서로 정비 |
| `HARNESS-MAINTAINER-GUIDE.md` | ✅ | 신규 채택자용 가이드 완성 |

---

## 5. 강점

**State continuity**: STATUS + Work 파일 + archive lifecycle이 견고하다. 세션이 중단되거나 Agent가 교체되어도 상태 복구 경로가 명확하다.

**Scope control**: Approval Matrix (L1/L2/L3)가 AI의 선의의 scope drift를 사전에 차단한다. 이는 일반 vibe coding 팀이 갖추지 못한 수준이다.

**Multi-tool alignment**: Claude/Codex/Cursor/scaffold가 같은 원칙을 참조하도록 정렬됐다. 도구 전환 시 drift가 최소화된다.

**Naming hygiene**: `harness-*` prefix로 Codex skill이 일반 프로젝트 skill과 명확히 구분된다. `source-command-*` 시절의 verbose함과 ambiguity가 제거됐다.

**DR / backlog 인덱스**: cascade 감사 시 Accepted DR 10개만 확인하면 되고, 회고는 최신 1개 또는 주제 관련 1개만 참조한다. 불필요한 전체 스캔이 사라졌다.

---

## 6. 약점 및 미해소 리스크

| 리스크 | 심각도 | 비고 |
| --- | --- | --- |
| Scaffold 미검증 | High | 실환경 실행 필요. `bash -n`과 temp 생성 모두 미완료 |
| Codex skill trigger 미검증 | High | `harness-*` 이름이 실제 Codex에서 올바르게 trigger되는지 확인 필요 |
| Rule compliance 강제 없음 | Medium | AI 자율 준수에만 의존. `/health`와 diff 리뷰가 유일한 검증 수단 |
| Cascade 비용 | Medium | workflow 문서 변경은 여전히 4-layer cascade가 필요. 변경을 억제하는 관성으로 작용 가능 |
| 신규 채택자 진입 장벽 | Medium | `HARNESS-MAINTAINER-GUIDE.md`가 있으나 실제 채택 경험 미검증 |
| Scaffold drift 가능성 | Low/Medium | script와 운영 문서 간 drift는 늦게 발견됨. `/health --cascade`로만 탐지 가능 |

---

## 7. 이전 회고 대비 변화

| 차원 | 2026-05-19 (최종 회고) | 2026-05-24 (현재) |
| --- | --- | --- |
| Tool surface 정렬 | Claude 중심, Codex 미완료 | 4방향 완전 정렬 |
| Skill naming | `source-command-*` (verbose) | `harness-*` (명확, 안정적) |
| Backlog 상태 | Done/Superseded 항목 혼재 | 정리 완료, 탐색 경로 명확 |
| DR/retrospective 인덱스 | 없음 | 각 1개 README로 인덱싱 |
| Cascade 감사 범위 | 불명확 | scope 규칙 문서화 완료 |
| scaffold 검증 | 미완료 | 여전히 미완료 (환경 제약) |

---

## 8. 권장 사항

**공개 전:**

1. `bash -n scripts/create-harness.sh` 통과 확인
2. `scripts/create-harness.sh generic /tmp/test-scaffold` 실제 실행 후 `rg "source-command"` 결과 없음 확인
3. Codex 실환경에서 `harness-start`, `harness-work` skill이 올바르게 trigger되는지 검증

**공개 후 운영 원칙 (이전 회고에서 유효했던 내용 재확인):**

- 새 규칙 추가 기준: 동일 실패 3회 이상 관측 시에만 검토
- cascade surface 확장 금지: 추가 전 "정말 cascade 해야 하는가?" 먼저 질문
- `/health --cascade`는 workflow/process 변경 후에만 실행 (평시 금지)
- product surface 작은 작업은 Quick Mode로 닫는다
- retrospective는 실행 규칙으로 즉시 승격하지 않는다

---

## 9. 최종 판단

| 항목 | 등급 |
| --- | --- |
| 구조 설계 | A- |
| Tool surface 정렬 | A |
| Naming consistency | A |
| State continuity | A |
| Scaffold | B (미검증) |
| Cascade 관리 비용 | C+ |
| Rule compliance 강제 | C+ |
| Public 채택 용이성 | B |
| **종합** | **B+** |

> 이 harness는 소규모 팀이 복수 AI Agent와 협업하는 운영 모델로서 공개 가능한 수준에 도달했다.  
> scaffold 실행 검증과 Codex 실환경 확인을 완료하면 public release 장애물은 없다.  
> 앞으로의 과제는 구조를 더 정교하게 만드는 것이 아니라, 실제 채택자가 사용하면서 발견하는 마찰을 줄이는 것이다.
