# HRF-002: Work 파일 기반 운영 체계 도입 — 리뷰 요청서

작성일: 2026-05-18
상태: 리뷰 요청
범위: Work 파일 체계 도입, docs/works/ 구조 정비, STATUS 전환, AI 도구 정렬, 시뮬레이션 검증, DR-013/014/015

## 참고 문서

| 문서 | 경로 |
| --- | --- |
| HRF-002 Work 파일 | [`docs/works/harness/HRF-002-work-system-refactor.md`](../works/harness/HRF-002-work-system-refactor.md) |
| 실행 계획 (Plan) | `/Users/kyungseo/.claude/plans/soft-knitting-quill.md` |
| DR-013: Work 파일 스펙 | [`docs/decisions/DR-013-work-file-spec.md`](../decisions/DR-013-work-file-spec.md) |
| DR-014: Archive 정책 | [`docs/decisions/DR-014-archive-policy.md`](../decisions/DR-014-archive-policy.md) |
| DR-015: State Update Proposal 재설계 | [`docs/decisions/DR-015-state-update-proposal-redesign.md`](../decisions/DR-015-state-update-proposal-redesign.md) |
| HRF-001 리뷰 결과 | [`docs/retrospectives/harness-refactor-review-result-20260515.md`](harness-refactor-review-result-20260515.md) |
| HRF-001 리뷰 요청서 | [`docs/retrospectives/harness-refactor-review-request-20260515.md`](harness-refactor-review-request-20260515.md) |
| Work 항목·네이밍 규칙 | [`docs/harness-protocol/03-work-items-and-naming.md`](../harness-protocol/03-work-items-and-naming.md) |
| Archive 라이프사이클 | [`docs/harness-protocol/04-document-lifecycle.md`](../harness-protocol/04-document-lifecycle.md) |
| 상태 기준 문서 | [`docs/STATUS.md`](../STATUS.md) |
| 워크플로우 매뉴얼 | [`docs/WORKFLOW-MANUAL.md`](../WORKFLOW-MANUAL.md) |
| 하네스 backlog (HRN-017) | [`docs/backlog/HARNESS.md`](../backlog/HARNESS.md) |

## 관련 커밋

| 커밋 | 내용 |
| --- | --- |
| `3288155` | HRF-002 Phase 0~A — DR-013/014 작성, git 태그 및 스냅샷 생성 |
| `4ebb5c9` | HRF-002 Phase B — 데이터 클린징 및 STATUS 구조 전환 |
| `44202d1` | HRF-002 Phase C — docs/works/ 구조 도입 및 archive 정비 |
| `ad9ed2f` | HRF-002 Phase D — STATUS 최종 정비 및 Work File Rules 확립 |
| `3955806` | HRF-002 Phase E — AI 도구 경로 참조 전환 (docs/TODO → docs/works) |
| `89b22bb` | HRF-002 Phase F — 하네스 문서 docs/works/ 경로 전환 |
| `604e4b9` | HRF-002 Phase G — 시뮬레이션 검증 및 갭 수정 (G2: 5개 갭) |
| `2779ba9` | HRF-002 Phase H — README/매뉴얼 정렬 |
| `e24fe5e` | DR-015 기록 및 HRF-002 리뷰 요청 문서 작성 |
| `6da7fe5` | G3 시뮬레이션 갭 수정 — create-harness.sh Work 파일 구조 동기화 (5개 갭) |
| `8561c3b` | HRN-017 등록 — DR-015 2계층 State Update Proposal 구현 후속 추적 |

---

## 1. 리뷰 목적

이 문서는 HRF-002 작업의 전체 과정을 외부 검토자가 평가할 수 있도록 정리한 리뷰 요청서다.

HRF-001(Phase 1 완료 후 AI Workflow Harness 리팩터링)에서 경량 상태 머신 기반 운영 체계가 확립됐다. HRF-002는 그 위에 **Work 파일 기반 작업 단위 체계**를 도입해 아래 문제를 해결하는 것이 목적이다.

- `STATUS.md` 비대화 — 모든 이력이 쌓이면 롤링 윈도우로 소실됨
- 세션 간 작업 맥락 손실 — Checkpoint가 사후 히스토리로만 기능
- AI 도구 간 작업 라우팅 불명확 — Work 파일 경로 참조 없음
- `docs/TODO/` 미활용 및 UPPERCASE 명명 불일치

리뷰어에게 확인받고 싶은 핵심 질문:

- Work 파일이 STATUS.md를 SSoT로 대체하는 구조 전환이 올바른가?
- 2계층 State Update Proposal 게이트(DR-015)가 실용적인가?
- 멀티 Active Work 시나리오에서 Work 파일 독립 게이트 원칙이 충분한가?
- 시뮬레이션 G2에서 발견된 5개 갭이 적절히 수정되었는가?
- Work File Rules의 위치(protocol 문서, 개별 Work 파일에는 반복 안 함)가 옳은가?

