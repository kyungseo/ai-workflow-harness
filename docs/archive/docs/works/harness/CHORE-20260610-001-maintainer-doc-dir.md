---
id: CHORE-20260610-001
priority: P2
status: Archived
risk: L2
scope: scaffold 미복사 source-only "release·maintenance 내부 문서" 3종을 `docs/` 루트에서 전용 디렉토리 `docs/maintainer/`로 통합한다. 대상 `VERIFICATION-COMMANDS.md`, `VERSIONING.md`, `docs/migrations/`(디렉토리째). SCAFFOLD-BOOTSTRAP·SCAFFOLD-ONBOARDING-GUIDE는 온보딩/사용자 표면이라 루트 유지(제외). inbound live 참조 cascade 갱신, DR-008 location 표 정합, DR-021 amendment note.
appetite: 0.5d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-008, DR-021, DR-028, DR-031]
related_troubleshooting: []
related_work: [CHORE-20260609-005]
---

# CHORE-20260610-001: source-only maintainer 문서 디렉토리 정리

## Top Summary

- **목표:** `docs/` 루트에 누적된 source-only maintainer 문서를 전용 디렉토리 `docs/maintainer/`로 통합해 루트 누적을 방지한다.
- **디렉토리 조직 원칙:** `docs/maintainer/` = **source-only "release·maintenance 내부 문서"**. 사용자 온보딩/scaffold 표면 문서는 제외한다.
- **결정 (사용자 승인):**
  - **이동 3종** → `docs/maintainer/`: `VERIFICATION-COMMANDS.md`(release sweep 카탈로그), `VERSIONING.md`(L4 자기선언 "source repo 전용 maintainer"), `docs/migrations/`(migration note).
  - **루트 유지 (제외 2종):** `SCAFFOLD-BOOTSTRAP.md`(생성물 `BOOTSTRAP.md` 설계 spec — scaffold 표면), `SCAFFOLD-ONBOARDING-GUIDE.md`(L1 "대상: 처음 사용하는 개발자" — 사용자용 매뉴얼, optional-pack `WORKFLOW-MANUAL` 계열).
  - **STATUS Recent Decisions DR-031 행:** immutable 유지(그 시점 결정 기록). 경로 갱신은 live SSoT인 DR-031 본문에서만.
  - **DR:** 신규 DR 대신 **DR-021(source/target boundary) amendment note** 1줄(source-only maintenance 내부 문서는 `docs/maintainer/` 수용).
- **판별 근거:** 3종은 scaffold 어떤 옵션에서도 target 미복사 + 비-온보딩 maintainer 내부. 제외 2종은 온보딩/사용자 표면.
- **비목표:** SCAFFOLD-* 2종 이동, scaffold script 수정(경로 하드코딩 없음), archive 참조 갱신, optional-pack(ARCHITECTURE/MAINTAINER-GUIDE) 이동.

## Impact Analysis (사전 확인 완료)

- **scaffold script 무영향:** `create-harness.sh`가 3종 경로를 하드코딩하지 않음(생성물에도 새기지 않음). 어떤 옵션에서도 target 미복사.
- **invariant leak 테스트 무영향:** `check-scaffold-invariants.sh [2]`는 절대경로·repo명만 탐지 → `docs/maintainer/` 경로 미탐지, 신규 leak 없음.
- **비-md/hook/gate-config/CI 하드코딩 전무.** `docs/README.md` 인덱스 부재.
- **참조 스타일 root-relative:** moved 파일 outbound 참조 불변, inbound만 갱신.
- **archive 참조(미갱신, 의도적):** VERIFICATION-COMMANDS 2건, VERSIONING 1건, migrations 1건.

## Scope / Plan

**(A) 이동** (`git mv`, history 보존):
```
docs/maintainer/
├── VERIFICATION-COMMANDS.md       ← docs/
├── VERSIONING.md                  ← docs/
├── migrations/                    ← docs/migrations/ (README.md + product-track-rename.md 통째)
└── README.md                      # 신규 dir index
```

