# DR-021: Source / Framework-vs-Project-State Boundary

Date: 2026-06-05
Status: Accepted (Amended 2026-06-08)

## Question

scaffold가 framework 자산과 project-state를 한 평면에 복사해 (a) framework만 업그레이드할 경로가 없고 (b) 무거운 framework 문서가 target에 누수돼 dangling reference를 만든다. source와 scaffold target의 책임 경계를 어떻게 정의하는가?

## Decision

scaffold 자산을 **3-class**로 분류한다.

| Class | 정의 | 소유 | default scaffold |
| --- | --- | --- | --- |
| **A. framework-owned** | source가 유지하는 workflow 기계(entrypoint, protocol/principles/workflow docs, command/skill/rule, prompt, settings/hooks, framework DR seed) | source | 포함(core 최소셋) |
| **B. project-state-owned** | target이 소유하는 작업 상태(STATUS, PLAN, backlog, works, target DR, retrospectives, troubleshooting, archive, README) | target | seed 골격만 |
| **Optional source pack** | source 소유이나 모든 target에 불필요한 무거운/예시 자산(`HARNESS-ARCHITECTURE`, `HARNESS-MAINTAINER-GUIDE`, `WORKFLOW-MANUAL`, session-start 외 prompt 번들, Spring profile) | source | **default 제외** — source link 또는 명시 flag |

경계는 **물리 디렉토리 이동 없이** logical marker(`.harness/manifest.json`, CHORE-20260605-006 구현 완료)로 식별한다. 이 분류표가 업그레이드 대상(A)과 leakage 불변식 테스트 대상의 입력이 된다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 3-class + logical marker (채택) | dangling/context-weight 해소, 업그레이드 경로 확보, 참조/자동로드 경로 보존 | manifest schema 등 하류 구현 필요 |
| 물리 `docs/` vs `harness/` 분리 | 경계 가시성 높음 | 모든 cross-reference·자동로드·scaffold 경로·cascade matrix 동시 파손, reversal High |
| 현행 copy 유지 | 단순 | framework 업그레이드 불가, dangling 지속 |

## Rationale

scaffold `adapt()`는 sed 치환 복사라 복사 순간 source↔target 연결이 끊긴다(`scripts/create-harness.sh:137-143`). `:199-226`이 entrypoint·protocol·maintainer 문서·DR 일부를 한 평면으로 복사하고, `:331-350`이 session-start 외 prompt까지 복사한다. `docs/PLAN.md:90-93`은 `HARNESS-ARCHITECTURE`/`HARNESS-MAINTAINER-GUIDE`를 "source Kept As Core"로 결정했으나 scaffold는 같은 문서를 target에도 ship한다 — "source keep"과 "target ship"이 한 결정에 뭉개진 것이 미분리의 표본이다. 무거운 framework 문서 누수는 target에서 DR-020/DR-011 dangling을 만든다. 물리 이동은 reversal cost가 높아 보류하고, logical marker로 경계를 긋는다.

외부화 3대 실패모드 매핑: ① 라우팅 누락(leakage→dangling 차단), ② 비대화(target context weight 감소), ③ 선언-실행 괴리(class marker가 leakage 테스트 대상 정의).

## Consequences

- default scaffold output이 축소된다(무거운 문서·확장 prompt·profile 제외) — downstream breaking 가능, 하류 slice에서 적용.
- exact scaffold file-list, manifest schema/hash, `--check`/`--upgrade`는 하류 slice 산출물.
- OQ-1(MANUAL 제외+source link), OQ-2(물리 분리 보류) 닫힘.
- physical move를 하지 않으므로 기존 cross-reference·자동 로드 경로는 유지된다.
- **reference integrity(하류 scope):** `docs/decisions/README.md` 인덱스처럼 framework가 참조하지만 미복사되는 자산은 하류에서 "A-class 필수 동반" 또는 "target에서 깨지지 않게 참조 조정" 중 하나로 해결한다. 이 DR은 exact file-list를 고정하지 않는다.

## Amendment History

| Date | Change |
|------|--------|
| 2026-06-08 | "향후" 표기 제거 — CHORE-20260605-006에서 manifest 구현 완료 |
| 2026-06-10 | source-only 위치 규약 추가 — 3-class 어디에도 ship되지 않는 **source-internal 유지보수 문서**(release verification·versioning policy·migration note 등)는 `docs/maintainer/`에 둔다. `docs/` 루트 누적과 source-only/배포 자산 혼재를 막기 위한 물리 정리이며, A/B/Optional class 경계나 logical marker 식별 방식은 불변. SCAFFOLD-* 온보딩 문서와 Optional source pack은 대상 아님 — CHORE-20260610-001 |

## Reversal Cost

Medium — 분류 원칙은 문서 결정이나, default 제외가 적용되면 generated surface가 바뀐다. 적용 전 단계에서는 Low.

## Linked Backlog Items

- CHORE-20260605-001 (slice 0 CP1 / DR-A)
- 부모: CHORE-20260604-001 §3·§6
- 연계: DR-023(canonical = A-owned), 하류 scaffold minimal output / manifest
