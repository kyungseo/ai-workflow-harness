# Troubleshooting

증상별 원인 분석과 조치 기록이다.

## 인덱스

| 증상 | 환경 | 파일 |
| --- | --- | --- |
| 승인된 범위 밖 문서까지 함께 수정됨 | Claude Code, Codex, Cursor 공통 workflow | [agent-scope-approval-drift.md](agent-scope-approval-drift.md) |

## Frontmatter 스펙 (DR-027)

```yaml
---
symptom: {한 줄 증상}
track: harness | product
category: {e.g. workflow, scaffold, command, git, tool, feature, api, data, infra, …}
environment: {e.g. Claude Code, Codex, Antigravity, Cursor, 공통, 기타}
status: Resolved | Unresolved | Workaround
related_dr: []
---
```

`track`: harness = AI workflow·명령·프로토콜 이슈 / product = 적용 프로젝트의 기능·인프라 이슈
`category`: 예시 목록이며 열거형으로 제한하지 않는다.

## 작성 규칙

- 파일명: `lowercase-hyphenated.md` (DR-008 기준)
- 구성: 증상 → 원인 → 조치 → 검증 → 변경 내역 → 관련 문서
- 해결 안 된 이슈는 `docs/STATUS.md` Blockers에 등록 후 해결 시 이 디렉터리로 이동
- 관련 결정이 DR-worthy이면 `docs/decisions/DR-*.md`로 별도 기록하고 역참조
