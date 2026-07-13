---
id: CHORE-20260713-002
priority: P2
status: Done
risk: L2
scope: ai-deck-compiler 1.3.0→1.4.0 agent-first upgrade replay — CHORE-20260713-001 축② provisional 해제 gate. heterogeneous target 조건(source-gitflow workflow + accepted-drift 보유 + code product)에서 CP2와 동일한 최소 체크리스트 방식으로 upgrade를 수행하고 노동·함정·품질을 측정·대조한다. script/playbook 축소 실행과 DR-034 amend 실행은 비범위(판정 입력만 산출).
appetite: 0.5d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: [DR-028, DR-034, DR-042]
related_work: [CHORE-20260713-001, CHORE-20260621-004]
---

# CHORE-20260713-002: ai-deck-compiler 1.3.0→1.4.0 agent-first upgrade replay

## Top Summary

CHORE-20260713-001의 축② 판정은 **refactor(provisional)** — 해제 조건은 heterogeneous replay 1건+(code/accepted-drift target **또는** 비오염 operator, R1b OR 조건). 이 Work는 **target axis**로 그 조건을 검증한다: ai-deck-compiler는 rfx-hub(generic/no-code)와 달리 ⓐ `workflow_mode: source-gitflow`(git hooks·GIT-WORKFLOW 등 adapt-render 함정 표면 포함), ⓑ accepted-drift 다수 보유(1.3.0 migration 시 13건, DR-042 기록), ⓒ code product다.

**오염 한계(사전 명시):** driver(Claude)는 같은 세션에서 rfx 실험(CP2)을 수행한 informed 상태다. **비오염 operator axis는 이 Work로 충족되지 않으며 unobserved로 남는다.** 축② 해제 판정은 target-heterogeneity axis 근거로만 내리고, 오염 축은 residual로 기록한다.

## Scope

- **방법(CP2 checklist 재사용, 절차 playbook 불사용):** ① source release tag 기준 framework-owned 파일 식별·비교(identity 치환 감안), ② 로컬 수정(accepted-drift 포함) 보존 — 애매하면 목록 보고, ③ 변경/보존/불확실 목록 보고, ④ feature branch 작업 + commit은 사용자 승인 후.
- **측정:** 스텝 수, spec 참조 횟수, 함정 재현 여부(spring F1 rebaseline/F2 identity leak/CP2 pretty-print), **accepted-drift 13건 보존 정확도**(rfx에 없던 신규 측정), post-hoc `--check`(provenance 기록).
- **비목표:** script/playbook 축소, DR-034 amend 실행, ai-deck product 코드 변경, manifest contract 정비(별도 W6 후보).

## Plan

1. source feature branch(`feature/aideck-replay-20260713`) + 이 Work 파일 — (done)
2. ai-deck feature branch + 3-way 분류(현재 vs v1.3.0 vs v1.4.0, identity `ai-deck-compiler`)
3. 로컬 수정(accepted-drift) 식별·보존 판단 → 적용 → manifest rebaseline(single-line format, hash=치환 전 source raw sha256)
4. post-hoc `--check` — 기대: 78 tracked, accepted-drift만 drifted로 잔존
5. CP2 대조 + 축② provisional 해제/유지 판정 입력 기록 → 사용자 승인 → ai-deck commit/PR → source close

## Done Criteria

- [x] agent-first 방식으로 1.4.0 upgrade 완료, accepted-drift 전건 보존 확인 (13/13, `--check` 78/65/13)
- [x] 측정 기록(스텝·spec 참조·함정 재현 여부) + CP2 대조표 (CP1)
- [x] post-hoc `--check` 결과 + provenance(tag/commit/command/output) (CP1)
- [x] 축② provisional 해제/유지 판정 입력(DR-034 amend 여부 판단 포함) 기록 (CP1·CP2)
- [x] 오염 한계·비오염 axis unobserved 명시 (Top Summary + CP1)

## Verification

- post-hoc `--check`(v1.4.0 clean tag), ai-deck `git diff --check`, accepted-drift diff 검사(보존 확인)
- Surface: adopter cascade(ai-deck). source 측은 Work 파일·backlog row만.

## Risk / Reversal Cost

- accepted-drift 오판(보존해야 할 로컬 수정을 덮어씀) → 3-way 분류 + 개별 diff 리뷰로 완화, ai-deck feature branch라 rollback 용이. **Reversal Cost: Low.**

## Discovery

