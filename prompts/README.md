# Prompt Library Guide

이 디렉토리는 자주 쓰는 작업 프롬프트 모음이다.

현재 총 **23개** 범용 프롬프트 (`00~22`) + 세션 부트스트랩 2개.

## 1) 프롬프트 종류

- `00~22 *.prompt.md`: 범용(task) 프롬프트
  - Claude, Cursor, ChatGPT, Gemini 등에서 공통 사용 가능
  - `00~20`: 일반 범용, `21~22`: Spring Boot 백엔드 특화
- `claude-session-start.md`, `cursor-session-start.md`: 세션 부트스트랩 프롬프트
  - 특정 도구/레포 운영 규칙에 맞춘 특화 프롬프트

## 2) 빠른 사용 절차 (초심자용)

1. 하고 싶은 작업 유형을 고른다. (아래 선택표 참고)
2. 해당 `.prompt.md` 파일 내용을 복사한다.
3. `{{...}}` 변수 자리에 내 프로젝트 정보/요청을 채운다.
4. AI 채팅에 붙여넣고 실행한다.
5. 결과에서 다음 4가지를 확인한다.
   - 계획
   - 변경(또는 제안)
   - 검증 방법
   - 리스크/가정
6. 결과가 애매하면 입력을 더 구체적으로 보강해서 다시 실행한다.

## 3) 프롬프트 선택표

### 일반

- 일반 작업 시작: `00-generic-task.prompt.md`
- 신규 뼈대 생성: `01-scaffold-project.prompt.md`
- 기존 기능 1개 추가 (단계 분리): `03-add-single-feature.prompt.md`
- 에러 원인 분석/수정 (minimal patch): `05-debug-error.prompt.md`
- 테스트 먼저 작성 (JUnit5/Mockito/AssertJ): `06-write-tests-first.prompt.md`
- 구조 리팩토링 (API contract 불변): `07-refactor-code.prompt.md`
- API 연동: `09-api-integration.prompt.md`
- README 작성: `15-write-readme.prompt.md`
- 코드 리뷰 (Spring 안티패턴 체크): `16-code-review.prompt.md`
- 재현 후 수정: `17-reproduce-and-fix.prompt.md`
- 기능 설계 우선: `19-design-feature.prompt.md`
- 변경사항 요약: `20-summarize-work.prompt.md`

### Spring Boot 백엔드 특화

- 서비스 신규 생성 (구조 포함): `02-scaffold-service.prompt.md`
- 보안 검토 (Spring Security / JWT): `04-security-review.prompt.md`
- 서비스 분리 리팩토링: `08-split-service.prompt.md`
- 입력 검증 및 예외 처리 추가: `10-add-validation.prompt.md`
- Resilience4j 내결함성 추가: `11-add-resilience.prompt.md`
- 성능 개선 (N+1 / JVM / 캐시): `12-performance-fix.prompt.md`
- Micrometer 메트릭 추가: `13-add-metrics.prompt.md`
- DB 마이그레이션 스크립트 작성: `14-write-migration.prompt.md`
- 캐시 레이어 추가 (Redis): `18-add-cache.prompt.md`
- 레이어별 코드 생성 (Controller/Service/Repository): `21-create-layer.prompt.md`
- 최소 수정 강제 (지정 부분만): `22-minimal-diff.prompt.md`

## 4) 추천 시작 3개 프롬프트 (초심자 스타터팩)

- `00-generic-task.prompt.md` (첫 시작용)
  - 언제 쓰나: 무엇부터 해야 할지 애매할 때
  - 왜 추천하나: 범위 정의 + 단계별 진행 + 리스크 확인을 한 번에 잡아줌
  - 입력 예시: `{{goal}} = "회원가입 API에 이메일 형식 검증 추가"`
- `05-debug-error.prompt.md` (문제 해결용)
  - 언제 쓰나: 에러 로그가 있고 원인/수정이 필요한 상황
  - 왜 추천하나: 재현, 원인 후보, 수정, 검증까지 흐름이 안정적임
  - 입력 예시: `{{error_log}} = "POST /login 500, NullPointerException at AuthService"`
- `20-summarize-work.prompt.md` (정리/공유용)
  - 언제 쓰나: 작업 종료 후 PR 설명, 팀 공유, 일일 보고 작성 시
  - 왜 추천하나: 핵심 변경/리스크/다음 액션을 짧게 정리 가능
  - 입력 예시: `{{change_scope}} = "auth-service 토큰 갱신 로직 + 테스트"`

초심자 권장 순서:

1. `00`으로 시작해 작업 범위와 접근을 고정
2. 문제 발생 시 `05`로 원인 분석/수정
3. 마무리는 `20`으로 결과 공유

## 5) 입력을 잘 쓰는 요령

- 나쁜 예: "버그 고쳐줘"
- 좋은 예: "로그인 시 500 에러가 발생. 재현: 이메일 로그인 -> submit. 기대: 토큰 발급, 실제: NullPointerException"

- 나쁜 예: "UI 좀 개선"
- 좋은 예: "모바일(375px)에서 카드가 잘림. 버튼 터치 영역 44px 이상, 대비 4.5:1 유지"

## 6) 결과 품질 체크리스트

- 범위 밖 변경을 하지 않았는가?
- 기존 동작이 깨지지 않는가?
- 검증 방법이 구체적인가?
- 리스크/가정/되돌리기 비용이 적혀 있는가?

## 7) 도구 특화 프롬프트 사용 시점

- **Claude Code** (권장): `.claude/commands/` 슬래시 커맨드를 사용한다.
  - `/start` — 세션 시작, STATUS.md 상태 요약
  - `/pick` — Phase 2 백로그에서 작업 선택
  - `/work P2-001` — 특정 백로그 항목 계획 수립
  - `/resume` — 중단된 작업 재개
  - `/debug` — 에러 분석/리팩토링 시작
  - `/done` — 세션 종료 요약
  - `/record-decision` — 확정된 기술 결정을 DR로 기록
  - `/health` — 워크플로우·문서 정합성 점검 (`--full`로 심화 점검)
- **`claude-session-start.md`**: Claude Code 슬래시 커맨드를 사용할 수 없는 환경에서 복붙용
- **`cursor-session-start.md`**: Cursor 환경에서 동일한 컨텍스트 로딩 절차로 세션 시작

공통 세션 시작 절차 (Claude/Cursor):

1. `CLAUDE.md` → `docs/CLAUDE.md` → `docs/STATUS.md` 순서로 읽기
2. 필요 시 `docs/PLAN-SUMMARY.md`(핵심 요약) 또는 `docs/PLAN.md`(전체 기술 근거) 로딩
3. 상태 요약 + 작업 목록 제시 후 사용자 승인 대기

## 8) 유지보수 규칙

- 새 프롬프트를 추가할 때 기존 파일과 같은 frontmatter 키를 유지한다.
  - `id`, `purpose`, `portability`, `difficulty`, `inputs`, `output_contract`
- 범용 프롬프트(task)와 도구 특화(session)를 섞지 않는다.
- 프롬프트가 길어지면 "입력 예시 1개 + 출력 형식"을 우선 유지한다.
- Spring Boot 특화 프롬프트(`21~`)는 `io.kyungseo.msa` 패키지 규칙을 따른다.
- 새 슬래시 커맨드는 `.claude/commands/`에 추가하고 이 README 섹션 7에 반영한다.
