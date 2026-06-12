---
id: CHORE-20260612-003
priority: P1
status: Done
risk: L2
scope: scaffold 후 첫 외부 contributor가 source context 없이 clone했을 때의 로컬 온보딩 마찰을 측정한다. local bare remote를 사이에 두고 두 사용자 흐름(hook 설치, branch/push 경로)을 검증하고, PR/ruleset/CI는 local 재현 불가 항목으로서 문서 gap만 inventory한다. 결과는 P0 gate series, onboarding refresh, maintainer operations, migration follow-up 중 적합한 곳으로 연결한다. 문서 수정은 범위 밖이며 발견물은 후속 Work로 연결한다.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-020, DR-021]
related_work: [CHORE-20260606-008, CHORE-20260606-010, CHORE-20260606-011, CHORE-20260606-015]
---

# CHORE-20260612-003: Scaffold Multi-User Clone Verification

## Top Summary

- **목표:** scaffold 후 첫 외부 contributor가 source context 없이 clone했을 때의 로컬 온보딩 마찰을 측정한다. local bare remote 기반 두 사용자 시뮬레이션으로 hook 설치·branch·push 경로를 검증하고, 발견된 gap을 후속 Work에 연결할 evidence로 확보한다.
- **이 Work의 진짜 가치:** GitHub gate 검증이 아니라, 첫 외부 contributor가 README/GUIDE만 보고 hook/branch 경로를 찾을 수 있는지 — 즉 로컬 온보딩 마찰 측정이다.
- **왜 지금:** W2 Adopter Transition의 마지막 항목. upgrade/migration(CHORE-20260611-010), docs cascade(CHORE-20260611-011), planning pack(CHORE-20260612-001), readability rewrite(CHORE-20260612-002)가 모두 완료됐다. clone 경로의 실 마찰을 측정하지 않으면 다음 product 적용 시 첫 번째 contributor가 blind spot에 부딪힌다.
- **핵심 경계:** discovery + gap 식별이 이 Work의 전부다. 발견물을 이 Work 안에서 수정하지 않는다. PR/ruleset/CI는 "검증"이 아닌 "remote-only gap inventory"로 다룬다.

## Background / Facts

- backlog 정의: "source-gitflow target과 generic/hook-less target을 분리해 검증하고, 결과는 P0 gate series 또는 onboarding refresh에 흡수한다."
- Done Criteria (backlog): "fresh scaffold → git init/remote/clone → 두 사용자 작업 → PR/check/manual gate 경로의 위험과 문서 gap을 식별하고 필요한 후속 Work로 연결"
- hook 설치는 per-clone 수동 실행(`tools/git-hooks/install-hooks.sh`)이며, 신규 contributor가 이를 알 수 있는 경로가 문서에 명확한지가 핵심 질문이다.
- `git clone <path>` 직접 clone은 origin 설정, 기본 branch 추적, push 대상, remote-first branch 생성 같은 실제 협업 마찰을 재현하지 못한다 (R0 지적). `git init --bare`를 bare remote로 두고 User A push → User B clone → branch/push 흐름으로 충실도를 올린다.
- GitHub branch ruleset/CI는 local에서 재현 불가 — "remote-only gap inventory"로 다룬다.
- temp/ 정책: Tier 2 simulation은 `temp/harness-tests/<scenario>-<ts>/` 에 생성 → 검증 → cleanup (`docs/maintainer/HARNESS-TEST-TAXONOMY.md §5`).

## Scope / Plan

> R0 review 반영 후 확정된 plan.

### 검증 매트릭스

**범주 A — local 검증 (bare remote 포함)**

