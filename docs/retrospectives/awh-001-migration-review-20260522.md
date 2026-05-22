# AWH-001 Migration Review — 2026-05-22

> 작성자: Claude Code (claude-sonnet-4-6)  
> 대상 branch: `feature/ai-workflow-harness-migration`  
> 기준: `git diff HEAD` (staged + unstaged + untracked 전체)  
> 목적: commit/PR 전 최종 정합성 검토  

---

## 결론

**전반적으로 잘 됐다.** 삭제 범위 정확성, 용어 통일 cascade, tool surface 재편 모두 의도에 부합한다.
단, **커밋 전 해소해야 할 P0 항목 2개**, **P1 항목 3개**가 있다.
P2는 optional 개선이며 커밋을 막지 않는다.

---

## 1. 검토 범위

| 계층 | 대상 |
|---|---|
| Canonical | `BEHAVIOR-PRINCIPLES.md`, `AGENT-WORKFLOW.md`, `HARNESS-PROTOCOL.md`, `HARNESS-QUICK-REFERENCE.md` |
| Tool-specific | `.claude/commands/*.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `CLAUDE.md`, `AGENTS.md`, `prompts/*.md` |
| 사용자 가이드 | `WORKFLOW-MANUAL.md`, `WORKFLOW-MANUAL-SUMMARY.md`, `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`, `ARCHITECTURE.md`, `DEVELOPER-GUIDE.md`, `CODING-CONVENTIONS.md` |
| Scaffold 산출물 | `scripts/create-harness.sh` (생성 결과 전체), `tools/git-hooks/*`, `.github/workflows/ci.yml` |
| 상태 파일 | `docs/STATUS.md`, `docs/works/harness/AWH-001-public-repo-migration.md`, `docs/works/README.md`, `docs/works/harness/README.md`, `docs/backlog/HARNESS.md` |

---

## 2. 발견 사항 요약

| ID | 우선순위 | 계층 | 파일 | 설명 |
|---|---|---|---|---|
| R-01 | **P0** | git 상태 | 전체 | staged/unstaged 분리 — AWH-001 Work 파일 untracked 포함 |
| R-02 | **P0** | 사용자 가이드 | `WORKFLOW-MANUAL-SUMMARY.md` | Work Lifecycle 다이어그램에 제거된 `Candidate` 상태 잔존 |
| R-03 | **P1** | 사용자 가이드 | `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` | 4곳에 `product surface` / `product 후보` stale 용어 잔존 |
| R-04 | **P1** | 사용자 가이드 | `WORKFLOW-MANUAL-SUMMARY.md` cascade → `WORKFLOW-MANUAL.md` | `WORKFLOW-MANUAL.md` 전체 stale 용어 감사 미완료 |
| R-05 | **P1** | CI | `.github/workflows/ci.yml` | stale-term check 범위가 핵심 6개 파일에만 한정 |
| R-06 | P2 | Scaffold | `scripts/create-harness.sh` | 생성되는 `PLAN.md` skeleton에 dual-track 구조 설명 없음 |
| R-07 | P2 | Canonical | `ARCHITECTURE.md` | Context Routing 다이어그램에 Product/Harness track 레이블 누락 |
| R-08 | P2 | Tool-specific | `.claude/rules/java-spring.md` | `paths:` glob이 삭제된 디렉터리 참조 (기능 영향 없음) |
| R-09 | P2 | 열린 질문 | `docs/STATUS.md` AWH-OQ-001 | Spring Boot profile 유지 결정이 informal (formal DR 없음) |

---

## 3. 계층별 상세 분석

### 3-1. Canonical 계층

| 파일 | 결과 |
|---|---|
| `BEHAVIOR-PRINCIPLES.md` | 변경 없음. harness repo에서도 그대로 유효 |
| `AGENT-WORKFLOW.md` | ✅ Project Constants, Verification Defaults, Operating Tracks 신규 섹션 모두 적절히 전환 |
| `HARNESS-PROTOCOL.md` | ✅ Operating Tracks 섹션 추가, `L1 Product track surface` 용어 정렬 완료 |
| `HARNESS-QUICK-REFERENCE.md` | ✅ Two-track 설명, 용어 정렬 완료 |

canonical 계층은 정합성 양호.

---

### 3-2. Tool-specific 계층

| 파일 | 결과 |
|---|---|
| `CLAUDE.md` / `AGENTS.md` | ✅ `Product track` 용어 정렬 완료 |
| `.claude/commands/health.md` | ✅ `DOCKERFILE-GUIDE.md` 참조 제거, `Product track Quick Mode` 경계 명확화 |
| `.claude/commands/pick.md` | ✅ `Product track 작업` 용어 정렬 |
| `.claude/commands/work.md` | ✅ `Product track surface L1 Quick Mode` 용어 정렬 |
| `.claude/rules/java-spring.md` | ⚠️ [R-08] `paths:` glob이 `common/**/*.java`, `services/**/*.java` 등 삭제된 경로 참조. 파일이 존재하지 않으면 Claude Code rule이 적용되지 않으므로 기능 영향은 없지만 기술적 불일치 |
| `.claude/rules/testing.md` | ✅ "Optional Spring Boot Testing Rules"로 적절히 격리 |
| `.cursor/rules/role-backend.mdc` | ✅ "Harness Maintainer Role"로 완전 교체. 설명 품질 높음 |
| `.cursor/rules/java-spring.mdc` | ✅ `alwaysApply: false`, optional example pack 레이블 적절 |
| `.cursor/rules/testing.mdc` | ✅ optional 격리 완료 |
| `.cursor/rules/execution.mdc` | ✅ Java/Gradle/Docker 가정 제거, harness 검증 명령으로 전환 |
| `prompts/claude-session-start.md` | ✅ `Product track` 용어 정렬, `PLAN-SUMMARY.md` 설명 harness 중심으로 수정 |
| `prompts/codex-session-start.md` | ✅ 동일 정렬 완료 |
| `tools/git-hooks/pre-commit` | ✅ Checkstyle → diff hygiene + shell syntax check. 적절하고 깔끔 |
| `tools/git-hooks/install.sh` | ✅ 설명 업데이트 |
| `.github/workflows/ci.yml` | ✅ 경량 docs/scaffold 검증으로 전환. ⚠️ [R-05] stale-term 검사 범위 한정 |

---

### 3-3. 사용자 가이드 계층

#### `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` — ⚠️ P1 [R-03]

다음 4곳에서 용어 정렬이 누락됐다:

| 위치 | 현재 (stale) | 정렬 후 |
|---|---|---|
| 2절 Load Rule 테이블 (line 276) | `product 후보 선택` | `Product track 후보 선택` |
| 4절 Work Routing 테이블 (line 354) | `product 후보` | `Product track 후보` |
| 5절 Approval Matrix (line 368) | `L1 product surface (제품 영역)` | `L1 Product track surface` |
| 5절 Quick Mode 설명 (line 372) | `product surface의 작고 명확한 L1 작업` | `Product track surface의 작고 명확한 L1 작업` |

Public 공개 전 external reader에게 노출되는 문서이므로 P1으로 분류.

#### `WORKFLOW-MANUAL-SUMMARY.md` (internal) — ⚠️ P0 [R-02]

6절 Work File Lifecycle 다이어그램 (lines 292–293):

```
[*] --> Candidate: backlog item   ← STALE
Candidate --> Active: /work 승인  ← STALE
```

HRN-021-S3에서 Work 파일 `Candidate` 상태가 공식 제거됐다. 같은 파일 line 648에서 "Work Candidate 상태를 제거해 lifecycle 단순화"라고 스스로 기술하고 있어 내부 모순이다.

`WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`의 동일 다이어그램은 이미 올바르게 정렬되어 있다:
```
[*] --> Active: /work 승인 후 Work 파일 생성  ← 올바름
```

사용자가 SUMMARY를 읽고 Backlog item을 Work 파일로 잘못 생성하면 harness 규칙과 충돌한다.

#### `WORKFLOW-MANUAL.md` — ⚠️ P1 [R-04]

읽은 60줄 범위에서는 문제 없음. 단, `grep` 결과:

```
docs/WORKFLOW-MANUAL.md:533: **착수 절차 (Backlog Candidate → Active Work):**
```

이 줄은 "backlog 후보 항목을 Active Work로 가져오는 절차"라는 의미로 `Candidate`를 개념적 용어로 사용하는 것으로 보이며 Work 파일 state를 지칭하는 것이 아니다. WORKFLOW-MANUAL-SUMMARY-PUBLIC.md line 436이 이를 명확히 한다: "Backlog의 `Candidate`는 후보 pool이며 Work 파일 상태가 아니다."

그러나 전체 파일에 대한 용어 감사(3,000+ 줄)가 이번 변경에서 수행되지 않았다. WORKFLOW-MANUAL-SUMMARY-PUBLIC.md에서 발견된 stale 패턴이 WORKFLOW-MANUAL.md에도 있을 가능성이 있다. 커밋 전 `rg "product surface|product 후보|L1 product"` 실행을 권장한다.

#### `ARCHITECTURE.md` — ⚠️ P2 [R-07]

완전히 harness 중심으로 재작성됐다. Context Routing 다이어그램(3절)에서 `docs/backlog/PHASE{n}.md` 노드에 "Product track" 레이블이 없어 두 백로그의 차이를 시각적으로 구분하기 어렵다. 기능 오류는 아니나 public 독자 입장에서 dual-track 의미가 다이어그램에서 직접 보이지 않는다.

#### `DEVELOPER-GUIDE.md` — ✅

"Harness maintainer 대상"으로 완전 재작성. 불필요한 Spring Boot 내용 없음.

#### `CODING-CONVENTIONS.md` — ✅

Documentation/workflow convention으로 재정의. Language Policy, Work File convention, Prompt convention 중심. 적절하다.

---

### 3-4. Scaffold 산출물 계층

`scripts/create-harness.sh` 생성 결과를 추적하면:

| 생성 파일 | 내용 | 평가 |
|---|---|---|
| `README.md` | Product track / Harness track 이중 구조 표, 첫 세션 안내 | ✅ |
| `docs/STATUS.md` | `PHASE1.md`와 `HARNESS.md` 양쪽 pointer | ✅ |
| `docs/backlog/PHASE1.md` | Product track 후보 skeleton | ✅ |
| `docs/backlog/HARNESS.md` | Harness track 후보 skeleton | ✅ |
| `docs/works/README.md` | `phase1/` (Product track) + `harness/` (Harness track) 카테고리 | ✅ |
| `docs/PLAN.md` | 프로젝트 목표·기술스택 skeleton | ⚠️ [R-06] dual-track 언급 없음 |
| `docs/AGENT-WORKFLOW.md` | `adapt` (sed 치환)으로 Operating Tracks 개념 포함 | ✅ |
| `.claude/settings.json` | deny 패턴, Stop hook | ✅ |
| `tools/git-hooks/pre-commit` | diff hygiene + shell syntax | ✅ |

사용자 원래 질문 **"새 프로젝트에서 Product + Harness 이중 구조 진입이 보장되는가?"**에 대한 답:
scaffold 결과물이 두 트랙 구조를 명확히 제공한다. 보장 수준은 충분하다.

---

## 4. 워크플로우 시뮬레이션

각 command/intent를 새 repo 기준으로 시뮬레이션했다.

### `/start`

1. `CLAUDE.md` → `@BEHAVIOR-PRINCIPLES.md`, `@AGENT-WORKFLOW.md` 자동 로드
2. `AGENT-WORKFLOW.md` → Operating Tracks 섹션 인식 (Product/Harness 이중 구조)
3. `docs/STATUS.md` current sections 확인 (AWH-001 Active, OQ 3개)
4. 결과 요약 제공

**판정: 정상.** Operating Tracks 개념이 AGENT-WORKFLOW.md에 명확히 삽입되어 세션 시작부터 두 트랙을 구분한다.

### `/pick`

1. `docs/STATUS.md` 확인
2. `docs/backlog/PHASE{n}.md` (없으면 skip) vs `docs/backlog/HARNESS.md` 비교
3. 현재 ai-workflow-harness에는 Product track backlog가 없어 HARNESS.md만 검토

**판정: 정상.** Product track backlog 부재가 정상 케이스(harness 전용 repo)로 처리된다.

### `/work {ID}`

1. Work 파일 검색 (`docs/works/{category}/`)
2. Quick Mode 기준 판단: "Product track surface L1"에만 적용 — harness repo에서는 대부분 L2
3. risk level 선언 → plan 승인 대기

**판정: 정상.** 단, ai-workflow-harness repo 자체에 Product track이 없으므로 Quick Mode 적용 대상이 사실상 없다. Agent가 이를 올바르게 인식하는지는 실제 세션에서 확인 필요.

### `/resume {ID}`

1. Work 파일 실제 상태 vs STATUS/Work drift 확인
2. AWH-001 재개 예: Done Criteria 미완료 항목(CP-5) 확인 → 자연스러운 진입

**판정: 정상.**

### `/close`

1. Work 파일 `status: Done`, `actual_end` 기입
2. README Active → Done 이동
3. STATUS Active pointer 제거 제안
4. archive 즉시 여부 확인

**판정: 정상.** Done Criteria에 "public 전환 전 review 완료"가 있으므로 `/close`는 해당 review 확인 완료 전에 실행하지 않는다.

### `/done`

1. 세션 변경·검증·리스크·다음 prompt 요약만 출력
2. Work Done 처리 없음

**판정: 정상.** `/close`와 역할 분리 명확.

### Archive

1. Done Work 파일을 `docs/archive/docs/works/{category}/`로 이동
2. `/start` 또는 `/resume`에서 Done 항목 발견 시 제안, 사용자 승인 후 수행
3. `git mv` 사용

**판정: 정상.** 승인 gate 명확.

### Quick Mode

- 조건: "Product track surface L1" (AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md, HARNESS-QUICK-REFERENCE.md 모두 일치)
- 현재 repo: Product track이 없으므로 Quick Mode 적용 케이스 자체가 없음
- scaffold된 신규 프로젝트: Product track 작업 등록 후 Quick Mode 올바르게 적용 가능

**판정: 정상.** 단, ai-workflow-harness 자체 운영에서는 Quick Mode 사용 빈도 0에 가까움.

### State Update (STATUS.md 변경)

1. Agent는 변경 전 최신 STATUS.md 확인
2. Approval Matrix 규칙에 맞는 제안 → 사용자 승인 → 수정 순서
3. AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md, HARNESS-QUICK-REFERENCE.md 모두 동일 규칙 명시

**판정: 정상.**

### Cascade / Trigger

- Canonical workflow 변경 → tool-specific, user-facing, scaffold 확인 순서 명확
- T15/T16 (STATUS/Tracking Finalization) — commit/PR 전 체크
- `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` Section 8 Trigger 다이어그램에는 T15/T16이 없지만, `WORKFLOW-MANUAL-SUMMARY.md`의 Section 8에는 T15/T16이 있음. 약간의 비대칭이나 기능 영향 없음

**판정: 허용 가능.** T15/T16은 PUBLIC 다이어그램이 아닌 내부 요약 및 canonical 문서에 기록돼 있어 AI 실행에 영향 없음.

### 신규 프로젝트 Scaffold

```bash
./scripts/create-harness.sh --profile generic my-new-project /path/to/project
```

결과:
- `docs/backlog/PHASE1.md` + `docs/backlog/HARNESS.md` 동시 생성
- `docs/works/phase1/` + `docs/works/harness/` 카테고리 생성
- `docs/AGENT-WORKFLOW.md` (Operating Tracks 포함, 프로젝트명 치환)
- `README.md` (dual-track 안내 표 포함)
- `docs/STATUS.md` (두 backlog 모두 pointer 포함)

**판정: 정상.** 사용자 원래 질문인 "Product + Harness 이중 구조로 자연스럽게 진입 가능한가?"에 충분히 답한다.

---

## 5. P0 — 커밋 전 반드시 해소

### R-01: staged/unstaged 분리

현재 git 상태:
- **staged**: Spring Boot 파일 삭제 ~180개
- **unstaged 수정**: harness docs, commands, rules, CI, hooks, prompts ~40개
- **untracked**: `docs/works/harness/AWH-001-public-repo-migration.md` (Work 파일 자체)

지금 커밋하면 삭제만 커밋된다. unstaged 수정 전체와 Work 파일을 함께 stage해야 한다.

```bash
git add docs/works/harness/AWH-001-public-repo-migration.md
git add .claude/ .cursor/ .github/ AGENTS.md README.md docs/ prompts/ scripts/ tools/
# 그 후 git status로 확인
```

### R-02: `WORKFLOW-MANUAL-SUMMARY.md` Work Lifecycle 다이어그램 stale Candidate 상태

`docs/WORKFLOW-MANUAL-SUMMARY.md` 6절 Work File Lifecycle 다이어그램 (lines 292–300):

```
# 현재 (STALE)
stateDiagram-v2
    [*] --> Candidate: backlog item
    Candidate --> Active: /work 승인
    Active --> Active: checkpoint / discovery
    Active --> Done: /close 승인
    Done --> Archived: archive 승인
    Archived --> [*]

    Done --> Active: 재개 금지\n후속 작업으로 분리