---

## 2. 도입 배경: 사용자 제안

HRF-002는 아래 관찰에서 시작됐다.

### 2.1 기존 구조의 문제

HRF-001 완료 시점의 STATUS.md는 약 200줄이었다. Done 처리된 Active Work 11개, Checkpoints 19개가 누적되어 있었고, 실제 현재 상태와 이력이 혼재했다. 롤링 윈도우 정책(DR-011)으로 Recent Decisions는 관리됐지만, Active Work와 Checkpoints는 무제한 성장하고 있었다.

핵심 문제: **Checkpoints가 사전 완료 기준이 아니라 사후 히스토리로 기능**하고 있었다. Agent가 긴 작업을 중단하고 재개할 때 어디까지 했는지 명확하지 않았고, STATUS.md에서 작업 이력을 읽는 비용이 높아졌다.

### 2.2 Work 파일 아이디어

사용자 제안: "작업 단위별로 독립 파일을 만들어 그 파일이 작업 내용, Checkpoints, 완료 기준의 SSoT가 되게 하고, STATUS.md는 포인터만 담게 하자."

이 아이디어는 ADR(Architecture Decision Record), Shape Up의 pitch/RFC 방식, 그리고 git-based issue tracking 패턴에서 영감을 받았다. Shape Up의 `appetite` 개념(작업에 배정할 최대 시간 상자)도 함께 도입하기로 했다.

---

## 3. 계획 수립: soft-knitting-quill 실행 계획

2026-05-18에 Claude Code Plan 모드로 전체 실행 계획을 수립했다. 계획은 `/Users/kyungseo/.claude/plans/soft-knitting-quill.md`에 기록되어 있다.

### 3.1 AS-IS / TO-BE

```
AS-IS                                    TO-BE
docs/                                    docs/
├── TODO/         ← UPPERCASE + 이름 부적절 ├── works/       ← 소문자 + Work 개념
│   ├── PHASE1/   ← UPPERCASE            │   ├── harness/
│   └── PHASE2/   ← 비어 있음            │   └── phase2/
├── archive/                             ├── archive/
│   └── harness-refactor-20260514/       │   ├── docs/        ← 경로 미러링
└── STATUS.md     ← 모든 것 포함          │   ├── prompts/
                                         │   └── snapshots/
                                         └── STATUS.md  ← 포인터 + Phase 기준만
```

### 3.2 Work 파일 스펙 (DR-013 핵심)

```yaml
---
id: {ID}
priority: {P0|P1|P2|P3}
status: {Candidate|Active|Done|Archived}
risk: {Low|Medium|High}
scope: {한 줄 범위 설명}
appetite: {1d|3d|1w|2w}           # Shape Up 개념 도입
planned_start: YYYY-MM-DD
planned_end: YYYY-MM-DD
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan          — 접근 방법 + Alternatives
## Done Criteria — 사전 완료 기준 (체크박스)
## Verification  — 검증 명령
## Checkpoints   — CP 테이블 (Todo → Done)
## Discovery     — 계획과 달라진 것, 새 발견
```

### 3.3 10개 Phase 구조

| Phase | 내용 | Gate |
| --- | --- | --- |
| 0 | 안전망 (git tag, STATUS 스냅샷) | git status clean |
| A | Spec 확정 (DR-013, DR-014 작성) | 사용자 DR 승인 |
| B | 데이터 클린징 (Done 항목 아카이브) | STATUS Update Proposal 승인 |
| C | 구조 정비 (docs/TODO/ → docs/works/, 소문자 전환) | find 소문자 확인 |
| D | STATUS.md 리팩토링 (포인터만 남기기) | STATUS Update Proposal 승인 |
| E | AI 도구 정렬 (Claude/Codex/Cursor/prompts) | 도구별 진입점 정렬 확인 |
| F | 하네스 문서 업데이트 | 프로토콜 문서 Work 파일 서술 완료 |
| G | 시뮬레이션 검증 (E2E 흐름) | 3개 도구 갭 없음 |
| H | README/매뉴얼 정렬 | 모든 README 일치 |
| I | 최종 검증 (/health 통과) | /health 통과 |

---

## 4. 실행 단계별 상세

### Phase 0 — 안전망

- `git tag hrf-002-start` 생성
- `docs/archive/snapshots/STATUS-before-hrf-002.md` 복사
- DR-013 번호 연속성 확인 (DR-012 다음)
- branch: `feature/p2-pre01` (기존 브랜치 그대로 사용)

### Phase A — Spec 확정

**DR-013: Work 파일 스펙** (`docs/decisions/DR-013-work-file-spec.md`)
- Work 파일 포맷 정의 (frontmatter + 섹션 구조)
- 상태 lifecycle: Candidate → Active → Done → Archived
- `docs/works/{category}/` 경로 정책

