프로젝트 워크플로우와 문서의 건강 상태를 점검하고 보고한다.

## 실행 원칙

- **구현 금지**: 보고와 제안만 한다. 수정·생성·커밋은 사용자 승인 후에만 진행한다.
- **STATUS 보호**: `docs/STATUS.md` 변경 필요가 발견되면 즉시 수정하지 말고 `STATUS Update Proposal`로 보고한다.
- **컨텍스트 절약**: `CLAUDE.md`와 `docs/AGENT-WORKFLOW.md`는 세션 시작 시 자동 로드됨 — 재읽기 금지.
  파일 목록·상태 확인은 full read 대신 `ls`, `rg` 명령을 우선 사용한다.
- **모드**:
  - (없음) → Quick 모드: A+B+E 영역, ~10개 타깃 읽기, 작업 블록 시작 전 사용
  - `--full` → 전체 모드: A+B+E+F+C+D 영역, 분기별·Phase 전환 전 사용

## 파일 읽기 순서

**Phase 1 — 현재 상태 파악 (1개만)**
`docs/STATUS.md` — CLAUDE.md·docs/AGENT-WORKFLOW.md는 이미 컨텍스트에 있으므로 스킵.

**Phase 2 — 워크플로우 구조 파악 (목록 우선)**
```bash
ls .claude/commands/    # 파일 수·이름 확인
ls .claude/rules/       # 파일 수·이름 확인
```
목록 이상 시에만 해당 파일 내용 확인. 정상이면 전체 로드하지 않는다.

**Phase 3 — 문서 파악 (섹션 단위)**
`docs/HARNESS-PROTOCOL.md` (문서 지도·아이템 위치 결정표만) → `README.md` (구조 블록·AI workflow 섹션만)
→ `docs/PLAN-SUMMARY.md` (기술 스택 테이블만)

(조건부) Validation, STATUS Update Proposal, Commit Gate 정합성 확인이 필요하면
`docs/harness-protocol/06-recovery-and-validation.md`의 해당 섹션만 읽는다.

**Phase 4 — 정렬 파악 (--full 시에만)**
`.cursor/rules/*.mdc` (frontmatter paths만) → `prompts/README.md` (인덱스만, 개별 파일 금지)

**Phase 5 — 현행화 확인 (--full, F영역 전용)**
```bash
# 최근 30일 변경된 구현 파일 목록
git log --since="30 days ago" --name-only --format="" | sort -u | rg "\.(java|kts|yml|xml|sh)$"
```
변경 파일 목록을 기반으로 관련 문서만 선택적 확인.
`docs/decisions/DR-*.md` 상태 확인:
```bash
rg -n "^# |^Status:" docs/decisions
```
제목과 Status 필드만 추출. 내용 읽기는 통합 후보로 의심되는 쌍에만 한정.

## 점검 영역

### A. 워크플로우 구조 정합성

- 각 slash command: 트리거 조건 명확성, Done Criteria 존재, 승인 대기 명시 여부
  (Phase 2에서 목록 확인 후 의심 항목만 내용 확인)
- 각 `.claude/rules/*.md`: `paths` glob이 실제 디렉토리 구조와 일치하는가
- `docs/AGENT-WORKFLOW.md` 워크플로우 기술 ↔ 실제 command 구현 사이 gap
  (이미 컨텍스트에 있는 docs/AGENT-WORKFLOW.md 기준으로 확인)
- command/prompt 종료 요약 ↔ `docs/harness-protocol/06-recovery-and-validation.md`의 Validation Checklist, STATUS Update Proposal, Commit Gate 정합성
- STATUS.md Active Work 항목: Done Criteria + Verification 모두 존재하는가
- DR 생애주기 양방향: STATUS.md Recent Decisions ↔ `rg` 결과의 DR Status 일치

### B. 문서 상호 정합성

- HARNESS-PROTOCOL.md와 `docs/harness-protocol/` 상세 문서 링크 ↔ 실제 파일 목록 일치
- README.md 프로젝트 구조 블록 ↔ 실제 디렉토리 구조
  ```bash
  ls -d */ .github .claude .cursor .devcontainer 2>/dev/null
  ```
- `.claude/rules/*.md` ↔ `.cursor/rules/*.mdc` 정렬 (DR-007 준수 여부)
  (파일 수·파일명 비교로 1차 확인, 내용 비교는 불일치 시에만)
- Language Rules 위반: `docs/*.md`가 영어 작성, `.claude/rules/*.md`가 한국어 작성된 경우
- STATUS.md Next Actions 순서 ↔ Active Work Priority/Status 논리 일관성

### C. Claude Code 기능 정렬 (--full)

- `.claude/settings.json`: `defaultMode`, `permissions.deny` 목록 현행성, hooks 설정
- MCP 서버 설정 상태 및 실제 활용 가능성
- Phase 2에서 읽은 rule/command 기반으로 중복 instruction·비효율 탐지
  (추가 파일 로드 없이 이미 확인한 내용에서 판단)