| 검증 항목 | 대상 | 방법 |
| --- | --- | --- |
| scaffold 생성 | source-gitflow, generic | `create-harness.sh` smoke |
| bare remote 설정 + User A 초기 push | 두 target 모두 | `git init --bare`, `git push origin` |
| User B clone + remote tracking | 두 target 모두 | `git clone <bare-remote>`, branch tracking 확인 |
| hook 설치 (source-gitflow) | source-gitflow | User B clone 후 `install-hooks.sh` 실행 확인 |
| hook 미설치 상태 commit | source-gitflow | pre-commit/commit-msg bypass 동작 확인 |
| commit-msg 포맷 강제 | source-gitflow | 잘못된 메시지로 commit 시도 |
| User B 첫 push (branch tracking) | 두 target 모두 | `git push -u origin <branch>` 흐름 확인 |
| `--check` flag (pre-manifest) | generic | `create-harness.sh --check` 동작 확인 |
| advisory 메시지 (hook-less) | generic | onboarding 문서 + install-hooks.sh 경로 확인 |
| **blind onboarding pass** | 두 target 모두 | README/GUIDE만 보고 hook/branch 경로 발견 가능한지 점검 |

**범주 B — remote-only gap inventory (local 재현 불가)**

| 항목 | 이유 | 조사 방법 |
| --- | --- | --- |
| protected branch push 차단 | GitHub ruleset 필요 | 온보딩 문서에 설정 안내 여부 확인 |
| CI check (required status check) | GitHub Actions 필요 | CI 설정 파일 존재 여부 + 문서 언급 확인 |
| PR review + merge | GitHub repo 필요 | GUIDE의 PR 절차 안내 명확성 확인 |

### 실행 단계

1. ~~Codex R0 plan review~~ — 완료 (2026-06-12)
2. **scaffold 생성** (temp/)
   - `temp/harness-tests/clone-vfy-source-gitflow-<ts>/`
   - `temp/harness-tests/clone-vfy-generic-<ts>/`
3. **bare remote 생성 + User A 초기 설정**
   - `git init --bare temp/harness-tests/bare-<target>-<ts>.git`
   - User A: scaffold dir을 remote에 연결, hook 설치, 첫 commit + push
4. **User B clone 시뮬레이션**
   - bare remote로부터 clone, remote tracking 확인
   - hook 설치 시도 (설치 안내 경로 확인)
   - feature branch 생성, commit, first push (`git push -u origin <branch>`)
5. **blind onboarding pass** — README/GUIDE만 보고 hook/branch/push 경로를 찾을 수 있는지 별도 점검
6. **remote-only gap inventory** — 온보딩 문서에서 protected branch/CI/PR 안내 명확성 확인
7. **발견물 정리** — gap/risk를 Critical/Advisory/Deferred로 분류
8. **Codex R1 result review** — 발견물과 후속 Work 연결이 적정한지 검토
9. **후속 Work backlog 등록** (해당 시)
10. **cleanup + work-close**

### 파일 범위

| 파일 | 역할 |
| --- | --- |
| `temp/harness-tests/clone-vfy-*/`, `temp/harness-tests/bare-*.git/` | 시뮬레이션 작업 — cleanup 대상 |
| 이 Work 파일 | findings 기록 SSoT |
| `docs/backlog/HARNESS.md` | 후속 Work 등록 (해당 시) |
| `docs/STATUS.md` | Active Work pointer (등록 완료) |

**수정하지 않는 파일**: 발견된 gap 대상 문서 일체 — 후속 Work 범위

## Done Criteria

- [x] source-gitflow target: scaffold → bare remote → User A push → User B clone → hook 설치 → commit 강제 → first push 경로 검증 완료
- [x] generic target: scaffold → bare remote → User B clone → hook-less advisory → `--check` 동작 검증 완료
- [x] blind onboarding pass: README/GUIDE만으로 hook/branch/push 경로 발견 가능한지 확인
- [x] remote-only gap inventory: PR/ruleset/CI 문서 안내 명확성 확인 (실행 검증 아님)
- [x] 발견된 gap/risk를 분류하고 근거를 기록
- [x] Critical finding이 있으면 finding 성격에 맞는 후속 Work로 연결 (G1/G2 → "source-gitflow second-contributor entry path 보강" backlog 등록)
- [x] Codex R1 review 완료, review 결과 Round Log에 기록

## Findings

> 검증 방법: `temp/harness-tests/` 하위에 두 target scaffold → `git init --bare` bare remote → User A push → User B clone → hook 설치 시도 → commit/push 시뮬레이션. 2026-06-12 실행.

### source-gitflow target

**검증 경로:** scaffold → bare remote → User A (`git init` + hook install + push) → User B (`git clone` + hook 미설치 commit → hook 설치 → commit 강제 → feature branch push)

