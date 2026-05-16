# DR-007: 파일 유형별 작성 언어 원칙

Date: 2026-05-11
Amended: 2026-05-16
Status: Accepted (Amended)

## Question

프로젝트 문서와 AI instruction 파일을 한국어와 영어 중 어떤 언어로 작성할 것인가?
한영 혼용 문서에서 영어 표기 기준을 어떻게 정의할 것인가?

## Decision

파일 용도에 따라 언어를 분리한다.

**영어 전용 (English Only)**

| 파일 유형 | 이유 |
|-----------|------|
| `CLAUDE.md` (루트), `AGENTS.md` | AI instruction 진입점. 영어가 token 효율과 instruction 준수율이 높음 |
| `.claude/rules/*.md` | Claude가 instruction으로 직접 처리 |
| `.cursor/rules/*.mdc` | Cursor가 instruction으로 직접 처리 |
| `.claude/settings.json` 설정 key와 command 구조 | 도구 설정과 shell command는 영어 기반으로 유지 |
| Frontmatter 키 (`paths`, `name`, `description` 등) | 도구가 파싱하는 메타데이터 — 파일 유형 무관 전역 적용 |

**한국어 주 언어 + Bilingual Rules 적용**

| 파일 유형 | 비고 |
|-----------|------|
| `docs/*.md`, `prompts/*.md`, `docs/decisions/DR-*.md` | 사람이 읽는 문서 |
| `.claude/commands/*.md` | 사용자가 직접 읽고 수정하는 slash command |
| `.claude/settings.json` hook 출력 메시지 | 사용자와 세션에 보이는 안내 메시지 |
| Java 인라인 주석 | WHY는 한국어로, 기술 용어는 영어 원문 유지 |

## Bilingual Rules (한영 혼용 표기 원칙)

"한국어 주 언어 + Bilingual Rules 적용" 파일에는 아래 규칙을 준수한다.

- **Section & Title:** 섹션명 및 타이틀은 영문 Title Case로 표기하며 한국어 번역을 사용하지 않는다. (예: Executive Summary, Background, Active Work, Next Steps, Decision, Rationale)
- **Technical Identity:** 기술 스택명, Framework, Library, Architecture 패턴은 한글로 음차하지 않고 영어 원문으로 표기한다. (예: Kubernetes, Microservices, CI/CD, Refactoring, Spring Boot)
- **Jargon & Metrics:** 실무 관용어 및 성능 지표는 영문 표기를 원칙으로 한다. (예: Pain Point, Latency, Throughput, Backlog, Bottleneck)
- **Grammar Continuity:** 영문 명사 뒤에 붙는 조사 및 어미는 한글 문법에 맞게 자연스럽게 결합한다. (예: "Kafka를 활용하여 Throughput을 개선함", "CI/CD Pipeline을 통해 배포 자동화를 구성함")

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 전체 영어 | AI instruction 효율 최적 | 한국어 개발자에게 문서 가독성 저하 |
| 전체 한국어 | 개발자 가독성 최적 | Claude가 instruction으로 처리할 때 token 비효율, 준수율 저하 가능 |
| **용도별 분리 + Bilingual Rules (채택)** | instruction 효율 + 문서 가독성 동시 달성, 기술 용어 표기 일관성 확보 | 파일별 언어 규칙을 기억/준수해야 함 |

## Rationale

Claude Code는 `CLAUDE.md`와 `.claude/rules/*.md`를 instruction으로 직접 처리하기 때문에 영어가 token 효율과 instruction 준수율 측면에서 유리하다.
반면 `docs/*.md`는 사람이 읽는 문서이므로 한국어를 주 언어로 작성해야 유지보수성이 높다.

Bilingual Rules 추가 배경: 한영 혼용 문서에서 기술 용어와 섹션 타이틀의 영어 표기 기준이 불명확하여 파일마다 표기가 달라지는 문제가 발생했다. 의미 전달이 명확한 기술 용어와 표준 섹션명은 영어를 유지하는 것이 가독성과 일관성 측면에서 유리하다.

## Consequences

- 신규 파일 작성 시 위 표를 기준으로 언어를 결정한다.
- AI(Claude/Cursor)가 instruction을 생성할 때 `.claude/rules/*.md`는 영어로 작성한다.
- Cursor rules(`.cursor/rules/*.mdc`)도 영어로 작성한다.
- `.claude/settings.json` hook 출력 메시지는 사용자에게 보이는 안내로 취급하여 한국어로 작성한다.
- "한국어 주 언어" 파일에서 기술 용어·섹션 타이틀·성능 지표는 Bilingual Rules를 따른다.
- Java 인라인 주석은 `// 한국어 이유 — 영어 기술 용어` 형식을 따른다.
- 기존 문서의 Bilingual Rules 적용 현황은 별도 검토 후 필요 시 수정한다.

## Reversal Cost

Medium — 모든 docs를 영어로 전환하거나, 모든 rules를 한국어로 전환하려면 파일 전수 수정 필요.

## Linked Backlog Items

- P2-PLAN-003 (AI workflow 정비 심화 + Cursor 정렬, 완료)
