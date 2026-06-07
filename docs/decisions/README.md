# Decision Records

AI Workflow Harness의 결정 근거 인덱스.
각 DR은 하나의 결정 이유(WHY)를 기록한다.

cascade 감사 시 이 인덱스의 Accepted DR만 확인 대상이다.
Superseded DR은 `docs/archive/docs/decisions/`로 이동된다. 아카이브 인덱스: [`docs/archive/docs/decisions/README.md`](../archive/docs/decisions/README.md)

**Status legend:**
- `Accepted` — 최종 확정
- `Accepted (Amended)` — 확정 후 세부 수정됨. DR 본문에 수정 범위 명시.
- `Accepted (일부 Deferred)` — 일부 항목 보류. DR 본문에 보류 범위 명시.
- `Superseded by DR-XXX` — 전체 대체됨. archive 이동 후보.
- `Draft` — 초안

**Track legend:** `harness` = AI workflow·명령·프로토콜 결정 / `product` = 적용 프로젝트의 기능·아키텍처 결정

| ID | Title | Date | Status | Track | 요약 |
|----|-------|------|--------|-------|------|
| DR-007 | 파일 유형별 작성 언어 원칙 | 2026-05-11 | Accepted (Amended) | harness | 문서·command·prompt·hook은 Korean primary + English technical terms |
| DR-008 | docs/ 파일명 대소문자 표준 | 2026-05-12 | Accepted | harness | `docs/` 파일명은 UPPER-KEBAB-CASE |
| DR-011 | STATUS.md Recent Decisions Rolling Window Policy | 2026-05-15 | Accepted | harness | Recent Decisions는 8개 rolling window, 후속 행동 바꾸는 결정만 포함 |
| DR-012 | Agent Entrypoint Symmetry | 2026-05-15 | Accepted | harness | CLAUDE.md/AGENTS.md 동등 진입점, 공통 규칙은 AGENT-WORKFLOW.md 위임 |
| DR-013 | Work 파일 기반 작업 단위 체계 도입 | 2026-05-18 | Accepted (Amended) | harness | `docs/works/{category}/{ID}-{topic}.md`, Top Summary·Context Manifest·Slice 기준·ID-less 정책 포함 |
| DR-014 | Archive 구조 정책 | 2026-05-18 | Accepted | harness | `docs/archive/` 하위 경로 미러링 방식 |
| DR-015 | State Update Proposal 2계층 게이트 모델 | 2026-05-18 | Accepted | harness | Work checkpoint=Layer 1(승인 불필요), STATUS 변경=Layer 2(승인 필요) |
| DR-016 | Work 파일 Done→Archived 전환 트리거 | 2026-05-18 | Accepted | harness | `/close`로 Done 처리, archive는 선택적 후속 단계 |
| DR-017 | Git 머지 전략 및 Branch Flow | 2026-05-20 | Accepted (Amended) | harness | feature→develop: Squash 기본 / Regular 예외; develop→main: Regular Merge 원칙 |
| DR-018 | CI 트리거 최적화 | 2026-05-20 | Accepted | harness | path filter + 병렬화, develop push CI 제거 |
| DR-019 | Codex Skill Naming Standard | 2026-05-24 | Accepted | harness | `.agents/skills/workflow-{name}/` prefix, suffix mapping 규칙 확정 |
| DR-020 | GitHub Repository Settings Policy | 2026-05-25 | Accepted (일부 Deferred) | harness | public 전환 ruleset/보안/기능 설정. `protect-main`·`protect-develop` 활성화, 일부 항목 보류 |
| DR-021 | Source / Framework-vs-Project-State Boundary | 2026-06-05 | Accepted | harness | scaffold 자산 3-class(framework/project-state/Optional pack), 물리 이동 없이 logical marker |
| DR-022 | PLAN Lifecycle — T5 배선 + Archive Drain | 2026-06-05 | Accepted | harness | hard gate 미신설, 기존 T5 closeout 배선 + PLAN archive drain |
| DR-023 | Canonical + Hybrid Adapter | 2026-06-05 | Accepted | harness | workflow canonical SSoT 1벌 + 도구별 hybrid adapter(hard-stop만 자체보유) |
| DR-024 | Gate Strictness 2D Taxonomy | 2026-06-05 | Accepted | harness | strictness × enforcement mode 2축, archive=optional hygiene |
| DR-025 | Commit Gate Runtime Enforcement | 2026-06-06 | Accepted | harness | DR-024 child. bundling 대상={T15,T16}, hard-stop=local-only 증명 기준(불가 시 degrade), override=commit-trailer sentinel, 구현은 downstream 위임 |
| DR-026 | `/repo-decision` → `/record-decision` Rename | 2026-06-07 | Accepted | harness | product·harness 양쪽 포괄. 원래 이름 복원, no-alias clean cut |