**DR-014: Archive 구조 정책** (`docs/decisions/DR-014-archive-policy.md`)
- 경로 미러링: `docs/archive/{원본-경로}/{파일명}.ext`
- 버전 접미사: `-v{N}`, 날짜 접미사: `-{YYYYMMDD}`
- 완료된 Work 파일: `docs/archive/docs/works/{category}/{ID}-{topic}.md`

**HARNESS.md HRF-002 등록**: Candidate → Active 전환

### Phase B — 데이터 클린징

- STATUS.md의 Done Active Work 11개와 CP-HRF-1~19 Checkpoints 아카이브
- `docs/archive/snapshots/hrf-001-completion/`으로 이동
- `temp/create-harness-test/` 삭제
- `prompts/.bak` 파일 삭제
- STATUS.md에 STATUS Update Proposal 적용 후 승인 받아 정리

### Phase C — 구조 정비

**디렉토리 리네이밍 (macOS 대소문자 비구분 FS 주의)**

macOS 대소문자 비구분 파일시스템에서 대소문자만 다른 리네임은 직접 불가. 2단계 필요:

```bash
# 완전히 다른 이름 — 1단계
git mv docs/TODO docs/works

# 대소문자만 다름 — 2단계 (중간 이름 경유)
git mv docs/works/PHASE1 docs/works/phase1-tmp
git mv docs/works/phase1-tmp docs/works/phase1

# 빈 디렉토리 (git이 추적하지 않음) — OS mv로 처리
mv docs/works/PHASE2 docs/works/phase2
```

**archive 구조 정비**

```
docs/archive/
├── docs/                           ← 새로 생성 (경로 미러링)
│   └── works/                      ← 완료 Work 파일 이동 경로
├── prompts/                        ← 새로 생성
└── snapshots/                      ← 기존 스냅샷 이동
    ├── harness-refactor-20260514/  ← 기존 archive 이동
    ├── hrf-001-completion/         ← Phase B에서 생성
    └── STATUS-before-hrf-002.md
```

**HRF-002 Work 파일 생성**: `docs/works/harness/HRF-002-work-system-refactor.md`

**발견 사항**: `scripts/create-harness.sh`에 `docs/works/PHASE{n}`이 대문자로 잘못 기재됨 → `replace_all`로 일괄 수정

### Phase D — STATUS.md 리팩토링

**STATUS Update Proposal 승인 후 적용.**

변경 내용:
- 75줄 → 61줄로 축소
- Active Work 섹션: 세부 내용 제거, Work 파일 포인터만 남김

  ```markdown
  | ID | Status | Work File |
  | HRF-002 | Active | docs/works/harness/HRF-002-work-system-refactor.md |
  ```

- Work Context Rule: 상태 머신 다이어그램 제거, 간결한 규칙 2줄만
- Recent Decisions: 8개 → 4개 (DR-011 rolling window 정책 적용)
- Pre-refactor backup 경로 수정: `docs/archive/snapshots/harness-refactor-20260514/`

### Phase E — AI 도구 정렬

`docs/TODO/PHASE{n}/` → `docs/works/{category}/` 참조 전수 교체.

| 파일 | 변경 내용 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | MUST NOT 항목, Context Routing, Work Item Routing 경로 갱신 |
| `.claude/rules/docs-workflow.md` | Work files 경로 갱신 |
| `.cursor/rules/coding.mdc` | 동일 |
| `prompts/cursor-session-start.md` | 동일 |
| `prompts/codex-session-start.md` | 동일 |

### Phase F — 하네스 문서 업데이트

| 파일 | 변경 내용 |
| --- | --- |
| `docs/harness-protocol/03-work-items-and-naming.md` | "Where To Put Items", "File Naming" 표, "TODO Decomposition" → "Work File Decomposition" 섹션명, **Work File Rules 섹션 신규 추가** |
| `docs/harness-protocol/02-context-loading.md` | 경로 갱신 |
| `docs/harness-protocol/04-document-lifecycle.md` | 경로 갱신, archive 이동 트리거 반영 |
| `docs/HARNESS-PROTOCOL.md` | 경로 갱신 |
| `docs/HARNESS-QUICK-REFERENCE.md` | Work 파일 관련 quick-ref 항목 추가 |
| `docs/decisions/DR-008-docs-filename-standard.md` | File Naming 표 갱신, Consequences 업데이트 |
| `docs/decisions/DR-013-work-file-spec.md` | "Work 파일 운영 규칙" 섹션 추가 (Work File Rules 위치 명시) |

**Work File Rules 신규 추가** — `docs/harness-protocol/03-work-items-and-naming.md`:

