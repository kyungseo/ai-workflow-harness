# DR-039: Antigravity (Gemini 기반) 도구 통합 — Codex surface 재사용

Date: 2026-06-18
Status: Accepted
Linked DRs: DR-012, DR-023, DR-007

## Question

기존 3개 지원 도구(Claude Code / Codex / Cursor)에 **Antigravity (Gemini 기반)**를 4번째 지원 도구로 추가할 때, 진입점·adapter surface를 어떤 구조로 통합하는가? 신규 per-command 미러를 만들 것인가, 기존 surface를 재사용할 것인가?

## Decision

Antigravity를 **Codex `.agents/` surface의 consumer로 통합한다.** 별도 진입 파일·adapter 디렉터리·prompt를 만들지 않는다.

- **진입점:** Antigravity는 root `AGENTS.md`를 자동 로드한다(실측 확정 — `.agents/AGENTS.md`가 없어도 root fallback 정상). 별도 진입 파일 불요. → DR-012의 entrypoint symmetry를 그대로 상속한다.
- **adapter:** Antigravity는 `.agents/skills/workflow-{name}/SKILL.md`(Codex adapter)를 자동 검색·소비하고 Step 0 → canonical `skills/workflow/{name}.md` 패턴을 동일 수행한다. → DR-023의 canonical + hybrid adapter 구조를 그대로 상속한다. canonical adapter 표의 `Antigravity` 행은 항상 Codex adapter 재사용을 가리킨다.
- **fallback prompt:** `prompts/codex-session-start.md`를 공유한다.
- **라벨:** 도구명 "Antigravity"를 1차 표기로 쓴다. 기반 모델은 "(Gemini 기반)" 수준의 generic 부연만 허용하고, 구체 버전(예: "Gemini 3.x")은 stale 리스크로 문서에 박지 않는다.
- **언어 정책:** DR-007을 따른다. Antigravity 통합은 신규 English-only surface를 만들지 않으므로(별도 진입 파일 없음) DR-007 surface 목록 변경이 필요 없다.

## Options Considered

| 선택지 | 장점 | 단점 |
| --- | --- | --- |
| Codex `.agents/` surface 재사용 (채택) | 신규 미러 0개, drift 표면 증가 없음, parity 차원 불변, 유지보수 세금 최소 | Codex/Antigravity 엔진 분화 시 공유 surface가 한쪽에 안 맞을 위험 (→ Exit Trigger로 관리) |
| Antigravity 전용 per-command adapter 미러 신설 | 도구별 독립 최적화 가능 | 12개 미러 추가, 4자 cascade·parity 확장 = drift 구조 재도입 (DR-023이 제거한 문제 부활) |
| Antigravity 전용 진입 파일 + rules 디렉터리 | Cursor식 경량 분리 | Antigravity가 AGENTS.md/.agents를 native 소비하므로 불필요한 중복 |

## Rationale

Antigravity는 자체 규약상 `AGENTS.md` open standard와 `.agents/skills/<name>/SKILL.md`(Codex 포맷)를 그대로 소비하며 thin pointer 패턴을 동일 수행한다. 실측(FEAT-20260618-001 S0/S0-proof)에서 ① root `AGENTS.md` 자동 로드, ② Step 0 → canonical 로드, ③ 연쇄 multi-step workflow가 async `run_command`(propose→승인→sandbox) 모델에서도 reactive wakeup으로 단절 없이 완주, ④ canonical 문서 전부 `view_file` 800라인 limit 미만임을 확인했다. 따라서 신규 surface 없이 기존 Codex surface 재사용이 가능하고, 이는 DR-023이 제거한 "self-contained 다벌 미러 → 수동 cascade drift" 문제를 다시 들이지 않는 유일한 선택지다.

## Consequences

- 도구 나열 surface(entry contract, canonical adapter 표, README/GUIDE/MANUAL, AGENT-WORKFLOW, scaffold 생성물)에 Antigravity를 추가한다. 정비 순서는 Claude → Codex → Antigravity → Cursor로 통일한다.
- `BEHAVIOR-PRINCIPLES.md` §6 repo-外 self-audit scope에 Antigravity global 경로(`~/.gemini/config`, `~/.gemini/antigravity`)를 추가한다.
- `check-surface-mirror-parity.sh`는 변경하지 않는다 — Antigravity는 자체 adapter/prompt가 없어 parity 차원이 아니며 false-positive를 만들지 않는다. 미래 maintainer 오인 방지용 주석만 추가한다.
- **기존 adopter migration (경량, 조건부):** **DR-023 canonical+hybrid adapter 구조를 갖춘** adopter(현행 scaffold 산출물)는 `.agents/skills/`(canonical 소비) surface를 이미 보유하므로 Antigravity가 기능상 자동 상속된다(추가 설치 작업 없음, 부족한 도구명 문서화만 정규 harness upgrade로 도달). 단 **pre-DR-023 또는 selective-migration 상태의 target**은 `.agents/skills/` 구조가 충분치 않을 수 있어 자동 상속 대상이 아니다 — 먼저 canonical/adapter inventory migration(`docs/maintainer/migrations/canonical-adapter-rename.md`)을 수용한 뒤에야 동일하게 동작한다. 따라서 "자동 상속"은 모든 기존 target에 대한 일괄 claim이 아니다. 본 결정의 Done scope는 source repo + 신규 scaffold로 한정한다.
- **Exit Trigger (decoupling):** 아래 중 하나가 관측되면 Antigravity를 Codex surface에서 분리(전용 adapter/override)하는 재검토를 연다. 그 전에는 분리하지 않는다(premature optimization 회피).
  - Codex와 Antigravity의 `SKILL.md` 파싱 규칙·variable interpolation·global customization lookup이 실제로 갈라져 한쪽에서 오동작이 재현될 때
  - Antigravity의 컨텍스트 한계(`view_file` 800라인 등)나 실행 모델 차이가 공유 surface로는 회피 불가능한 workflow 실패를 일으킬 때
  - 두 도구가 동일 workspace에서 병렬 작업할 때 공유 상태로 인한 충돌이 기존 `HARNESS-PARALLEL-WORK-CONTROLS.md`(agent-agnostic) 범위로 커버되지 않을 때

## Reversal Cost

Medium — 통합은 대부분 additive 문서 변경이라 되돌리기는 단순(해당 행 제거). 단 Exit Trigger 발동 시 전용 surface 신설은 별도 High-cost 전환(DR-023 미러 부활)이므로 그 시점에 별도 DR로 판단한다.

## Linked Backlog Items

- FEAT-20260618-001 (Antigravity 4번째 지원 도구 추가)
- 연계: DR-012 (entrypoint symmetry), DR-023 (canonical + hybrid adapter), DR-007 (language policy)
