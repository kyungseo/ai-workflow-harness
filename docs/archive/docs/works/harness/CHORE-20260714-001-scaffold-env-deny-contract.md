---
id: CHORE-20260714-001
priority: P2
status: Done
risk: L2
scope: UF-08의 scaffold env read deny wildcard를 secret-file contract와 정합화하고 fixture gate로 고정한다.
appetite: 1d
planned_start: 2026-07-14
planned_end: 2026-07-14
actual_end: 2026-07-14
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260713-001]
---

# CHORE-20260714-001: Scaffold Env Deny Contract

## Top Summary

Source와 scaffold가 생성하는 Claude settings의 `Read(./.env.*)` broad deny를 `.env`, `.env.local`, `.env.*.local` exact secret-file contract로 교정한다. Committed sanitized `.env.example`은 readable이어야 하며, source와 실제 scaffold target 모두 같은 negative/positive fixture matrix를 통과해야 한다. Spring product-local 교정은 evidence로만 사용하고 해당 repository 파일은 변경하지 않는다.

## Context Manifest

| 순서 | 파일 | 역할 |
| --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | UF-08 scope·fixture gate SSoT |
| 2 | `.claude/settings.json` | source tool permission surface |
| 3 | `scripts/create-harness.sh` | adopter scaffold settings 생성 owner |
| 4 | `.gitignore` | secret env filename contract |
| 5 | `scripts/tests/` | deterministic source/scaffold verification spine |
| 6 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | test tier와 runner boundary |

Trigger: backlog의 `Scaffold .env deny wildcard 교정 quick-fix (UF-08, fixture gate 필수)` candidate 착수 / spring product-local correction evidence upstream 반영.

## Scope

- Source `.claude/settings.json`과 `scripts/create-harness.sh` 생성 settings를 동일한 exact deny contract로 정렬한다.
- Secret env negative fixtures와 sanitized `.env.example` positive fixture를 JSON pattern-level deterministic assertion으로 추가한다.
- Source settings는 Tier 0, 실제 생성 target은 scaffold invariant에서 검증한다.
- `docs/WORKFLOW-MANUAL.md` permission 예시와 maintainer test taxonomy/catalog를 current truth로 정렬한다.

### Non-Target

- `.env` 또는 다른 secret 파일 내용 읽기
- 별도 `.env.production` convention 신설
- Claude Code permission engine 자체의 runtime integration test 주장
- spring-modular-template 파일 변경
- UF-01·UF-06 또는 다른 W6 후보 구현
- 완료 Work archive

## Done Criteria

- [x] Source와 scaffold settings가 `.env`, `.env.local`, `.env.*.local`을 deny한다.
- [x] `.env.example` fixture는 broad wildcard에 차단되지 않고 readable 판정을 받는다.
- [x] Source settings와 generic/optional/source-gitflow scaffold가 같은 fixture matrix를 통과한다.
- [x] WORKFLOW-MANUAL과 maintainer verification 문서가 6번째 invariant를 current truth로 설명한다.
- [x] focused fixture, syntax, full harness validation과 `git diff --check`가 통과한다.
- [x] 사용자 final review를 통과한다.

## Verification

- `bash scripts/tests/check-env-permission-contract.sh .claude/settings.json`
- `bash -n scripts/create-harness.sh scripts/tests/*.sh`
- `bash scripts/tests/run-harness-checks.sh --all`
- current live surface의 exact broad deny stale scan
- `git diff --check`

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Work/STATUS lifecycle surface 생성 | ✓ 완료 |
| 2 | source/scaffold deny contract 교정 | ✓ 완료 |
| 3 | fixture gate와 validation spine 연결 | ✓ 완료 |
| 4 | docs cascade·full validation·final review | ✓ 완료 |

## Next Actions

- ✓ Work/STATUS lifecycle surface 생성
- ✓ source와 scaffold permission 교정
- ✓ negative/positive fixture gate 구현
- ✓ 문서 cascade와 full validation
- ✓ 사용자 final review

## Discovery

- `CHORE-20260714-001`은 2026-07-14 현재 branch의 첫 CHORE Work로 충돌이 없다.
- UF-08은 HARNESS backlog Summary와 Details에 이미 2단 등록되어 `/work-register` 신규 변경은 필요하지 않았다.
- `.gitignore`는 이미 `.env`, `.env.local`, `.env.*.local` exact contract를 소유한다. 결함은 source `.claude/settings.json`, scaffold 생성 블록과 WORKFLOW-MANUAL 예시의 broad wildcard다.
- Spring product-local `.claude/settings.json`은 같은 exact contract로 교정 완료되어 upstream expected shape evidence로 사용한다.
- Fixture helper는 JSON `permissions.deny`를 파싱해 required exact pattern 3개와 broad wildcard absence를 확인하고, `.env`·`.env.local`·`.env.test.local` negative / `.env.example` positive matrix를 pattern level에서 판정한다. Claude Code permission engine runtime integration을 주장하지 않는다.
- Broad wildcard 재주입 fixture와 `.env.local` deny 누락 fixture는 각각 non-zero로 실패했고 source settings positive fixture는 통과했다.
- `run-harness-checks.sh --all` 첫 실행은 sandbox가 repo-local `temp/harness-tests/` 생성을 차단해 환경 실패했다. 동일 명령을 repository write 권한으로 재실행해 Tier 0/1, generic·optional·source-gitflow invariant 6종, manifest matrix, rule parity가 모두 PASS했고 생성물은 cleanup됐다.
- PLAN 영향 없음 — W6 축④의 이미 등록된 bounded quick-fix를 실행하며 roadmap 방향이나 새 정책을 바꾸지 않는다.
- 2026-07-14 사용자 final review 승인 후 Work Done 처리했다. Forward-relevant deferred decision은 없고 archive는 별도 지시까지 보류한다.
- Invariant-Impact: Modified — Claude env read deny는 broad wildcard가 아니라 secret filename contract이며, `.env.example` readable positive fixture와 함께 검증돼야 한다 → source Tier 0 + scaffold invariant fixture matrix.