> Work 파일과 실제 저장소 상태가 충돌하면 실제 저장소 상태가 진실이다.  
> 불일치 발견 시 Work 파일을 현행화하고 Discovery 섹션에 기록한다.  
> 이 섹션이 Work 파일 공통 운영 규칙의 권위 문서다. 개별 Work 파일은 이 규칙을 반복하지 않는다.

### Phase G — 시뮬레이션 검증

#### G1. PRE-C1 Work 파일 E2E 테스트

`docs/works/phase2/PRE-C1-arch-analysis.md`를 Candidate 상태로 생성했다. Done → Archive 흐름은 별도 세션에서 실제 작업 착수 시 수행 예정.

`docs/works/phase2/README.md`에 PRE-C1 Candidate 행 추가.

#### G2. 세션 흐름 시뮬레이션 — 발견된 5개 갭

**Claude Code 시뮬레이션:**

갭 1: `/work` 명령이 `docs/works/{category}/` Work 파일 존재 여부를 확인하는 절차가 없음  
→ `.claude/commands/work.md`에 "Work File Check" 섹션 추가

갭 2: `/resume` 명령이 Work 파일 Checkpoints drift 체크를 하지 않음  
→ `.claude/commands/resume.md`에 "Active Work에 Work 파일 포인터가 있으면 해당 Work 파일도 읽어줘. Checkpoints와 실제 파일 상태 일치 여부 확인" 추가

갭 3: `/done` 명령이 Work 파일 Done→Archive 흐름을 안내하지 않음  
→ `.claude/commands/done.md`에 항목 11 추가: `status: Done`, `actual_end` 기입, git mv로 archive 이동, README 업데이트, STATUS 포인터 제거 제안

**Codex 시뮬레이션:**

갭 4: `AGENTS.md`의 `/work`, `/resume`, `/done` 설명에 Work 파일 참조 없음  
→ `AGENTS.md` 세 곳 업데이트: Work 파일 생성/Checkpoints drift 체크/Done→Archive 흐름 추가

**Cursor 시뮬레이션:**

갭 5: `.cursor/rules/workflow.mdc`에 Work 파일 착수·완료 절차 없음  
→ Work file start procedure (docs/works/{category}/ 확인) 및 Work file completion procedure (Done→Archive via git mv) 추가

### Phase H — README/매뉴얼 정렬

| 파일 | 변경 내용 |
| --- | --- |
| `docs/WORKFLOW-MANUAL.md` | `docs/TODO/` 경로 참조 전수 변환, 디렉토리 다이어그램 `TODO/ → works/`, Work 파일 섹션 전면 재작성 (DR-013 frontmatter 템플릿, 착수 3단계, 완료 5단계), ToC Work File Lifecycle 앵커 추가 |
| `README.md` | AI Workflow Harness 테이블에 `docs/works/` 행 추가 |

### Phase I — 최종 검증 (/health)

`/health` Quick 모드 실행 결과:

**🟡 Needs Attention** — 2건

1. (P0) `STATUS.md` Next Actions가 Phase G, H를 가리키고 있으나 완료됨 → STATUS Update Proposal 필요
2. (P1) `docs/backlog/HARNESS.md`의 HRN-006이 완료됐음에도 Open 상태 유지 → Closed 처리 필요

HRF-002 Done Criteria 9개 중 8개 완료. 나머지: `/health 통과` (STATUS Update Proposal 승인 + Closed 처리 후 통과 예정)

---

## 5. 세션 중 주요 설계 결정

### 5.1 Work File Rules 위치 결정

**발단**: "Work 파일과 실제 저장소 상태가 충돌하면 실제 파일 상태를 우선한다"는 규칙을 어디에 두어야 하는가?

후보:
- A. 각 Work 파일에 반복 기재
- B. Protocol 문서(03-work-items-and-naming.md)에 한 번만, Work 파일은 참조

**결정**: B를 선택. 멀티 Active Work 환경에서 규칙을 Work 파일마다 복사하면 수정 시 동기화 문제가 생긴다. Protocol 문서의 Work File Rules 섹션이 권위 문서이고, DR-013이 이를 참조하도록 업데이트했다.

### 5.2 DR-015: State Update Proposal 2계층 게이트 재설계

**발단**: HRF-001에서 도입한 "STATUS Update Proposal" 게이트가 Work 파일 SSoT 전환 이후 역전된 구조를 만들고 있다.

- Work 파일 Checkpoint 업데이트 → 게이트 없음 (AI가 자유롭게 수정)
- STATUS.md 포인터 한 줄 추가 → 무거운 Proposal 필요

위험도가 낮은 변경에 더 무거운 게이트가 붙어 있는 구조.

**결정**: "STATUS Update Proposal"을 "State Update Proposal"로 확장하고 2계층으로 차등 적용.

