# Maintainer (source-only)

`ai-workflow-harness` **source repo 전용** 유지보수 문서 디렉토리다.
여기의 문서는 scaffold 어떤 옵션(`--with-optional` 포함)에서도 target에 복사되지 않는다.
scaffold 적용 repository에는 존재하지 않으므로, 다른 문서가 이곳을 가리킬 때는 `(source-only / N/A in adopter repo)`로 취급한다.

경계 근거: `docs/decisions/DR-021-source-target-boundary.md` (Amendment 2026-06-10).

| 자산 | 역할 |
| --- | --- |
| `VERIFICATION-COMMANDS.md` | Layer별 검증 명령 카탈로그 + "Release Full Sweep" 릴리즈 전수 점검 프리셋 |
| `VERSIONING.md` | semver 기준·tag 매핑·bump 절차의 SSoT (근거: DR-028) |
| `migrations/` | source framework 변경을 기존 target repo가 수용하는 migration note 인덱스 |

**여기에 두지 않는 것:** scaffold/온보딩 표면 문서(`docs/SCAFFOLD-BOOTSTRAP.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`)와 Optional source pack(`docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`)은 성격이 달라 `docs/` 루트에 유지한다.
