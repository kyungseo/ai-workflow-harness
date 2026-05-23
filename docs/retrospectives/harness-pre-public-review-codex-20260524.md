# AI Workflow Harness — Codex 공개 전 최종 리뷰

> 작성일: 2026-05-24  
> 작성자: Codex  
> 범위: AI Workflow Harness v1.0.0 — HRN-028 이후 Codex/tool surface 및 scaffold 검증  
> 목적: public release 전 Codex 관점의 workflow 실행 가능성, naming 정합성, scaffold readiness 최종 평가

---

## 결론

**공개 준비 상태: 준비 완료에 가까움 (A-)**

HRN-026~028 이후 harness는 Codex에서도 실행 가능한 형태로 정렬됐다. 특히 `.agents/skills/source-command-*`를 `.agents/skills/harness-*`로 정리한 결정은 적절하다. `harness-*` prefix는 일반 programming skill과 구분되며, Claude command의 slash namespace와 Codex skill trigger namespace 차이를 잘 반영한다.

공개 전 남은 확인은 하나다.

1. 새 Codex 세션에서 `harness-*` skill discovery/trigger가 실제 skill list에 반영되는지 확인

현재 세션은 rename 이전에 시작됐을 수 있으므로, 새 세션 기준 확인이 필요하다. 다만 repository 구조, scaffold 산출물, 문서 cascade, shell 검증은 통과했다.

---

## 1. Codex 관점 핵심 변경

| Work | 변경 | Codex 관점 평가 |
| --- | --- | --- |
| HRN-026 | `.agents/skills/`, `.codex/hooks.json` 도입 및 health cascade 반영 | Codex가 `AGENTS.md` 인라인 table에만 의존하지 않게 됨 |
| HRN-028 | `source-command-*` → `harness-*` rename | skill trigger ambiguity 감소, harness 소유권 명확화 |
| HRN-028 후속 보강 | manual/prompt guide에 `.agents/skills/harness-*`와 `.codex/hooks.json` 명시 | user-facing scaffold 설명과 실제 산출물 정렬 |

---

## 2. Tool Surface 상태

| Surface | 상태 | 비고 |
| --- | --- | --- |
| `AGENTS.md` | 정렬됨 | `.agents/skills/harness-{name}/SKILL.md` mapping 명시 |
| `.agents/skills/harness-*/SKILL.md` | 정렬됨 | 11개 skill, frontmatter name과 directory 일치 |
| `.codex/hooks.json` | 정렬됨 | Stop hook reminder가 `/close`/`/done` 분리와 commit/status finalization을 상기 |
| `.claude/commands/*.md` | 유지 | slash command contract 변경 없음 |
| `.cursor/rules/*.mdc` | 유지 | workflow rule은 `.agents/skills/` 추상 경로로 충분 |
| `scripts/create-harness.sh` | 정렬됨 | `.agents/skills/*/` 동적 순회로 `harness-*` 자동 반영 |

판단: Codex surface는 이제 "Claude command의 단순 복사본"이 아니라, harness workflow capability로 읽히는 이름 체계를 갖췄다.

---

## 3. Scaffold 검증 결과

검증은 현재 repository에서 직접 실행했다.

| 검증 | 결과 | 비고 |
| --- | --- | --- |
| `git diff --check HEAD^..HEAD` | 통과 | HRN-028 커밋 범위 whitespace 문제 없음 |
| `bash -n scripts/create-harness.sh` | 통과 | shell syntax 문제 없음 |
| command/skill suffix mapping | 통과 | `.claude/commands/{name}.md` ↔ `.agents/skills/harness-{name}/SKILL.md` 누락/초과 없음 |
| generic scaffold 생성 | 통과 | `/private/tmp/hrn-028-review-generic` |
| `spring-boot` scaffold 생성 | 통과 | `/private/tmp/hrn-028-review-spring` |
| generated scaffold stale search | 통과 | `source-command-*` 재도입 없음 |
| user-facing scaffold guide 반영 | 통과 | generated `WORKFLOW-MANUAL.md`, `prompts/README.md`에 Codex skill/hook 설명 반영 |

Claude 리뷰 시점의 "scaffold 미검증" 리스크는 현재 검증으로 해소됐다.

---

## 4. Public Readiness Checklist