| Layer | 변경 유형 | 게이트 |
| --- | --- | --- |
| Layer 1 (Work 파일) | Checkpoint/Discovery 업데이트 | 없음 — 실행 후 보고 |
| Layer 1 (Work 파일) | `status: Done`, `actual_end` 기입 | 명시적 사용자 확인 필요 |
| Layer 2 (STATUS.md) | Active Work 포인터 추가/제거 | 인라인 1줄 제안 |
| Layer 2 (STATUS.md) | Phase 완료 기준 체크 또는 focus 변경 | 현행 Proposal 유지 |

멀티 Active Work 규칙: AI가 State Update 제안 시 대상 Work 파일 ID를 항상 명시 (예: "HRF-002 CP5 Done으로 업데이트하겠습니다").

### 5.3 macOS 대소문자 비구분 FS 처리

`PHASE1` → `phase1` 리네임은 macOS에서 직접 `git mv` 불가. 2단계 중간 이름 경유 방식으로 처리했다. 이 패턴은 Discovery 섹션에 기록해 유사 상황 발생 시 참조 가능.

---

## 6. 전체 변경 파일 목록

### 신규 생성

| 파일 | 내용 |
| --- | --- |
| `docs/works/harness/HRF-002-work-system-refactor.md` | HRF-002 Work 파일 |
| `docs/works/harness/README.md` | Harness work 인덱스 |
| `docs/works/phase2/README.md` | Phase 2 work 인덱스 |
| `docs/works/phase2/PRE-C1-arch-analysis.md` | Phase 1 아키텍처 분석 Candidate Work 파일 |
| `docs/decisions/DR-013-work-file-spec.md` | Work 파일 스펙 |
| `docs/decisions/DR-014-archive-policy.md` | Archive 구조 정책 |
| `docs/decisions/DR-015-state-update-proposal-redesign.md` | State Update Proposal 2계층 게이트 |
| `docs/archive/docs/` | 경로 미러링 archive 디렉토리 |
| `docs/archive/prompts/` | prompts archive 디렉토리 |
| `docs/archive/snapshots/STATUS-before-hrf-002.md` | STATUS.md 사전 스냅샷 |
| `docs/archive/snapshots/hrf-001-completion/` | HRF-001 완료 상태 아카이브 |

### 디렉토리 리네이밍

| 변경 전 | 변경 후 |
| --- | --- |
| `docs/TODO/` | `docs/works/` |
| `docs/works/PHASE1/` | `docs/works/phase1/` |
| `docs/works/PHASE2/` | `docs/works/phase2/` |
| `docs/archive/harness-refactor-20260514/TODO-PHASE1/` | `docs/archive/snapshots/harness-refactor-20260514/todo-phase1/` |
| `docs/archive/harness-refactor-20260514/` | `docs/archive/snapshots/harness-refactor-20260514/` |
| `docs/archive/phase1-plan.md`, `phase1-status.md` | `docs/archive/snapshots/` 이동 |

### 수정된 파일

**AI 도구 진입점 및 규칙**

| 파일 | 주요 변경 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Context Routing, Work Item Routing 경로 갱신 (`docs/TODO/` → `docs/works/`) |
| `AGENTS.md` | `/work`, `/resume`, `/done` Work 파일 관련 절차 추가 |
| `.claude/commands/work.md` | Work File Check 섹션 신규 추가 (갭 1 수정) |
| `.claude/commands/resume.md` | Work 파일 Checkpoints drift 체크 추가 (갭 2 수정) |
| `.claude/commands/done.md` | Work 파일 Done→Archive 흐름 항목 11 추가 (갭 3 수정) |
| `.claude/rules/docs-workflow.md` | Work files 경로 갱신 |
| `.cursor/rules/workflow.mdc` | Work 파일 착수/완료 절차 추가 (갭 5 수정) |
| `.cursor/rules/coding.mdc` | 경로 갱신 |
| `prompts/cursor-session-start.md` | 경로 갱신 |
| `prompts/codex-session-start.md` | 경로 갱신 |

**하네스 프로토콜 문서**

| 파일 | 주요 변경 |
| --- | --- |
| `docs/harness-protocol/03-work-items-and-naming.md` | **Work File Rules 섹션 신규 추가**, "TODO Decomposition" → "Work File Decomposition" 섹션 개명, 경로 갱신 |
| `docs/harness-protocol/02-context-loading.md` | 경로 갱신 |
| `docs/harness-protocol/04-document-lifecycle.md` | 경로 갱신, archive 트리거 반영 |
| `docs/HARNESS-PROTOCOL.md` | 경로 갱신 |
| `docs/HARNESS-QUICK-REFERENCE.md` | Work 파일 quick-ref 항목 추가 |
| `docs/decisions/DR-013-work-file-spec.md` | Work 파일 운영 규칙 섹션 추가 (Work File Rules 위치 명시) |
| `docs/decisions/DR-008-docs-filename-standard.md` | File Naming 표 갱신, Consequences 업데이트 |

