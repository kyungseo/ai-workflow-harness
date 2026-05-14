# DR-007: 파일 유형별 작성 언어 원칙

Date: 2026-05-11
Status: Accepted

## Question

프로젝트 문서와 AI instruction 파일을 한국어와 영어 중 어떤 언어로 작성할 것인가?

## Decision

파일 용도에 따라 언어를 분리한다.

| 파일 유형 | 언어 | 이유 |
|-----------|------|------|
| `CLAUDE.md` (루트), `.claude/rules/*.md` | 영어 | Claude가 instruction으로 직접 처리. 영어가 token 효율과 instruction 준수율이 높음 |
| `.cursor/rules/*.mdc` | 영어 | Cursor가 instruction으로 직접 처리. Claude rules와 같은 원칙 적용 |
| `.claude/settings.json` 설정 key와 command 구조 | 영어 | 도구 설정과 shell command는 영어 기반으로 유지 |
| `.claude/settings.json` hook 출력 메시지 | 한국어 + 기술용어 영어 | 사용자와 세션에 보이는 안내 메시지 |
| frontmatter 키 (`paths`, `name`, `description` 등) | 영어 | 도구가 파싱하는 메타데이터 |
| `docs/*.md`, `prompts/*.md`, `docs/decisions/DR-*.md` | 한국어 + 기술용어 영어 | 사람이 읽는 문서. 기술 용어(`@Transactional`, N+1, Circuit Breaker 등)는 번역하지 않음 |
| `.claude/commands/*.md` | 한국어 + 기술용어 영어 | 사용자가 직접 읽고 수정하는 slash command |
| Java 인라인 주석 | 한국어 이유 + 영어 기술용어 | 사람이 읽는 코드 맥락. WHY는 한국어로 쓰고 기술 용어는 번역하지 않음 |

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 전체 영어 | AI instruction 효율 최적 | 한국어 개발자에게 문서 가독성 저하 |
| 전체 한국어 | 개발자 가독성 최적 | Claude가 instruction으로 처리할 때 token 비효율, 준수율 저하 가능 |
| **용도별 분리 (채택)** | instruction 효율 + 문서 가독성 동시 달성 | 파일별 언어 규칙을 기억/준수해야 함 |

## Rationale

Claude Code는 `CLAUDE.md`와 `.claude/rules/*.md`를 instruction으로 직접 처리하기 때문에 영어가 token 효율과 instruction 준수율 측면에서 유리하다.
반면 `docs/*.md`는 사람이 읽는 문서이므로 한국어로 작성해야 유지보수성이 높다.
기술 용어는 어느 언어 파일이든 영어 원문을 유지한다 (번역 시 의미 손실 위험).

## Consequences

- 신규 파일 작성 시 위 표를 기준으로 언어를 결정한다.
- AI(Claude/Cursor)가 instruction을 생성할 때 `.claude/rules/*.md`는 영어로 작성한다.
- Cursor rules(`.cursor/rules/*.mdc`)도 영어로 작성한다.
- `.claude/settings.json` hook 출력 메시지는 사용자에게 보이는 안내로 취급하여 한국어로 작성한다.
- 언어 정책의 원칙은 이 DR에 보존하고, 자동 로드 문서에는 필요한 최소 운영 규칙만 유지한다.
- Java 인라인 주석은 `// 한국어 이유 — 영어 기술 용어` 형식을 따른다.

## Reversal Cost

Medium — 모든 docs를 영어로 전환하거나, 모든 rules를 한국어로 전환하려면 파일 전수 수정 필요.

## Linked Backlog Items

- P2-PLAN-003 (AI workflow 정비 심화 + Cursor 정렬, 완료)