### D. Vibe Coding / Prompt Engineering (--full)

- plan→approve→implement 3단계가 모든 command에 명시적으로 강제되는가
  (Phase 2 목록 확인 시 의심 항목만 내용 확인)
- 트리거 조건이 "상황에 따라"처럼 모호하게 기술된 항목
- 각 command의 출력 형식이 명시되어 있는가
- `prompts/README.md` 인덱스 기준으로 Phase 2 대비 누락 유형 확인
  (개별 prompt 파일은 로드하지 않는다)

### E. 백로그/DR 위생

- STATUS.md Active Work: Verification 완료되었으나 Done 처리가 지연된 항목
- `docs/backlog/PHASE{n}.md`: product/preparation 항목 중 선행 조건이 이미 충족된 항목, 범위·우선순위 재검토 필요 항목
- `docs/backlog/HARNESS.md`: harness 항목 중 완료되었거나 새 상태 머신과 충돌하는 항목, hard enforcement 후보
- DR 상태 확인 (Phase 5 `rg` 결과 재사용):
  - Draft 상태이나 결정이 실질적으로 완료된 DR → Accepted 처리 필요
  - STATUS.md Blockers/OQ 중 이미 해소되었으나 Closed 처리 누락
  - DR ↔ backlog 연결: `Linked Backlog Items` 섹션 누락·오기
- **DR 삭제/통합/Superseded 후보 식별**:
  - *1단계 (파일명 기반)*: DR 파일명에서 주제 키워드 추출 → 유사 주제 후보 그루핑
  - *2단계 (내용 확인)*: 1단계에서 의심되는 쌍에 한해서만 내용 비교
  - 삭제 후보: Draft 장기 유지 + 연결 backlog 없음 + 관련 OQ Closed
  - 통합 후보: 동일·유사 주제 복수 DR (1단계 필터 후 확인)
  - Superseded 후보: 이후 결정으로 실질적으로 대체되었으나 Accepted 유지
  - 후보 발견 시, cascade 업데이트 대상을 함께 제시:
    `docs/STATUS.md` / 관련 backlog(`PHASE{n}.md` 또는 `HARNESS.md`) DR 참조 항목 /
    `docs/PLAN-SUMMARY.md` DR 범위 / 연관 DR 파일

### F. 구현 반영 현행화 (--full)

Phase 5의 git log 결과를 기준으로, 변경된 구현 파일 유형별로 관련 문서만 선택 확인한다.

| 변경 파일 유형 | 확인 대상 문서 |
|---------------|---------------|
| `*.java`, `*.kts` (새 모듈·레이어) | `README.md` 기술 스택, `PLAN-SUMMARY.md` |
| `Dockerfile`, `docker-compose.yml` | `DOCKERFILE-GUIDE.md`, `README.md` 셋업 |
| `.github/workflows/*.yml` | `README.md` CI 항목, `DEVELOPER-GUIDE.md` CI 섹션 |
| `.claude/commands/*.md` (신규) | `HARNESS-PROTOCOL.md` 또는 `docs/harness-protocol/`, `README.md` AI workflow 섹션 |
| `config/checkstyle/**`, `.editorconfig` | `DEVELOPER-GUIDE.md` 코드 컨벤션 섹션 |
| `docs/decisions/DR-*.md` (신규 Accepted) | STATUS.md Recent Decisions, 연관 backlog Done Criteria |

STATUS.md Recent Decisions는 **최근 8개 항목만** 대상으로 한다.
전체 이력 점검은 명시적 요청 시에만 진행한다.

`docs/DEVELOPER-GUIDE.md`는 아래 변경이 감지될 때만 읽는다:
- 새 도구 도입 (git hooks, Checkstyle 등)
- API 추가 절차 또는 코드 컨벤션 정책 변경

`docs/PLAN.md`는 제목·섹션 헤더 수준만 확인한다:
```bash
rg -n "^## |^### " docs/PLAN.md
```

## 보고 형식

```
## 종합 상태: [🟢 양호 / 🟡 주의 필요 / 🔴 조치 필요]

## 영역별 요약
| 영역 | 상태 | 발견 항목 수 |
|------|------|-------------|
| A. 구조 정합성      | 🟢/🟡/🔴 | n건 |
| B. 문서 정합성      | 🟢/🟡/🔴 | n건 |
| E. 백로그/DR 위생   | 🟢/🟡/🔴 | n건 |
| (F. 현행화)        | 🟢/🟡/🔴 | n건 |

## 상세 발견 항목

### [영역명]
- [✓ / ⚠ / ✗] 항목명: 세부 내용

## 개선 제안
P0 (즉시 — 승인 후 적용 가능):
P1 (계획 필요):
P2 (선택적 개선):
```

STATUS.md 변경이 필요한 발견 항목은 `STATUS Update Proposal` 섹션으로 별도 제안한다.
보고 후 "승인하신 항목부터 진행할까요?"로 끝낸다.
