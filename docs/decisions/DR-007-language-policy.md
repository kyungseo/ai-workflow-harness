# DR-007: 파일 유형별 작성 언어 원칙

Date: 2026-05-11
Amended: 2026-05-16, 2026-06-15
Status: Accepted (Amended)
Linked DRs: DR-030

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
| `skills/workflow/*.md` | workflow 상세 절차의 canonical SSoT |
| `.claude/commands/*.md` | 사용자가 직접 읽고 수정하는 slash command |
| `.agents/skills/*/SKILL.md` | Codex workflow skill adapter. 상세 절차는 `skills/workflow/*.md`를 따름 |
| `.claude/settings.json` hook 출력 메시지 | 사용자와 세션에 보이는 안내 메시지 |
| Java 인라인 주석 | WHY는 한국어로, 기술 용어는 영어 원문 유지 |

## Bilingual Rules (한영 혼용 표기 원칙)

"한국어 주 언어 + Bilingual Rules 적용" 파일에는 아래 규칙을 준수한다.

- **Section & Title:** 섹션명 및 타이틀은 영문 Title Case로 표기하며 한국어 번역을 사용하지 않는다. (예: Executive Summary, Background, Active Work, Next Steps, Decision, Rationale)
- **Technical Identity:** 기술 스택명, Framework, Library, Architecture 패턴은 한글로 음차하지 않고 영어 원문으로 표기한다. (예: Kubernetes, Microservices, CI/CD, Refactoring, Spring Boot)
- **Jargon & Metrics:** 실무 관용어 및 성능 지표는 영문 표기를 원칙으로 한다. (예: Pain Point, Latency, Throughput, Backlog, Bottleneck)
- **Grammar Continuity:** 영문 명사 뒤에 붙는 조사 및 어미는 한글 문법에 맞게 자연스럽게 결합한다. (예: "Kafka를 활용하여 Throughput을 개선함", "CI/CD Pipeline을 통해 배포 자동화를 구성함")

## Non-File Surfaces

이 DR은 파일 유형뿐 아니라 아래 운영 표면(persisted 파일이 아닌 표면 포함)의 언어도 규율한다. **이 DR이 harness 언어 정책의 단일 SSoT**이며, 다른 표면은 규칙을 재서술하지 않고 이 DR을 pointer로 참조한다.

| 표면 | 언어 규칙 |
|------|-----------|
| Commit message | type prefix는 영문(`feat`, `fix`, `docs`, …). subject·body는 한국어 주체 + Bilingual Rules. co-author trailer는 영문(시스템 생성, 번역하지 않음). |
| PR body | 한국어 주체 + Bilingual Rules. 제목은 commit subject 규칙과 동일. |
| Agent 사용자 노출 출력 (진행 narration, tool 설명, echo 라벨 등) | 대화 언어를 따른다(기본 한국어). 이는 **default conversational convention**이며 hard-gate 대상이 아니다(자연어·human-in-loop 영역 — 강제 검증 부적합). |

Commit/PR의 **구조**(Conventional Commits)와 절차는 git-workflow 규칙(`docs/GIT-WORKFLOW.md §5`, `.claude/rules/git-workflow.md`)이 보유하고, **언어는 이 DR을 SSoT로 따른다.**

## Default Language And Adopter Override

- 이 harness의 기본 언어 정책은 위 표 기준 **한국어 주체 + Bilingual Rules**다.
- **이 DR이 언어 정책의 authoritative SSoT**(정의·근거·변경 절차의 출처)다. 다만 "한 파일만 고치면 끝"은 아니다 — 신뢰성 있는 in-context 도달을 위해 default 언어 directive는 always-loaded entry/rule surface에 **의도적으로 inline mirror**된다(pointer-only는 DR을 자동 로드하지 않는 도구—예: Codex가 `AGENTS.md`를 직접 따름—에서 실패하므로). 자동 mirror 동기화 메커니즘은 없다(아래 전략 DR 범위).
- 따라서 **default 언어를 바꾸는 것은 단일 파일 수정이 아니라 정책 변경**이며, 이 DR과 아래 mirror surface를 함께 갱신해야 한다. 이 목록(무엇을 어디서 바꿀지)도 이 DR이 규정한다:
  - `AGENTS.md` (Language Policy)
  - `.claude/rules/git-workflow.md` (Commit Message Format)
  - `.cursor/rules/git-commit.mdc` (Commit Message)
  - `docs/GIT-WORKFLOW.md` §5
  - `docs/BEHAVIOR-PRINCIPLES.md` §5 (agent 출력)
  - `docs/WORKFLOW-MANUAL.md` Appendix C (digest), `README.md` (adopter note)
- adopter-facing 산출물 언어(i18n), 1차 청중(primary audience) 선택, scaffold 언어 출력 옵션, **위 mirror를 자동 동기화/생성하는 메커니즘** 같은 **미래 전략 결정**은 이 DR의 범위가 아니라 별도 전략 DR(Linked DRs 참조)에서 다룬다. 이 DR은 **현재 효력을 가진 운영 규칙의 SSoT**만 보유한다.

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
- Commit message·PR body·agent 사용자 노출 출력의 언어는 이 DR을 SSoT로 따른다(위 Non-File Surfaces 참조).
- 다른 표면(`docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, git-workflow rule/§5, `AGENTS.md`, `docs/BEHAVIOR-PRINCIPLES.md`, `README.md`)은 언어 규칙을 재서술하지 않고 이 DR을 pointer로 참조한다. 규칙 변경은 이 DR에서 한 번만 한다.

## Reversal Cost

Medium — 모든 docs를 영어로 전환하거나, 모든 rules를 한국어로 전환하려면 파일 전수 수정 필요.

## Linked Backlog Items

- P2-PLAN-003 (AI workflow 정비 심화 + Cursor 정렬, 완료)