**사용자 대면 문서**

| 파일 | 주요 변경 |
| --- | --- |
| `docs/WORKFLOW-MANUAL.md` | 디렉토리 다이어그램 갱신, Work 파일 섹션 전면 재작성 (DR-013 템플릿 + 착수/완료 절차), 경로 참조 전수 변환 |
| `README.md` | AI Workflow Harness 표에 `docs/works/` 행 추가 |

**상태 및 스크립트**

| 파일 | 주요 변경 |
| --- | --- |
| `docs/STATUS.md` | 75줄 → 61줄, Work 파일 포인터 형식 전환, Recent Decisions 4개로 축소 |
| `scripts/create-harness.sh` | 3개 경로: `docs/TODO/PHASE{n}/` → `docs/works/phase{n}/` (소문자) |

---

## 7. Discovery: 계획과 달라진 것

HRF-002 Work 파일 Discovery 섹션에 기록된 항목들:

1. **macOS case-insensitive FS에서 git mv 추적 교차**: 동일 내용 파일 간 리네임 추적이 교차될 수 있으나 실제 파일 위치는 정확.
2. **docs/works/PHASE2/ 빈 디렉토리**: git이 추적하지 않아 OS mv로 처리.
3. **TODO-BLOCK*.md 파일들**: Phase 1 완료 당시 작업 단위로, 구형 형식(Work 파일 이전). `docs/works/phase1/`에 유지하되 신규 Work 파일과 형식이 다름.
4. **Work File Rules 위치**: 개별 Work 파일이 아닌 `docs/harness-protocol/03-work-items-and-naming.md`에 위치. DR-013이 해당 섹션을 권위 문서로 참조.
5. **`scripts/create-harness.sh` 대문자 오류**: Phase C 커밋 직전 발견. `docs/works/PHASE{n}` (대문자)로 잘못 기재되어 `replace_all`로 즉시 수정.
6. **STATUS.md Next Actions 잔류**: Phase G, H 완료 후에도 Next Actions에 미완료 항목으로 남아 있음 — `/health` 후 STATUS Update Proposal 필요 (P0).

---

## 8. 잔여 리스크 및 후속 작업

| 항목 | 심각도 | 추적 |
| --- | --- | --- |
| DR-015 2계층 게이트를 commands/AGENTS.md/workflow.mdc에 반영 미완료 | 중간 | HRN-017 (Candidate, P2) |
| `STATUS.md` Next Actions가 Phase G, H를 아직 가리킴 | 높음 (P0) | STATUS Update Proposal 후 수정 |
| `docs/backlog/HARNESS.md` HRN-006이 Open 상태 | 낮음 | Closed 처리 필요 |
| Work 파일 Done→Archive 흐름 실제 실행 미검증 (G1 시뮬레이션은 Candidate까지만) | 중간 | PRE-C1 완료 시 첫 실제 실행 |
| `HRN-002` hard enforcement와 DR-015 연계 검토 미완 | 낮음 | HRN-002 착수 시 |

---

## 9. 수행한 검증

```bash
# 디렉토리 소문자 확인
find docs/ -type d | sort

# 구 경로 참조 잔존 확인 (0건이어야 함)
grep -rn "docs/TODO" . --include="*.md" --include="*.sh" --include="*.mdc" \
  | grep -v "archive\|\.git\|DR-013"

# STATUS.md 간결성
wc -l docs/STATUS.md  # 61줄 (60줄 이내 목표 근사)

# git tag 확인
git tag | grep hrf-002-start

# 관련 커밋
git log --oneline | head -10
```

---

## 10. 리뷰어 체크리스트

### 10.1 Work 파일 설계

- Work 파일이 STATUS.md를 대체하는 SSoT 역할을 올바르게 정의하고 있는가?
- frontmatter 스펙(DR-013)에서 누락되거나 과도한 필드가 있는가?
- `appetite` 필드가 실용적인가, 아니면 추정이 어려워 의미 없이 채워질 가능성이 있는가?
- `Discovery` 섹션이 계획-실행 간 갭을 추적하기에 충분한 구조인가?

### 10.2 2계층 State Update Proposal (DR-015)

- Layer 1 / Layer 2 게이트 분리가 실용적인가?
- "인라인 1줄 제안"과 "Proposal" 사이의 경계가 충분히 명확한가?
- 멀티 Active Work 환경에서 각 Work 파일 독립 게이트 원칙이 실무적으로 작동하는가?
- DR-015 구현이 아직 commands/AGENTS.md/workflow.mdc에 반영되지 않았다 — 이 지연이 허용 가능한가?

### 10.3 Work File Rules 위치

