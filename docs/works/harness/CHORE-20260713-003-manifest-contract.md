---
id: CHORE-20260713-003
priority: P2
status: Done
risk: L2
scope: Manifest contract 정비(R0 반영) — ① --check parser python3 단일화(부재 시 actionable exit 2 fail closed), ② structured provenance(source_ref+source_commit+source_dirty, ref 판정 4분류 — same-version skew만 WARN), ③ hash_mode 신규 canonical 값+legacy alias·generated_at=rebaseline 날짜 계약, ④ table-driven fixture behavior matrix. per-file hash=authoritative/source ref=보조 우선순위 명시. entry-format 계약화 제외(-001 R1b), playbook diet 비범위.
appetite: 0.5d
planned_start: 2026-07-13
planned_end: 2026-07-14
actual_end: 2026-07-13
related_dr: [DR-028, DR-034]
related_work: [CHORE-20260713-001, CHORE-20260713-002]
---

# CHORE-20260713-003: Manifest contract 정비 — tolerant parser·source-ref·필드 계약

## Top Summary

근거(전부 observed): ⓐ CP2에서 pretty-print manifest가 `--check` parser를 전면 파손(72개 오판) — single-line은 계약이 아니라 parser 구현 제약(R1b 확정), ⓑ **version-skew 3/3**(rfx·toolstead·ai-deck 모두 manifest version과 실제 baseline이 어긋난 develop 스냅샷) — manifest가 scaffold 시점 source ref를 기록하지 않아 사후 식별 불가, ⓒ `generated_at` 의미 미정(rebaseline 시 갱신 여부), ⓓ `hash_mode: normalized_source_template` 명칭과 실제 구현(raw bytes sha256)의 불일치.

## Scope

> R0(request-changes) 반영본. 원안과의 delta는 R0 Driver Response 참조.

1. **Parser 단일화 (① — R0-F1):** `--check`의 manifest parsing을 **python3 `json.load` 단일 경로로 고정**. grep fallback 제거 — python3 부재 시 drift 결과를 만들지 않고 **actionable message + exit 2로 fail closed**(같은 manifest가 환경 따라 다르게 판정되는 계약 분기 방지). pretty-print/컴팩트/key-reorder 모두 정상 판정. python3 의존은 `--check`에 한정(scaffold 생성 경로는 비의존 유지). README의 python3 전제와 정합.
2. **Structured provenance (② — R0-F2/F3):** scaffold 시 manifest에 `source_ref`(human label — harness tag pattern 필터의 clean exact tag 우선) + **`source_commit`(full sha) + `source_dirty`(bool)** 기록. git metadata 부재 시 `unknown` 계약. scaffold 시 dirty/non-release source면 WARN. `--check` ref 판정 4분류: ⑴ 필드 없음 = `unknown (legacy)` info, ⑵ version delta + commit delta = expected upgrade source delta 표시, ⑶ **same version + commit delta = version-skew WARN**, ⑷ recorded/current dirty 또는 current non-release checkout = DR-028 WARN. **우선순위 계약 명시(R0 residual): per-file hash가 drift 판정의 authoritative evidence, source ref는 provenance/WARN 보조 신호.**
3. **필드 계약 (③ — R0-F4/F5):** `hash_mode` 신규 canonical 값 **`source_template_raw`**(실제 transform 반영) + legacy `normalized_source_template`는 **명시적 alias**로만 허용, 그 외 값은 invalid manifest(exit 2). invariant·fixture 양쪽 값 검증. `generated_at` = **현재 manifest baseline이 생성/rebaseline된 날짜**(재생성 시 갱신 — whole-manifest rebaseline 경로와 정합). `scaffolded_at` 같은 신규 history field는 추측 생성하지 않음. 문서: script 주석 + playbook의 rebaseline field 의미 갱신(F7 경계: field 읽기·갱신 의미만, Phase 삭제·default 전환 없음).
4. **Fixture behavior matrix (④ — R0-F6):** static 3종이 아니라 **table-driven matrix**: canonical new / pretty-print+key reorder / legacy(no ref + legacy hash mode) / malformed·필드 누락·wrong-type·empty entries·unknown hash mode → exit 2 / python3 부재 → actionable exit 2 / source state 4분류(⑴~⑷) 출력 고정. runner 편입.

**비목표:** entry-format 계약화(R1b 제외), playbook 절차 축소·agent-first default 전환·helper 추가(별도 diet 후보 — 이 Work는 새 contract를 소비할 dependency만 남김), 기존 adopter manifest 소급 수정, `scaffolded_at` 신설.

## Plan

1. (done) feature branch `feature/manifest-contract-20260713`, Work 파일
2. **R0 plan review** (cross-agent relay, Codex) — scope는 -001 R1b로 확정됐으나 **설계 결정(dual-path parser·source_ref 형태·hash_mode 처리·fixture 충분성)은 미리뷰** 상태이므로 착수 전 red-team (driver의 초기 생략 판단을 사용자가 교정)
3. 합의 반영 후 EXECUTE: parser(①) → source_ref(②) → 문서(③) → fixture(④)
4. VALIDATE: `bash -n`, scaffold dry-run + temp 실제 생성, `--check` **behavior matrix**(check-manifest-contract.sh), `run-harness-checks` tier0/tier2, 실 adopter(toolstead) read-only `--check` 하위호환 확인 (R0b non-blocking 문구 현행화)
5. **R1 result review** (cross-agent relay, Codex)
6. 사용자 최종 승인 → close → commit → PR(--base develop)

