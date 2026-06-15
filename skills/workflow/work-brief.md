# work-brief

Canonical workflow procedure for `/work-brief`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/work-brief.md` |
| Codex | `.agents/skills/workflow-work-brief/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

전략·비교·포지션 문서를 만들거나, 기존 문서의 위치가 `retrospective`/`brief`/`decision` 중 어디가 맞는지 분류할 때 쓰는 workflow다.

## Trigger & Command Rules

사용자가 채팅창에 **`/work-brief` 커맨드를 입력하거나**, 아래 문맥을 요청하면 본 workflow를 가동한다.

- **명시적 커맨드:** `/work-brief [topic]`
- **자연어 트리거:** "방향 문서", "비교 문서", "포지션 페이퍼", "전략 메모", "이 문서 회고 말고 brief 같다", "이 문서를 어디에 둬야 할지 분류해줘"
- **예외:** Accepted 결정 자체를 기록하려는 경우 `/record-decision`, 실제 사건/Phase를 돌아보는 회고는 `docs/retrospectives/`, 발표/보고 산출물은 `/work-doc`

## Phase 1: Document Triage

먼저 아래 분류부터 확정한다.

| 질문 | Yes면 |
| --- | --- |
| 실제로 있었던 세션/Phase/incident를 돌아보고 무엇을 배웠는가가 중심인가? | `docs/retrospectives/` |
| 채택된 규칙/구조/정책을 근거·reversal cost와 함께 확정 기록하는가? | `docs/decisions/DR-*.md` |
| 옵션 비교, 현재 포지션, 경계 정리, 방향 제안이 중심인가? | `docs/briefs/` |

Brief는 **아직 Accepted decision은 아니지만**, 방향 수립에 쓰일 논증과 비교를 남기는 문서다.

## Phase 2: Brief Alignment

최대 3개까지 필요한 질문만 하거나, 문맥이 충분하면 바로 정렬한다.

| Attribute | Validation Criteria |
| --- | --- |
| **Core Question** | 어떤 방향/옵션/경계를 비교하는가 |
| **Scope** | source repo posture / default scaffold / source-gitflow opt-in 등 적용 층위를 분리했는가 |
| **Audience** | maintainer, contributor, adopter, reviewer 중 누구를 위한 문서인가 |
| **Follow-up Surface** | 이 문서가 나중에 DR, backlog, Work, README/Protocol 변경으로 이어지는가 |
| **Evidence Level** | 실제 관측인지, 기존 회고/DR inference인지 구분하는가 |

## Phase 3: Context Loading

필요한 최소 문서만 읽는다.

- 현재 상태나 후속 후보가 중요하면 `docs/STATUS.md`
- Accepted 결정 근거가 필요하면 관련 `docs/decisions/DR-*.md`
- 실제 회고 근거가 필요하면 `docs/retrospectives/`에서 관련 1개만
- 기존 방향 문서와 비교가 필요하면 `docs/briefs/`에서 관련 1개만
- live tracker 영향이 있으면 `docs/backlog/*.md`, `docs/works/**`

모든 회고나 모든 brief를 먼저 읽지 않는다.

## Phase 4: Authoring Or Reclassification

### 4.1 새 brief 작성

출력 경로:

- `docs/briefs/{topic}-{YYYYMMDD}.md`

최소 구조:

1. 결론
2. 질문/배경
3. 비교·분석
4. 리스크와 맹점
5. Revisit Triggers
6. 연결

### 4.2 기존 문서 재분류

기존 live 문서가 brief에 더 가깝다고 판단되면:

1. `docs/briefs/`로 이동한다.
2. 원본/대상 `README.md` 인덱스를 같은 변경에 갱신한다.
3. 내부 링크와 backlog/reference 경로를 함께 갱신한다.
4. archive 전수 분류는 사용자가 요청한 경우에만 한다.

문서 본문은 **위치 정정에 필요한 최소 변경**만 한다. 역사 자체를 다시 쓰지 않는다.

## Phase 5: Validation Checklist

- [ ] brief / retrospective / DR 분류 이유가 한 줄로 설명 가능한가
- [ ] `docs/briefs/README.md` 인덱스가 실제 파일과 맞는가
- [ ] 원본 인덱스에서 이동된 행이 제거됐는가
- [ ] 관련 backlog / protocol / quick reference / workflow routing 중 최소 필요한 표면만 갱신했는가
- [ ] brief가 Accepted-ready 결정으로 수렴했는지 점검하고, 그렇다면 `/record-decision` 제안 여부를 판단했는가 (premature DR 강제 아님)
- [ ] `git diff --check` clean

## Phase 6: Delivery Handshake

완료 시 아래를 보고한다.

1. 생성 또는 이동된 파일 경로
2. 어떤 문서가 왜 `brief`로 분류됐는지
3. 남은 follow-up surface. 특히 brief가 **Accepted-ready 결정으로 수렴했다면 `/record-decision`(DR)을 제안**한다 — 강제는 아니다. 아직 탐색적이면 brief + Revisit Triggers로 유지한다(premature crystallization 회피). backlog/Work 후속 여부도 함께 보고한다.
