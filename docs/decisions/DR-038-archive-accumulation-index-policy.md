# DR-038: Archive Accumulation & Index Location Policy

Date: 2026-06-13
Status: Accepted
Track: harness
Linked DRs: DR-013, DR-014, DR-016

## Question

완료된 Work·DR·기타 artifact가 archive에 누적되는 구조는 문제인가? 문제라면 어떤 관리 정책(현행유지/rollup/retention/미이동/index 재배치)을 채택하는가? 그리고 archived 인덱스는 어디에 두는가?

## Context — 누적 실해악 정량화 (2026-06-13 실측)

| 측정 | 값 | 해악 |
| --- | --- | --- |
| archive works (harness) | 105개 (2026-06-10 71개 → +34/3일) | **≈0** — `docs/archive/`는 세션 시작 시 자동 로드되지 않는다 |
| archive 전체 | 150 files / 2.1M | ≈0 — repo bloat 사소 |
| archive decisions / retrospectives | 8 / 4 | ≈0 |
| **live `docs/works/harness/README.md`의 Archived 테이블** | **106 rows / 전체 130줄** | ⚠️ **유일한 실제 비용** |

핵심: "archive는 자동 로드 안 됨 → cost≈0"은 `docs/archive/` **파일에만 참**이다. archived **인덱스**는 live category README 안에 박혀 있어, harness `/work-plan`·`/work-close` 때마다 agent context에 로드된다. +3/day로 단조 증가한다.

추가 발견: archive-side mirrored README는 이미 **표준 패턴**이다 — `docs/archive/docs/decisions/README.md`(존재), `docs/archive/docs/retrospectives/README.md`(존재)가 따른다. `docs/works/{category}`만 3-table live README(Active/Done/**Archived**)로 archived 인덱스를 hot path에 두는 **유일한 outlier**였다. 이 패턴의 출처는 DR-016(line 56·102)·DR-013(권장 섹션)·HARNESS-PROTOCOL Index Rules이며, 동시에 `.claude/rules/docs-workflow.md`는 이미 "the archive index"(별도)를 가정해 **내부 불일치** 상태였다.

## Decision

1. **누적 자체는 무조치한다 (retention = keep-all).** `docs/archive/`는 자동 로드되지 않아 운영/context 비용이 ≈0이다. **rollup/digest(B), retention/pruning(C), close 시 미이동(D)은 채택하지 않는다** — 모두 정보 손실 또는 git history 추적성 저하를 동반하는데, 이를 정당화할 실해악이 없다.
2. **archived 인덱스는 archive-side mirrored README에 둔다 (index relocation).** live `docs/works/{category}/README.md`는 **`Active` + `Done (Archive Pending)`만** 보유하고, 완전 종결 Work의 인덱스는 `docs/archive/docs/works/{category}/README.md`로 이전한다. 이는 decisions·retrospectives가 이미 쓰는 패턴이며, works/harness outlier를 거기에 정합시킨다.
3. **모든 category에 일관 적용한다.** harness·product(DR-031 대칭)·decisions·retrospectives·troubleshooting 모두 동일 규칙: live 인덱스 = 현행(Active/Pending), archive-side 인덱스 = Archived.
4. **archive-side README는 create-on-first-archive다.** fresh scaffold는 빈 archive-side README를 seed하지 않는다(decisions/retro 기존 동작과 동일). 첫 archive 이동 시 `/work-close`가 생성한다.

## Options Considered

| Option | 장점 | 단점 | 판단 |
| --- | --- | --- | --- |
| A. 현행 유지 + 무조치 근거만 명문화 | 변경 0 | live README hot-path 인덱스 단조 증가를 방치 | 부분 채택(retention은 무조치) |
| B. rollup/digest | 파일 수↓ | granular 검색성↓, 정보 압축 손실 | 기각 |
| C. retention/pruning | repo 축소 | git log 외 본문 영구 손실, reversal cost | 기각 |
| D. close 시 archive 미이동 | archive dir 폐지 | Done 추적성을 git history에만 의존 | 기각 |
| **E. archive-side index relocation** | 무손실(전 행 보존), hot path에서만 제거, 기존 decisions/retro 패턴과 일치, 구조 불일치 해소 | canonical/protocol/scaffold cascade 필요 | **채택** |

## Rationale

문제의 본질은 "파일이 쌓인다"가 아니라 **"archived 인덱스가 live working 파일에 얹혀 context로 끌려온다"**였다. 이 하네스의 핵심 철학(session-start는 현행 섹션만 로드, archive는 자동 로드 안 함)에 비추면, 무한 증가하는 archived 인덱스를 live README에 두는 것은 아키텍처 모순이다. relocation은 무손실이면서 이 모순을 해소하고, 이미 존재하는 decisions/retro 패턴으로 works를 일원화한다. 누적된 파일 자체(105개)는 자동 로드되지 않으므로 prune/rollup으로 건드릴 이유가 없다.

## Consequences

- live `docs/works/{category}/README.md`는 `Active` + `Done (Archive Pending)` + archive-side pointer로 유지하고, `Archived` 테이블은 두지 않는다.
- archived 인덱스는 `docs/archive/docs/works/{category}/README.md`에 둔다. (이 결정과 함께 works/harness 106행을 이전한다.)
- DR-016(Done→Archived 트리거)과 DR-013(work-file-spec README 섹션 권장)을 이 정책에 맞게 amend한다.
- HARNESS-PROTOCOL Index Rules, `/work-close` Archive 절차, `/work-plan` README 생성 안내, `.claude/rules/docs-workflow.md`, `scripts/create-harness.sh`(live README seed·pointer), repo-health index 점검을 archive-side 기준으로 정렬한다.
- backlog `Archive 누적 관리 정책` 항목과 흡수된 `AWH-OQ-001`(historical artifact 보존량 기준)을 종결한다 — 보존량 결정은 "keep-all + archive-side index"로 답한다.
- behavior 불변: Done/Archived 상태 분리, soft archive 트리거(`/session-start`·`/work-resume`), git mv 경로 미러링(DR-014)은 그대로다.

## Reversal Cost

Medium — 다중 canonical/protocol/scaffold 표면을 정합시키므로, 되돌리면 그 표면들을 함께 복원해야 한다. 단 데이터(인덱스 행)는 무손실 이동이라 정보 손실 위험은 없다.

## Linked Work

- CHORE-20260613-013
</content>
