# docs/CLAUDE.md

이 문서는 Claude Code의 프로젝트 운영 규칙이다.
Phase와 무관하게 유지하여 다른 프로젝트에서도 같은 구조로 재사용할 수 있게 한다.

## Context Sources

아래 목록은 프로젝트 문맥을 파악하기 위한 참조 우선순위다.
이 순서는 구현 프로세스가 아니다.

1. `CLAUDE.md` — 공통 작업 계약
2. `docs/CLAUDE.md` — 프로젝트 운영 규칙
3. `docs/STATUS.md` — 현재 상태, Active Work, checkpoints, blockers
4. `docs/PLAN-SUMMARY.md` — 기술 스택, 포트, 핵심 아키텍처 결정 요약 (기본 로드)
5. `docs/backlog/*.md` 또는 `docs/decisions/*.md` — 후보 작업과 미결정 사항
6. `docs/TODO//PHASE{n}/*.md` — 완료된 Phase의 상세 작업 분해 또는 명시적으로 지정된 세부 작업 목록
7. `docs/archive/*.md` — 과거 이력 참조
8. `docs/PLAN.md` — 전체 기술 근거 (969줄, 상세 검토가 필요할 때만 로드)

## Session Startup

MUST:

1. `CLAUDE.md`를 읽는다.
2. 이 파일을 읽는다.
3. `docs/STATUS.md`의 상단/current 섹션만 읽는다.
4. 요청 작업에 필요할 때만 active plan 또는 backlog를 읽는다.
5. 큰 변경 전에는 현재 상태, 제안 단계, Verification, Risks를 요약한다.

MUST NOT:

- 작업에 과거 이력 복원이 필요하지 않다면 `docs/PLAN.md`, archive, TODO 파일 전체를 읽지 않는다.

## Work Management Model

아래 파일들은 작업 context와 상태를 관리하기 위한 것이다.
실제 실행은 항상 `plan -> approval -> implementation -> verification -> status update` 흐름을 따른다.

모든 Active Work 항목은 가능하면 아래 정보를 가진다.

- ID
- Priority
- Status
- Scope
- Dependencies
- Done Criteria
- Verification
- Owner/Notes

사용 기준:

- `docs/STATUS.md`: live board와 현재 작업 상태
- `docs/backlog/*.md`: 후보 작업과 우선순위
- `docs/TODO//PHASE{n}/*.md`: Phase가 의도적으로 세부 작업 분해를 필요로 하거나 완료된 Phase 상세를 검토할 때만 사용
- `docs/archive/*.md`: 완료된 Phase의 과거 이력

## Legacy Phase Task Files

`docs/TODO//PHASE1/TODO-BLOCK*.md`는 폐기된 문서가 아니다.
이 파일들은 Phase 1의 상세 작업 분해이며, 과거 구현 맥락, 판단 근거, checkpoint 세부 내용을 복원할 때 유용하다.

새 Phase의 기본값은 다음과 같다.

- `docs/backlog/PHASE{n}.md`: 우선순위가 있는 후보 작업
- `docs/STATUS.md`: Active Work와 checkpoint 상태
- `docs/TODO/PHASE{n}/...`: 큰 Phase를 더 작은 실행 단위로 나눌 필요가 있을 때만 생성

Phase 2 작업 중에는 Phase 1 TODO block 파일을 기본으로 읽지 않는다.

## Approval Boundaries

MUST wait for user approval before:

- multi-step plan 이후 구현을 시작할 때
- 승인된 범위를 넘어서는 작업을 추가할 때
- infrastructure, secrets, database data, deployment behavior를 변경할 때
- 현재 작업 범위를 넘어 historical 또는 strategic 문서를 수정할 때

작고 명시적으로 요청된 문서 수정은 바로 진행할 수 있다.

## Project Constants

- Runtime: Java 21+
- Framework: Spring Boot 3.5.x
- Build: Gradle wrapper
- Architecture: Spring Boot microservices template
- Base package: `io.kyungseo.msa`
- Active state file: `docs/STATUS.md`
- Phase 1 archive: `docs/archive/phase1-status.md`
- Phase 1 plan archive: `docs/archive/phase1-plan.md`
- Phase 1 task details: `docs/TODO//PHASE1/TODO-BLOCK*.md`

## Verification Defaults

가장 좁지만 충분한 Verification을 우선한다.

- Java unit/module change: `./gradlew test`
- Build/config change: `./gradlew build`
- Gateway 또는 integration flow: 관련 checkpoint에 정의된 검증
- Documentation-only change: diff와 링크 확인

Verification을 실행할 수 없다면 이유와 남은 risk를 보고한다.

## Language Rules

파일 유형에 따라 언어를 구분한다.

**영어로 작성:**
- `CLAUDE.md` (루트), `.claude/rules/*.md` — Claude가 instruction으로 직접 처리하는 파일. 영어가 token 효율과 instruction 준수율이 높다.
- frontmatter 키 (`paths`, `name`, `description` 등) — 도구가 파싱하는 메타데이터.

**한국어로 작성 (기술 용어는 영어 원문 유지):**
- `docs/*.md`, `prompts/*.md`, `docs/decisions/DR-*.md` — 사람이 읽는 문서.
- 기술 용어 (`@Transactional`, N+1, Circuit Breaker 등)는 번역하지 않는다.

## Documentation Rules

MUST:

- `docs/STATUS.md`는 짧고 현재 상태 중심으로 유지한다.
- 완료된 Phase 상세는 `docs/archive/`로 옮긴다.
- `docs/PLAN.md`는 승인된 방향과 아키텍처 중심으로 유지하고 task log로 쓰지 않는다.
- backlog 항목은 실행 가능하고 검증 가능하게 작성한다.

NEVER:

- 같은 긴 규칙 블록을 `CLAUDE.md`, `docs/CLAUDE.md`, `.claude/system.md`에 중복 작성하지 않는다.
