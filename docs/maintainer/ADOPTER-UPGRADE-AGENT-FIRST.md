# ADOPTER-UPGRADE-AGENT-FIRST.md (source-only)

manifest 보유 adopter repository를 released source baseline으로 올릴 때의 **default entry**다.
이 문서는 `ai-workflow-harness` **source repo 전용**이며 scaffold target으로 배포되지 않는다.

이 경로는 절차 문서가 아니라 **계약 + gate + 최소 체크리스트**다. 실행 방법의 세부는 agent가 manifest 계약과 검증 도구(`--check`)로부터 스스로 도출한다 — 이 방식은 heterogeneous replay(ai-deck 1.3.0→1.4.0)와 fresh-session canary(toolstead 1.4.0→1.5.0, playbook 미제공, `--check` 83/83/0, 질문 0회)로 검증됐다.

## Entry Conditions

**route 판정의 SSoT** — 상위 진입점(maintainer README·`SOURCE-REPO-OPERATIONS.md` §G·Layer T)은 판정식을 재열거하지 않고 이 섹션을 가리킨다.

**판정식: 아래 4개 조건 전부 충족 AND Fallback override 해당 없음 → default(이 문서). 그 외 전부 → fallback(playbook).**
기술 조건 4개를 충족해도 ownership 불확실·고위험·blocker 등 아래 Fallback 절에 해당하면 fallback이다.

- target에 `.harness/manifest.json`이 있다 (manifest target)
- source baseline이 released tag다 (DR-028 — `docs/maintainer/VERSIONING.md`)
- `bash scripts/create-harness.sh --check <target>`이 실행 가능하다 (python3 필요 — fail closed)
- target working tree가 clean이다 (dirty면 owner 명시 승인 전 중단)

**Fallback → `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`:**
pre-manifest target(baseline acquisition부터 필요), external manual adopter, ownership 분류가 불확실한 target, `--check` 실행 불가 또는 판정 실패, 진행 중 policy/index/namespace blocker 발생(playbook Phase 7), temp rehearsal이 필요하다고 판단되는 고위험 변경. fallback 경로는 unobserved residual(비오염 operator·external manual·pre-manifest)을 위해 유지된다 — 이 경로들의 폐기 evidence는 없다.

## Non-Negotiable Gates (4)

체크리스트를 어떻게 수행하든 이 4개는 생략 불가다.

| Gate | 내용 |
| --- | --- |
| ① Source ref 고정 | released tag 기준 **tag-pinned git worktree**로 source bytes를 고정한다. `develop`/current checkout 비교는 pre-release tracking 예외로만 라벨링 |
| ② Ownership/보존 분류 | 모든 변경 파일이 분류에 매핑된 뒤에만 쓴다 — **미분류 overwrite 금지**. 로컬 수정(accepted-drift)은 보존이 기본, 애매하면 목록 보고. 분류 어휘·adapt-render trap·DR-043 값 보존 gate는 playbook Phase 4 |
| ③ Post-hoc `--check` | 적용 + rebaseline 후 **clean tag worktree 기준** `--check`로 독립 재검증. 해석 규칙·manifest field 계약(provenance/hash_mode/generated_at)은 playbook Phase 6 |
| ④ Owner sign-off | 변경/보존/불확실 목록 보고 → 승인 후 write. commit/PR은 target `docs/GIT-WORKFLOW.md`를 따름 |

## Minimum Checklist (manifest-target upgrade)

1. **Probe (read-only):** target branch/상태·manifest 확인, 현재 `--check` 기록 (아직 proof 아님). 명령 카탈로그: `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T (T0).
2. **Source 고정:** old/new released tag 각각 tag-pinned worktree 생성 (gate ①).
3. **비교·분류:** 현재 target vs old tag vs new tag 3-way **내용** 비교로 framework-owned 파일 식별 (identity 치환 감안). manifest hash 세대가 다르면 hash 비교 대신 내용 비교로 전환한다 (hash_mode 계약: playbook Phase 6).
4. **보존 판단:** 로컬 수정·accepted-drift 식별 → 변경/보존/불확실 목록 작성 (gate ②).
5. **Sign-off:** 목록 보고 → owner 승인 (gate ④) → target feature branch에 적용.
6. **Rebaseline:** 새 tag 기준 shadow scaffold(동일 project-name/profile/workflow)로 새 manifest 획득·이식 — provenance(`source_ref`/`source_commit`/`source_dirty`)가 released tag를 가리키는지 확인.
7. **재검증:** clean tag worktree 기준 post-hoc `--check` (gate ③) — 기대: 의도한 accepted-drift만 drifted, `source-updated` 0, version-skew WARN 없음.
8. **기록:** 결과 요약은 playbook Minimal Report Template, source closeout은 playbook Phase 10 기준.

## Evidence Boundary

- **검증된 범위:** manifest 보유 heterogeneous target의 agent-first upgrade (ai-deck replay — accepted-drift 13/13 보존 + toolstead fresh-session canary — 계약·도구만으로 전 과정 자가 수행).
- **검증되지 않은 범위:** pre-manifest baseline acquisition, external manual adopter UX, 비오염 operator의 process 효율 일반화. evidence 축 구분: fallback 경로에는 fresh-session agent-first evidence가 없고 informed-driver walkthrough evidence(초기 ai-deck walkthrough)만 있다. 이 경로들은 playbook이 fallback으로 담당한다.