```

```
# 올바른 상태 (WORKFLOW-MANUAL-SUMMARY-PUBLIC.md와 동일하게)
stateDiagram-v2
    [*] --> Active: /work 승인 후 Work 파일 생성
    Active --> Active: checkpoint / discovery
    Active --> Done: /close 승인
    Done --> Archived: archive 승인
    Archived --> [*]

    Done --> [*]: 재개 금지\n후속 작업으로 분리
```

HRN-021-S3에서 Work 파일 Candidate 상태 제거가 결정됐다. 다이어그램이 여전히 Candidate를 Work 파일 상태로 표시하고 있어 같은 파일 내 역사 기술(line 648: "Work Candidate 상태를 제거해 lifecycle 단순화")과 모순된다. PUBLIC 버전은 이미 올바르게 정렬되어 있다.

---

## 6. P1 — 커밋 전 처리 권장

### R-03: `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` stale 용어 4곳

| Line | 현재 | 수정 후 |
|---|---|---|
| 276 | `product 후보 선택` | `Product track 후보 선택` |
| 354 | `product 후보` | `Product track 후보` |
| 368 | `L1 product surface (제품 영역)` | `L1 Product track surface` |
| 372 | `product surface의 작고 명확한 L1 작업` | `Product track surface의 작고 명확한 L1 작업` |

PUBLIC 파일에 남은 stale 용어는 public reader 관점에서 혼란을 줄 수 있다. 특히 Approval Matrix의 `L1 product surface (제품 영역)`는 "제품 영역"이라는 괄호 주석이 harness-only repo에서 맥락이 어색하다.

### R-04: `WORKFLOW-MANUAL.md` 전체 용어 감사 미완료

WORKFLOW-MANUAL.md는 3,000줄 이상의 원본 매뉴얼이다. 이번 변경에서 `docs/WORKFLOW-MANUAL-SUMMARY.md`와 `SUMMARY-PUBLIC.md`에 stale 용어가 발견됐으므로, 원본에도 같은 패턴이 있을 가능성이 높다.

커밋 전 실행 권장:

```bash
rg -n "product surface|product 후보|L1 product" docs/WORKFLOW-MANUAL.md
```

### R-05: CI stale-term check 범위 한정

`.github/workflows/ci.yml`의 stale-term check:

```yaml
! grep -RInE 'Spring Boot 3\.5|io\.kyungseo\.msa|Gradle wrapper' \
  AGENTS.md CLAUDE.md docs/AGENT-WORKFLOW.md docs/PLAN.md docs/PLAN-SUMMARY.md docs/STATUS.md prompts
