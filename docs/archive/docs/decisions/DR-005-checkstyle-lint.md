# DR-005: Checkstyle 기반 Lint 채택 및 Google Java Style 오버라이드

Date: 2026-05-12
Status: Accepted

## Question

Java 코드 품질 자동 검증 도구로 무엇을 사용하고, 어떤 규칙 기준을 적용할 것인가?

## Decision

Checkstyle 10.x를 채택한다. Google Java Style을 기반으로 하되 프로젝트 관행에 맞게 핵심 규칙을 오버라이드한다.

핵심 오버라이드:
- `LineLength`: 100 → 120자
- `Indentation`: 2 spaces → 4 spaces
- Javadoc 강제 규칙 전체 비활성 (최소 주석 정책, DR-004 연계)

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Checkstyle (채택) | 업계 표준, Google Style 공식 지원, IntelliJ 플러그인 성숙 | XML 설정 장황, auto-fix 없음 |
| Spotless + google-java-format | auto-format 지원, 설정 간단 | Checkstyle 대비 규칙 커스터마이징 제한 |
| Spotless + Checkstyle 병행 | 포맷 자동화 + 규칙 검증 분리 | 도구 복잡성 증가, 이중 관리 |
| SpotBugs | 버그 패턴 정적 분석 | 포맷/스타일 검증 불가, 별도 의사결정 필요 |
| Lint 없음 | 초기 마찰 없음 | 코드 품질 편차 누적 |

## Rationale

- Checkstyle은 Google Java Style의 공식 XML config를 제공하며 Spring 생태계에서 검증된 도구다.
- 기존 코드가 4-space indent와 120자 라인 길이를 사용하므로 Google 기본값 오버라이드가 필수.
- Javadoc 강제는 최소 주석 정책(DR-004)과 상충하므로 전면 비활성.
- Spotless는 auto-format이 장점이나 이번 단계에서는 검증(check)만 필요 → 향후 추가 가능.
- SpotBugs는 별도 의사결정 항목으로 분리 (OQ-005 예정).

## Consequences

- `config/checkstyle/checkstyle.xml`: Google Java Style 기반 + 오버라이드
- `config/checkstyle/suppressions.xml`: 테스트 파일 star import 허용 (MockMvc/Mockito 관행)
- `build.gradle.kts`: `checkstyle` 플러그인 적용, `toolVersion = "10.21.0"`
- `./gradlew checkstyleMain checkstyleTest`: 0 위반 확인 완료
- 기존 소스 5개 파일 수정 (미사용 import 제거, 브레이스 추가, star import 전개)
- pre-commit hook에 `./gradlew checkstyleMain` 추가 (DR-006 연계)
- CI `lint` job에 `checkstyleMain checkstyleTest` 추가 (DR-006 연계)

## Reversal Cost

Medium — Checkstyle 제거 시 `build.gradle.kts`, `config/checkstyle/`, Git hook, CI 수정 필요.
소스 코드 변경사항(import 정리 등)은 품질 개선이므로 롤백 불필요.

## Linked Backlog Items

- PRE-A2+A3 (통합 완료)
- SpotBugs 도입 여부: 별도 결정 필요 (OQ-005로 추가 예정)
