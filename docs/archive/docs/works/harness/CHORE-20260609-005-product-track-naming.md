---
id: CHORE-20260609-005
priority: P2
status: Archived
risk: L2
scope: product track backlog/work 네이밍을 harness track과 대칭으로 전환. `docs/backlog/PHASE{n}.md`→`docs/backlog/PRODUCT.md`(phaseless 기본), `docs/works/phase{n}/`→`docs/works/product/`. phase는 optional migration. harness 내부 "Phase"(절차 단계·STATUS 필드·refactor)는 보존. DR-031로 결정 기록.
appetite: 1d
planned_start: 2026-06-09
planned_end: 2026-06-09
actual_end: 2026-06-09
related_dr: [DR-008, DR-013, DR-014, DR-029, DR-031]
related_troubleshooting: []
related_work: []
---

# CHORE-20260609-005: Product Track 네이밍 전환 (PHASE{n} → PRODUCT)

## Top Summary

- **목표:** harness 내부 "Phase"(리팩토링 milestone·명령 절차 단계·STATUS 필드)와 product backlog `PHASE{n}`의 네이밍 충돌을 해소한다. product track을 harness track과 **대칭**으로 만들고(단일 `PRODUCT.md` / `docs/works/product/`), phase는 **optional**로 강등한다.
- **결정 (사용자 승인, Option B):**
  - `docs/backlog/PHASE{n}.md` → `docs/backlog/PRODUCT.md` (phaseless 기본)
  - `docs/works/phase{n}/` → `docs/works/product/`
  - optional phasing = **migration**: 단계 도입 시 `PRODUCT.md`→`PRODUCT-P1.md` rename 후 `PRODUCT-P2.md` 추가. `PRODUCT.md` 단독 OR `PRODUCT-P{n}` 연번 중 하나만 존재("1 빠짐" 회피).
  - DR-014 archive 트리거 "Phase 완료" → "product track work 완료/마일스톤"(harness 동형).
  - `feature/p{n}-` 단축 패턴은 "단계 운영 시 단축형"으로 설명만 일반화.
- **판별자:** all-caps `PHASE{n}`/`PHASE1`/`PHASE*.md`/`works/phase`는 product 전용 → rename. Title-case "Phase"는 대부분 보존.
- **Adopter migration note:** 이미 scaffold된 repo(`PHASE1.md`/`phase1/` 보유)의 수용 절차는 **`docs/migrations/product-track-rename.md`**(source-only) 참조. 선례 패턴: `docs/migrations/canonical-adapter-rename.md`.
- **비목표:** harness "Phase" 전반 변경, 예제 prompt(08/11/13/14) 갱신, archive 재작성.

## Optional Phasing Migration — Side Effects & Handling

단계 도입 시 `PRODUCT.md`→`PRODUCT-P1.md` rename의 부가 영향과 대응. **핵심 전략: canonical·tooling·rule을 phasing-agnostic으로 작성해 migration 영향을 최소화한다.**

- **선제 차단 (이 Work에서 적용):**
  - 문서 표기: "`docs/backlog/PRODUCT.md`(단계 운영 시 `PRODUCT-P{n}.md`)".
  - tooling grep: `docs/backlog/PRODUCT*.md` **glob** 사용 → phaseless/phased 양쪽 동작.
  - work 디렉토리 **decouple**: backlog가 phasing해도 `docs/works/product/` 단일 유지. Work 파일은 date-based Work ID(`<TYPE>-<YYYYMMDD>-<NNN>`)라 phase 무관.
- **migration 시점 영향 (DR-031 체크리스트로 명문화):**
  1. `git mv docs/backlog/PRODUCT.md docs/backlog/PRODUCT-P1.md`
  2. inbound 참조 갱신: `rg 'PRODUCT\.md'` → STATUS / `docs/works/**` Discovery / `docs/decisions/**` Linked Backlog / PLAN-SUMMARY 등 project-local 참조를 `PRODUCT-P1.md`로
  3. `docs/backlog/PRODUCT-P2.md` 추가
  4. work 디렉토리·Work ID·tooling glob은 무변경(decouple/agnostic 덕분)
  5. 검증: `rg 'backlog/PRODUCT\.md'` 0건(phased 상태에서 stale 참조 없음)

## Scope / Plan (원자적 — 부분 rename 금지)

