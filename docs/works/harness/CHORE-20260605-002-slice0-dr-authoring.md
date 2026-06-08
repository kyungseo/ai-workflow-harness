---
id: CHORE-20260605-002
priority: P1
status: Done
risk: High
scope: Slice 0가 합의한 4축 방향을 정식 DR(DR-021~024)로 작성하고 Codex 검토·사용자 승인 후 Accepted 처리한다. 실제 breaking 적용은 후속 slice
appetite: 1d
planned_start: 2026-06-05
planned_end: 2026-06-06
actual_end: 2026-06-05
related_dr: [DR-021, DR-022, DR-023, DR-024]
related_troubleshooting: []
related_work: [CHORE-20260604-001, CHORE-20260605-001]
---

# CHORE-20260605-002: Slice 0 DR Authoring

## Top Summary (결론 먼저)

- **목표:** slice 0(CHORE-20260605-001) Direction Decisions의 4 primary 방향을 정식 DR로 고정.
- **산출 DR:** DR-021(boundary), DR-022(PLAN lifecycle), DR-023(canonical+hybrid adapter), DR-024(gate 2D taxonomy). child(Commit gate runtime enforcement)는 하류 slice에서 별도 DR.
- **비목표:** 실제 적용(scaffold minimal output, canonical 추출, command rename, hook/CI 구현). DR은 방향·근거·reversal만 고정.
- **프로세스:** DR Draft 작성 → Codex 검토(faithfulness/완전성) → 사용자 승인 → Status: Accepted + index/cascade.

