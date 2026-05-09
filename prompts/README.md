# Prompt Library Guide

이 디렉토리는 자주 쓰는 작업 프롬프트 모음이다.

## 1) 프롬프트 종류

- `00~20 *.prompt.md`: 범용(task) 프롬프트
  - Claude, Cursor, ChatGPT, Gemini 등에서 공통 사용 가능
- `claude-session-start.md`, `cursor-start.md`: 세션 부트스트랩 프롬프트
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

- 일반 작업 시작: `00-generic-task.prompt.md`
- 신규 뼈대 생성: `01-scaffold-project.prompt.md`
- 작은 앱 MVP: `02-todo-mvp.prompt.md`
- 기존 기능 1개 추가: `03-add-single-feature.prompt.md`
- UI 개선: `04-improve-ui.prompt.md`
- 에러 원인 분석/수정: `05-debug-error.prompt.md`
- 테스트 먼저 작성: `06-write-tests-first.prompt.md`
- 구조 리팩토링: `07-refactor-code.prompt.md`
- 큰 컴포넌트 분리: `08-split-component.prompt.md`
- API 연동: `09-api-integration.prompt.md`
- 폼 검증: `10-form-validation.prompt.md`
- 상태 관리 정리: `11-state-management.prompt.md`
- 성능 개선: `12-performance-fix.prompt.md`
- 접근성 개선: `13-accessibility-fix.prompt.md`
- 반응형 문제 수정: `14-responsive-fix.prompt.md`
- README 작성: `15-write-readme.prompt.md`
- 코드 리뷰: `16-code-review.prompt.md`
- 재현 후 수정: `17-reproduce-and-fix.prompt.md`
- JS -> TS 마이그레이션: `18-migrate-ts.prompt.md`
- 기능 설계 우선: `19-design-feature.prompt.md`
- 변경사항 요약: `20-summarize-work.prompt.md`

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

- `claude-session-start.md`
  - Claude Code에서 현재 레포 규칙(`CLAUDE.md`, `docs/CLAUDE.md`)을 먼저 반영해 시작할 때 사용
- `cursor-start.md`
  - Cursor 환경에서 Claude와 동일한 컨텍스트 로딩 절차로 세션을 시작할 때 사용

공통 세션 시작 절차 (Claude/Cursor):

1. `CLAUDE.md` -> `docs/CLAUDE.md` -> `docs/STATUS.md` 순서로 읽기
2. 현재 블록의 `docs/TODO/TODO-BLOCK{n}.md` 읽기
3. 상태 요약 + 작업 목록 제시 후 사용자 승인 대기
4. 필요 시 `docs/PLAN.md`, `docs/ARCHITECTURE.md`를 추가 로딩

## 8) 유지보수 규칙

- 새 프롬프트를 추가할 때 `00~20` 파일과 같은 frontmatter 키를 유지한다.
  - `id`, `purpose`, `portability`, `difficulty`, `inputs`, `output_contract`
- 범용 프롬프트(task)와 도구 특화(session)를 섞지 않는다.
- 프롬프트가 길어지면 "입력 예시 1개 + 출력 형식"을 우선 유지한다.