```

`docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md` 등 live core 문서가 범위에서 빠져 있다. 향후 용어 재도입이 발생해도 CI에서 잡히지 않는다.

최소한 아래 경로 추가를 권장한다:

```yaml
! grep -RInE 'Spring Boot 3\.5|io\.kyungseo\.msa|Gradle wrapper' \
  AGENTS.md CLAUDE.md \
  docs/AGENT-WORKFLOW.md docs/PLAN.md docs/PLAN-SUMMARY.md docs/STATUS.md \
  docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md \
  docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md \
  prompts
```

---

## 7. P2 — Optional 개선

### R-06: Scaffold 생성 `PLAN.md`에 dual-track 설명 없음

`create-harness.sh`가 생성하는 `docs/PLAN.md` skeleton:

```markdown
## 목표
*(채워야 함)*

## 기술 스택 선택 근거
*(채워야 함)*
```

초기 세션에서 사용자가 PLAN.md를 채울 때 Product track과 Harness track 각각의 목표를 적도록 유도하면 좋다. `## Product Track 목표`와 `## Harness Track 목표` placeholder 주석 추가를 검토할 수 있다. (현재 README.md skeleton은 잘 안내하고 있으므로 낮은 우선순위)

### R-07: `ARCHITECTURE.md` Context Routing 다이어그램 track 레이블 누락