| 항목 | 결과 | 비고 |
| --- | --- | --- |
| scaffold 생성 | ✓ | `tools/git-hooks/` 포함 (commit-msg, pre-commit, install.sh, lib/) |
| bare remote + User A push | ✓ | `git init --bare` → push works |
| User B clone + remote tracking | ✓ | `git clone` 후 `origin/main` 추적 정상 |
| hook 미설치 상태 비규격 commit | **통과** (위험) | hooks dir 비어있어 강제 없음 |
| hook 설치 (`sh tools/git-hooks/install.sh`) | ✓ | clear output, commit-msg + pre-commit 설치됨 |
| hook 설치 후 비규격 commit 차단 | ✓ | exit 1, 명확한 오류 메시지 |
| hook 설치 후 규격 commit 통과 | ✓ | |
| User B feature branch + first push | ✓ | `git push -u origin feature/test-userb` remote tracking 정상 |
| `--check` 출력 | ✓ | `hook-capable (... run tools/git-hooks/install.sh to activate)` |

### generic target

| 항목 | 결과 | 비고 |
| --- | --- | --- |
| scaffold 생성 | ✓ | `tools/` 없음 (hook-less 정상) |
| User B clone + remote tracking | ✓ | |
| hook-less 상태 비규격 commit | 통과 (기대 동작) | honor-system advisory |
| advisory 메시지 (README) | ✓ | README 61-62줄에 명시: "hook을 설치하지 않는다... advisory" |
| `--check` 출력 | ✓ | `advisory-only (no hook files)` 명확 |

### Gap / Risk 목록

| # | 분류 | 대상 surface | 내용 | 흡수 후보 |
| --- | --- | --- | --- | --- |
| G1 | **Critical** | scaffold target README.md, docs/GIT-WORKFLOW.md §0-1 | **entry-path discoverability failure**: README는 첫 세션과 bootstrap만 안내하고 hook install을 직접 가리키지 않음. BOOTSTRAP.md는 "source-gitflow면 GIT-WORKFLOW §0-1을 따르라"는 pointer만 있음. 실제 hook 설치 명령은 GIT-WORKFLOW §0-1에 있지만 "Clone from existing remote" 시나리오가 없어 second-contributor가 enforcement 활성화 경로를 blind onboarding 상태에서 찾기 어려움. 결과: 비규격 commit이 무음 통과 | source-gitflow second-contributor entry path 보강 |
| G2 | **Critical** | docs/GIT-WORKFLOW.md §0-1 | "Fresh repo"(초기 설정자)와 "Existing repo"(overlay 적용자) 분기는 있으나 **"Clone from existing remote"**(두 번째 contributor) 경로가 없음. Existing repo 섹션은 이미 repo 안에 있다는 전제로 `git status`, `git remote -v` 부터 시작하므로 clone 진입 경로와 맥락이 다름. 최소 보강: §0-1에 clone 하위 절 또는 note | source-gitflow second-contributor entry path 보강 |
| G3 | Advisory | docs/GIT-WORKFLOW.md §0-1 | `develop` push 누락 시 User B clone에 `develop` 없음. §0-1 Fresh repo 절차에 push develop이 포함돼 있으나(구조적 blocker 아님), bootstrap 검증 단계가 없어 운영 실수 리스크로 남음 | source-gitflow second-contributor entry path 보강 |
| G4 | Advisory | scaffold target README.md | GitHub Ruleset 설정·CI required check 활성화 안내가 README에 없음. GIT-WORKFLOW.md §GitHub Ruleset에 문서화됨. CI 파일(`.github/workflows/harness-validate.yml`) 존재. remote-only 설정이므로 Critical 아님 | onboarding refresh (별도 scope) |
| G5 | Deferred | scripts/create-harness.sh | `project-name`에 `/` 포함 시 `sed` delimiter 충돌(`sed: bad flag in substitute command: h`). "잘못된 사용"에서만 발생. 이번 Work 핵심 narrative와 분리 — maintainer ops / script hardening 후보 | maintainer operations (별도) |

> **G5 분리 근거 (R1 반영):** clone verification의 핵심 산출물과 직접 연결되지 않고 narrative를 흐릴 수 있다. 별도 추적.

