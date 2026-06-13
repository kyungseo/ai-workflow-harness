---
id: CHORE-20260613-020
priority: P2
status: Done
risk: L2
scope: W1~W5 완료 후 전체 정렬 검토에서 발견한 문서 현행화 gap을 닫는다. (1) `HARNESS-MAINTAINER-GUIDE.md` §5 Validation에 validation spine runner(`run-harness-checks.sh`) 등재, §9 Public Release Checks에 version-release sweep(Release Full Sweep / §3-1 / spine `--all`) pointer 추가. (2) `VERIFICATION-COMMANDS.md` scripts/tests cascade note에 `check-default-template-parity.sh` 스크립트명 등재(P2). README Documentation Map 2건(PLAN-SUMMARY/SCAFFOLD-BOOTSTRAP)은 의도된 제외/무관으로 비범위.
appetite: 0.25d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-036]
related_troubleshooting: []
related_work: [CHORE-20260613-018, CHORE-20260613-019, CHORE-20260611-009]
---

# CHORE-20260613-020: MAINTAINER-GUIDE validation/release currency + catalog 등재 보완

## Top Summary

- **목표:** W1~W5 산출물 현행화 매트릭스 검토에서 확정한 gap을 닫는다. 검증 척추 runner와 release sweep이 maintainer 메인 진입 문서(`HARNESS-MAINTAINER-GUIDE.md`)의 §5/§9 본문에 누락된 것이 핵심.
- **왜 지금:** validation spine(CHORE-20260611-005~ / 018)·Release gate 연결(019)까지 끝났는데, 정작 maintainer가 처음 보는 §5 Validation 표는 scaffold 검증을 dry-run만으로 표기하고 §9는 public 전환(visibility)만 다룬다. 운영 진입점과 실제 검증 자산 사이 단절.
- **핵심 경계:** §2-a가 이미 maintainer satellite 문서를 pointer로 가리키므로, §5/§9에 **명령 복제가 아니라 pointer/1줄**만 추가한다. SSoT(VERIFICATION-COMMANDS / GIT-WORKFLOW §3-1)는 그대로.
- **역할:** Claude author + self red-team(plan + result).

## Red Team — 착수 전 자기검토

| # | 공격 | 판정 |
| --- | --- | --- |
| RT1 | `HARNESS-MAINTAINER-GUIDE.md`가 optional-pack ship → source-only 토큰(`run-harness-checks.sh`, `VERIFICATION-COMMANDS.md`) 삽입 시 leak-scan FAIL | §2-a가 **이미** `VERIFICATION-COMMANDS.md`·`SOURCE-REPO-OPERATIONS.md`를 참조하며 leak-scan 통과 중. 동일 수준. 구현 후 `--all`로 실측 확정 |
| RT2 | §5/§9에 sweep 전체 복제 = SSoT 중복 | pointer/1줄만. 상세는 VERIFICATION-COMMANDS·GIT-WORKFLOW §3-1 유지 |
| RT3 | README 2건도 고쳐야? | 아니오. PLAN-SUMMARY는 README가 PLAN 계열 의도적 비등재, SCAFFOLD-BOOTSTRAP은 W1~W5 무관 기존 상태. scope 밖 |
| RT4 | P2(default-template-parity 등재)가 P1과 성격이 달라 한 Work에 묶으면 산만? | 둘 다 "검증 자산 ↔ 문서 현행화"라는 동일 테마. catalog cascade note 한 줄이라 저비용 |

## Scope / Non-Goals

### Scope

1. `HARNESS-MAINTAINER-GUIDE.md` §5 Validation 표에 validation spine runner row 추가(상세는 TAXONOMY/VERIFICATION-COMMANDS pointer).
2. `HARNESS-MAINTAINER-GUIDE.md` §9 Public Release Checks에 version-release sweep pointer 추가(GIT-WORKFLOW §3-1 + Release Full Sweep). public 전환 vs version release 구분 명시.
3. `VERIFICATION-COMMANDS.md` scripts/tests cascade note에 `check-default-template-parity.sh`(+ 누락 helper) 스크립트명 등재.

### Non-Goals

- README Documentation Map 2건(PLAN-SUMMARY/SCAFFOLD-BOOTSTRAP) — 의도된 제외/W1~W5 무관
- §5/§9에 sweep/Layer 전체 복제
- 새 검증 항목·스크립트 추가, CI/pre-commit 배선(DR-036 유지)

## Done Criteria

- [x] §5 Validation에 spine runner row 추가(runner 진입점 + TAXONOMY/VERIFICATION-COMMANDS pointer)
- [x] §9에 version-release sweep pointer(§3-1 / Release Full Sweep / VERSIONING) + public 전환과 명시 구분
- [x] `VERIFICATION-COMMANDS.md` cascade note 스크립트 목록을 6개로 현행화(default-template-parity 등재)
- [x] `run-harness-checks.sh --all` OVERALL PASS, leak-scan [2] 3모드 green (MAINTAINER-GUIDE optional-pack 영향 없음 실측)
- [x] 재교차 매트릭스 6×3 전부 ✓ (TAXONOMY/VERIFICATION-COMMANDS/MAINTAINER-GUIDE §5)
- [x] result self red-team

## Verification

- `bash scripts/tests/run-harness-checks.sh --all` → OVERALL PASS (leak-scan 3모드 green)
- `git diff --check` clean
- 재교차 grep 매트릭스: 6개 스크립트 × {TAX, VC, MG} = 전부 ✓✓✓

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | branch + Work 파일 + scope 확정(§5/§9 + P2; README 2건 제외) | 완료 |
| CP1 | §5 spine row + §9 sweep pointer + VERIFICATION-COMMANDS 6개 현행화 | 완료 |
| CP2 | --all 검증(leak-scan 실측) + 재교차 6×3 grep + result red-team | 완료 |

## Result Red Team (구현 후 자기검토)

| # | 공격 | 판정 |
| --- | --- | --- |
| RR1 | MAINTAINER-GUIDE optional-pack에 source-only 토큰 추가 → leak-scan FAIL? | **무위험 실측.** `--all` leak-scan [2] 3모드 PASS. §2-a 기존 참조와 동일 수준 |
| RR2 | §5 매트릭스가 run-harness-checks로 대표 — 개별 스크립트명 6개 미기재 과소? | 의도. §5는 검증 진입점이라 runner 하나 + TAXONOMY/VC pointer로 충분. 6개 나열은 과잉 |
| RR3 | §5/§9 SSoT 복제? | pointer/1줄만. sweep 상세는 VERIFICATION-COMMANDS·§3-1 유지 |
| RR4 | README 2건 미처리가 검토 누락? | 아니오 — PLAN-SUMMARY는 README PLAN 계열 의도적 비등재, SCAFFOLD-BOOTSTRAP은 W1~W5 무관. scope에서 명시 제외 |

**종합:** maintainer 진입 문서(§5/§9)와 검증 자산의 단절을 pointer로 연결. catalog SSoT 스크립트 목록을 3→6 현행화. leak-scan·SSoT 중복 모두 회피.

## Discovery

- W1~W5 완료 후 전체 정렬 검토(2단계: 직접 검토 + 산출물 역추적 매트릭스)에서 발견. gap이 `HARNESS-MAINTAINER-GUIDE.md` §5/§9에 집중됨을 정량 확인. README 2건은 의도/무관으로 scope에서 제외.

## Next Actions

1. §5/§9 + VERIFICATION-COMMANDS 등재 구현.
2. --all 검증, result red-team, work-close. 이후 archive 3건(017/018/019) 별도 처리.
