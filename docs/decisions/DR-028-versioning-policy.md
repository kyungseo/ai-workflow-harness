# DR-028: Versioning Policy — Git Tag SSoT + Semver 기준

Date: 2026-06-08
Status: Accepted (Amended 2026-06-21)
Track: harness
Supersedes:

## Question

`VERSION` 파일(`0.2.0`)과 git release tag 라인(`ai-workflow-v1.0.8`)이 어긋나 있다. 어느 쪽이 버전 SSoT인가? semver의 MAJOR/MINOR/PATCH는 이 harness/scaffold 프레임워크에서 무엇을 의미하는가? Phase 2 릴리즈는 어떤 단위로 올리는가?

## Decision

1. **버전 SSoT = GitHub release tag 라인.** tag 형식은 `ai-workflow-v{X.Y.Z}` (접두사 `ai-workflow-v` + bare semver).
2. **`VERSION` 파일 = bare semver mirror.** `develop`의 `VERSION`은 *다음 in-development 릴리즈 값*을 담는다. 릴리즈 시 이 값이 그대로 tag가 된다 (`ai-workflow-v{VERSION}`).
3. **semver 기준은 scaffold consumer contract를 대상으로 한다** (아래 Rationale).
4. **Phase 2 릴리즈 = `1.1.0` (MINOR).** command rename(no-alias)·scaffold 구조 변경 등 adopter-facing 변경을 포함하나, *신규 scaffold가 일관되게 동작*하므로 MINOR로 처리하고, 기존 adopter용 breaking 항목은 릴리즈 노트 Breaking 섹션에 명시한다.
5. 상세 기준·매핑·bump 절차는 `docs/maintainer/VERSIONING.md`(source-only maintainer 문서)에 둔다.
6. **adopter upgrade/apply evidence의 source-ref baseline 기본값은 released `main` 또는 release tag다.** `develop` 또는 current checkout 기준 probe는 internal dogfooding / pre-release tracking 예외로 허용하되, source branch, HEAD sha, `git describe --tags --always --dirty`, 예외 라벨을 함께 기록한다. `VERSION` 문자열만으로 release parity를 주장하지 않는다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| tag 라인을 SSoT, VERSION을 1.1.0 정렬 (채택) | 공개 릴리즈 이력(v1.0.x)과 일치. 사용자 멘탈 모델 단순 | VERSION drift 재발 방지 장치(정책 문서) 필요 |
| VERSION(0.2.0)을 SSoT로, tag를 0.x로 재정렬 | — | 이미 공개된 v1.0.x tag 9개와 충돌. 이력 파괴 |
| Phase 2를 MAJOR(2.0.0)로 | 엄격 semver(breaking=major) 부합 | adopter 1개·초기 단계에서 과도. 매 구조 변경마다 major 인플레이션 |

## Rationale

**왜 tag 라인이 SSoT인가:** `ai-workflow-v1.0.0`~`v1.0.8` 9개 tag가 이미 공개 릴리즈 이력이다. `VERSION`=0.2.0은 manifest 작업(CHORE-20260605-006)에서 tag 라인과 정렬하지 않은 채 유입된 drift다. 공개된 이력을 SSoT로 두고 파일을 거기에 맞추는 것이 비용·혼란 최소다.

**왜 upgrade evidence도 tag line을 기본 source-ref baseline으로 쓰는가:** `scripts/create-harness.sh --check <target>`는 operator가 실행 중인 source checkout을 비교한다. 따라서 `VERSION` 값이 같아도 `main`, `develop`, feature checkout의 drift 결과가 달라질 수 있다. released upgrade proof는 released `main` 또는 release tag 기준일 때만 그렇게 부른다. `develop`/current checkout 기준 결과는 pre-release tracking 또는 dogfooding evidence로 라벨링한다.

**semver를 무엇에 적용하는가 — scaffold consumer contract:** 이 프레임워크의 "공개 API"는 adopter가 소비하는 표면이다 = scaffold output 구조, command/skill surface, workflow/gate 계약, manifest 형식. 내부 harness 개발 표면(maintainer만 소비)의 변경은 consumer contract가 아니다.

- **MAJOR** — scaffold output 구조·command surface·workflow/gate 계약·manifest schema를 **신규 adopter 기준으로 호환 불가하게** 바꾸거나, (upgrade/migration 구현 후) upgrade 경로를 깨는 변경.
- **MINOR** — 하위호환 추가: 신규 command/option/optional pack, 추가적 workflow/문서/rule.
- **PATCH** — adopter 비가시 변경: 버그·문서·wording·내부 refactor.

**왜 Phase 2가 MINOR인가:** 현재 자동 upgrade 경로가 없다(백로그 항목). 따라서 semver는 *신규 scaffold*가 보는 contract를 기준으로 한다. Phase 2는 신규 scaffold에서 일관되게 동작하므로 "running deployment를 깨는" breaking이 아니라 "새 구조로의 전환"이다. 기존 adopter(`ai-deck-compiler`)는 수동 마이그레이션이 필요하나, 이는 릴리즈 노트 Breaking 명시로 처리한다. 초기 단계·adopter 1개 환경에서 매 구조 변경을 MAJOR로 올리면 버전 인플레이션이 발생한다.

## Consequences

- `VERSION` 0.2.0 → 1.1.0. scaffold가 stamp하는 `manifest.json`의 `harness_version`도 1.1.0으로 정렬.
- `docs/maintainer/VERSIONING.md` 신설 — semver 기준·tag 매핑·bump 절차의 SSoT. source-only(scaffold 미포함).
- 릴리즈 시 `develop`→`main` merge 후 `git tag ai-workflow-v{VERSION}`.
- upgrade/migration 메커니즘 구현 시 semver 기준에 "upgrade 경로 호환성"을 1급 기준으로 편입(해당 백로그 항목에서 재확인).
- adopter upgrade/migration walkthrough는 source-ref baseline을 기록한다. clean release tag가 아닌 checkout에서 얻은 `--check` 결과는 released upgrade proof로 쓰지 않는다.
- `--check`는 비교에 사용한 source ref를 출력하고, clean release tag가 아니면 report-only WARN을 낸다.

## Reversal Cost

Low — 값·문서 변경뿐. `VERSION` revert는 1줄. 향후 2.0 정의 시 기준 재조정 가능.

## Linked Backlog Items

- HARNESS.md: "버전 체계 정의 + VERSION 정렬" (P0) → CHORE-20260608-002
- HARNESS.md: "Harness upgrade/migration 메커니즘" (P1) — semver 기준에 upgrade 호환성 편입 예정
- CHORE-20260621-006 — upgrade baseline source-ref policy and `--check` ref visibility

## Amendment History

| Date | Change |
| --- | --- |
| 2026-06-21 | adopter upgrade/apply evidence의 source-ref baseline을 released `main`/release tag 기본값으로 명시. `develop`/current checkout probe는 명시 예외 라벨과 source ref 기록을 요구. `--check` source-ref output/WARN 연계. |