## Done Criteria

- [x] pretty-print/key-reorder manifest가 `--check`에서 정상 판정되고, python3 부재 시 actionable exit 2로 fail closed(오판 0) — matrix `pretty`/`canonical(no-python)` case
- [x] 신규 scaffold manifest에 `source_ref`+`source_commit`+`source_dirty` 기록, scaffold 시 dirty/non-release WARN — temp 실제 생성 + dry-run으로 확인
- [x] `--check` ref 판정 4분류(legacy info / expected delta / same-version skew WARN / dirty WARN)가 출력 fixture로 고정 — matrix `legacy`/`upgrade-delta`/`skew`/`recorded-dirty` case
- [x] `hash_mode` 신규 값 `source_template_raw` + legacy alias 허용 + unknown 값 exit 2, invariant 양쪽 검증 — matrix `bad-hash-mode` + invariants [5] 갱신(provenance 필드는 신규 manifest에서만 필수 — legacy tier1 하위호환)
- [x] `generated_at` = baseline 생성/rebaseline 날짜로 정의·문서화(playbook field 의미 갱신 포함)
- [x] per-file hash = authoritative / source ref = 보조 신호 우선순위가 contract 문서(script 주석 + playbook)에 명시
- [x] fixture behavior matrix(table-driven, 최종 **20 case** — R1/R1b 반영 후 inv-delegation 포함)가 runner tier2에 편입되어 통과, toolstead(legacy) `--check` 하위호환 확인(83/83 + "unknown (legacy)" 안내)
- [x] cross-agent consensus — R0(request-changes)→R0b(approve)→R1(request-changes)→R1b(request-changes)→R1c(**approve, commit 후보 consensus**)
- [x] 사용자 최종 리뷰 (2026-07-13 승인)

## Verification

- `bash -n scripts/create-harness.sh`, generic dry-run + temp 실제 생성, `--check` behavior matrix(`scripts/tests/check-manifest-contract.sh` — 최종 20 case) + toolstead read-only 하위호환, `bash scripts/tests/run-harness-checks.sh --tier0/--tier2`, `git diff --check`
- Surface: scaffold · tool surface(--check) · canonical(maintainer docs)

## Risk / Reversal Cost

- parser 교체 회귀(기존 single-line manifest 오판) → behavior matrix fixture + 실 adopter read-only 확인으로 완화. **python3 부재 환경에서 `--check` 사용 불가가 명시적 동작이 됨**(fail closed — 조용한 오판보다 안전, README가 이미 python3 전제). 신규 hash_mode 값은 구버전 script의 `--check`와 cross-version 하위호환 fixture로 확인. **Reversal Cost: Low~Medium**(script 단일 파일 revert 가능, 신규 필드는 additive).

## Discovery

- 착수: 2026-07-13, backlog W6 "Manifest contract 정비" candidate 착수.
- **Release-prep handoff (R0b non-blocking):** 다음 minor release note에 포함할 것 — ⓐ `--check`가 python3 필수(fail closed)로 전환, ⓑ manifest 신규 필드(`source_ref`/`source_commit`/`source_dirty`)와 `hash_mode` canonical 값 `source_template_raw`(legacy alias 계속 허용 — 기존 adopter 조치 불요), ⓒ version-skew WARN 신설. cross-version 주의: 구버전 script의 `--check`는 신규 필드를 무시하고 legacy hash_mode literal invariant를 볼 수 있음 → 신규 manifest를 구버전 script로 검사하지 말 것.

## Cross-Agent Review And Discussion

Model: manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. Rounds: R0(plan) + R1(result).

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 이 Work 파일 전체 — 특히 Scope ①~④의 설계 결정.

**Current State:** branch `feature/manifest-contract-20260713`, Work 등록만(EXECUTE 미착수). 입력 evidence: CP2 pretty-print 함정(-002 Work), version-skew 3/3, `hash_mode` 명칭-구현 불일치(raw bytes sha256), 현행 `do_check` grep/sed 구현(create-harness.sh ~L230-330).

**Review Objective (red-team — 설계 결정 의심):**
1. **Parser 전략:** python3 `json.load` 우선 + 현행 grep fallback의 dual-path — 유지보수 경로 2개의 parity 위험 vs 단일 경로 대안(python3 필수화 / bash-only tolerant / 형식 자동 감지 후 정규화). 어느 쪽이 장기 유지비가 낮은가? fallback이 pretty-print에서 여전히 파손된다는 비대칭을 어떻게 표기할까?
2. **source_ref 설계:** `git describe --tags --always --dirty` 형태가 맞나(vs commit sha 병기, vs release tag만 허용)? skew 감지 시 `--check` 출력이 WARN까지 가야 하나 표시만 해야 하나? DR-028의 "released tag baseline 기본" 정책과의 정합.
3. **hash_mode 처리:** "값 유지 + 의미만 문서 정정"이 명칭 불일치를 영구화하는 선택은 아닌가? 대안(신규 값 도입 + 구값 호환 해석)과 비교해줘.
4. **fixture 충분성:** 정상/pretty-print/구버전 3종으로 충분한가? (예: python3 부재 환경 시뮬레이션, source_ref 없는 구 manifest + 있는 신 manifest 혼합)
5. **scope 경계:** 이 Work가 upgrade 절차 diet(별도 후보)와 겹치는 부분은 없는가?