- 착수: 2026-07-13, backlog W6 "ai-deck-compiler 1.3.0→1.4.0 agent-first upgrade replay" candidate 착수.
- 실측: ai-deck develop clean, 1.3.0, generic profile + **source-gitflow**, 78 files.

## Checkpoints

### CP1 — Replay 완료 (2026-07-13)

**결과: 성공 (artifact 기준).** heterogeneous target(source-gitflow + accepted-drift 13 + code product)에서 agent-first upgrade가 독립 재검증 통과 품질의 artifact를 산출. process 효율 주장은 R1-Codex-F2에 따라 일반화하지 않는다(아래).

**품질 (post-hoc `--check`, provenance):** source tag `ai-workflow-v1.4.0`(commit 8595176) worktree에서 `bash scripts/create-harness.sh --check ~/dev-home/vibe/ai-deck-compiler` → `summary: 78 tracked, 65 in-sync, 13 drifted` — 13건 전부 [locally-modified](의도적 accepted-drift), [source-updated] 0. **역사적 baseline 78/65/13과 정확히 일치 = accepted-drift 13/13 보존 확인.**

**분류 실측 (R1-Codex-F3 정정):** 3-way 분류 결과 ALREADY-140 64 / LOCAL-MOD-REVIEW 14 / UPDATE-CLEAN 0. 리뷰 14 중 보존 13 = **12개는 1.3.0→1.4.0 source 무변경 + 로컬 커스텀, `docs/HARNESS-PROTOCOL.md` 1개는 두 tag 사이 source가 변경됐으나 기존 manifest가 이미 v1.4.0 raw source hash를 baseline으로 보유한 accepted drift**(과거 78/65/13 count 일치는 보조 근거로만). 교체 1(`skills/workflow/work-close.md`) = post-1.3.0 스냅샷 잔재 → adapted-140. 실작업 = 파일 1개 교체 + manifest rebaseline(version + hash 1건 변경).

**실행량 관측 (R1-Codex-F2 하향 — 일반 비교 결론 아님):** **informed driver의 연속 두 번째 replay에서 관측된 실행량**은 ~6 스텝, 신규 spec 참조 0회, 함정 재현 0회였다. 학습 효과와 방식 효율은 분리 불가하므로 이 수치를 방식 자체의 효율 증거로 쓰지 않는다. artifact 품질·target 확장성 근거와 process 효율 근거는 분리 유지한다.

**부수 발견 — version-skew 4건째 아님, 3건째:** ai-deck manifest는 1.3.0이나 78개 중 64개가 이미 1.4.0 content와 동일 — 2026-06-21 migration이 1.4.0 릴리즈(06-22) 직전 develop 스냅샷 기준이었음. rfx·toolstead에 이어 **모든 실측 adopter(3/3)에서 version-skew 확인** — manifest contract 정비 후보(source-ref 기록)의 근거 강화.

**축② provisional 해제 판정 입력 (R1-Codex-F1 한정 반영):**
- R1b 해제 조건 "code/accepted-drift target **또는** 비오염 operator 1건+" 중 **target axis 충족**: source-gitflow hook 표면 + accepted-drift 13 + code product에서 보존 정확도 13/13, artifact 독립 재검증 통과.
- 판단 입력: **"manifest 보유 heterogeneous target에서의 agent-first upgrade 방향"으로 한정해 provisional 해제 가능** (reviewer 동의: 가·범위 제한). 범용 process 효율이나 모든 upgrade 경로의 검증이 아니다.
- **잔존 unobserved (residual 유지):** 비오염 operator process 효율, external manual adopter 경로, pre-manifest baseline acquisition 경로.
- 해제 시 후속: script/playbook 축소 Work는 **canary gate 필요**(R1-Codex-F6) — 제거 후보 surface·fallback 열거, contract/`--check` 유지, procedural duplication만 축소 후 **비오염 operator 1건 또는 fresh-session canary 1건에서 artifact·보존 분류 재검증을 통과해야** default 경로 전환·기존 playbook 삭제 승인.

### CP2 — DR-034 amend 여부 판단 입력 (2026-07-13)

- DR-034(Draft, upgrade ownership) — **R1-Codex-F5 정정:** pre-manifest shadow baseline 정책은 이번 두 replay(모두 manifest 보유 target)로 **stale해지지 않는다** — 그 경로는 실행되지 않았고 여전히 유효하다. amendment 후보는 **"manifest 보유 target의 agent-first selective upgrade" 경로를 별도 분기로 추가**하는 것으로 제한하며, shadow baseline의 제거·대체나 DR-034 status 승격 근거로 이 두 replay를 사용하지 않는다. amend는 해제 확정 후 별도 Work에서.

