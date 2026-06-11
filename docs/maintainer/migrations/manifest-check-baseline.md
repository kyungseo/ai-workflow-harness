# Manifest Check Baseline Migration

이 문서는 CHORE-20260605-006에서 도입된 `.harness/manifest.json` / `scripts/create-harness.sh --check` baseline을 pre-manifest target repo가 수용할 때 참고하는 migration note다.

## Summary

- pre-manifest target에는 `.harness/manifest.json`이 없으므로 `--check`는 drift를 계산하지 못한다.
- target의 framework-owned surface를 먼저 inventory하고, 같은 project-name/workflow/profile의 shadow scaffold에서 current source manifest를 획득한다.
- shadow manifest를 target copy에 먼저 심고 `--check`로 실제 drift 분포를 관측한 뒤, `framework_files[].path`를 기준으로 framework-owned 파일을 selective migration한다.
- target-local product state는 자동 overwrite하지 않는다.
- baseline 심기 후 첫 `--check`는 drift 분포가 나올 수 있다. drift 0을 강제하지 않고, framework drift와 accepted project-owned drift를 분류해 기록한다.

## Applicability

이 note는 아래 조건에 해당하는 target에 적용한다.

- 이미 harness가 적용되어 있으나 `.harness/manifest.json`이 없다.
- `scripts/create-harness.sh --check <target>`가 `untracked target / pre-manifest scaffold`로 종료한다.
- target이 product-specific workflow, skill, command, docs, decision record를 보유할 수 있다.

적용하지 않는 경우:

- manifest가 이미 있고 `--check`가 정상 report를 낸다.
- 새 프로젝트에 처음 harness를 overlay하는 경우. 그 경로는 `--existing` 또는 신규 scaffold다.

## Migration Steps

1. **Read-only inventory**
   - target의 `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.agents/skills/`, `.cursor/rules/`, `skills/`, `prompts/`, core docs, product docs를 읽기 전용으로 분류한다.
   - framework-owned 후보와 project-owned/customized 후보를 분리한다.
2. **Shadow scaffold 생성**
   - source repo에서 target과 같은 project-name, workflow, profile로 fresh scaffold를 만든다.
   - project-name은 반드시 일치해야 한다. `adapt()`가 project-name을 치환하므로 이름이 다르면 hash 비교가 오염된다.
3. **Framework-owned 파일 selective migration**
   - 먼저 shadow scaffold의 `.harness/manifest.json`만 target copy에 심고 `--check`를 실행해 drift 분포를 관측한다.
   - shadow scaffold의 `.harness/manifest.json` `framework_files[].path`를 기준으로 파일별 반영 여부를 판단한다.
   - target customization이 의심되는 파일은 overwrite 전에 diff를 보고 accepted drift 또는 manual merge로 분류한다.
4. **Manifest baseline 심기**
   - manifest baseline은 drift 관측 전에 먼저 추가한다.
   - `.harness/gate-config`는 project-owned add-only 파일이므로 자동 overwrite하지 않는다.
5. **Project-owned index 보강**
   - target에 product DR이 있으면 `docs/decisions/README.md` index closure를 맞춘다.
   - `docs/STATUS.md`, `docs/PLAN.md`, backlog, Work 파일은 target state이므로 source scaffold 내용으로 덮지 않는다.
6. **Verify**
   - `scripts/create-harness.sh --check <target>`로 framework drift를 확인한다.
   - `scripts/tests/check-scaffold-invariants.sh <target>`로 source-only leakage, DR/index closure, manifest 자기일관성을 확인한다.

## ai-deck-compiler Probe (2026-06-11)

read-only 실측:

- `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/.harness/manifest.json` 없음.
- `scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/ai-deck-compiler` 결과: `untracked target / pre-manifest scaffold`, exit 3.
- `docs/GIT-WORKFLOW.md`에 `policy_type: source-gitflow` marker 있음.
- project-name은 `package.json` 기준 `ai-deck-compiler`.

temp simulation:

- target copy: `temp/chore-20260611-010/ai-deck-copy`
- shadow scaffold: `temp/chore-20260611-010/ai-deck-shadow`
- shadow options: project-name `ai-deck-compiler`, `--workflow source-gitflow`, `--profile generic`
- manifest tracked files: 76.
- manifest만 심은 첫 `--check`: `76 tracked, 9 in-sync, 67 drifted` (`target-missing` 37, `locally-modified` 30).
- 1차 selective 반영: `target-missing` 37개 신규 framework 파일 복사.
- 2차 selective 반영: hard invariant를 깨는 locally-modified 3개(`docs/HARNESS-NAMING-RULES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`)와 project-owned decision index 보강.
- 중간 `--check`: `76 tracked, 49 in-sync, 27 drifted`.
- 남은 27개는 manifest-tracked locally-modified manual-merge/copy candidates로 분류. temp simulation에서는 current framework baseline으로 반영해 최종 검증.
- 최종 `--check`: `76 tracked, 76 in-sync, 0 drifted`.
- invariant first run: `docs/decisions/README.md` 부재로 FAIL.
- target-local accepted DR rows(DR-021~023)을 README index에 등록한 뒤 invariant PASS.

## Accepted Drift Recording

target migration Work는 아래 표를 남긴다.

| Path | Classification | Action | Reason |
| --- | --- | --- | --- |
| `path/to/file` | framework-owned / project-owned / customized | copied / merged / accepted drift / skipped | 근거 |

`accepted drift`는 실패가 아니다. 다만 다음 upgrade에서 다시 판단할 수 있도록 이유를 기록한다.
