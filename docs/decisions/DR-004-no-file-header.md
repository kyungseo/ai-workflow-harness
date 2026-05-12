# DR-004: Java 파일 헤더 없음 정책

Date: 2026-05-12
Status: Accepted

## Question

Java 소스 파일에 프로젝트 정보와 라이선스를 담은 파일 헤더 주석을 추가할 것인가?

## Decision

파일 헤더를 추가하지 않는다. `LICENSE` 파일이 전체 프로젝트의 라이선스를 커버한다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Full 헤더 (8줄, 프로젝트 설명 + 라이선스) | 파일 단위로 저작권 명시 | AI 컨텍스트 비용 증가, Git diff 노이즈, 기존 89개 파일 소급 필요 |
| Slim 헤더 (3줄, 타이틀 + 저작권 + 라이선스) | 간결한 저작권 표시 | 동일 단점 (소급 없이 신규만 적용 시 불일치) |
| 헤더 없음 (채택) | AI 컨텍스트 최소화, diff 노이즈 없음, 소급 불필요 | 파일 단위 라이선스 표시 없음 (LICENSE로 대체) |

## Rationale

- 오픈소스 법적 효력은 `LICENSE` 파일 하나로 전체 프로젝트를 커버한다 (Berne Convention 기준).
- Vibe Coding + AI 환경에서 파일당 헤더는 매 context load마다 토큰을 소비한다.
- 기존 89개 Java 파일에 소급 적용하면 Git blame이 전체 오염된다.
- 신규 파일에만 적용하면 파일 간 불일치가 발생한다.

## Consequences

- 신규 Java 파일에도 파일 헤더를 추가하지 않는다.
- IntelliJ File Header Template을 설정하지 않는다.
- `docs/coding-conventions.md` 섹션 1에 "파일 헤더 없음" 정책을 명시했다.
- Checkstyle에 파일 헤더 검증 규칙을 추가하지 않는다.

## Reversal Cost

Low — LICENSE 파일이 있으므로 헤더를 나중에 추가해도 법적 효력에 영향 없음.
추가 시: 전체 파일 일괄 수정 + Git blame 오염.

## Linked Backlog Items

- PRE-A2+A3 (통합 완료)