| 항목 | 상태 | 비고 |
| --- | --- | --- |
| Codex entrypoint | 완료 | `AGENTS.md`가 behavior/workflow/status와 skill mapping을 제공 |
| Codex command skills | 완료 | `harness-*` 11개 |
| Skill naming hygiene | 완료 | 일반 skill과 구분되는 `harness-*` prefix |
| Claude/Codex suffix mapping | 완료 | health/cascade 문서에 명시 |
| Scaffold generic profile | 완료 | 생성 검증 통과 |
| Scaffold spring-boot profile | 완료 | optional profile 생성 검증 통과 |
| User-facing docs | 완료 | manual/prompt guide 보강 |
| Retrospective archive | 완료 | 이전 회고는 archive, 최신 리뷰만 live |
| Fresh Codex session trigger | 남음 | 새 세션에서 skill list와 trigger 확인 필요 |

---

## 5. 강점

**Naming clarity**: `harness-*`는 `work`, `doc`, `debug` 같은 generic skill name 충돌을 피하면서도 `source-command-*`보다 짧고 의미가 안정적이다.

**Manual-first safety**: Codex도 Approval Matrix, Quick Mode, Work file, STATUS finalization을 같은 흐름으로 따른다. 자동화보다 명시적 gate가 우선인 설계가 잘 유지됐다.

**Scaffold resilience**: skill directory를 하드코딩하지 않고 `.agents/skills/*/`로 순회하므로 future rename에도 script 변경 비용이 낮다.

**Tool-neutral core**: `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`가 공통 규칙을 담당하고, 도구별 surface는 얇게 유지된다.

**Recovery path**: 실패·drift·scope expansion 시 FAIL/RECOVER로 이동하는 경로가 entrypoint, command/skill, protocol에 걸쳐 반복된다.

---

## 6. 남은 리스크

| 리스크 | 심각도 | 판단 |
| --- | --- | --- |
| 새 Codex 세션 skill discovery 미확인 | Medium | 현재 세션 skill list는 시작 시점 snapshot일 수 있음. public 전 fresh session에서 확인 필요 |
| Skill trigger false positive/negative | Medium | `harness-*` prefix로 줄였지만 실제 trigger 품질은 사용 중 관찰 필요 |
| Cascade 비용 | Medium | workflow/tool surface 변경 시 여전히 manual cascade가 필요 |
| 신규 채택자 초기 부팅 비용 | Medium | `BOOTSTRAP.md`와 guide가 있으나 실제 외부 채택 경험은 아직 없음 |
| Rule compliance hard enforcement 부재 | Low/Medium | health/cascade와 review가 보완 수단. 의도적인 manual-first tradeoff |

---

## 7. Codex 세션 시작 시뮬레이션

새 repository scaffold 후 Codex 흐름은 다음처럼 자연스럽다.

1. Codex가 `AGENTS.md`를 entrypoint로 읽는다.
2. `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/STATUS.md`를 확인한다.
3. `/start` intent는 `.agents/skills/harness-start/SKILL.md`로 연결된다.
4. Next Actions가 bootstrap/onboarding을 가리키면 `docs/BOOTSTRAP.md`를 조건부로 읽는다.
5. Product track L1 작업은 Quick Mode로 처리하고, harness/workflow 변경은 L2로 격상한다.
6. Work 완료는 `/close`, 세션 요약은 `/done`으로 분리한다.

이 흐름은 Claude command와 의미상 같지만, Codex에서는 skill 이름이 `harness-*`로 namespace화되어 있다는 점이 다르다. 이 차이는 올바른 방향이다.

---

## 8. 공개 전 권장 작업

1. 새 Codex 세션을 시작해 skill list에 `harness-start`, `harness-work`, `harness-health`가 노출되는지 확인한다.
2. 새 세션에서 `/start` intent 또는 "현재 상태 요약" 요청이 `harness-start` workflow를 자연스럽게 타는지 확인한다.
3. HRN-028 Work 파일의 검증 미완료 메모를 현재 검증 결과로 갱신한다.
4. 이 리뷰와 Claude 리뷰 중 공개 전 live retrospective로 둘 문서를 선택하거나, 둘 다 유지한다면 `docs/retrospectives/README.md`에서 역할을 구분한다.

---

## 9. 최종 판단

| 항목 | 등급 |
| --- | --- |
| Codex entrypoint clarity | A |
| Skill naming | A |
| Claude/Codex mapping | A- |
| Scaffold readiness | A- |
| User-facing guide alignment | A- |
| Fresh-session trigger confidence | B |
| External adopter readiness | B+ |
| **종합** | **A-** |

> Codex 관점에서 AI Workflow Harness는 public release 직전 상태로 충분히 정리됐다.  
> 남은 확인은 구조 문제가 아니라 runtime discovery 확인에 가깝다.  
> 공개 후에는 규칙을 더 늘리기보다, 실제 adopter가 겪는 마찰을 관찰해 작은 보정으로 대응하는 것이 좋다.