3절 flowchart에서 `docs/backlog/PHASE{n}.md` 노드와 `docs/backlog/HARNESS.md` 노드의 의미(Product track vs Harness track)가 시각적으로 구분되지 않는다. 독립 다이어그램이므로 레이블 추가로 dual-track 개념을 명시할 수 있다.

### R-08: `.claude/rules/java-spring.md` paths 고아 참조

```yaml
paths:
  - "common/**/*.java"
  - "services/**/*.java"
  - "gateway/**/*.java"
  - "**/build.gradle.kts"
  - "settings.gradle.kts"
  - "gradle/**/*.toml"
```

이 경로들은 이번 변경에서 모두 삭제됐다. Claude Code는 path match가 없으면 rule을 적용하지 않으므로 기능 영향은 없다. 하지만 optional Spring Boot example rule로 유지하는 의도라면 패턴 자체는 `spring-boot` profile 적용 시 의미 있는 참조가 될 수 있어 실질적 문제는 없다.

### R-09: AWH-OQ-001 informal resolution

Spring Boot profile이 optional example pack으로 `create-harness.sh`에 유지되어 사실상 결정이 됐다. 그러나 `STATUS.md`에 아직 AWH-OQ-001이 Open 상태로 남아 있고, formal DR이 없다. 공개 전 이 결정을 DR로 기록하거나 OQ를 Closed로 처리하는 것이 추적성 측면에서 낫다.