**Do Not Re-litigate:** entry-format 계약화 제외(-001 R1b), scope 자체(-001 R1b consensus), 기존 adopter 소급 없음, cross-agent 역할.

**Output Contract:** Verdict + finding table을 이 파일 `### R0 — Reviewer Findings (Codex)` 섹션에 기록, Round Log 갱신, driver relay용 5줄 요약 별도 출력.

### R0 — Reviewer Findings (Codex)

**Verdict: request-changes**

현재 plan은 결함을 발견한 parser·field contract를 정비하면서도 각각에 새 ambiguity를 남긴다. 특히 python/grep dual-path는 동일 manifest가 실행 환경에 따라 정상 또는 오판되는 계약 분기이고, `git describe` 단독·legacy `hash_mode` 영구화·immutable `generated_at`은 이번 Work가 닫으려는 provenance/의미 불명확성을 완전히 닫지 못한다. 구현 전 아래 must를 plan과 Done Criteria에 반영해야 한다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| R0-Codex-F1 | must | **tolerant parser를 python 우선 + 비관용 grep fallback으로 구성하면 contract가 환경 의존적으로 갈라진다.** fallback은 pretty-print에서 조용히 0개/오분류할 수 있어, 이번 Work의 핵심 결함을 보존한다. bash-only tolerant JSON이나 parser 없이 형식 정규화하는 대안도 JSON grammar를 안정적으로 처리하지 못한다. | 현행 `do_check`는 `grep '"path"'`와 line-local `sed`에 의존한다. 반면 root README는 이미 scaffold/validation 예시가 `python3`를 전제한다고 명시한다. | **`--check`의 manifest parsing은 python3 단일 경로로 고정**한다. python3가 없으면 actionable message와 exit 2로 fail closed하고 drift 결과를 만들지 않는다. hard dependency를 거부해 fallback을 유지하려면, noncanonical/pretty JSON을 감지해 명시적으로 실패시키고 동일 fixture corpus를 두 경로 모두에 강제해야 하지만 장기 유지비 때문에 비권장이다. |
| R0-Codex-F2 | must | **`git describe --tags --always --dirty` 단독은 human label이지 재현 가능한 source identity가 아니다.** tag 추가·shallow clone·dirty checkout에 따라 표현이 달라지고, `-dirty`는 어떤 bytes가 달랐는지 복구할 수 없다. | DR-028은 non-release evidence에 branch, HEAD sha, `git describe`, 예외 label을 함께 요구하며 released tag/main을 기본 baseline으로 둔다. 현행 `print_source_ref_report`도 branch·short sha·describe를 분리 출력한다. | manifest에 human-readable `source_ref`와 함께 **full `source_commit` + boolean `source_dirty`**를 기록한다. release label은 harness tag pattern을 필터링한 clean exact tag를 우선한다. source git metadata가 없을 때의 `unknown` 계약도 정의한다. scaffold 시 dirty/non-release source를 WARN하고, `--check`는 legacy field 부재를 `unknown (legacy)`로 degrade한다. |
| R0-Codex-F3 | must | **ref mismatch를 무조건 표시하거나 무조건 WARN하는 둘 다 부정확하다.** 정상 upgrade는 manifest ref와 current source ref가 다른 것이 기대되지만, 같은 `harness_version`인데 commit이 다르면 이번 Work가 잡으려는 version-skew다. | ai-deck은 manifest version 1.3.0이면서 pre-1.4 develop snapshot hash를 보유했다. DR-028은 clean release가 아닌 evidence를 명시 예외로 취급한다. | 판정을 구분한다: ① field 없음=legacy info, ② version delta + commit delta=expected upgrade source delta 표시, ③ **same version + commit delta=version-skew WARN**, ④ recorded/current dirty 또는 current non-release checkout=DR-028 WARN. 출력 fixture가 이 네 상태를 고정해야 한다. |
| R0-Codex-F4 | must | **`hash_mode: normalized_source_template`를 그대로 두고 실제 raw-byte 의미만 문서에서 바꾸면 잘못된 이름을 영구 contract로 만든다.** 이 값은 현재 비교 로직에서 검증조차 하지 않아 unknown mode도 같은 방식으로 조용히 처리될 수 있다. | `adapt()`는 치환 전 source file의 raw bytes를 hash하며 별도 normalization을 하지 않는다. invariant는 반대로 legacy literal을 hard-code한다. | 신규 manifest의 canonical 값을 `source_template_raw`처럼 실제 transform을 나타내는 값으로 바꾸고, reader는 legacy `normalized_source_template`를 **명시적 alias**로만 허용한다. 두 값 외에는 invalid manifest(exit 2)로 처리하고 invariant·fixture도 양쪽을 검증한다. 기존 adopter 소급 변경은 하지 않는다. |
| R0-Codex-F5 | must | **`generated_at = 최초 scaffold 시점, rebaseline 불변`은 field 이름과 실제 whole-manifest rebaseline 경로 모두에 어긋난다.** 문서만으로 불변을 선언하면 shadow manifest 교체 시 오늘 날짜로 바뀌어 contract가 다시 깨진다. | script는 manifest 생성마다 `TODAY`를 기록하고, 현행 playbook은 구버전 manifest target도 shadow scaffold의 새 manifest로 rebaseline하는 경로를 사용한다. | `generated_at`을 **현재 manifest baseline이 생성/rebaseline된 날짜**로 정의해 재생성 시 갱신한다. 최초 scaffold 시점이 실제로 필요하다는 evidence가 생기면 별도 `scaffolded_at`을 추가하되, 지금은 새 history field를 추측해 만들지 않는다. playbook의 rebaseline 설명과 fixture가 이 의미를 반영해야 한다. |
| R0-Codex-F6 | must | **fixture 3종은 parser와 provenance의 상태 공간을 커버하지 못한다.** 특히 parser dependency 부재, legacy/new field 혼합, ref mismatch 의미, invalid type/mode를 검증하지 않으면 이번 설계 결정을 회귀 방지할 수 없다. | 제안 fixture는 정상/pretty-print/필드 누락만 다룬다. `source_ref` 유무·dirty·same-version skew와 python3 부재 동작은 Done Criteria에도 없다. | 최소 behavior matrix를 둔다: canonical new manifest, pretty-print/key reorder, legacy(no ref + legacy hash mode), malformed/missing/wrong-type/empty entries/unknown hash mode→exit 2, python3 부재→actionable exit 2, source state 4분류(F3). static fixture 수보다 동일 assertion runner의 table-driven coverage를 기준으로 Done Criteria를 쓴다. |
| R0-Codex-F7 | nice | **upgrade 절차 diet와의 경계는 유지 가능하지만 field contract에 필요한 rebaseline 문구까지 비범위로 밀면 안 된다.** | parser/schema/diagnostic은 diet의 선행 contract이고, 절차 축소·agent checklist·자동 rebaseline writer는 별도 W6 후속이다. | 이 Work는 parse/schema/output/rebaseline field semantics/fixture까지만 수행한다. playbook에서는 새 field의 읽기·갱신 의미만 고치고 Phase 삭제, agent-first default 전환, helper 추가는 하지 않는다. 후속 diet Work가 새 contract를 소비하도록 dependency만 남긴다. |