| 그룹 | 파일 | 작업 |
| --- | --- | --- |
| DR | `DR-031`(신규 Accepted), `DR-008`·`DR-013`·`DR-014`·`DR-029` | 결정+migration 체크리스트 기록, 예시/spec/트리거 갱신 |
| canonical | `AGENT-WORKFLOW.md`, `HARNESS-PROTOCOL.md`, `HARNESS-NAMING-RULES.md`, `HARNESS-QUICK-REFERENCE.md` | PHASE{n}→PRODUCT(phasing-agnostic 표기) |
| tool surface | `skills/workflow/{work-plan,work-register,work-close,work-select,record-decision,repo-health}.md`, `prompts/{claude,codex,cursor}-session-start.md`, `.claude/rules/docs-workflow.md`, `.cursor/rules/coding.mdc` | 경로/토큰/prose, repo-health glob |
| scaffold | `scripts/create-harness.sh` | PRODUCT.md 생성, works/product/ dir, 안내/표/README 템플릿 |
| user-facing | `README.md`, `WORKFLOW-MANUAL.md`, `SCAFFOLD-BOOTSTRAP.md`, `SCAFFOLD-ONBOARDING-GUIDE.md`, `VERIFICATION-COMMANDS.md` | 경로/mermaid/체크리스트 |
| gitflow | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | `feature/p{n}-` 설명 일반화 |
| backlog | `docs/backlog/HARNESS.md` | 이 항목(summary row + details) 제거 |

**PRESERVE:** work-doc/repo-health 절차 "Phase 1-6", STATUS 필드 "Current phase/Phase completion criteria/phase·focus", harness "Phase 2 refactor", 전체 archive, 예제 prompt.

## Done Criteria

- [x] 위 매핑 원자적 적용, harness "Phase" 오변경 0
- [x] `rg 'PHASE\{n\}|PHASE[0-9]|backlog/PHASE|works/phase'` — 실 stale 0 (전환-설명 의도적 참조만 잔존: DR-031/migration note/Work/인덱스)
- [x] canonical/tooling phasing-agnostic(glob `PRODUCT*.md`/optional-suffix) 적용
- [x] scaffold 실물 생성(`temp/sim-product3`): `docs/backlog/PRODUCT.md`("# Product Backlog") + `docs/works/product/` 생성, `PHASE1` 미생성 확인
- [x] product 개발 체인 파일 정합 확인(STATUS→PRODUCT.md→works/product→work-plan/register), 생성 canonical PRODUCT.md 참조 일치
- [x] cascade 정합: canonical↔adapter(.claude/commands·.agents/skills·.cursor PHASE 0)↔prompts↔rules
- [x] README/MANUAL/GUIDE/BOOTSTRAP/ONBOARDING 갱신 확인
- [x] DR-031(Accepted, migration 체크리스트 포함) + DR-008/013/014/029 갱신
- [x] adopter migration note `docs/migrations/product-track-rename.md` 신설 + 기존 migration note를 `docs/migrations/`로 이동(전용 디렉토리 신설, prefix 제거)
- [x] 사용자 최종 리뷰 통과 (2026-06-09)
- [ ] 사용자 최종 리뷰 후 Done

## Verification

`rg` 다중 패턴 0건, `bash -n create-harness.sh`, scaffold dry-run 실물(PRODUCT.md/works/product/), 시뮬레이션, cascade grep, DR 정합.

## Risk / Reversal

L2, blast-radius 큼. Risk: harness "Phase" 오변경 → file-by-file 수동 disambiguation(blind sed 금지). Reversal: 원자적 단일 PR revert.

## Checkpoints

- (착수) Work 생성, branch `feature/chore-20260609-005-product-track-naming`.

## Next Actions

- DR-031 작성 → canonical → DR → tool surface → scaffold → user-facing → backlog 제거 → 검증.

## Discovery

- 전수 sweep(2026-06-09): all-caps PHASE = product 전용 판별자 확정. Title-case "Phase" 대부분 보존(work-doc/repo-health 절차, STATUS 필드, harness refactor).
- DR-014 "Phase 완료" archive 트리거가 phaseless에서 무효 → product work 완료 기준으로 변경(DR-031 반영).
- Migration 부가영향 분석: canonical/tooling을 phasing-agnostic(glob/optional-suffix)으로 작성 + work dir decouple → migration 영향을 파일 rename·project-local 참조·PRODUCT-P2 추가 3가지로 국한.
- (Archived 2026-06-09) PR #120 merge 후 archive drain. `docs/archive/docs/works/harness/`로 이동.
