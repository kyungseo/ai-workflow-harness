---
id: CHORE-20260608-002
priority: P0
status: Archived
risk: L2
scope: 버전 체계 정의 + VERSION↔git tag 정렬. semver 정책 문서(VERSIONING.md) 신설, VERSION 0.2.0→1.1.0 조정, DR-028 기록, VERSION→create-harness.sh→manifest.json 경로 정합성 검증.
appetite: 1d
planned_start: 2026-06-08
planned_end: 2026-06-08
actual_end: 2026-06-08
related_dr: [DR-021, DR-028]
related_troubleshooting: []
related_work: []
---

# CHORE-20260608-002: 버전 체계 정의 + VERSION 정렬

## Top Summary

- **목표:** `VERSION`(0.2.0)과 git tag 라인(`ai-workflow-v1.0.8`)의 모순을 해소하고, 재발 방지용 semver 정책을 문서화한다. Phase 2 릴리즈를 `1.1.0`으로 확정.
- **핵심 결정 (사용자 승인):**
  - 버전 SSoT = **GitHub release tag 라인** (`ai-workflow-v{X.Y.Z}`). `VERSION` 파일은 bare semver mirror.
  - `develop`의 `VERSION` = 다음 in-development 릴리즈 값 → `1.1.0`.
  - Phase 2는 command rename(no-alias) 등 adopter-facing 변경 포함하나 **MINOR(1.1.0)** + 릴리즈 노트 breaking 명시로 처리.
  - 정책을 **DR-028**로 기록.
- **배선 현황:** `VERSION → HARNESS_VERSION → manifest.json` 경로(`create-harness.sh:135-138,716`)는 이미 정상. 값만 drift. 코드 변경 불요.
- **비목표:** 릴리즈 실행(tag/PR), VERIFICATION-COMMANDS 보완(별도 Work), archive drain(별도).

## Scope / Plan

| 순서 | 대상 | 작업 |
| --- | --- | --- |
| 1 | `docs/VERSIONING.md` (신규) | semver 기준(MAJOR/MINOR/PATCH) + tag↔VERSION 매핑 + bump 절차. source-only maintainer 문서(scaffold 미포함) |
| 2 | `VERSION` | `0.2.0` → `1.1.0` |
| 3 | `docs/decisions/DR-028-versioning-policy.md` (신규) | 버전 정책 결정 기록 |
| 4 | `docs/decisions/README.md` | DR-028 행 추가 |
| 5 | `docs/works/harness/README.md` | Active 행 추가 |
| 6 | `docs/STATUS.md` | Active Work pointer 추가 (승인됨). 완료 시 Next Actions P0 #0 해소 |
| 7 | Verification | `bash -n` + dry-run scaffold → manifest `harness_version`=1.1.0 확인 (Layer R) |

## Done Criteria

- [x] `docs/VERSIONING.md` 존재: semver 기준 + tag 매핑 + bump 절차 포함
- [x] `VERSION` = `1.1.0`
- [x] `docs/decisions/DR-028-versioning-policy.md` 존재, README 행 추가
- [x] scaffold dry-run에서 manifest `harness_version` = `1.1.0` 확인 (Layer R PASS: 69 tracked, 0 drifted)
- [x] `VERSIONING.md` scaffold 미포함 결정 기록 (source-only — 파일 헤더 + DR-028)
- [x] `bash -n scripts/create-harness.sh` PASS
- [x] STATUS Active Work pointer 반영 (Next Actions P0 #0 해소는 `/work-close` 시 처리)

## Checkpoints

- 2026-06-08: 구현 완료. VERSIONING.md + DR-028 신설, VERSION 0.2.0→1.1.0, DR/works README 행 추가, STATUS pointer 반영. Layer R 검증 PASS(manifest 1.1.0, drift 0).

## Discovery

- 2026-06-08: STATUS Next Actions P0 #0 "버전 체계 정의 + VERSION 정렬" 착수 (HARNESS.md backlog row 없음 — STATUS Next Action에만 존재). `VERSION`=0.2.0이 tag 라인 v1.0.8과 어긋난 drift 확인 — CHORE-20260605-006(manifest)에서 tag 라인 미정렬로 유입 추정. 값 참조는 `VERSION` 파일 + `docs/STATUS.md` 텍스트뿐(blast radius 작음).