- Protocol 문서(03-work-items-and-naming.md)에 Work File Rules를 두고, 개별 Work 파일은 이를 반복하지 않는 방식이 올바른가?
- DR-013이 이 섹션을 권위 문서로 참조하는 연결이 충분히 명확한가?
- Agent가 Work 파일을 보다가 이 규칙을 찾아갈 수 있는가?

### 10.4 시뮬레이션 갭 수정 (G2)

- `/work`, `/resume`, `/done`, `AGENTS.md`, `workflow.mdc`에 추가된 Work 파일 절차가 실제 세션에서 작동할 만큼 구체적인가?
- Done→Archive 흐름(git mv, README 업데이트, STATUS 포인터 제거)이 명확하게 정의되었는가?

### 10.5 archive 구조 (DR-014)

- 경로 미러링 방식(`docs/archive/{원본-경로}/`)이 실용적인가?
- 완료된 Work 파일을 `docs/archive/docs/works/{category}/`로 이동하는 규칙이 명확한가?

### 10.6 도구 간 정렬

- Claude Code, Codex, Cursor 세 도구가 Work 파일 참조 흐름을 일관되게 따르는가?
- G2 시뮬레이션 갭(5개) 수정이 향후 추가 갭 발생을 충분히 예방하는가?

### 10.7 신규 스캐폴딩 시나리오 (G3)

- `create-harness.sh`가 생성하는 구조가 HRF-002 이후 워크플로우와 완전히 정합한가?
- G3 시뮬레이션 갭(5개) 수정으로 신규 프로젝트의 첫 세션 경험이 충분히 개선되었는가?
- `docs/works/README.md`에 카테고리 정보를 미리 안내하는 방식이 과도한가, 아니면 적절한가?

---

## 11. 권장 다음 단계

1. STATUS Update Proposal 승인 후 `STATUS.md` Next Actions 정리 및 HRF-002 완료 처리
2. `docs/backlog/HARNESS.md` HRN-006 Closed 처리
3. HRN-017 착수 시 commands/AGENTS.md/workflow.mdc에 DR-015 2계층 게이트 반영
4. PRE-C1 실제 착수 시 Work 파일 Done→Archive 첫 번째 실제 실행
5. HRN-002(hard enforcement) 착수 시 DR-015와의 연계 검토

---

## 12. 신규 스캐폴딩 시뮬레이션 (G3)

### 12.1 시뮬레이션 목적

G2 시뮬레이션(기존 프로젝트에서 Work 파일 흐름 검증)에 이어,
**이 템플릿을 복사해 신규 프로젝트를 시작한 사람이 하네스를 처음 열었을 때의 흐름**을 검증했다.

시나리오: 개발자 A가 `base-msa-template`을 스캐폴딩해 `order-management` 프로젝트를 시작.

```bash
scripts/create-harness.sh --profile spring-boot order-management /path/to/order-management
```

### 12.2 스캐폴딩 생성 구조 (HRF-002 이전)

`create-harness.sh`가 생성하는 주요 항목:

| 생성 항목 | 형태 |
| --- | --- |
| `CLAUDE.md`, `AGENTS.md` | 프로젝트명 치환 복사 |
| `docs/AGENT-WORKFLOW.md` | Project Constants `[fill in]` 플레이스홀더 포함 새 파일 |
| `docs/STATUS.md` | 빈 템플릿 (프로젝트명 포함) |
| `docs/backlog/PHASE1.md`, `HARNESS.md` | 빈 템플릿 |
| `docs/PLAN.md`, `PLAN-SUMMARY.md` | 빈 템플릿 |
| `.claude/commands/`, `.claude/rules/` | 복사 |
| `.cursor/rules/`, `prompts/` | 복사 |
| `docs/archive/` | 빈 디렉토리 (.gitkeep) |

**누락**: `docs/works/`, `docs/archive/docs/works/`

### 12.3 Claude Code 첫 세션 시뮬레이션

예상 흐름:

```text
CLAUDE.md → AGENT-WORKFLOW.md → docs/STATUS.md (빈 템플릿) → /work P1-001
```

**갭 NS-1 발견**: `/work P1-001` 실행 시 Work File Check → `docs/works/phase1/` 확인

- `docs/works/` 디렉토리 자체가 없음
- `work.md`에는 "Work 파일이 없으면" 처리만 있고, **디렉토리 자체 없음 케이스** 미처리
- Agent가 Work 파일 생성을 시도할 때 `docs/works/phase1/README.md` Active 테이블 행 추가 지시 → **README.md 자체가 없어 실패**

**갭 NS-2 발견**: STATUS.md Active Work 테이블 형식 불일치

- 스캐폴딩된 STATUS.md: `| ID | Scope | Status | Branch | Done Criteria |` (HRF-001 이전 형식)
- HRF-002 이후 형식: `| ID | Status | Work File |`
- Agent가 STATUS.md에 Work 파일 포인터 추가 시 기존 열 구조와 충돌

