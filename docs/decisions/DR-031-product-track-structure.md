# DR-031: Product Track Structure — Symmetric PRODUCT.md + Optional Phase

Date: 2026-06-09
Status: Accepted
Track: harness
Linked DRs: DR-008, DR-013, DR-014, DR-029

## Question

product track backlog/work를 어떻게 명명·구조화할 것인가? 기존 `docs/backlog/PHASE{n}.md` / `docs/works/phase{n}/`는 harness 내부 "Phase"(리팩토링 milestone, 명령 절차 단계, STATUS `Current phase` 필드)와 네이밍이 충돌한다.

## Decision

product track을 harness track과 **대칭** 구조로 만들고, phase 개념을 **optional**로 강등한다.

**1. 기본 구조 (phaseless, harness와 대칭).**

| | harness track | product track |
| --- | --- | --- |
| backlog | `docs/backlog/HARNESS.md` | `docs/backlog/PRODUCT.md` |
| work dir | `docs/works/harness/` | `docs/works/product/` |

**2. Optional phasing.** 단계 운영이 실제 필요한 프로젝트만 product backlog를 분할한다. 분할은 **migration**으로 수행한다(아래 절차). `PRODUCT.md` 단독 상태 OR `PRODUCT-P1.md`부터의 연번 상태 중 하나만 존재하며, `PRODUCT.md`와 `PRODUCT-P2.md`가 혼재하지 않는다("P1 누락" 회피).

**3. Phasing-agnostic 참조 원칙.** canonical 문서·tooling·rule은 product backlog를 phasing 상태와 무관하게 동작하도록 작성한다.

- 문서 표기: `docs/backlog/PRODUCT.md`(단계 운영 시 `docs/backlog/PRODUCT-P{n}.md`).
- tooling grep: `docs/backlog/PRODUCT*.md` glob 사용.
- work 디렉토리는 backlog phasing과 **decouple** — phasing 여부와 무관하게 `docs/works/product/` 단일 유지. Work 파일은 date-based Work ID(`<TYPE>-<YYYYMMDD>-<NNN>`, DR-013)라 phase에 종속되지 않는다.

**4. Archive 트리거 (DR-014 갱신).** "Phase 완료 시 `docs/works/phase{n}/` 이동"은 phaseless에서 성립하지 않는다. product track work는 **완료/마일스톤 시 `docs/works/product/`에서 archive**로 이동한다(harness track과 동형).

**5. harness "Phase" 보존.** 명령 절차 단계(work-doc/repo-health "Phase 1-6"), STATUS 필드(`Current phase`, `Phase completion criteria`), harness 리팩토링 milestone("Phase 2")은 변경하지 않는다. 이 결정은 product track backlog/work 네이밍에만 적용된다.

## Optional Phasing Migration Checklist

phaseless → phased 전환 시(adopter-side 운영):

1. `git mv docs/backlog/PRODUCT.md docs/backlog/PRODUCT-P1.md`
2. project-local inbound 참조 갱신: `rg 'backlog/PRODUCT\.md'` → `docs/STATUS.md`, `docs/works/**`(Discovery), `docs/decisions/**`(Linked Backlog), `docs/PLAN-SUMMARY.md` 등을 `PRODUCT-P1.md`로
3. `docs/backlog/PRODUCT-P2.md` 추가
4. work 디렉토리·Work ID·canonical/tooling glob은 무변경(phasing-agnostic·decouple 덕분)
5. 검증: `rg 'backlog/PRODUCT\.md'` 0건

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| A. `PROD-P{n}` (phase 필수, prefix) | 최소 구조 변경 | harness/product 비대칭(충돌 근원) 유지, '-P' cryptic, phase 강제 |
| **B. `PRODUCT.md` 대칭 + phase optional (채택)** | 두 트랙 동형, 기본 네이밍에서 "Phase" 제거로 충돌 완전 해소, 대부분 adopter에 불필요 구조 미강제 | optional phasing migration 절차 필요(phasing-agnostic 작성으로 비용 최소화) |
| C. full i18n식 다벌 유지 | — | 해당 없음(과설계) |

## Rationale

충돌의 근원은 "harness=phaseless / product=phased"의 비대칭이었다. product를 harness와 대칭(`PRODUCT.md`/`works/product/`)으로 만들면 기본 네이밍에서 "Phase" 단어가 사라져 충돌이 구조적으로 해소된다. 대부분의 adopter는 단일 backlog로 충분하므로 phase를 강제하지 않고, 필요한 프로젝트만 migration으로 도입한다. canonical/tooling을 phasing-agnostic으로 작성해 migration 비용을 파일 rename·project-local 참조·신규 phase 파일 추가로 국한한다.

## Consequences

- `docs/backlog/PHASE{n}.md` → `docs/backlog/PRODUCT.md`, `docs/works/phase{n}/` → `docs/works/product/` 전면 전환(CHORE-20260609-005).
- DR-008(filename 예시), DR-013(work spec `works/product/`), DR-014(archive 트리거), DR-029(routing table) 갱신.
- scaffold(`create-harness.sh`)가 `PRODUCT.md` + `docs/works/product/` 생성.
- canonical/tooling은 `PRODUCT*.md` glob / "단계 시 PRODUCT-P{n}" 표기로 phasing-agnostic.
- harness "Phase"(절차·STATUS·refactor) 및 archive는 불변.
- `feature/p{n}-{topic}` 브랜치 단축 패턴은 "단계 운영 시" 용도로 설명만 일반화.
- 이미 scaffold된 target repo(`PHASE1.md`/`phase1/` 보유)의 수용 절차는 `docs/migrations/product-track-rename.md`(source-only)로 제공한다.

## Reversal Cost

Medium — 전면 네이밍 전환이라 되돌리려면 동일 규모 역전환 필요. 단 원자적 단일 PR이라 revert는 단순.

## Linked Backlog Items

- CHORE-20260609-005