## Context Manifest (재개 시 읽을 파일·섹션)

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260605-001-phase2-slice0-direction.md` | Direction Decisions CP1~6 | 각 DR의 결정·근거·OQ 매핑 원본 |
| 2 | 〃 | Cross-Agent Review R1~R4 | 합의·보강(adapter 범위, clean baseline) 근거 |
| 3 | `docs/decisions/DECISION-TEMPLATE.md` | 전체 | DR 형식 |
| 4 | `docs/decisions/README.md` | index | Accepted 등록 위치 |

## Plan

slice 0 Work의 CP1~6은 각 DR의 Question/Decision/Rationale/Reversal/닫는 OQ를 이미 산출했다. 이 Work는 그것을 DECISION-TEMPLATE 형식으로 옮기고 cross-agent 검토를 거쳐 Accepted한다. 새 설계는 하지 않는다.

## Done Criteria

- [x] DR-021~024 Draft 작성 (slice 0 CP1~4 방향에 충실)
- [x] Codex가 DR Draft를 검토하고 faithfulness/완전성 합의 (Cross-Agent Review에 기록)
- [x] 사용자 승인 후 DR Status: Accepted, Date 기입
- [x] `docs/decisions/README.md` index에 DR-021~024 Accepted 행 추가
- [x] cascade: STATUS Recent Decisions 반영 필요 여부 판정, DR-022(PLAN 영향)의 PLAN cascade 판정
- [x] **사용자 최종 리뷰** 후 Done

## Verification

- documentation-only: `git diff --check`, DR 링크/번호 충돌 점검(`ls docs/decisions/`).
- 추적성: 각 DR이 slice 0 CP와 1:1, 닫는 OQ가 slice 0 OQ 매핑과 일치.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | DR-021~024 Draft 작성 | Done |
| 2 | Codex 검토 + 합의 (R6) + 보강 반영 | Done |
| 3 | Accepted 처리 + index/cascade | Done |

## Cross-Agent Review And Discussion

slice 0의 R0~R4를 이어, 이 Work는 **DR Draft의 정식화 충실성**을 검토한다. Codex는 각 DR이 slice 0 합의를 왜곡/누락 없이 옮겼는지, reversal/consequence가 정확한지 확인한다.

### Round Log

| Round | 작성자 | 단계 | 요약 |
| --- | --- | --- | --- |
| R5 | Claude | DR Draft | DR-021~024 Draft 작성. Codex faithfulness 검토 대기 |
| R6 | Codex | DR Review | DR-021~024 정식화 충실성 검토. 방향은 조건부 동의, DR-021/023/024에 소규모 문구·라인 인용 보강 요청 |

### Codex DR Review

작성: Codex, 2026-06-05. 검토 범위는 DR Draft가 slice 0 합의(CP1~4, CP5 OQ 매핑, CP6 DR split, R4 보강)를 충실히 옮겼는지까지다. DR Status를 Accepted로 바꾸거나 적용 상세를 추가하지 않는다.

#### Summary

DR-021~024는 **조건부 동의**다. 네 DR 모두 Decision Template의 필수 섹션(Question, Decision, Options Considered, Rationale, Consequences, Reversal Cost, Linked Backlog Items)을 갖추고, slice 0의 4 primary DR + child split을 왜곡하지 않는다. 특히 DR-023은 R4의 adapter 보강을 반영했고, DR-024는 clean baseline을 보조 예시로 낮추며 대표 4범주를 archive/commit/release/bootstrap으로 정리했다.

수정 요청은 결론 변경이 아니라 정식화 품질 보강이다. DR-021은 Decision 안의 reference-integrity 문장을 하류 scope로 더 명확히 낮추고, DR-023/024는 Rationale의 근거 라인 인용을 더 정밀하게 보강하면 Accepted 전 형태로 충분하다.

#### DR별 검토

| DR | 판단 | Faithfulness / 근거 | OQ 매핑 | Reversal Cost | 수정 요청 |
| --- | --- | --- | --- | --- | --- |
| DR-021 Source / Boundary | 조건부 동의 | CP1의 3-class boundary와 physical split 보류를 충실히 옮겼다. `adapt()` sed copy 근거는 정확하고(`scripts/create-harness.sh:137-143`), scaffold가 entrypoint/protocol/maintainer docs/DR seed를 한 평면에 복사한다는 근거도 맞다(`scripts/create-harness.sh:199-226`). prompt bundle 복사 근거도 정확하다(`scripts/create-harness.sh:331-350`). `PLAN.md`의 source core 근거도 맞다(`docs/PLAN.md:90-93`). | OQ-1, OQ-2 닫힘은 CP5와 일치. OQ-4를 닫는다고 주장하지 않아 적절하다. | Medium 타당. direction 자체는 낮지만 default scaffold 변경은 하류 breaking 가능. | Decision의 `docs/decisions/README.md` 동반/참조 조정 문장은 정확한 문제의식이지만 exact file-list처럼 읽힐 수 있다. `Decision`보다는 `Consequences` 또는 `Scope(하류)` 성격으로 "reference integrity는 하류에서 A-class 동반/참조 조정 중 하나로 해결"이라고 낮춰 쓰는 편이 slice 0 boundary와 더 충실하다. |
| DR-022 PLAN lifecycle | 동의 | CP2의 T5 배선 + archive drain + hard gate 미신설을 그대로 옮겼다. T3/T5/T15~T17 라인은 정확하다(`docs/HARNESS-PROTOCOL.md:421-435`). rolling window 근거도 정확하다(`docs/HARNESS-PROTOCOL.md:496`). Roadmap 정지 근거도 맞다(`docs/PLAN.md:112-119`). | OQ-3 닫힘, OQ-7 잔여 유지가 CP5와 일치. | Low 타당. 현재 DR은 trigger/drain 규칙 방향 결정이며 runtime hard-stop이 아니다. | 필수 수정 없음. Accepted 전 가독성 차원에서 `:433-435`, `:421`, `:496`, `:112-119` shorthand를 전체 파일 경로 포함 표기로 풀면 더 좋다. |
| DR-023 Canonical + hybrid adapter | 조건부 동의 | CP3와 R4 보강을 정확히 반영했다. adapter가 Step 0, hard-stop 요약+action 차단 조건, entry mechanism, fallback만 갖고 Approval Matrix 전문·상세 checklist·cascade matrix는 canonical에 둔다는 문장은 R4 조건과 일치한다. 부모 Work의 hybrid adapter 근거와도 맞다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:762-784`). §10-a 순서 제약도 정확하다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:947-960`). | OQ-8, OQ-15 닫힘은 CP5/CP6과 일치. OQ-15는 실제 rename 적용이 아니라 no-alias + 단독 선행 금지 + 하류 breaking slice 원칙만 닫는다. | High 타당. 실제 적용은 command/skill/rule/scaffold output을 함께 바꾸는 breaking 전환. | Rationale에 부모 Work line citation을 직접 추가하길 권장한다. 현재 line count와 `ai-deck-compiler` 비교가 사실상 부모 Work 근거에 의존하므로, `docs/works/...:762-784`를 Rationale에 붙이고, Consequences의 "§10-a 순서 제약"에도 `:947-960`을 붙이면 추적성이 좋아진다. |
| DR-024 Gate strictness taxonomy | 조건부 동의 | CP4와 R4 보강을 잘 옮겼다. 대표 4범주를 archive/commit/release/bootstrap으로 제한하고 clean baseline을 보조 예시로 둔 점은 R4와 일치한다. parent §9의 2D taxonomy와 child enforcement 분리도 맞다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:919-942`). `STATUS.md:41` row도 실제 2026-05-29 decision이다(`docs/STATUS.md:41`). | OQ-12, OQ-13, OQ-16 닫힘이 CP5와 일치. OQ-14를 child DR로 이연한 것도 R3/R4 합의와 일치. | Low 타당. vocabulary와 대표 분류는 문서 결정이고, runtime enforcement는 child DR에서 재평가. | Rationale의 `start.md` 근거를 실제 파일/라인으로 바꿔라: `.claude/commands/start.md:11-13`이 archive 대기 Work를 clean idle 조건에 포함하는 부분이다. 또 child 분리 문장은 현재 적절하므로 DR-024에 exception table/override UX를 더 쓰지 않는다. |