### 12.4 Codex 첫 세션 시뮬레이션

예상 흐름:

```text
AGENTS.md → AGENT-WORKFLOW.md → docs/STATUS.md → 작업 선택
```

**갭 NS-5 발견**: 신규 프로젝트 README.md와 STATUS.md Next Actions가 Codex 초기화 절차를 안내하지 않음

- 스캐폴딩된 README.md: "Claude Code에서 `/start`로 첫 세션 시작"만 안내
- Codex 사용자: `prompts/codex-session-start.md`를 사용해야 하나 안내 없음
- STATUS.md Next Actions: Claude Code 전용 절차만 명시

### 12.5 Cursor 첫 세션 시뮬레이션

예상 흐름:

```text
prompts/cursor-session-start.md → .cursor/rules/workflow.mdc → docs/STATUS.md → /work
```

**갭 NS-3 발견**: 첫 Work 파일 완료 시 Done→Archive 흐름 실패

- `done.md` 항목 11: Work 파일을 `docs/archive/docs/works/{category}/`로 `git mv`
- 스캐폴딩된 프로젝트에 `docs/archive/docs/works/`가 없음
- `git mv` 실행 시 대상 디렉토리 부재로 오류 발생

**갭 NS-4 발견** (NS-1 연계): `work.md` Work File Check의 미존재 디렉토리 처리 없음

- `docs/works/{category}/`가 없을 때 "Work 파일이 없으면" 분기로 처리되나 디렉토리 생성 절차 미안내
- `docs/works/{category}/README.md`가 없을 때 "Active 테이블에 행 추가" 지시 → 파일 없음 오류

### 12.6 발견된 5개 갭 및 수정

| 갭 | 증상 | 수정 대상 | 수정 내용 |
| --- | --- | --- | --- |
| NS-1 | 첫 `/work` 시 `docs/works/{category}/` 없음 | `scripts/create-harness.sh` + `work.md` | `docs/works/` 디렉토리 및 README.md 스캐폴딩 추가; work.md에 "디렉토리 없으면 생성" 분기 추가 |
| NS-2 | STATUS.md Active Work 테이블이 구버전 형식 | `scripts/create-harness.sh` | 템플릿 Active Work 열을 `ID | Status | Work File`로 교체 |
| NS-3 | 첫 `/done` 시 `docs/archive/docs/works/` 없어 git mv 실패 | `scripts/create-harness.sh` | `docs/archive/docs/works/` 디렉토리와 `.gitkeep` 스캐폴딩 추가 |
| NS-4 | `work.md`가 README.md 미존재 케이스 미처리 | `.claude/commands/work.md` | Work File Check에 "README.md 없으면 먼저 생성" 항목 추가 |
| NS-5 | README.md·STATUS.md가 Codex/Cursor 초기화 절차 미안내 | `scripts/create-harness.sh` | README.md와 STATUS.md Next Actions에 3개 도구별 첫 세션 절차 추가 |

### 12.7 수정 후 스캐폴딩 생성 구조

```
order-management/
├── CLAUDE.md, AGENTS.md
├── docs/
│   ├── STATUS.md           ← Active Work 포인터 형식 (HRF-002)
│   ├── AGENT-WORKFLOW.md   ← [fill in] 플레이스홀더
│   ├── works/
│   │   └── README.md       ← 카테고리 인덱스 + 사용 안내  ← 신규
│   ├── archive/
│   │   ├── .gitkeep
│   │   └── docs/works/
│   │       └── .gitkeep    ← 경로 미러링 준비             ← 신규
│   └── backlog/
│       ├── PHASE1.md
│       └── HARNESS.md
└── README.md               ← 3개 도구별 첫 세션 안내      ← 개선
```

### 12.8 G3 시뮬레이션 총평

G2(기존 프로젝트)와 G3(신규 스캐폴딩)는 **다른 차원의 갭을 탐지**한다.

| 구분 | 탐지 대상 | 발견 갭 |
| --- | --- | --- |
| G2 (기존 프로젝트) | 기존 하네스 흐름의 Work 파일 연결 누락 | 5개 (commands, AGENTS.md, workflow.mdc) |
| G3 (신규 스캐폴딩) | 스캐폴드 → 첫 세션 간 구조 불일치 | 5개 (create-harness.sh, work.md) |

G3 시뮬레이션을 통해 **`create-harness.sh`가 HRF-002의 Work 파일 체계를 반영하지 못하고 있었음**이 드러났다. 스캐폴딩 스크립트는 프로토콜 문서와 함께 진화해야 하며, 하네스 구조 변경 시 `create-harness.sh` 동기화를 Cascade Tracker에 포함할 것을 제안한다.
