---
id: CHORE-20260610-010
priority: P1
status: Active
risk: L2
scope: HARNESS backlog 전체를 의존성 기반으로 reorg(시퀀싱)한다. 원 내용(항목+detail) 무손실, 기존 work/문서의 참조 링크 업데이트, detail 가독성(ul) 포함. 이번 세션에서 6개 workflow 정비 테마를 병합/링크 등록(준비 단계) 완료. 본 reorg(시퀀싱·재배열·참조 정합·재포맷)는 fresh session + plan mode에서 수행.
appetite: 1d
planned_start: 2026-06-10
planned_end:
related_dr: [DR-021, DR-023]
related_troubleshooting: []
related_work: [CHORE-20260610-009]
---

# CHORE-20260610-010: Backlog 정리 — 의존성 reorg + 시퀀싱

## Top Summary

- **목표:** HARNESS backlog가 연관·복잡해 선/후 결정이 어려운 상태. 전체를 펼쳐 의존성을 파악하고 체계적으로 재배열(시퀀싱)한다.
- **불변 제약 (사용자 명시):**
  - 원래 백로그 내용(항목뿐 아니라 **detail**)이 누락되면 안 된다.
  - 기존 work 등에서 참조하는 링크가 있으면 **업데이트 포함**.
  - detail 가독성을 위해 **ul 적극 사용**(한 라인에 쭉 연결 금지).
- **이번 세션 완료(준비 단계):** 미등록 workflow 정비 6개 테마를 기존 중복 항목과 **병합/링크**해 등록함(아래 "이번 세션 산출물"). 본 reorg 실행은 다음 세션.

## 배경 / 분석 (다음 세션 컨텍스트)

- backlog `docs/backlog/HARNESS.md` 현재 **#### 항목 21개**(2-tier: Summary 표 + Details 블록) + Deferred Ideas.
- 사용자 요청의 핵심: "전체를 펼쳐놓고 선/후 관계를 파악하여 체계적으로 정리." 단순 재배열이 아니라 **중복 병합 + 새 테마 흡수 + 의존성 시퀀싱**.
- **의존성 척추 가설 (검증 필요):**
  ```
  0. (본 Work) backlog reorg/시퀀싱
  1. ★ harness 검증 테스트 체계 정립   ← 다른 리팩토링의 ENABLER (선순위 후보)
       ├─ 2. Canonical 개념 계층화 restructure (trigger family ⊂ 여기, canonical-weight 클러스터 흡수)
       └─ 3. 문서-only 규칙 강제화 (구조 확정 후)
  ```
  근거: "변경마다 검증이 들쭉날쭉·놓침 많음"은 모든 리팩토링에서 겪는 고통 → test 체계를 먼저 깔면 restructure·강제화가 test-backed로 안전.

## 이번 세션 산출물 (준비 단계 — commit됨)

backlog에 등록·병합한 항목 (content 무손실, additive):

- **신규 P1**: `harness workflow 검증 테스트 체계 정립`, `Canonical 개념 계층화 + context-routing restructure`, `문서-only 규칙 강제화 (CI/hook/hard-gate)`
- **병합**: "Trigger 정비" → 기존 `Harness protocol trigger family simplification`에 흡수(restructure와 시퀀싱 함께 결정)
- 각 항목에 기존 중복 항목 링크 + detail ul 포맷
- "백로그 의존성 reorg" 후보 row는 **본 Active Work로 승격**되며 backlog candidate에서 제거됨

## Scope / Plan (다음 세션 실행)

1. **전체 펼치기** → 21개 + Deferred를 의존성 그래프로 매핑 (선/후, 흡수/병합 후보). 검증: 각 항목의 Dependencies/연계 표기 교차 확인.
2. **중복 병합 확정** → restructure가 흡수하는 항목(trigger, repo-health slice, work-doc class, optional pack 재정의 일부) 경계 결정. 검증: 병합 후 누락 detail 0.
3. **시퀀싱** → 의존성 위상정렬로 P0~P3 + 착수 순서 재배치. 검증: 순환 의존 없음, enabler(test 체계) 선순위.
4. **참조 링크 업데이트** → backlog 항목을 가리키는 work/docs 참조 정합. 검증: `grep -rn "backlog/HARNESS"` 정합.
5. **재포맷** → detail ul 일괄 적용(한 줄 연결 제거). 검증: detail 블록 가독성.
6. **무손실 검증** → 재정렬 전후 항목·detail diff.

## Done Criteria

- [ ] 21개+신규 테마가 의존성 기반으로 시퀀싱됨(순환 없음, enabler 선순위)
- [ ] 중복 항목 병합/링크 확정, 누락 detail 0 (재정렬 전후 무손실 diff)
- [ ] backlog를 참조하는 work/docs 링크 정합 (`grep` 확인)
- [ ] detail ul 포맷 일괄 적용
- [ ] `git diff --check` clean, shipped DR closure green

## Verification

- 재정렬 전후 `git diff`로 항목·detail 무손실 대조
- `grep -rn "backlog/HARNESS" docs/` 참조 정합
- detail 가독성(ul) 점검, summary↔details 매칭

## Risk / Reversal

- 리스크: content 무손실이 최우선 — 재배열 중 detail 누락 위험. 완화: 재정렬 전 항목 인벤토리 캡처 + 전후 diff 대조.
- 되돌리기: Low~Medium. 단일 파일(+참조) 변경, branch 단위 revert. git 이력이 안전망.

## Checkpoints

- (착수) 2026-06-10 — branch `feature/chore-20260610-010-backlog-theme-registration`. 6개 테마 병합/링크 등록(준비 단계) 완료. 본 Work는 Active 유지, reorg 실행은 다음 세션.

## Resume Hint (다음 세션)

- `/work-resume` 또는 `/session-start` 후 본 Work 선택.
- 시작점: 위 "Scaffold / Plan" 1단계(전체 펼치기). 의존성 척추 가설을 먼저 검증.
- **fresh session 권장 이유**: content 무손실 + 참조 업데이트 + 깊은 의존성 분석 → 최대 헤드룸 필요.

## Next Actions

- (다음 세션) 전체 펼치기 → 병합 확정 → 시퀀싱 → 참조 업데이트 → ul 재포맷 → 무손실 검증 → `/work-close`.