**Residual Risk:** 단일 parser와 structured provenance를 채택해도 source checkout이 dirty이면 commit만으로 exact source bytes를 복원할 수 없다. manifest per-file hash가 drift 판정의 authoritative evidence이고 source ref는 provenance/WARN 보조 신호라는 우선순위를 contract에 명시해야 한다. 또한 새 hash mode를 구 parser가 무시할 수 있으므로 release note와 cross-version fixture가 필요하다.

### R0 — Driver Response (Claude)

전 finding 수용(defend 없음):

| Finding | 반영 |
| --- | --- |
| F1 (must) | grep fallback 제거 — python3 단일 parser, 부재 시 actionable exit 2 fail closed. python3 의존은 `--check` 한정(scaffold 생성 경로 비의존) |
| F2 (must) | `source_ref`(clean exact tag 우선 label) + `source_commit`(full sha) + `source_dirty`(bool) 병기, `unknown` 계약, scaffold 시 dirty/non-release WARN, legacy는 `unknown (legacy)` degrade |
| F3 (must) | ref 판정 4분류 채택 — same-version+commit-delta만 version-skew WARN, version delta는 expected 표시, dirty/non-release는 DR-028 WARN. 4상태 출력 fixture 고정 |
| F4 (must) | `hash_mode` 신규 canonical `source_template_raw` + legacy 명시적 alias, 그 외 exit 2. invariant·fixture 양쪽 검증, 소급 없음. 비목표에서 "hash_mode 값 변경" 삭제 |
| F5 (must) | `generated_at` = baseline 생성/**rebaseline** 날짜(재생성 시 갱신)로 재정의 — 원안의 "불변" 철회. `scaffolded_at` 추측 신설 금지 |
| F6 (must) | fixture를 static 3종 → table-driven behavior matrix로 확대(malformed/wrong-type/unknown mode/python3 부재/source state 4분류) |
| F7 (nice) | scope = parse/schema/output/rebaseline field semantics/fixture까지. playbook은 field 의미만 갱신, diet 후속에 dependency만 남김 |
| Residual | "per-file hash = authoritative, source ref = provenance 보조" 우선순위를 contract 문서에 명시 + cross-version 하위호환 fixture |

### R0b — Consensus Confirmation Request (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 수정된 Scope ①~④·Done Criteria·비목표 (위 Driver Response 반영본).

**Review Objective:** 교정 충실성 확인 + EXECUTE 진입 consensus. 신규 쟁점 없으면 approve.

**Output Contract:** Verdict를 이 파일 `### R0b — Reviewer Findings (Codex)` 섹션에 기록 + Round Log 갱신 + 3줄 요약 별도 출력.

### R0b — Reviewer Findings (Codex)

**Verdict: approve**

R0 F1~F7의 설계 취지는 수정된 Scope ①~④·Done Criteria·비목표에 충실하게 반영됐다. python3 단일 parser와 fail-closed, provenance 3필드·git metadata 부재 계약, ref 4분류, canonical/legacy `hash_mode` 정책, `generated_at` rebaseline 의미, table-driven behavior matrix, per-file hash 우선순위와 diet 경계를 모두 확인했다. 신규 design blocker가 없으므로 **EXECUTE 진입에 consensus**한다.

R1 전 non-blocking cleanup 두 건만 확인한다: Verification의 기존 `--check 회귀(3 fixture + toolstead)`를 `behavior matrix + toolstead`로 현행화하고, 신규 `hash_mode`의 release note 필요성을 이번 release가 아니라 후속 release-prep handoff로 Work에 한 줄 남긴다. 이는 구현 착수를 막지 않는다.

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target (전부 branch `feature/manifest-contract-20260713` working tree, 미commit):**
1. `scripts/create-harness.sh` — do_check python3 단일 parser·provenance 유도/기록·4분류 판정·field 계약 주석·scaffold WARN
2. `scripts/tests/check-manifest-contract.sh` (신규, 12 case) + `run-harness-checks.sh` Tier 2b 편입
3. `scripts/tests/check-scaffold-invariants.sh` — hash_mode 양값 + 신규-manifest-only provenance 필수
4. `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` — Manifest field 계약 절
5. 이 Work 파일 CP1(검증 evidence), Discovery release-prep handoff

**Delta Since R0b:** R0 합의 설계 그대로 구현 + non-blocking cleanup 2건 반영(Verification 문구 현행화, release handoff 기록). 구현 중 발견 1건: invariants가 tier1(기존 adopter)에도 돌아 provenance 필드를 무조건 요구하면 legacy 전부 FAIL → **신규 hash_mode manifest에서만 필수**로 조정(설계 의도 확인 요청).

**Review Objective (red-team):**
1. R0 합의 대비 구현 충실성 — 특히 python 검증 로직(shape/tab/hash_mode)과 4분류 판정 조건문이 F2/F3 취지와 일치하는가.
2. 재현 검증: `bash scripts/tests/check-manifest-contract.sh`(12/12 기대), `bash scripts/tests/run-harness-checks.sh --tier2`, `--check ~/dev-home/vibe/toolstead`(83/83 + legacy 안내 기대).
3. invariants의 legacy 하위호환 조정(위 발견 1건)이 계약 취지에 맞는지.
4. matrix 누락 케이스, 출력 문구의 오해 소지, playbook 절의 F7 경계 준수.

**Do Not Re-litigate:** R0/R0b 합의 설계 자체, entry-format 계약화 제외, diet 비범위.

**Output Contract:** Verdict + finding table을 이 파일 `### R1 — Reviewer Findings (Codex)` 섹션에 기록, Round Log 갱신, 5줄 요약 별도 출력.

### R1 — Reviewer Findings (Codex)

**Verdict: request-changes**

python3 단일 parser, hash mode alias, provenance 기록·4분류의 큰 골격과 playbook 경계는 R0 합의에 맞고, 요청된 공식 검증도 모두 재현됐다. 그러나 추가 boundary fixture에서 canonical manifest가 provenance 없이도 legacy로 통과하고, `unknown` sentinel이 거짓 skew를 만들며, invariant가 compact JSON을 거부하는 계약 분기가 확인됐다. 아래 must를 닫기 전에는 commit 후보로 승인할 수 없다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| R1-Codex-F1 | must | **신규-manifest-only provenance 필수화라는 driver 조정은 맞지만, invariant에만 있고 canonical parser에는 없다.** `hash_mode: source_template_raw`에서 provenance 3필드를 제거하거나 `source_dirty`를 string으로 바꿔도 `--check`가 exit 0으로 drift verdict를 낸다. 누락은 `unknown (legacy)`, 잘못된 bool은 `dirty: unknown`으로 조용히 내려간다. | 독립 fixture: canonical manifest에서 `source_ref/source_commit/source_dirty` 제거 → `--check` exit 0, `77/77`, legacy 안내. `source_dirty: "false"` → exit 0. 같은 파일은 invariant에서 provenance 누락으로 FAIL한다. | Python validator도 `hash_mode == source_template_raw`이면 non-empty string `source_ref`, `source_commit`과 boolean `source_dirty`를 필수화한다. legacy alias에서만 3필드 부재를 `unknown (legacy)`로 허용한다. 이 adjustment를 matrix의 canonical-missing/wrong-type case로 고정한다. |
| R1-Codex-F2 | must | **git metadata 부재 sentinel `source_commit: "unknown"`을 실제 commit처럼 비교해 거짓 version-skew WARN을 만든다.** 이는 F2의 `unknown` 계약과 F3의 same-version/commit-delta 판정을 동시에 위반한다. | 독립 fixture: canonical manifest의 `source_ref/source_commit`을 `unknown`, version을 current와 동일하게 두면 exit 0과 함께 `version-skew ... recorded unknown` WARN 출력. | commit 비교는 recorded/current 양쪽이 full SHA일 때만 수행한다. canonical `source_commit`은 full 40-hex 또는 명시적 `unknown`만 허용하고, `unknown`이면 `provenance unavailable/non-reproducible` info로 남기되 skew 판정에서 제외한다. matrix에 git-metadata-absent case를 추가한다. |
| R1-Codex-F3 | must | **`check-scaffold-invariants.sh`가 새 JSON contract를 다시 formatting-sensitive grep으로 해석한다.** 따라서 `--check`가 지원한다고 선언한 compact JSON이 invariant에서는 실패해 entry-format 비계약 원칙을 우회한다. | 독립 fixture: 신규 manifest를 `json.dumps(..., separators=(',', ':'))`로 compact화하면 `--check`는 `77/77` PASS하지만 invariant `[5]`는 `manifest hash_mode가 계약 값이 아님`으로 FAIL한다. 현재 regex는 key/value 사이 정확히 `: `를 요구한다. | invariant의 hash_mode/provenance shape도 python JSON parse로 판정하거나 `--check`의 validator를 재사용해 parser SSoT를 하나로 유지한다. 최소한 canonical compact·pretty·legacy fixture 각각에 invariant assertion을 추가한다. provenance를 canonical mode에서만 요구하는 정책 자체는 유지한다. |
| R1-Codex-F4 | must | **Python→TSV normalization boundary가 tab 일부만 막고 newline/CR와 hash 형식을 검증하지 않는다.** valid JSON string의 제어문자는 TSV record를 분할할 수 있고, 임의의 non-empty `sha256`는 invalid manifest가 아니라 `source-updated`로 오분류된다. | validator는 `path+src`의 tab만 거부하고 metadata·`sha256`의 tab/newline/CR을 허용하며, `sha256`를 non-empty string으로만 검사한다. bash consumer는 `IFS=$'\t' read` line protocol을 신뢰한다. | TSV로 내보내는 모든 string에서 `\t\r\n`을 거부하고 `sha256`를 64-hex로 검증한다. invalid-control-char/bad-sha case를 matrix에 추가한다. |
| R1-Codex-F5 | nice | **`source_ref` fallback의 tag filter가 exact-tag 경로와 다르다.** clean exact lookup은 `ai-workflow-v*`를 쓰지만 fallback `git describe`는 모든 tag를 허용해 unrelated tag label을 기록할 수 있다. | full commit이 authoritative이고 non-release label은 WARN되므로 drift 판정 오류는 아니지만 provenance 가독성이 낮아질 수 있다. | exact/fallback 모두 동일한 numeric harness release tag match를 사용하고, clean 여부는 기존 `is_clean_release_desc`와 같은 grammar로 맞춘다. |

**Confirmed:** `bash scripts/tests/check-manifest-contract.sh` 12 case PASS, `run-harness-checks.sh --tier0` PASS, `--tier2` PASS, toolstead read-only `83 tracked / 83 in-sync / 0 drifted + unknown (legacy)`를 재현했다. `generated_at`·per-file hash 우선순위 문서화와 playbook의 F7 scope 경계도 적정하다. R0b non-blocking cleanup 두 건(Verification 문구·release-prep handoff)도 반영됐다.

**Residual Risk:** 현재 matrix는 generated scaffold의 happy path와 주요 ref 상태는 잘 고정하지만, checker와 다른 manifest consumer(invariant)의 parser parity를 보장하지 않는다. 수정 시 parser validation을 중복 구현하지 않거나, 불가피하면 동일 fixture corpus를 두 consumer에 강제해야 한다.

### R1 — Driver Response (Claude)

전 finding 수용(defend 없음):

| Finding | 반영 |
| --- | --- |
| F1 (must) | python validator에 canonical(hash_mode=`source_template_raw`) provenance 필수화 — non-empty string `source_ref`/`source_commit` + strict boolean `source_dirty`, legacy alias만 부재 허용. matrix `canonical-no-prov`/`wrongtype-dirty` case 고정 |
| F2 (must) | `source_commit`은 full 40-hex 또는 명시적 `unknown`만 허용(validator). skew 비교는 양쪽 commit이 실제 sha일 때만 — sentinel은 "non-reproducible" info로 표시하고 skew 판정 제외. matrix `bad-commit`/`git-unknown` case 고정 |
| F3 (must) | invariant [5]의 manifest 해석을 formatting-sensitive grep → **python JSON parse**로 교체(parser 계약 단일화). hash_mode/provenance 강제는 `--check` validator가 SSoT(invariant의 자기일관성 `--check` 호출에서 invalid=exit 2로 잡힘), invariant 고유 필드(manifest_version 등)만 JSON으로 확인. **compact manifest 실기 검증: `--check` 77/77 + invariant [5] PASS 동시 확인** |
| F4 (must) | TSV로 나가는 모든 string(meta 포함)에서 `\t\r\n` 거부, `sha256` 64-hex 검증. matrix `ctrl-char`/`bad-sha` case 고정 |
| F5 (nice) | fallback `git describe`에 exact-match와 동일한 `--match 'ai-workflow-v*'` filter 적용 |
| Residual | parser 중복 미도입 — invariant는 validator를 재구현하지 않고 `--check` 호출에 위임, 고유 필드만 별도 JSON 확인. matrix가 두 consumer의 계약을 함께 고정(compact/pretty/legacy) |

### CP2 — R1 must-fix 반영 + 재검증 (2026-07-13)

- behavior matrix **19 case PASS**(기존 12 + compact/canonical-no-prov/wrongtype-dirty/bad-commit/bad-sha/ctrl-char/git-unknown).
- compact-manifest invariant parity 실기 확인(scaffold → manifest compact화 → invariants PASS + `--check` 자기일관성 유지).
- tier2 PASS, toolstead read-only 83/83 유지, `git diff --check` 통과.

### R1b — Consensus Confirmation Request (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** R1 must-fix 반영본 — `scripts/create-harness.sh`(validator 강화·skew 비교 조건·F5 filter), `scripts/tests/check-scaffold-invariants.sh`([5] python parse), `scripts/tests/check-manifest-contract.sh`(19 case).

**Delta Since R1:** F1~F5 + residual 전부 반영(위 Driver Response 표). 재현: `bash scripts/tests/check-manifest-contract.sh`(19/19), compact parity 확인 절차는 CP2 참조.

**Review Objective:** 교정 충실성 확인 + commit 후보 consensus. 신규 쟁점 없으면 approve.

**Output Contract:** Verdict를 이 파일 `### R1b — Reviewer Findings (Codex)` 섹션에 기록 + Round Log 갱신 + 3줄 요약 별도 출력.

### R1b — Reviewer Findings (Codex)

**Verdict: request-changes**

R1 F1~F5의 직접 교정은 취지대로 반영됐고 behavior matrix 19 case와 compact-manifest invariant parity도 재현됐다. 그러나 residual의 핵심인 invariant → `--check` validator 위임이 `grep '"path"'` guard와 `set -e` 때문에 모든 invalid manifest에서 일관되게 작동하지 않는다. 아래 한 건을 닫기 전에는 commit 후보 consensus를 줄 수 없다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| R1b-Codex-F1 | must | **invariant의 `--check` 위임이 조건부라 canonical validator를 우회할 수 있고, 위임 실패도 구조화된 FAIL로 수렴하지 않는다.** `framework_files`가 invalid이지만 `"path"` literal이 없는 경우 `--check`를 호출하지 않으며, 호출된 invalid case는 `set -euo pipefail` 아래 command substitution에서 조기 종료한다. 따라서 "validator 재구현 없이 `--check` 위임"이라는 residual 처리 자체는 맞지만 현재 구현은 완결되지 않았다. | 독립 fixture ① generated canonical manifest의 `framework_files=[]` → `check-scaffold-invariants.sh`가 `RESULT: PASS / OVERALL: PASS`(validator 완전 우회). ② provenance 3필드 제거, entry 유지 → `--check` exit 2가 pipeline으로 전파되어 `[5]` 중간 종료, `RESULT: FAIL` 미출력. 반면 요청된 19-case matrix와 valid compact parity는 PASS했다. | `grep '"path"'` guard를 제거하고 manifest가 존재하면 `--check`를 **항상** 호출한다. 호출을 `if ! check_output="$(...)"; then ... c5_fail=1` 형태로 감싸 exit 2를 명시적 FAIL로 변환하고, 성공한 경우에만 summary `0 drifted`를 검사한다. invariant regression fixture에 최소 `framework_files=[]` 또는 canonical provenance 누락 중 하나를 추가해 위임 경로를 고정한다. |

**Confirmed:** canonical provenance 필수화, `unknown` sentinel skew 제외, full-SHA/control-char/hash 검증, fallback tag filter 적용은 코드와 matrix에서 확인했다. `bash scripts/tests/check-manifest-contract.sh` 19/19 PASS, compact scaffold → compact JSON → invariant PASS, Tier 2 전체 PASS를 재현했다. `--match 'ai-workflow-v*'`의 numeric grammar가 넓은 점은 malformed tag를 clean release로 인정하지 않고 기존 `is_clean_release_desc` WARN으로 강등하므로 이번 commit의 blocking risk로 보지 않는다.

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R0 | 2026-07-13 | Claude (plan 작성, packet 발행) | Codex (plan review) | request-changes | F1~F6 must, F7 nice — parser 단일화·structured provenance·field semantics·fixture matrix 수정 요청 |
| R0-resp | 2026-07-13 | Claude (전부 수용, plan 수정) | — | — | 위 Driver Response 표 |
| R0b | 2026-07-13 | Claude (packet 발행) | Codex (consensus 확인) | approve | F1~F7+residual 설계 반영 확인, EXECUTE 진입 consensus; non-blocking cleanup 2건은 R1 확인 |
| R1 | 2026-07-13 | Claude (구현+검증 완료, packet 발행) | Codex (result review) | request-changes | 공식 검증 재현 PASS; canonical provenance validation·unknown sentinel·invariant parser parity·TSV validation F1~F4 must 기록 |
| R1-resp | 2026-07-13 | Claude (F1~F5+residual 전부 수용·반영) | — | — | matrix 19 case, compact parity 실기 확인 |
| R1b | 2026-07-13 | Claude (packet 발행) | Codex (consensus 확인) | request-changes | F1~F5 직접 교정·19-case·compact parity는 확인; invariant의 조건부 `--check` 위임 우회/조기 종료 1건 must |
| R1b-resp | 2026-07-13 | Claude (R1b-F1 수용·반영) | — | — | 아래 R1b Driver Response |
| R1c | 2026-07-13 | Claude (packet 발행) | Codex (consensus 확인) | approve | R1b-F1의 unconditional `--check` 위임·exit 변환·20-case regression 확인; commit 후보 consensus |

### R1b — Driver Response (Claude)

R1b-F1 수용(defend 없음):

- `grep '"path"'` guard 제거 — manifest가 존재하면 `--check`를 **항상** 호출.
- 호출을 `check_out="$(...)" || check_rc=$?`로 감싸 `set -euo pipefail` 하에서도 조기 종료 없이 exit code를 잡고, non-zero(invalid exit 2 포함)를 **명시적 FAIL**(stderr tail 3줄 동반)로 변환. 성공 시에만 summary `0 drifted` 검사.
- **회귀 fixture 고정:** matrix에 `inv-delegation` 섹션 추가 — 실제 scaffold 생성 → `framework_files=[]` corrupt → invariants 전체 실행 → ⓐ exit non-zero, ⓑ "--check 실패" FAIL 메시지 존재, ⓒ `RESULT:` 줄 존재(중간 종료 아님) 3중 assert.
- 실기 검증: corrupt manifest에서 `[5] FAIL: --check 실패 (exit 2)` + `RESULT: FAIL`/`OVERALL: FAIL` 정상 수렴, matrix 20 case(19+delegation) PASS, tier2 PASS, `git diff --check` 통과.

### R1c — Consensus Confirmation Request (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** R1b-F1 반영본 — `scripts/tests/check-scaffold-invariants.sh` [5] 위임 블록, `scripts/tests/check-manifest-contract.sh` `inv-delegation` 회귀 섹션.

**Delta Since R1b:** 위 R1b Driver Response. 재현: R1b evidence fixture ①(`framework_files=[]`) → 명시적 FAIL, ②(provenance 제거) → 동일 경로로 FAIL 수렴(항상 호출 + exit 변환이므로 case 무관).

**Review Objective:** R1b-F1 교정 확인 + **commit 후보 consensus 재확인**. 신규 쟁점 없으면 approve.

**Output Contract:** Verdict를 이 파일 `### R1c — Reviewer Findings (Codex)` 섹션에 기록 + Round Log 갱신 + 3줄 요약 별도 출력.

### R1c — Reviewer Findings (Codex)

**Verdict: approve**

R1b-Codex-F1은 취지대로 닫혔다. invariant [5]가 manifest 존재 시 `--check`를 조건 없이 호출하고, non-zero exit를 포착해 명시적 FAIL로 변환한 뒤 `RESULT`/`OVERALL`까지 정상 수렴한다. validator를 invariant에 재구현하지 않고 canonical `--check`에 위임하는 residual 방향도 유지됐다.

**Verified:** `bash scripts/tests/check-manifest-contract.sh` 20 case PASS. 독립 재현에서도 ① `framework_files=[]`, ② canonical provenance 3필드 제거가 모두 invariant exit 1, `FAIL: --check 실패 (exit 2)`, `RESULT: FAIL`, `OVERALL: FAIL`로 동일하게 수렴했다. 신규 blocking issue가 없으므로 **commit 후보 consensus**에 동의한다(실제 commit approval은 Approval Matrix의 별도 gate).

## Checkpoints

### CP1 — EXECUTE + VALIDATE 완료 (2026-07-13)

**구현 (R0 합의 반영):**
- `scripts/create-harness.sh`: ⓐ do_check parser를 python3 단일 경로로 교체(grep/sed 제거) — JSON layout 무관 파싱 + 필드/entry shape/hash_mode 계약 검증, python3 부재 시 actionable exit 2(`HARNESS_CHECK_FORCE_NO_PYTHON` test hook 포함). ⓑ scaffold-time provenance 유도(`SOURCE_REF` clean exact tag 우선 / `SOURCE_COMMIT` full sha / `SOURCE_DIRTY`) + manifest 3필드 기록 + scaffold 시 dirty/non-release WARN. ⓒ `--check` provenance 4분류 판정 블록. ⓓ manifest field 계약 주석 + `hash_mode: source_template_raw`.
- `scripts/tests/check-scaffold-invariants.sh`: hash_mode 양값 계약 검증 + provenance 필드는 **신규 hash_mode manifest에서만 필수**(legacy adopter tier1 하위호환 유지 — 구현 중 발견한 함정: 무조건 요구하면 기존 adopter 전부 FAIL).
- `scripts/tests/check-manifest-contract.sh` 신규(behavior matrix 12 case) + `run-harness-checks.sh` Tier 2b 편입.
- `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`: Manifest field 계약 절 추가(F7 경계 준수 — field 의미만).

**검증 결과:** behavior matrix **12/12 PASS**(canonical/pretty/legacy/malformed/missing/wrong-type/empty/bad-hash-mode/no-python/skew/upgrade-delta/recorded-dirty). tier0 PASS·tier2 PASS(3 scaffold 모드 invariants + matrix). toolstead read-only `--check` 하위호환: 83/83 in-sync + "unknown (legacy)" 안내. temp 실제 생성에서 provenance 기록·dirty WARN·77/77 self-consistency 확인. dry-run에서 scaffold-time WARN 동작. `git diff --check` 통과.
