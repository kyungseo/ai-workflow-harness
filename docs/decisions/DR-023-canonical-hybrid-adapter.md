# DR-023: Canonical + Hybrid Adapter

Date: 2026-06-05
Status: Accepted

## Question

workflow 절차가 Claude command·Codex skill·Cursor rule에 self-contained 3벌(canonical 0)로 반복되고 `T11` 수동 cascade로 동기화돼 drift가 구조적 필연이다. 어떻게 단일화하는가?

## Decision

workflow 절차를 공통 **canonical SSoT 1벌**(루트 `skills/` 또는 동급)로 모으고, 도구별 표면은 **hybrid adapter**로 전환한다.

| 계층 | 보유 내용 |
| --- | --- |
| **Canonical (SSoT 1벌)** | 세부 절차, 검토축, cascade matrix, checklist, 상태 전이 |
| **Hybrid adapter** (`.claude/commands/`·`.agents/skills/`·`.cursor/rules/`) | Step 0, 핵심 gate **hard-stop 요약 + action 차단 조건**, 도구별 entry mechanism(slash 자동 / `AGENTS.md` routing / Cursor rule), fallback |

**adapter 최소 보유 범위:** Step 0 + 핵심 gate hard-stop(branch isolation, Approval Matrix gate, validation-before-commit)의 **요약·차단 조건** + entry mechanism + fallback. **Approval Matrix 전문·상세 checklist·cascade matrix는 canonical에 둔다** — adapter가 세부를 복제하면 "중복 없는 SSoT" 원칙을 깬다.

full thin pointer가 아니라 hybrid인 이유: ① Claude의 canonical 로드 지시는 `@` 하드 import가 아니라 자연어 유도라 100% 결정적이지 않다 → 핵심 gate는 adapter 자체 보유. ② 세 도구의 실행 mechanism 차이가 크다 — 그 차이가 "도구 고유=가볍게"의 자리. ③ workflow gate는 실패 시 damage가 크다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Canonical + hybrid adapter (채택) | mirror 부피·target context weight 동시 감소, drift 구조 제거, gate 안전 보존 | scaffold output 구조 변경(breaking), 자연어 로드 결정성 보강 필요 |
| Full thin pointer adapter | 최대 단일화 | 자연어 로드 실패 시 핵심 gate 누락 위험 |
| 현행 self-contained 3벌 | 도구별 독립 | drift 필연, 수천 줄 수동 cascade |

## Rationale

`/work`+`/close` 한 쌍만으로 Claude 239줄 + Codex 259줄 + Cursor 98줄 ≈ 596줄이 canonical 없이 `T11`(`docs/HARNESS-PROTOCOL.md:429`) 수동 cascade로 동기화된다. 11개 command 전체로는 수천 줄. drift는 사고가 아니라 구조다. 사용자 `ai-deck-compiler`의 `skills/create-deck.md`(837줄 canonical) ← thin command(115줄) 패턴이 도메인 skill에서 검증됐고 workflow skill에는 자리만 비어 있다. 단 workflow는 도메인보다 도구별 실행 mechanism 차이가 크고 gate damage가 커서 full thin이 아니라 hybrid가 안전하다(부모 Work 근거: `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:762-784`).

외부화 3대 실패모드 매핑: ① 라우팅 누락(canonical 1 SSoT 라우팅), ② 비대화(3벌→1+thin), ③ 선언-실행 괴리(adapter 자체 hard-stop, 위임 아님).

## Consequences

- canonical workflow 디렉토리가 신설되고, command/skill/rule이 adapter로 축소된다.
- scaffold도 canonical 1벌 + thin adapter만 복사 → DR-021 A/B boundary와 정합(canonical = framework A-owned).
- **실제 canonical 추출·adapter 전환·command rename(no legacy alias)은 같은 breaking slice(slicing draft #13)로 적용한다. 단독 선행 금지** — Q4 `--check` 최소 경로 위에서만(§10-a 순서 제약: `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:947-960`).
- active target(`ai-deck-compiler` 등)은 자기 repo 별도 migration Work로 수용(OQ-17 cross-repo 경계).
- OQ-8(adapter minimum hard-stop), OQ-15(no-alias rename 방향) 닫힘.

## Reversal Cost

High — scaffold output 구조와 command/skill/rule을 동시에 바꾸는 breaking 전환이다. 방향 결정(이 DR) 자체는 Low이나 적용은 High.

## Linked Backlog Items

- CHORE-20260605-001 (slice 0 CP3 / DR-C)
- 부모: CHORE-20260604-001 §5·§10
- 연계: DR-021(canonical=A-owned), DR-019(skill naming)