**(B) inbound live 참조 cascade** (`docs/X` → `docs/maintainer/X`):

| 이동 문서 | 갱신 파일 |
| --- | --- |
| VERIFICATION-COMMANDS | `HARNESS-QUICK-REFERENCE.md`, `HARNESS-RECOVERY-VALIDATION.md`, `AGENT-WORKFLOW.md`, `backlog/HARNESS.md`(verification preset), `skills/workflow/repo-health.md`, `VERSIONING.md`(상호) |
| VERSIONING | `backlog/HARNESS.md`, `DR-028`, `VERIFICATION-COMMANDS.md`(상호) |
| migrations | `backlog/HARNESS.md`, `DR-008`(location 표), `DR-031`(본문), `retrospectives/harness-distribution-plugin-model-20260608.md`, `skills/workflow/repo-health.md` |

**(C)** DR-008 location 표 `docs/migrations/` → `docs/maintainer/migrations/`.
**(D)** DR-021 amendment note 추가.
**(E)** backlog candidate 행(scope 3개로 정정) 정비는 **develop merge 후 tracking-only**. 본 작업에선 verification-preset 경로만 갱신.

## Done Criteria

- [x] 3종 자산 → `docs/maintainer/` `git mv`, history 보존 (R 상태 확인)
- [x] `docs/maintainer/README.md` 신설
- [x] inbound live 참조 stale 0 (의도적 잔존: STATUS:41 immutable, backlog candidate row, Work self)
- [x] DR-008 location 표 정합 (`docs/maintainer/migrations/`)
- [x] DR-021 amendment note 반영 (2026-06-10 행)
- [x] DR-031 본문 migrations 경로 갱신
- [x] scaffold dry-run에 maintainer 문서 미생성 (누수 0건 확인)

## Verification

- `git mv` 후 `rg` stale 0 (archive·maintainer 내부 self 제외)
- `bash -n scripts/create-harness.sh` + `bash scripts/create-harness.sh --dry-run <name> temp/<name>` → maintainer 미출력
- `bash scripts/tests/check-scaffold-invariants.sh temp/<name>` → leak 0 유지 (가능 시)
- `git diff --check`
- 임시 산출물은 프로젝트 내 `temp/`에 생성(/tmp 권한 회피)

## Risk / Reversal

- **리스크:** inbound 참조 누락 시 dangling pointer. `rg` 전수로 차단.
- **되돌리기:** Low~Medium. 역 `git mv` + cascade 재갱신, branch 단위 revert.

## Discovery

- backlog의 "source-only maintainer 문서 디렉토리 정리" candidate(P2) 착수. CHORE-20260609-005 논의에서 파생.
- 원 candidate는 6종 대상이었으나, scaffold 동작 검토로 SCAFFOLD-BOOTSTRAP(scaffold 표면)·SCAFFOLD-ONBOARDING-GUIDE(사용자 매뉴얼)·optional-pack 2종을 제외, **순수 maintenance 내부 3종**으로 축소(사용자 승인).
- 2026-06-10 archive: PR #123 develop merge 완료 후 archive drain. backlog candidate row 정리와 동일 commit(CHORE-20260610-002 tracking).

## Checkpoints

- 2026-06-10 착수 — feature branch 생성, Work 파일/STATUS Active pointer 등록.
- 2026-06-10 실행 완료 — 3종 `git mv`(history 보존), inbound cascade 9개 파일 갱신, `docs/maintainer/README.md` 신설, DR-021 amendment + DR-008/DR-028/DR-031 경로 정합. 검증: stale 0(의도적 잔존 제외), `git diff --check` clean, scaffold dry-run 누수 0.

## Next Actions

- feature branch에서 (A)~(D) 실행 → verification → `/work-close`로 Done + STATUS/index 번들.
