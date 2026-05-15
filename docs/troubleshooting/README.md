# Troubleshooting

증상별 원인 분석과 조치 기록이다.

## 인덱스

| 증상 | 환경 | 파일 |
| --- | --- | --- |
| Testcontainers 실행 시 `Could not find a valid Docker environment` | macOS, Docker Desktop 4.73.0+ | [testcontainers-docker-desktop-4.73.md](testcontainers-docker-desktop-4.73.md) |

## 작성 규칙

- 파일명: `lowercase-hyphenated.md` (DR-008 기준)
- 구성: 증상 → 원인 → 조치 → 검증 → 관련 문서
- 해결 안 된 이슈는 `docs/STATUS.md` Blockers에 등록 후 해결 시 이 디렉터리로 이동
- 관련 결정이 DR-worthy이면 `docs/decisions/DR-*.md`로 별도 기록하고 역참조