---

## 8. 커밋 전 체크리스트

```
[ ] R-01: git add unstaged 수정 40개 + AWH-001 Work 파일 stage
[ ] R-02: WORKFLOW-MANUAL-SUMMARY.md Work Lifecycle 다이어그램 Candidate 제거
[ ] R-03: WORKFLOW-MANUAL-SUMMARY-PUBLIC.md 4곳 stale 용어 수정
[ ] R-04: rg "product surface|product 후보|L1 product" docs/WORKFLOW-MANUAL.md 실행 후 결과에 따라 처리
[ ] R-05: CI stale-term check 범위 확장 (optional, P1)
[ ] validation: git diff --check
[ ] validation: bash -n scripts/create-harness.sh
[ ] validation: ./scripts/create-harness.sh --dry-run --profile generic ci-check /tmp/ci-check
```

---

## 9. 잘 된 부분 (변경하지 말 것)

- **Staged 삭제 범위**: Spring Boot runtime surface 전체 삭제. 과잉 삭제 없음
- **Operating Tracks 개념 삽입**: AGENT-WORKFLOW.md → HARNESS-PROTOCOL.md → QUICK-REFERENCE → create-harness.sh 산출물까지 cascade 정확
- **용어 통일 "Product track"**: canonical, tool-specific, prompts 전 범위 일관 적용
- **role-backend.mdc 교체**: "Harness Maintainer Role"로 완전 전환, 내용 품질 높음
- **pre-commit hook**: Checkstyle 제거 후 diff hygiene + shell syntax check로 적절히 전환
- **CI workflow**: 경량 검증 + stale-term check 구조 자체는 옳다
- **create-harness.sh**: dual-track scaffold 산출물 전체가 사용자 질문에 정확히 답함
- **DEVELOPER-GUIDE.md / CODING-CONVENTIONS.md**: 깔끔하게 harness 중심으로 재작성
- **private-info cleanup**: 로컬 절대경로 제거, `.mcp.json` 삭제

