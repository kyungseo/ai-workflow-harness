---
id: CHORE-20260610-011
priority: P2
status: Archived
risk: L2
scope: reorg(CHORE-20260610-010)가 ad-hoc 도입한 backlog Seq 구조의 거버넌스 결정 + 정렬. (B) 채택 — Seq 열·Sequencing Guide·항목 주석 완전 제거, 의존성 SSoT는 Dependencies 필드, 시퀀싱 뷰는 STATUS Next Actions.
appetite: 0.25d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-031]
related_troubleshooting: []
related_work: [CHORE-20260610-010]
---

# CHORE-20260610-011: 백로그 Seq/Sequencing 포맷 거버넌스 정렬

## Top Summary

- **배경:** reorg(CHORE-20260610-010)가 `docs/backlog/HARNESS.md`에 `Seq` 열 · `Sequencing Guide` 섹션 · 항목별 `> Seq …` 주석을 governing spec 없이 ad-hoc 도입. scaffold 템플릿(5열)·`work-register`/`work-close` Backlog Entry Format(5열)·PRODUCT/HARNESS 대칭(DR-031)과 divergent.
- **결정 (B) 채택:** Seq는 `Dependencies`에서 파생되는 derived data이므로 테이블 열로 유지하지 않는다.
  - 근거: ① derived data를 손유지 열로 복제 = DRY 위반 + drift ② 시퀀싱 뷰는 STATUS Next Actions가 이미 담당(중복) ③ churn↑·cascade·drift 비용이 at-a-glance 이점 상회 ④ 비대칭 reversal cost(B→A 승격은 쌈, A→B 환원은 비쌈).
- **(A) 기각 사유:** scaffold·work-register·work-close·PRODUCT 대칭·DR까지 adopter-facing cascade. solo + 빠른 churn 환경에서 유지 부채 과다.

## 변경 내용 (실행 완료)

- `docs/backlog/HARNESS.md`:
  - Summary `Seq` 열 제거 → 5열(`ID|Priority|Status|Risk|Title`) 복원. scaffold 템플릿·work-register 포맷과 정합.
  - `## Sequencing Guide` 섹션 완전 제거.
  - 항목별 `> Seq …` 주석 22줄 완전 제거 (등록일 `> 2026-… 등록` 주석은 보존).
  - `> Details 정렬: …Seq(wave) 순서…` 라인 제거.
  - 본 거버넌스 항목(자체) row + `####` 블록 제거(work-close).
- `docs/STATUS.md`: Next Actions의 "Seq 순서" 포인터를 "`Dependencies` 기준 + enabler 우선 권장 순서"로 교체. Recent Decisions에 (B) 결정 기록.

## 무손실 / cascade 검증

- Seq 주석의 ordering rationale는 고유 SSoT가 아니다 — 의존성은 각 항목 `Dependencies` 필드에, 착수 우선순위는 STATUS Next Actions에 보존됨(예: enabler `검증 테스트 체계` 1순위).
- scaffold 템플릿/work-register 포맷은 원래 5열 → 열 제거로 즉시 정합(템플릿 변경 불요).
- PRODUCT.md는 source 미존재, scaffold가 5열 대칭 생성 → 대칭 복원.

## Done Criteria

- [x] (A)/(B) 결정 기록 (본 Work + STATUS Recent Decisions)
- [x] HARNESS.md Seq 열·Guide·주석·Details 정렬 라인 제거, 5열 복원
- [x] HARNESS.md ↔ scaffold 템플릿 ↔ work-register Backlog Entry Format 포맷 정합 (모두 5열)
- [x] 무손실 (detail·Dependencies 보존), 이중 공백 0
- [x] `git diff --check` clean, shipped DR closure green

## Verification

- `grep '^> Seq ' docs/backlog/HARNESS.md` → 0
- `grep '| Seq |' docs/backlog/HARNESS.md` → 0 (Summary 헤더 5열)
- scaffold 템플릿(`create-harness.sh` L1133·1171) 5열과 source Summary 5열 일치
- live 문서 Seq 잔존 grep → STATUS 갱신으로 해소

## Risk / Reversal

- Low. 단일 파일(+STATUS) 변경, branch 단위 revert. 필요 시 Seq 재도입은 별도 결정(비대칭상 저비용).

## Checkpoints

- (착수·완료) 2026-06-10 — branch `feature/chore-20260610-011-seq-format-governance`. 소규모 결정 작업이라 동일 세션에서 착수→실행→완료. backlog candidate "백로그 Seq/Sequencing 포맷 거버넌스 정렬" 착수 후 (B) 적용으로 해소.

## Discovery

- backlog의 "백로그 Seq/Sequencing 포맷 거버넌스 정렬" candidate 착수. (B) 결정으로 항목 해소 → backlog row 제거(동일 commit).
