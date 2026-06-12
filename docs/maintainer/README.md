# Maintainer (source-only)

`ai-workflow-harness` **source repo 전용** 유지보수 문서 디렉토리다.
여기의 문서는 scaffold 어떤 옵션(`--with-optional` 포함)에서도 target에 복사되지 않는다.
scaffold 적용 repository에는 존재하지 않으므로, 다른 문서가 이곳을 가리킬 때는 `(source-only / N/A in adopter repo)`로 취급한다.

경계 근거: `docs/decisions/DR-021-source-target-boundary.md` (Amendment 2026-06-10).

| 자산 | 역할 |
| --- | --- |
| `README.md` | 이 디렉토리의 source-only maintainer 문서 지도 |
| `SOURCE-REPO-OPERATIONS.md` | source repo 변경 lifecycle 운영 runbook — 검증 척추 산출물을 실행 순서로 엮는 진입 문서(순서축, SSoT 복제 아님) |
| `HARNESS-TEST-TAXONOMY.md` | surface별 검증 기준, Tier 정의, `temp/` 정책, runner와 catalog의 역할 경계 |
| `VERIFICATION-COMMANDS.md` | Layer별 검증 명령 카탈로그 + "Release Full Sweep" 릴리즈 전수 점검 프리셋 |
| `VERSIONING.md` | semver 기준·tag 매핑·bump 절차의 SSoT (근거: DR-028) |
| `migrations/` | source framework 변경을 기존 target repo가 수용하는 migration note 인덱스 |

**여기에 두지 않는 것:** scaffold/온보딩 표면 문서(`docs/SCAFFOLD-BOOTSTRAP.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`)와 Optional source pack(`docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`)은 성격이 달라 `docs/` 루트에 유지한다.

## 문서 표면 분류 (logical marker)

DR-021은 source/target 경계를 **물리 디렉토리 이동 없이** logical marker로 식별한다. 아래 표가 그 marker다 — "audience(누가 읽나)"와 "distribution(어떻게 배포되나)"은 직교축이며, **source-only(어디에도 ship 안 됨)만** `docs/maintainer/`에 물리 격리하고 **배포되는 문서는 `docs/` 루트에 유지**한다.

| 문서 | audience | distribution | 위치 |
| --- | --- | --- | --- |
| `WORKFLOW-MANUAL.md` | user / adopter | optional-pack (`--with-optional`) | `docs/` 루트 |
| `SCAFFOLD-ONBOARDING-GUIDE.md` | adopter (도입 시) | source-only (미배포) | `docs/` 루트 |
| `HARNESS-ARCHITECTURE.md` | maintainer / contributor | optional-pack | `docs/` 루트 |
| `HARNESS-MAINTAINER-GUIDE.md` | maintainer | optional-pack | `docs/` 루트 |
| `HARNESS-TEST-TAXONOMY.md`, `VERIFICATION-COMMANDS.md`, `VERSIONING.md`, `migrations/` | maintainer | source-only (미배포) | `docs/maintainer/` |
| `SOURCE-REPO-OPERATIONS.md` | source maintainer / AI driver | source-only (미배포) | `docs/maintainer/` |

> SCAFFOLD-ONBOARDING-GUIDE는 source-only이나 *도입 시 source/clone에서 읽는* adopter용이라 루트에 둔다 (maintainer 전용 자산과 성격이 다름).
> docs/ 물리 레이아웃 자체(audience별 디렉토리 분리)의 재검토 여지는 `docs/backlog/HARNESS.md` "Prompt surface diet + optional pack 재정의"(P1)에서 reversal-cost 논거와 함께 다룬다.

## Migration Notes

`migrations/`는 일반 upgrade guide가 아니라, 특정 framework 변경을 이미 scaffold된 target repo가 수용할 때 참고하는 per-change note 모음이다.
인덱스 SSoT는 `docs/maintainer/migrations/README.md`다.
