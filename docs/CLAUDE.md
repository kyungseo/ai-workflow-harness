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
6. `docs/TODO/PHASE{n}/*.md` — 완료된 Phase의 상세 작업 분해 또는 명시적으로 지정된 세부 작업 목록
7. `docs/archive/*.md` — 과거 이력 참조
8. `docs/PLAN.md` — 전체 기술 근거 (969줄, 상세 검토가 필요할 때만 로드)

### Context 로드 조건

각 레벨은 아래 조건이 충족될 때만 로드한다. 조건이 없으면 로드하지 않는다.

| 레벨 | 파일 | 로드 조건 |
| --- | --- | --- |
| 4 | `docs/PLAN-SUMMARY.md` | 기술 스택·포트·패키지 구조 확인 필요 시; 새 서비스·레이어 추가 전 |
| 5 | `docs/backlog/*.md` | `/pick`, `/work` 실행 시; 작업 범위·우선순위 확인 필요 시 |
| 5 | `docs/decisions/*.md` | 관련 DR이 있는 작업 시작 시; 아키텍처 결정이 구현에 직접 영향을 줄 때 |
| 6 | `docs/TODO/PHASE{n}/*.md` | 해당 Phase 세부 작업 분해 확인 시; 명시적 TODO block 참조 요청 시 |
| 7 | `docs/archive/*.md` | 이전 Phase 구현 맥락 복원 필요 시; 명시적으로 "Phase {n}에서 어떻게 했는지" 요청 시 |
| 8 | `docs/PLAN.md` | PLAN-SUMMARY로 부족한 상세 근거 필요 시; 아키텍처 변경 검토 시; Phase 계획 자체 수정 시 |

## Session Startup

> Claude Code 환경에서는 `CLAUDE.md`와 `docs/CLAUDE.md`(이 파일)가 세션 시작 시 자동 로드된다.
> 아래 1~2번은 Claude Code에서 자동 충족된다. Cursor / ChatGPT 등 다른 도구에서는 수동으로 진행한다.

MUST:

1. `CLAUDE.md`를 읽는다. *(Claude Code: 자동)*
2. 이 파일을 읽는다. *(Claude Code: 자동, `@docs/CLAUDE.md` via CLAUDE.md)*
3. `docs/STATUS.md`의 상단/current 섹션만 읽는다.
4. 요청 작업에 필요할 때만 active plan 또는 backlog를 읽는다.
5. 큰 변경 전에는 현재 상태, 제안 단계, Verification, Risks를 요약한다.

MUST NOT:

- 작업에 과거 이력 복원이 필요하지 않다면 `docs/PLAN.md`, archive, TODO 파일 전체를 읽지 않는다.

## Work Management Model

아래 파일들은 작업 context와 상태를 관리하기 위한 것이다.
실제 실행은 항상 `plan -> approval -> implementation -> verification -> status update` 흐름을 따른다.
작업 상태가 바뀌면 `docs/STATUS.md` 업데이트 필요 여부를 제안한다.

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
- `docs/TODO/PHASE{n}/*.md`: Phase가 의도적으로 세부 작업 분해를 필요로 하거나 완료된 Phase 상세를 검토할 때만 사용
- `docs/archive/*.md`: 완료된 Phase의 과거 이력

### Decision Records 관리

**DR-worthy 기준 (하나 이상 해당 시 기록):**
- 도구·프레임워크 선택 (예: Checkstyle vs Spotless, Helm vs Kustomize)
- 아키텍처 경계·정책 결정 (예: CI job 분리 구조, 파일 헤더 없음 정책)
- 되돌리기 비용 Medium 이상
- 두 개 이상 컴포넌트 또는 개발자에 영향

**DR 불필요:**
- 구현 세부사항 (변수명, 줄 순서)
- 버그 수정
- 명확한 범위 내 마이너 config 조정

**트리거 (Claude가 능동적으로 제안하는 시점):**
1. 계획 승인 직후 (구현 시작 전) — 해당 계획의 DR-worthy 결정 목록화 후 일괄 제안
2. STATUS.md의 Open Question이 Closed로 전환될 때
3. `/done` 커맨드 실행 시 (7번 단계)

**묻는 형식 — 목록화 후 일괄 제안:**

> 이번 작업에서 아래 결정이 확정되었습니다. DR로 기록해둘까요?
> - DR-00X: 결정 제목 (reversal cost: Low/Medium/High)