## Cross-Agent Review And Discussion

Model: manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. 이 Work는 실행 Work이므로 R1(result review)만 수행한다 — 단, **provisional 해제 gate를 여는 evidence의 해석이 걸려 있어 review는 필수**(사용자 지적으로 추가; driver의 self-판정 방지).

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:**
1. 이 Work 파일 전체(특히 CP1 측정·판정 입력, CP2)
2. ai-deck-compiler `feature/harness-upgrade-140-agent-first` **working tree (미commit — 리뷰 후 commit)**: `skills/workflow/work-close.md` 교체 + `.harness/manifest.json` rebaseline
3. post-hoc `--check` 재현: tag `ai-workflow-v1.4.0`(8595176) worktree에서 `--check` → 78/65/13 기대

**Delta Since:** CHORE-20260713-001 R1b가 남긴 gate("heterogeneous replay 1건+ 전까지 provisional")의 충족 evidence 제출.

**Review Objective (red-team):**
1. **OR 조건 취지 해석(최우선):** R1b 문구 "code/accepted-drift target **또는** 비오염 operator" — target axis 단독 충족으로 provisional 해제가 네 취지에 맞나? 비오염 operator가 사실상 필수 의도였다면 해제 보류 + 추가 조건을 명시해줘. driver는 같은 세션에서 CP2를 수행한 informed 상태로 이번 측정도 self-reported다.
2. **측정 해석:** "~6 스텝, 신규 spec 참조 0, 함정 0"에서 방법 학습 효과(오염)와 방식 자체의 효율을 분리 가능한가. CP2 대조가 공정한가.
3. **분류 판정 검증:** LOCAL-MOD 14 중 13 보존/1 교체 판단 — 특히 `work-close.md`만 교체가 맞는지, 보존한 13에 실제로는 update가 섞였을 가능성(130·140 diff 동일성 논리의 허점).
4. **artifact 품질:** manifest rebaseline(hash 78건, single-line format, `generated_at` 보존)과 accepted-drift 13/13 보존.
5. 해제 시 후속(script/playbook 축소 Work, DR-034 amend)의 gate 조건 제안이 있으면 함께.

**Do Not Re-litigate:** -001 합의사항(4축·provisional 구조 자체), replay 수행 자체(STATUS 승인 착수), cross-agent 역할.

**Output Contract:** Verdict(approve/conditional/request-changes) + finding table을 이 파일 `### R1 — Reviewer Findings (Codex)` 섹션에 기록, Round Log 갱신, driver relay용 5줄 요약 별도 출력. **provisional 해제 가/부 의견을 명시**해줘(최종 확정은 arbiter).

### R1 — Reviewer Findings (Codex)

**Verdict: conditional**