---

*이 문서는 검토 전용이며 commit 대상이 아니다. 검토 완료 후 삭제해도 무방하다.*

---

## 10. Codex 의견 및 조치 내역 — 2026-05-22

### 검토 의견

Codex 재검토 결과, 본 리뷰의 P0/P1 판단에 대체로 동의한다.

| ID | Codex 판단 | 사유 |
|---|---|---|
| R-01 | 동의, 단 commit 절차 항목 | 내용 결함은 아니지만 현재 상태에서 stage 범위를 놓치면 삭제만 커밋될 수 있어 commit 직전 필수 확인 대상이다. 이 리뷰 파일은 "commit 대상 아님"으로 유지한다. |
| R-02 | 동의, P0 | `WORKFLOW-MANUAL-SUMMARY.md`가 Work file `Candidate` 상태를 여전히 lifecycle state로 표현해 현재 workflow와 충돌했다. |
| R-03 | 동의, P1 | public summary에 `product surface`, `product 후보`, `L1 product surface` 용어가 남아 external reader에게 Product/Harness track 모델을 흐릴 수 있었다. |
| R-04 | 처리 완료로 판단 | `rg "product surface|product 후보|L1 product" docs/WORKFLOW-MANUAL.md` 재확인 결과 원본 `WORKFLOW-MANUAL.md`에는 해당 stale pattern이 남아 있지 않았다. |
| R-05 | 동의, P1 | CI stale-term check가 live core docs 일부만 확인해 향후 runtime identity regression을 놓칠 수 있었다. |
| R-06~R-09 | 이번 조치 제외 | optional 개선 또는 별도 결정/DR 성격이 있어 AWH-001 commit 전 필수 정합성 조치와 분리한다. |