**미결 의사결정 발견 시 (계획 검토 중):**
1. STATUS.md `Blockers And Open Questions`에 OQ-XXX 추가 제안
2. `docs/decisions/DR-XXX.md` Draft 파일 생성 제안

승인 없이 파일을 생성하지 않는다.

**DR 삭제/통합/Superseded 절차:**

DR이 삭제·통합·Superseded 처리될 때 아래 cascade 대상을 함께 업데이트한다.

| 유형 | 판단 기준 |
| --- | --- |
| 삭제 후보 | Draft 장기 유지 + 연결 backlog 없음 + 관련 OQ Closed → 결정 자체가 불필요해진 것 |
| 통합 후보 | 동일·유사 주제가 복수 DR로 분산 |
| Superseded 후보 | 이후 결정으로 내용이 실질적으로 대체되었으나 status가 여전히 Accepted인 것 |

cascade 업데이트 대상:

| 파일 | 업데이트 내용 |
| --- | --- |
| `docs/STATUS.md` Recent Decisions | 해당 항목 제거 또는 수정 |
| `docs/STATUS.md` Blockers/OQ | 연관 OQ Closed 처리 |
| `docs/backlog/PHASE2.md` | DR 번호 참조 항목 수정 |
| `docs/PLAN-SUMMARY.md` | 의사결정 기록 참조 범위 수정 |
| 연관 DR 파일 | Superseded 처리 시 후속 DR 번호 명시 |

승인 없이 파일을 수정·삭제하지 않는다.
`/health` 커맨드 E영역에서 후보 식별 시, cascade 업데이트 대상 목록을 함께 제시한다.

### STATUS.md → Archive 이동

**트리거 (다음 중 하나):**
- Phase의 모든 Checkpoint가 Done 상태로 전환되었을 때
- 새 Phase 시작 전 STATUS.md를 새 Phase 기준으로 재편할 때

**이동 대상:**
- 완료된 Phase의 Active Work 테이블 전체
- 해당 Phase의 Checkpoints 테이블
- 해당 Phase의 Recent Decisions 항목

**절차:**
1. Claude가 트리거 조건 감지 시 이동을 제안한다. 승인 없이 진행하지 않는다.
2. 사용자 승인 후 `docs/archive/phase{n}-status.md`에 이동 내용을 작성한다.
3. STATUS.md에서 이동한 섹션을 제거하고 현재 Phase 내용만 유지한다.

### docs/TODO/PHASE{n}/ 생성

**트리거 (다음 중 하나 이상):**
- 단일 backlog 항목이 3개 이상의 독립 서브태스크로 분해되어야 할 때
- 작업 범위가 3개 이상의 서비스·모듈을 가로질러 상세 조율이 필요할 때
- 사용자가 명시적으로 세부 분해를 요청할 때

**절차:**
1. Claude가 필요성을 제안하고 구조 초안을 제시한다. 승인 없이 생성하지 않는다.
2. 사용자 승인 후 `TODO-BLOCK{n}-{주제}.md` 형식으로 생성한다.
3. 생성 후 STATUS.md의 해당 Active Work 항목에 TODO 파일 경로를 Notes에 추가한다.

## Legacy Phase Task Files

`docs/TODO/PHASE1/TODO-BLOCK*.md`는 폐기된 문서가 아니다.
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
- Phase 1 task details: `docs/TODO/PHASE1/TODO-BLOCK*.md`

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
- `.claude/settings.json` hook 메시지 중 Claude에게 전달되는 instruction — 영어.
- frontmatter 키 (`paths`, `name`, `description` 등) — 도구가 파싱하는 메타데이터.

**한국어로 작성 (기술 용어는 영어 원문 유지):**
- `docs/*.md`, `prompts/*.md`, `docs/decisions/DR-*.md` — 사람이 읽는 문서.
- `.claude/commands/*.md` — 사용자가 직접 읽고 수정하는 slash command. 한국어 유지.
- 기술 용어 (`@Transactional`, N+1, Circuit Breaker 등)는 번역하지 않는다.

## Documentation Rules

MUST:

- `docs/STATUS.md`는 짧고 현재 상태 중심으로 유지한다.
- 완료된 Phase 상세는 `docs/archive/`로 옮긴다.
- `docs/PLAN.md`는 승인된 방향과 아키텍처 중심으로 유지하고 task log로 쓰지 않는다.
- backlog 항목은 실행 가능하고 검증 가능하게 작성한다.

NEVER:

- 같은 긴 규칙 블록을 `CLAUDE.md`, `docs/CLAUDE.md`, `.claude/system.md`에 중복 작성하지 않는다.