#### Cross-DR Checks

- **Template 충실성:** 4개 DR 모두 `docs/decisions/DECISION-TEMPLATE.md:7-36`의 필수 섹션을 갖췄다.
- **R4 보강 반영:** DR-023은 adapter 최소 보유 범위를 R4 조건대로 정리했다. DR-024도 clean baseline을 보조 예시로 낮췄다.
- **OQ 매핑:** DR-021=OQ-1·2, DR-022=OQ-3(+OQ-7 잔여), DR-023=OQ-8·15, DR-024=OQ-12·13·16, child=OQ-14로 CP5/CP6과 일치한다.
- **Child 분리:** `Commit gate runtime enforcement`를 DR-024의 하류 child DR로 분리한 처리는 R3/R4 합의와 맞다. DR-024는 causal finalization bundling을 representative category로만 고정하고, exception table/override UX/hook 구현은 하류로 둔다.
- **Status:** 4개 DR 모두 Draft 상태로 남아 있어 사용자 승인 전 Accepted 금지 조건을 지킨다.

### Consensus Log

| Date | Topic | Consensus | Remaining Risk |
| --- | --- | --- | --- |
| 2026-06-05 | R6 DR faithfulness | Codex는 DR-021~024가 slice 0 합의를 대체로 충실히 정식화했다고 판단. DR-023 R4 adapter 보강과 DR-024 clean baseline/child split도 반영됨. | Accepted 전 DR-021 reference-integrity 문장 위치, DR-023 parent Work line citation, DR-024 `.claude/commands/start.md` line citation 보강 필요 |

## Discovery

- R6 보강 반영(2026-06-05): DR-021 reference-integrity 문장을 Decision→Consequences(하류 scope)로 이동, DR-023 Rationale/Consequences에 부모 Work `:762-784`·`:947-960` 인용 추가, DR-024 근거를 `.claude/commands/start.md:11-13`으로 정정. DR-022는 수정 불필요.
- 다음: 사용자 승인 시 4 DR Status Draft→Accepted, README index 등록, cascade(STATUS Recent Decisions + DR-022 PLAN 영향) 처리.