### 검증 한계 — 시뮬레이션에서 다루지 않은 시나리오

**Bootstrap 완료 후 later-contributor 경로 (미검증):**
이번 시뮬레이션은 "fresh scaffold 직후" User B clone에 가깝다. 실제 multi-user friction은 아래 순서에서 더 선명하게 드러날 수 있다:
1. 첫 maintainer가 bootstrap 완료
2. `docs/STATUS.md`에서 bootstrap pointer 제거
3. **그 후 User B clone**

이 시나리오를 검증하지 않으면 BOOTSTRAP.md의 온보딩 기여도를 과대평가할 수 있다. G1/G2 후속 Work에서 이 경로도 커버하는지 확인 필요.

### Remote-only gap inventory (local 재현 불가)

| 항목 | 이유 | 문서 gap |
| --- | --- | --- |
| GitHub branch ruleset (protected branch push 차단) | GitHub repo 없음 | Advisory — GIT-WORKFLOW.md §GitHub Ruleset에 문서화됨, README 미언급 (G4와 연계) |
| GitHub Actions CI check (required status check) | runner 없음 | Advisory — `.github/workflows/harness-validate.yml` 존재, 활성화 방법 README 미언급 (G4와 연계) |
| 실제 PR review + merge | GitHub repo 없음 | GIT-WORKFLOW.md §2에 PR base rule 문서화됨. README 직접 언급 없음 |

## Round Log

### R0 — Plan Review (Codex, 2026-06-12)

**Review 결과:** 조건부 승인 보류. (1) `git clone <path>` local 시뮬레이션은 origin 설정·branch tracking·push 대상 같은 실제 협업 마찰을 재현하지 못함. (2) Top Summary/Done Criteria가 PR/ruleset/CI "검증"을 약속하지만 같은 문서가 local 재현 불가를 인정하는 모순이 있음. (3) 후속 Work 흡수처가 "P0 gate series / onboarding refresh"로만 좁혀져 있어 findings 분류 왜곡 가능. (4) "W2 마지막 항목"은 순서 설명이지 필요성 설명이 아님 — 진짜 가치는 "첫 외부 contributor의 로컬 온보딩 마찰 측정"으로 고정해야 함. (5) blind onboarding pass와 bare remote branch tracking이 매트릭스에서 빠짐.

**수용/반영 내용:** 5개 포인트 전부 수용. (1) `git init --bare` 기반 bare remote로 시뮬레이션 충실도 상향. (2) PR/ruleset/CI를 "검증"에서 "remote-only gap inventory"로 격하, 매트릭스 범주 A/B 분리. (3) 후속 Work 연결 대상을 maintainer operations / migration follow-up까지 확장. (4) Top Summary에 "진짜 가치" 한 줄 고정. (5) blind onboarding pass + bare remote branch tracking 항목 추가.

---

### R1 — Result Review (Codex, 2026-06-12)

**Review 결과:** G1/G2는 유지 가능하나 "완전 누락"보다 "entry-path discoverability failure"로 재서술 필요. G2는 Existing repo 섹션으로 완전 대체되지 않음 — "Clone from existing remote" 하위 절이나 note가 필요. G3/G4는 Advisory 유지. G5는 이 Work 핵심 narrative와 무관 — Deferred 분리 권고. Done Criteria가 현재 분류를 미리 고정하는 구조는 수정 필요. 빠진 시나리오: "bootstrap 완료 후 later-contributor clone" 경로가 미검증이며, 이를 무시하면 BOOTSTRAP.md 중요도를 과대평가할 수 있음.

**수용/반영 내용:** 5개 포인트 전부 수용. (1) Done Criteria 일반화 — 분류 선행 고정 제거. (2) G1 재서술: "완전 누락" → "entry-path discoverability failure", CLAUDE.md surface 제거, BOOTSTRAP.md 역할 재정의. (3) G5 Deferred 분리 + 분리 근거 명시. (4) 후속 Work를 "source-gitflow second-contributor entry path 보강"으로 좁게 정의. (5) "bootstrap 완료 후 later-contributor" 미검증 시나리오를 검증 한계 섹션에 기록.