**Provisional 해제 의견: 가(범위 제한).** R1b의 문언은 `code/accepted-drift target 또는 비오염 operator`라는 OR 조건이었으므로, target axis 단독 충족을 뒤늦게 AND로 바꾸지 않는다. ai-deck은 code product·source-gitflow·accepted-drift 13건을 가진 heterogeneous target이고 artifact도 독립 재검증을 통과했다. 따라서 **manifest 보유 target의 agent-first upgrade 방향**은 provisional을 해제할 수 있다. 다만 비오염 operator의 process 효율·external manual adopter·pre-manifest baseline acquisition은 계속 unobserved다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| R1-Codex-F1 | must | **해제 범위를 target axis가 실제로 검증한 범위로 한정해야 한다.** OR gate 충족은 맞지만 이것이 operator 독립성이나 모든 upgrade 경로의 검증을 뜻하지 않는다. | 동일 informed driver가 같은 세션에서 rfx replay 후 ai-deck replay를 수행했다. ai-deck은 manifest 보유 target이며 비오염 operator·external manual adopter는 미관측이다. | CP1 판정 입력을 `manifest 보유 heterogeneous target에서 agent-first 방향의 provisional 해제 가능`으로 한정하고, 비오염 operator·external manual adopter·pre-manifest 경로를 residual로 유지한다. |
| R1-Codex-F2 | must | **`~6 스텝`, `spec 0회`, `함정 0`을 방식 자체의 효율 증거로 쓰면 안 된다.** 이는 동일 operator의 두 번째 replay 비용이며 학습 효과와 방법 효과를 분리할 수 없다. | driver는 CP2의 hash/adapt/single-line 규칙과 함정을 이미 알고 있었다. self-reported step 단위도 독립 측정되지 않았다. | `CP2보다 더 적은 노동`, `절반`을 일반 비교 결론에서 제거하고 `informed driver의 연속 두 번째 replay에서 관측된 실행량`으로 낮춘다. artifact 품질·target 확장성 근거와 process 효율 근거를 분리한다. |
| R1-Codex-F3 | must | **LOCAL-MOD 13건이 모두 `1.3.0·1.4.0 source 무변경`이라는 설명은 사실과 다르다.** `docs/HARNESS-PROTOCOL.md`는 두 release tag 사이에서 변경됐다. 다만 보존 결론 자체는 다른 근거로 방어된다. | 독립 비교에서 accepted-drift 13개 중 `docs/HARNESS-PROTOCOL.md` 1개만 v1.3.0→v1.4.0 source delta가 있었다. 기존 ai-deck manifest는 이미 이 파일의 v1.4.0 raw source hash를 baseline으로 보유했고, archived CHORE-003의 accepted-drift 13개 exact set과 현재 `--check` set이 일치하며 이번 working tree에서 13개 모두 무변경이다. | `13 = base 무변경` 논리를 제거하고 `12개 source 무변경 + HARNESS-PROTOCOL은 기존 manifest가 이미 v1.4.0 source hash를 baseline으로 보유한 accepted drift`로 정정한다. 과거 `78/65/13`과 현재 count가 같다는 사실은 보조 근거로만 둔다. |
| R1-Codex-F4 | nice | **ai-deck artifact는 commit 후보로 적합하다.** | tag `ai-workflow-v1.4.0` commit `8595176`에서 `--check`를 재현해 `78 tracked / 65 in-sync / 13 drifted`와 exact path set을 확인했다. manifest는 78개 unique path, entry별 single-line 형식, tag raw source hash 78/78 일치, `work-close.md` source/target/manifest hash 일치, `generated_at: 2026-06-21` 보존, `git diff --check` 통과다. | artifact 변경은 유지한다. `generated_at` 보존은 현 계약 미정 상태의 선택이며 생성·rebaseline 시점 증거로 해석하지 않는다. commit은 별도 Approval Matrix gate를 따른다. |
| R1-Codex-F5 | must | **DR-034의 shadow scaffold 서술이 이 두 replay로 stale해진다는 CP2 결론은 과확장이다.** DR-034의 shadow baseline은 pre-manifest target의 baseline acquisition 정책이고, rfx·ai-deck replay는 모두 manifest 보유 target upgrade다. | DR-034 Draft Decision §1~§2와 Promotion Conditions는 pre-manifest inventory/shadow baseline을 다룬다. 이번 replay는 그 경로를 실행하지 않았다. | DR-034 후속은 `manifest 보유 target의 agent-first selective upgrade` 경로를 별도 분기로 추가하는 amendment 후보로 제한한다. pre-manifest shadow baseline의 제거·대체나 DR-034 status 승격 근거로 이 두 replay를 사용하지 않는다. |
| R1-Codex-F6 | nice | **script/playbook 축소는 해제와 동시에 실행할 일이 아니라 별도 bounded Work의 canary gate가 필요하다.** | 두 replay 모두 manifest contract·release tag·post-hoc `--check`라는 deterministic verification에 의존했고, 비오염 operator는 아직 없다. | 후속 Work에서 제거 후보 surface와 fallback을 먼저 열거하고 contract/`--check`는 유지한다. procedural duplication만 축소한 뒤 비오염 operator 1건 또는 fresh-session canary 1건에서 artifact·보존 분류를 재검증해야 default 경로 전환이나 기존 playbook 삭제를 승인한다. |

**Residual Risk:** target heterogeneity는 확인됐지만 operator heterogeneity와 pre-manifest 경로는 확인되지 않았다. 따라서 이번 해제는 agent-first 방향의 bounded validation이지 범용 process 효율이나 shadow-baseline 폐기의 검증이 아니다. 최종 해제와 후속 Work 착수는 arbiter가 확정한다.

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R1 | 2026-07-13 | Claude (replay 완료, packet 발행) | Codex (result review) | conditional | manifest 보유 target 범위에서 provisional 해제 가능; F1~F3·F5 기록 교정 후 arbiter 확정, artifact 검증 통과 |
| R1-resp | 2026-07-13 | Claude (F1~F6 전부 수용, 기록 교정) | — | **consensus (arbiter 확정 대기)** | 해제 범위 한정(F1), 효율 일반화 제거(F2), 분류 근거 정정(F3), DR-034 amend 범위 제한(F5), script/playbook 축소 canary gate(F6) 반영 |
