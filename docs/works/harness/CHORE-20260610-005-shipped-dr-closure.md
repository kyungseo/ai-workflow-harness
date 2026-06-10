---
id: CHORE-20260610-005
priority: P1
status: Done
risk: L2
scope: shipped 표면 문서가 scaffold seed에 없는 DR을 참조해 target에서 dangling을 만드는 패턴을 예방+해소한다. (정책) DR-033으로 closure 규약 확정(mode-a self-describe / mode-b Linked DRs 가드 / seed SSoT=create-harness.sh 파생). (A) 작성 rule. (B) source-only static check + VERIFICATION-COMMANDS·HARNESS-RECOVERY-VALIDATION·repo-health 배선 + invariant [1] Linked DRs 제외. (remediation) 기존 4건(DR-029→DR-011/030, DR-013/014→DR-031) 해소. backlog P1 closure guard + P2 remediation 통합.
appetite: 1d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-033, DR-021, DR-013, DR-014, DR-029]
related_troubleshooting: []
related_work: [CHORE-20260610-003]
---

# CHORE-20260610-005: Shipped DR reference closure guard + 4건 remediation

## Top Summary

- **목표:** shipped 표면(core canonical·shipped DR seed·adapter/rule/prompt)이 scaffold seed 밖 DR을 참조해 target dangling을 만드는 반복 패턴을 **사전 예방 + 기존 4건 해소**. CHORE-20260610-003에서 `HARNESS-PROTOCOL → DR-032`를 뒤늦게 발견한 경험에서 파생.
- **결정 (사용자 승인):** 통합 1 Work(policy→guard→remediation), mode-b = **B-ii(Linked DRs 가드)**.
- **정책 (DR-033):**
  - mode-a (canonical→DR): body는 seed DR만, 비-seed는 self-describe (DR-032 관례화).
  - mode-b (shipped DR seed 파일→DR): 비-seed lineage는 `Linked DRs:` frontmatter에만, body self-describe. check는 `Linked DRs:` 라인 제외.
  - seed SSoT: `create-harness.sh` 기본 adapt 블록(`^adapt .*docs/decisions/DR-`)에서 파생 — 제3 사본 금지.

## Scope / Plan (실행 순서 = checkpoint)

1. **DR-033** 신규(Accepted) + decisions/README.
2. **(A) 작성 rule**: `.claude/rules/docs-workflow.md` + `HARNESS-PROTOCOL.md` cascade trigger.
3. **(B) static check**: 신규 `scripts/tests/check-shipped-dr-closure.sh`(seed 파생, shipped docs core set, DR-NNN grep `Linked DRs:` 제외 → 위반 flag). 배선: `docs/maintainer/VERIFICATION-COMMANDS.md`(Layer+Release Full Sweep), `docs/HARNESS-RECOVERY-VALIDATION.md`(정책 pointer), `skills/workflow/repo-health.md`(cascade). `scripts/tests/check-scaffold-invariants.sh [1]` Linked DRs 제외 갱신.
4. **(remediation) 4건**:
   - DR-029: 본문 DR-030 self-describe + `Linked DRs`에 DR-030 추가(DR-011 기존).
   - DR-013: `Linked DRs: DR-031` 추가 + 본문 표 셀 self-describe.
   - DR-014: `Linked DRs: DR-031` 추가 + 본문 표 셀 self-describe.

## 4건 dangling 위치 (확인 완료)

| DR | 참조 | 위치 |
| --- | --- | --- |
| DR-029 | DR-011 | frontmatter `Linked DRs:` (line 6) — test 제외로 해소 |
| DR-029 | DR-030 | body (line 42, 예시) — self-describe + Linked DRs |
| DR-013 | DR-031 | body 표 셀 (line 135) — Linked DRs + self-describe |
| DR-014 | DR-031 | body 표 셀 (line 53) — Linked DRs + self-describe |

## Done Criteria

- [x] DR-033 신규 + decisions/README closure
- [x] 작성 rule(docs-workflow + HARNESS-PROTOCOL cascade) 명문화
- [x] `check-shipped-dr-closure.sh` 신규, seed=create-harness.sh 파생, Linked DRs 제외, `bash -n` OK, 위반 0
- [x] VERIFICATION-COMMANDS Layer I + Release Full Sweep(row 4 포함), HARNESS-RECOVERY-VALIDATION Validation Checklist pointer, repo-health Phase 5 cascade 배선
- [x] invariant `[1]` Linked DRs 제외 갱신
- [x] 4건 remediation 후 `check-scaffold-invariants.sh` **OVERALL PASS** (처음으로 전 모드 green) + static check 위반 0

## Verification 결과

- `check-shipped-dr-closure.sh`: 위반 0 (작업 중 3 body 위반 검출 → remediation 후 0).
- `check-scaffold-invariants.sh`: OVERALL PASS — `[1]` 포함 5종 전부 green (pre-existing 4 dangler 해소: 3건 Linked DRs 이동 + DR-029→DR-011은 Linked DRs 제외로).
- `bash -n` 두 스크립트 OK, `git diff --check` clean.

## Verification

- `bash -n` 두 스크립트, 의도적 dangling 주입 → check 탐지 시뮬레이션
- scaffold 생성(temp/) 후 `check-scaffold-invariants.sh` 전체 PASS
- `check-shipped-dr-closure.sh` 위반 0, `git diff --check`

## Risk / Reversal

- 리스크: invariant/static 두 check seed·제외 규칙 불일치 → false pass/fail. 동일 파생·동일 제외로 일치.
- 되돌리기: Medium. DR-033 + 스크립트 + rule revert. branch 단위.

## Discovery

- backlog P1(closure guard) + P2(4건 remediation) candidate 통합 착수. 사용자 결정: 통합 1 Work, B-ii.

## Checkpoints

- (착수) 2026-06-10 branch + Work 파일.
- 2026-06-10 실행 — DR-033 → 작성 rule(docs-workflow + HARNESS-PROTOCOL) → static check 스크립트 + invariant Linked DRs 제외 + VERIFICATION-COMMANDS/HARNESS-RECOVERY-VALIDATION/repo-health 배선 → 4건 remediation(DR-013/014 Linked DRs+self-describe, DR-029 Linked DRs 확장+self-describe).
- **self-catch (정책 자기적용):** rule 작성 중 shipped HARNESS-PROTOCOL·docs-workflow에 `DR-033`을 인용 → 그 자체가 mode-a 위반. self-describe로 정정. static check가 이 패턴을 잡도록 설계됨을 실증. 모든 shipped 배선은 DR 번호 없이 self-describe + source-only N/A 표기.
- 2026-06-10 검증 — closure check 위반 0, invariant OVERALL PASS(첫 전모드 green).

## Next Actions

- DR-033 → rule → check+invariant → remediation → verification → `/work-close`.
