---
id: CHORE-20260605-006
priority: P1
status: Done
risk: Medium
scope: Q4 최소 경로 — scaffold 생성 시 `.harness/manifest.json`(harness version + framework-owned 파일 list+hash) 기록, `scripts/create-harness.sh --check <target>`로 target의 framework surface가 source 대비 drift났는지 보고. slice #13(canonical+adapter+no-alias rename, breaking)의 전제조건(DR-023 §41, 부모 §10-a). `--upgrade`(3-way merge)는 deferred. OQ-10(hash 기준) 확정 포함
appetite: 2d
planned_start: 2026-06-05
planned_end: 2026-06-07
actual_end: 2026-06-05
related_dr: [DR-021, DR-023]
related_troubleshooting: []
---

# CHORE-20260605-006: Scaffold Manifest + `--check` (Q4 최소 경로)

## Top Summary (결론 먼저)

- **목표:** scaffold target이 "어느 harness 버전에서 나왔고, framework surface가 source 대비 얼마나 drift났는지"를 알 수 있는 최소 장치를 만든다. 이게 있어야 slice #13의 no-alias command rename을 책임 있게 진행할 수 있다(부모 §10-a: "migration note는 필요조건이지 충분조건이 아니다").
- **2축:** ① **manifest 생성** — scaffold 시 `.harness/manifest.json`에 harness version + framework-owned 파일 list+hash 기록. ② **`--check`** — `create-harness.sh --check <target>`가 target manifest를 읽어 framework surface drift를 파일 단위로 보고.
- **설계 행운:** `adapt()`의 치환이 단일 토큰(`ai-workflow-harness`→PROJECT_NAME)뿐이라(`create-harness.sh:adapt`), hash는 **normalized source-template hash**로 깔끔히 정의 가능(OQ-10). 또한 framework 파일 = `adapt()` 대상, B-class seed = `write_text` 대상으로 자연 분리되므로, **manifest를 adapt() 호출 기록에서 파생**하면 별도 file-list 유지보수 drift가 없다.
- **비목표:** `--upgrade` 3-way merge(deferred, §619/§800 — target 다수+pain 실측 후), canonical+adapter 전환, command rename(slice #13), manifest 기반 자동 갱신. DR-021 경계 변경 없음(분류는 그대로 사용).
- **enforcement(DR-024):** `--check`는 report-only 진단 도구(hard-stop 아님).

## Context Manifest

| 순서 | 파일 | 섹션/라인 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-023-canonical-hybrid-adapter.md` | §41 Consequences | "단독 선행 금지 — Q4 `--check` 최소 경로 위에서만" 제약의 출처 |
| 2 | `docs/works/harness/CHORE-20260604-001-...md` | §6(589-619), §10-a(947-960), Codex(789-806), OQ-10(984) | manifest/check/upgrade 설계 합의·순서·hash 미결 |
| 3 | `scripts/create-harness.sh` | `adapt()`, `write_text()`, flag 파싱(32-), guards(95-) | 생성 시 manifest 기록 지점, `--check` 모드 분기 |
| 4 | `scripts/create-harness.sh` | slice #9 `--with-optional` 블록 | manifest가 추적할 framework file set(default vs optional) |
| 5 | `scripts/tests/check-scaffold-invariants.sh` | 양쪽 모드 생성 패턴 | manifest/`--check` 검증 hook 추가 위치 |

## Defect/Scope Inventory (실측)

| # | 항목 | 근거 |
| --- | --- | --- |
| M1 | target에 harness version/manifest 0 — 자기가 어느 버전에서 나왔는지 모름 | 부모 §594; `find .harness` 없음 |
| M2 | source repo에 version marker 없음 | `VERSION` 파일·script 상수 부재 |
| M3 | `--check` drift 진단 장치 없음 → no-alias rename 시 target이 어디서 깨지는지 알 수 없음 | 부모 §10-a, §618 |
| M4 | framework file list가 코드(adapt 호출)에만 존재, 선언적 기록 없음 | manifest의 입력이 될 목록이 암묵적 |

## Plan

### A. harness version 소스 (M2)

- repo 루트 `VERSION` 파일 신설, 초기값 **`0.2.0`**(R20 — Phase 2 계열 추적 모델 도입이라 0.1.x보다 의미 선명). `create-harness.sh`가 읽어 manifest에 기록. 부재 시 `0.0.0-dev` fallback. → PQ-2.

### B. manifest 생성 (M1·M4)

- `adapt()`가 복사하는 dst 경로를 `FRAMEWORK_FILES` 배열에 누적(framework=A-class+optional 자동 식별). `write_text` 대상(B-class seed)은 제외.
- 모든 복사 후 `.harness/manifest.json` write. **schema(R20 확정):**
  ```json
  {
    "manifest_version": 1,
    "harness_version": "0.2.0",
    "source_identity": "ai-workflow-harness",
    "generated_at": "2026-06-05",
    "profile": "generic",
    "workflow_mode": "generic",
    "with_optional": false,
    "project_name": "<name>",
    "hash_algorithm": "sha256",
    "hash_mode": "normalized_source_template",
    "framework_files": [{"path": "CLAUDE.md", "sha256": "..."}]
  }
  ```
- hash 기준 = **normalized source-template hash**(치환 전 source 파일 내용 sha256; 단일 토큰 치환이라 project-agnostic). OQ-10 이 결정으로 closure(DR 신설 불필요 — DR-021/023 하류 구현 상세). → PQ-1.
- 제외(과함): target-owned 목록, B-class seed hash, upgrade/merge policy, rename mapping.
- `--dry-run`에서는 manifest 미기록(파일 생성 없음 원칙 유지).

### C. `--check <target>` 모드 (M3) — R20 확정

- flag 파싱에 `--check` 추가. `create-harness.sh --check <target-dir>`. source repo에서 target 대상으로 실행(부모 §960).
- target `.harness/manifest.json` 읽어 harness_version + framework file 목록·hash 확보.
- **파일별 status(R20):**
  - `in-sync`: 현재 source template hash == manifest 기록 hash, 그리고 target 파일 정상.
  - `source-updated`(**primary signal**): 현재 source template hash != manifest 기록 hash → source가 scaffold 이후 진화. rename이 요구하는 핵심 신호.
  - `locally-modified`(**best-effort advisory**): target 파일 reverse-normalize(PROJECT_NAME→`ai-workflow-harness`) hash != manifest hash → target이 framework file 직접 수정. **sed/regex 특수문자 escaping 필수**.
  - `diverged`: source-updated + locally-modified 동시.
  - `source-missing`: manifest에 있으나 현재 source에 없음(삭제/rename) → #13 rename 대비 미리 상태명 확보.
- **missing/invalid manifest 처리:** target에 `.harness/manifest.json` 없으면 fail 아님 → "untracked target / pre-manifest scaffold"로 report.
- **exit code(R20):** invalid/missing manifest = nonzero, drift 발견 = 기본 0 + summary. CI hard mode는 하류.
- 출력: version delta(target vs current source) + 파일별 status + 요약. report-only(쓰기 없음).

### D. 검증 hook (E)

- `check-scaffold-invariants.sh`에 manifest 존재·형식 + `--check` 자기일관성(갓 생성한 target은 source-updated 0) 검사 추가 여부. → PQ-4.

### 결정 필요 (Codex) — PQ-1~4

## Done Criteria

- [x] `VERSION`(0.2.0) 소스 확정, manifest에 harness_version 기록 (A)
- [x] scaffold 생성 시 `.harness/manifest.json` 기록 — framework-owned 파일만(adapt 파생), B-class 제외, default 56/`--with-optional` 74 (B)
- [x] hash 기준(OQ-10) 확정·구현: normalized source-template hash (PQ-1)
- [x] `--check <target>` status 구현: in-sync/source-updated/locally-modified/source-missing/target-missing, missing manifest→untracked report(exit 3), invalid=exit 2, drift=exit 0 (C·R20·D-2)
- [x] locally-modified를 reverse-normalize→**forward-render**로 교체(과치환 해소, D-1). project name 치환은 scaffold adapt와 동일
- [x] 갓 생성 target `--check` → drift 0(자기일관성), source 1개 수정 후 → 그 파일만 source-updated, target 1개 수정 → 그 파일만 locally-modified, untracked → exit 3 (검증)
- [x] `bash -n`/`sh -n` PASS, 1b 불변식 테스트 양쪽 모드 여전히 PASS(+[5] manifest 검사 추가)
- [x] manifest/`--check`가 DR-021 A/B 경계 준수(framework만 추적, target-owned 미추적)
- [x] cascade 점검: scaffold 변경 → user-facing(README §10 `--check` 안내) 정합
- [x] OQ-10 closure 기록(부모 Work OQ 표 — normalized source-template hash, DR 신설 안 함)
- [x] (R21 P1) invalid manifest → exit 2 통제: framework_files 키 필수 + entry 0 검출. malformed 2케이스 exit 2 확인
- [x] (R21 P2) `.claude/settings.json` manifest 미추적을 의도된 B-class seed로 Work 명시(D-7)

## Verification

- `bash -n scripts/create-harness.sh` + `sh -n`
- default·`--with-optional` temp 생성 → `.harness/manifest.json` 형식·framework set 확인
- `--check` 자기일관성: 갓 생성 target → drift 0
- `--check` 민감도: source framework 파일 1개 수정 후 → 그 파일만 source-updated
- `scripts/tests/check-scaffold-invariants.sh` 양쪽 모드 PASS(회귀 없음)
- `git diff --check`

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Work 파일 + plan 작성, Codex 검토 대기 | Done |
| CP1 | PQ-1~4 합의(Codex round R20) | Done |
| CP2 | A(VERSION 0.2.0) + B(manifest 생성, adapt 파생) 구현 | Done |
| CP3 | C(`--check` 모드, forward-render) 구현 | Done |
| CP4 | D(1b [5] 검증) + 자기일관성/민감도/untracked 검증 + cascade(README §10) | Done |
| CP5 | Codex 결과 검토(R21) → /close → commit → PR | Done |

## Cross-Agent Review And Discussion

이 섹션은 Claude↔Codex가 이 slice 계획을 검토/논쟁/합의하는 SSoT다.
Round는 Round Log에 누적, 합의는 Consensus Log, 미해결은 Plan-Level Open Questions에 둔다.

### Round Log

| Round | 주체 | 요지 | 반영 |
| --- | --- | --- | --- |
| R19 | Claude | Q4 최소 경로 plan 초안: version 소스 / manifest(adapt 파생) / `--check`(normalized hash) / 검증 hook. PQ-1~4 제기 | 본 문서 |
| R20 | Codex | PQ-1/2/4 동의, PQ-3 조건부(source-updated 필수 + locally-modified best-effort). schema 필드 추가, `--check` status 확장(source-missing), exit code 정책, missing-manifest report, sed escaping 주의 | Plan A/B/C·PQ status·Consensus |
| R21 | Codex | 구현 결과 검토: D-1(forward-render)·D-2(diverged 제거)·D-3(+src) 동의. P1(invalid manifest exit 2 미통제) + P2(`.claude/settings.json` 미추적 의도 확인) 지적. 양쪽 모드+민감도+exit 케이스 재검증 PASS | D-6(P1 fix)·D-7(P2 문서화)·Consensus |

(R-번호는 Phase 2 cross-agent 연속 카운터. slice #9가 R18에서 종료.)

### Codex Result Review (R21)

- **D-1/D-2/D-3 전면 동의.** Codex 재검증: target 수정 1건만 locally-modified, source mismatch 1건 source-updated, missing manifest exit 3.
- **P1(고침):** invalid manifest(version+project만, framework_files 없음)가 `grep '"sha256"'` + `set -e`로 exit 1 abort → exit 2/legible 실패로 통제 필요. → D-6 적용.
- **P2(의도 확정):** `.claude/settings.json`(write_text 생성)이 manifest 미추적. DR-021 A-class가 settings/hooks 포함하나, target 커스터마이즈 seed 성격으로 의도된 B-class 제외임을 Work에 명시. `.codex/hooks.json`(adapt) 추적과의 비대칭은 follow-up 후보. → D-7 기록.

### Codex Plan Review (R20)

- **PQ-1:** 동의. OQ-10을 normalized source-template hash로 closure. DR 신설 불필요(DR-021/023 하류 구현). 단 `--upgrade`/merge policy까지 가면 별도 DR 후보.
- **PQ-2:** 동의. VERSION 파일 > script 상수/git describe. 초기값 `0.2.0`.
- **PQ-3:** source-updated=primary, locally-modified=best-effort advisory, 동시=diverged. reverse-normalize는 framework file을 target이 수정한 사실 포착에 유용하나 **project name의 sed/regex 특수문자 escaping 필수**.
- **PQ-4:** 동의. adapt() 파생 file list. 검증: manifest 존재 + JSON shape 최소 + default/optional set 차이 + 자기일관성(갓 생성 source-updated 0) + source 1개 수정 시 그 파일만 source-updated. 과한 file-list 계약 테스트는 deferred(#13 canonical 후 변경 가능).
- **schema:** `manifest_version:1`, `hash_algorithm:sha256`, `hash_mode:normalized_source_template`, `source_identity` 추가. target-owned 목록·B-class hash·upgrade policy·rename mapping은 제외.
- **--check 모델 허점 3:** ① missing manifest → fail 아님, "untracked/pre-manifest" report. ② exit code: invalid/missing=nonzero, drift=0+summary, CI hard mode는 하류. ③ `source-missing` status 지금 넣기(#13 rename/삭제 대비).

### Plan-Level Open Questions

| ID | Question | 결정 | Status |
| --- | --- | --- | --- |
| PQ-1 (OQ-10) | manifest hash 기준 | **normalized source-template hash**. OQ-10 closure, DR 신설 불필요(R20) | Resolved(R20) |
| PQ-2 | harness version 소스 | 루트 **`VERSION` 파일**, 초기값 `0.2.0`(R20) | Resolved(R20) |
| PQ-3 | `--check` 비교 범위 | source-updated=primary 필수, locally-modified=best-effort advisory, diverged/source-missing status 포함. reverse-normalize sed escaping 필수(R20) | Resolved(R20) |
| PQ-4 | manifest 파생 + 검증 | adapt() 파생 file list, 검증 5항목, 과한 계약 테스트 deferred(R20) | Resolved(R20) |

### Consensus Log

- **R21 합의(구현 결과):** D-1(forward-render)·D-2(diverged 제거)·D-3(+src 필드) 동의. P1 수정(invalid manifest→exit 2, framework_files 키 필수 + entry 0 검출). P2는 `.claude/settings.json`=의도된 B-class seed로 Work 명시(settings/hooks 추적 일원화는 follow-up). 1b 양쪽 모드+민감도+exit 케이스 모두 PASS.
- **R20 합의:** PQ-1=normalized source-template hash(OQ-10 closure), PQ-2=VERSION 파일 0.2.0, PQ-3=source-updated primary + locally-modified advisory(escaping 주의) + source-missing/diverged status, PQ-4=adapt() 파생 + 검증 5항목. schema에 manifest_version/hash_algorithm/hash_mode/source_identity 추가. missing manifest는 report(untracked), exit code invalid/missing=nonzero·drift=0. `--upgrade`는 deferred.

## Discovery

- **D-1 (PQ-3 구현 수정 — 핵심): reverse-normalize는 흔한 project-name substring을 과치환.** target 파일을 `PROJECT_NAME→ai-workflow-harness` 역치환해 hash 비교하려 했으나, 짧은/흔한 이름(예 `mp`)은 `example`/`temp`/`comp` 등 자연 등장 substring까지 치환해 **48/56 false positive**. → **forward-render 비교**로 교체: source 미변경 시 현재 template을 `ai-workflow-harness→project_name`(scaffold adapt와 동일 치환)로 렌더해 target과 hash 비교. 신뢰 가능. 검증: 자기일관성 56/0, target 1개 수정 시 정확히 1개 locally-modified.
- **D-2: `diverged` status 제거.** forward-render 방식에선 source-updated와 locally-modified를 at-generation snapshot 없이 동시 분리 불가. source 변경 시 local edit를 깨끗이 떼어낼 수 없어 **source-updated를 primary로 우선** 보고. status = in-sync/source-updated/locally-modified/source-missing/target-missing(diverged 제외).
- **D-3 (schema 확장): `framework_files`에 `src` 필드 추가.** Codex schema `{path, sha256}`에서 `{path, src, sha256}`로 확장. `git-workflow.md`(generic은 `scripts/templates/default/...`에서 복사)·`GIT-WORKFLOW.md`(source-gitflow)처럼 **target relpath ≠ source relpath**인 파일을 `--check`가 재-hash할 anchor가 필요. path=target-relative, src=template-relative.
- **D-4: framework file 자동 식별 검증.** adapt() 누적으로 default 56 / `--with-optional` 74 framework 파일(차이 18 = docs 3 + prompt 13 + companion DR 2). manifest의 `hash_algorithm: "sha256"` 메타라인도 "sha256" 포함이라 단순 `grep -c '"sha256"'`은 +1 오차 — do_check 루프는 `"path"` 필터로 정확.
- **D-5 (set -u): `${VAR:=$(mktemp)}` 인라인 할당이 `set -u`와 충돌.** `check_list`를 명시 `local` 선언으로 분리.
- **OQ-10 closure:** normalized source-template hash로 확정, 부모 Work OQ 표 Resolved 기록, DR 신설 안 함.
- **D-6 (R21 P1 fix): invalid manifest가 exit 2로 통제되지 않았음.** `field` 검증이 harness_version/project_name만 보고, 이후 `grep '"sha256"'`가 `set -e` 하에서 매치 0이면 exit 1로 abort(문서화된 invalid=2 아님, summary 없음). → ① 검증에 `"framework_files"` 키 필수 추가, ② entry 선택을 `grep '"path"'`(metadata 라인 회피)로 바꾸고 `|| true` 가드, ③ entry 0이면 invalid(return 2). 두 malformed 케이스 모두 exit 2 확인.
- **D-7 (R21 P2 의도 확정): `.claude/settings.json`은 manifest 미추적 — 의도된 B-class seed.** write_text로 inline 생성되며 target이 permission/hook을 스택별로 커스터마이즈하는 project-state 성격(STATUS/PLAN seed와 동일). 따라서 framework drift 추적 대상에서 제외가 맞다. `.codex/hooks.json`은 정적 template라 adapt()로 복사되어 추적되는 비대칭이 있으나, 이는 "복사 template = 추적, inline 생성 = target seed"라는 현재 경계의 결과. 완전한 settings/hooks 추적 일원화(예: settings.json을 template로 이동하거나 hooks.json을 write_text로 전환)는 minimal Q4 범위 밖 → 후속 후보. manifest는 "복사된 framework template"을 추적한다는 경계로 본 slice 확정.