### 반영한 조치

| ID | 조치 | 파일 |
|---|---|---|
| R-02 | Work File Lifecycle 다이어그램에서 `Candidate` 상태를 제거하고 `/work 승인 후 Work 파일 생성 -> Active`로 정렬했다. Done 이후 재개도 `Active` 복귀가 아니라 후속 작업 분리로 종료되게 수정했다. | `docs/WORKFLOW-MANUAL-SUMMARY.md` |
| R-03 | public summary의 stale 용어를 `Product track 후보`, `Product track / Phase 기능`, `L1 Product track surface`, `Product track surface`로 정렬했다. | `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` |
| R-05 | CI stale runtime identity scan 범위에 `HARNESS-PROTOCOL`, `HARNESS-QUICK-REFERENCE`, `WORKFLOW-MANUAL*` live docs를 추가했다. | `.github/workflows/ci.yml` |
| R-05 follow-up | 확장된 CI scan을 로컬에서 재현하자 optional Spring Boot prompt bundle의 과거 package identity가 추가로 드러나 `com.example.*` placeholder로 정리했다. | `prompts/02-scaffold-service.prompt.md`, `prompts/21-create-layer.prompt.md` |

### 추가 확인

R-04 확인 명령:

```bash
rg -n "product surface|product 후보|L1 product" docs/WORKFLOW-MANUAL.md
```

결과: match 없음.

### 남은 항목

- R-01은 commit 직전 staging 절차에서 처리한다. `AWH-001-review-2026-05-22.md`는 검토 전용 파일이므로 stage 대상에서 제외한다.
- R-06, R-07, R-08, R-09는 public-ready migration 후속 개선 또는 별도 decision 정리 후보로 남긴다.
