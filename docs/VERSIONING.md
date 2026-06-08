# VERSIONING.md

AI Workflow Harness의 버전 정책 SSoT다.
이 파일은 source repo 전용 maintainer 문서다. scaffold 대상 아님.

결정 근거: `docs/decisions/DR-028-versioning-policy.md`

---

## 1. 버전 SSoT

| 항목 | 값 |
| --- | --- |
| 버전 SSoT | **GitHub release tag 라인** |
| tag 형식 | `ai-workflow-v{X.Y.Z}` (접두사 `ai-workflow-v` + bare semver) |
| `VERSION` 파일 | bare semver mirror (`X.Y.Z`). `develop`은 *다음 in-development 릴리즈* 값을 담는다 |
| 소비 경로 | `VERSION` → `create-harness.sh`(`HARNESS_VERSION`) → `.harness/manifest.json`(`harness_version`) |

`VERSION`과 tag는 항상 `ai-workflow-v{VERSION}` 관계로 묶인다. 릴리즈 시점에 `develop`의 `VERSION` 값이 그대로 tag가 된다.

---

## 2. Semver 기준 — scaffold consumer contract 대상

semver는 adopter가 소비하는 표면(scaffold output 구조, command/skill surface, workflow/gate 계약, manifest 형식)을 기준으로 적용한다. 내부 harness 개발 표면(maintainer만 소비)의 변경은 consumer contract가 아니다.

| 단위 | 기준 | 예 |
| --- | --- | --- |
| **MAJOR** | 신규 adopter 기준 호환 불가한 contract 변경. (upgrade 구현 후) upgrade 경로를 깨는 변경 | scaffold output 구조 incompatible 개편, manifest schema breaking |
| **MINOR** | 하위호환 추가 | 신규 command/option/optional pack, 추가 workflow·rule·문서 |
| **PATCH** | adopter 비가시 변경 | 버그·문서·wording·내부 refactor |

> **현 단계 정책 (1.x):** 자동 upgrade 경로가 아직 없다. 따라서 semver는 *신규 scaffold*가 보는 contract를 기준으로 한다. 기존 adopter에 수동 마이그레이션이 필요한 변경은 MAJOR로 강제하지 않고 **릴리즈 노트 Breaking 섹션에 명시**한다. upgrade/migration 메커니즘 구현 시 "upgrade 경로 호환성"을 MAJOR 1급 기준으로 편입한다(DR-028 Consequences).

---

## 3. Bump 절차

```
1. 작업이 MAJOR/MINOR/PATCH 중 무엇인지 §2 기준으로 판정
2. 릴리즈 직전, develop의 VERSION을 목표 값으로 설정 (in-development 동안 미리 올려두어도 됨)
3. develop → main release PR
4. main merge 후: git tag ai-workflow-v{VERSION} && git push origin --tags
5. (선택) 다음 사이클 첫 작업에서 develop VERSION을 다음 목표 값으로 bump
```

- `VERSION` 변경은 protected 파일 영향이 없고 reversal cost Low다. feature branch에서 수정 → develop → main 경로를 따른다.
- 릴리즈 노트에는 변경 단위 근거와 (있으면) Breaking 항목을 명시한다.

---

## 4. 릴리즈 전 검증

버전을 올려 릴리즈하기 전, 출하 표면에 대한 전수 검증을 수행한다.
검증 명령 카탈로그: `docs/VERIFICATION-COMMANDS.md` (Release Full Sweep 프리셋 — 해당 항목 정비 후).

판정 분류:

| 분류 | 처리 |
| --- | --- |
| 출하 표면의 결함/회귀 | 릴리즈 전 반드시 수정 |
| 미구현 기능의 갭 | 용인, 백로그 추적 |
| 품질 개선/wording | 릴리즈 후 또는 별도 |

`VERSION` 정합성 자체는 `docs/VERIFICATION-COMMANDS.md` Layer R로 확인한다 (`VERSION` == manifest `harness_version`).
