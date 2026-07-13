# DR-044: Safety Rule Layer — Canonical SSoT + 4-Tool Thin Projection

Date: 2026-07-13
Status: Accepted
Track: harness
Linked DRs: DR-007, DR-021

<!-- Accepted 2026-07-13 (CHORE-20260713-007, cross-review R0/R1 Codex — R1-F3 권고로 Draft 아닌 Accepted 기록). brief rule-asset-generalization-strategy-20260622 축 A의 실행 결정. 이 DR은 source-only이며 scaffold seed에 포함하지 않는다 — shipped 표면(skills/safety/*, adapter, AGENTS.md)은 이 DR token을 인용하지 않고 self-describe한다. -->

## Question

stack-agnostic 안전 rule(destructive/privileged/secret, infra 안전)이 도구별로 메커니즘·범위가 불일치하고(Claude path-scoped vs Cursor always) Codex/Antigravity에는 부재했다. 이 안전 의도를 4개 도구(Claude Code / Codex / Antigravity / Cursor)에 어떤 구조로 정규화하는가?

## Decision

1. **A1/A2 이층 분리:** A1 실행 안전(destructive/privileged/secret — **always**, 모든 경로) / A2 infra 안전(infra/deploy/environment — **path-scoped**). 하나의 rule로 합치지 않는다.
2. **canonical SSoT = `skills/safety/`:** `safety-critical.md`(A1)·`infra.md`(A2). 호출형 Codex skill이 아닌 canonical rule document이며, guard 전문은 이 위치만 보유한다. 언어는 English Only(DR-007 amendment 2026-07-13).
3. **adapter = thin projection:** 각 도구 표면(`.claude/rules/`, `.cursor/rules/`)은 canonical load directive + fail-closed bootstrap guard 1~2문장만 보유한다. 전문 복제 금지. pointer 소비가 특정 도구에서 신뢰되지 않는다는 실측이 나올 때만 그 도구에 한해 bounded duplication 예외 + semantic assertion을 도입한다.
4. **Codex/Antigravity 경로 = root `AGENTS.md` entry contract:** Safety Rule Layer 절이 A1을 session start에 항상, A2를 infra 작업 시 조건부로 로드하도록 지시한다. 중간 shared doc은 만들지 않는다(pointer hop 최소화).
5. **승인 경계 = state-changing/destructive/privileged로 한정:** read-only/query/render/validate/dry-run(secret 미접촉)과 bounded temp cleanup(같은 process가 만든 unique temp dir, path/prefix 검증 후)은 승인 없이 허용한다. 이 경계가 없으면 안전 rule이 정상 검증 workflow(deterministic runner의 temp cleanup 포함)를 차단한다(R1 실측).
6. **scaffold default 편입:** 모든 신규 target(generic 포함)에 배포. `--no-safety` opt-out은 두지 않는다. 기존 adopter는 다음 upgrade에서 framework-add 5건으로 수용(manifest tracked +5, 수동 migration 없음).
7. **정합 검증 = `check-rule-surface-parity.sh`:** 존재·pointer(literal)·scope semantics·thin projection invariant·copy matrix(static, runner Tier 0d) + temp scaffold 실생성·generated AGENTS.md routing·manifest exact entry(`--scaffold`, Tier 2c). 내용 동등성은 검사하지 않는다.

## Evidence Boundary

- **Codex runtime evidence:** current-entry consumption 확인 — reviewer 세션이 `AGENTS.md`를 읽고 A1 canonical을 로드·적용해 행동을 바꿈(승인 없는 destructive cleanup 회피). fresh-session auto-load는 기존 root-entry contract에 의존.
- **Antigravity: contract/static evidence만** — runtime 미실측. "4개 도구 runtime 소비 확인"으로 표현하지 않는다.
- Claude `paths: "**"`·Cursor `alwaysApply`의 canonical dereference는 static routing까지만 검증됨.

## Rationale

같은 안전 의도가 도구별로 갈라진 비대칭(구조 결함)과 신규 scaffold default의 구조적 일관성이 근거다 — "사고 예방 실적"이 아니다. workflow canonical화(SSoT+thin adapter)의 원칙을 재사용하되, rule은 always/path-scoped 적용이라 저장·적용 메커니즘을 별도 설계했다. 전문 복제는 canonical-in-name-only가 되므로 기각했다(cross-review R0-F2).

## Consequences

- 신규 scaffold target은 4툴 안전 surface를 기본 보유. manifest tracked set +5.
- adapter/canonical 변경 시 rule parity check가 회귀를 잠근다. adapter에 전문이 재유입되면 thin projection invariant(MUST:/NEVER: heading 탐지)가 FAIL.
- 축 B(stack rule: java-spring/testing)는 이 구조의 대상이 아니다 — product-first import 경로(option-pack backlog)로 별도 진행.

## Reversal Cost

Medium — source revert는 용이하나 릴리즈 후에는 adopter manifest tracked set 변화(framework-add 5건)가 동반되고, 4툴 표면과 scaffold copy matrix·검증 스크립트를 함께 되돌려야 한다. A1/A2는 파일·copy loop·assertion이 독립적이라 부분 롤백 가능.
