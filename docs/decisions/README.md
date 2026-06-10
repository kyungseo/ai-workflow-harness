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
- `Draft` — 초안. 아직 확정 전(선택 보류). cascade 감사 대상 아님.
- `Draft (Dropped)` — 채택하지 않기로 한 Draft. 폐기 사유 명시 후 archive 이동, 번호 retire (DR-029).

**Track legend:** `harness` = AI workflow·명령·프로토콜 결정 / `product` = 적용 프로젝트의 기능·아키텍처 결정

| ID | Title | Date | Status | Track | 요약 |
|----|-------|------|--------|-------|------|
| DR-007 | 파일 유형별 작성 언어 원칙 | 2026-05-11 | Accepted (Amended) | harness | 문서·command·prompt·hook은 Korean primary + English technical terms |
| DR-008 | docs/ 파일명 대소문자 표준 | 2026-05-12 | Accepted | harness | `docs/` 파일명은 UPPER-KEBAB-CASE |
| DR-011 | STATUS.md Recent Decisions Rolling Window Policy | 2026-05-15 | Accepted | harness | Recent Decisions는 8개 rolling window, 후속 행동 바꾸는 결정만 포함 |
| DR-012 | Agent Entrypoint Symmetry | 2026-05-15 | Accepted | harness | CLAUDE.md/AGENTS.md 동등 진입점, 공통 규칙은 AGENT-WORKFLOW.md 위임 |
| DR-013 | Work 파일 기반 작업 단위 체계 도입 | 2026-05-18 | Accepted (Amended) | harness | `docs/works/{category}/{ID}-{topic}.md`, Top Summary·Context Manifest·Slice 기준·ID-less 정책·`related_work` 필드 포함 |
| DR-014 | Archive 구조 정책 | 2026-05-18 | Accepted | harness | `docs/archive/` 하위 경로 미러링 방식 |
| DR-015 | State Update Proposal 2계층 게이트 모델 | 2026-05-18 | Accepted | harness | Work checkpoint=Layer 1(승인 불필요), STATUS 변경=Layer 2(승인 필요) |
| DR-016 | Work 파일 Done→Archived 전환 트리거 | 2026-05-18 | Accepted | harness | `/close`로 Done 처리, archive는 선택적 후속 단계 |
| DR-017 | Git 머지 전략 및 Branch Flow | 2026-05-20 | Accepted (Amended) | harness | feature→develop: Squash 기본 / Regular 예외; develop→main: Regular Merge 원칙 |
| DR-018 | CI 트리거 최적화 | 2026-05-20 | Accepted | harness | path filter + 병렬화, develop push CI 제거 |
| DR-019 | Codex Skill Naming Standard | 2026-05-24 | Accepted | harness | `.agents/skills/workflow-{name}/` prefix, suffix mapping 규칙 확정 |
| DR-020 | GitHub Repository Settings Policy | 2026-05-25 | Accepted (일부 Deferred · Amended) | harness | public 전환 ruleset/보안/기능 설정. `protect-main`·`protect-develop` 활성화. `delete_branch_on_merge` off(2026-06-08, develop 유실 방지) |
| DR-021 | Source / Framework-vs-Project-State Boundary | 2026-06-05 | Accepted | harness | scaffold 자산 3-class(framework/project-state/Optional pack), 물리 이동 없이 logical marker |
| DR-022 | PLAN Lifecycle — T5 배선 + Archive Drain | 2026-06-05 | Accepted | harness | hard gate 미신설, 기존 T5 closeout 배선 + PLAN archive drain |
| DR-023 | Canonical + Hybrid Adapter | 2026-06-05 | Accepted | harness | workflow canonical SSoT 1벌 + 도구별 hybrid adapter(hard-stop만 자체보유) |
| DR-024 | Gate Strictness 2D Taxonomy | 2026-06-05 | Accepted | harness | strictness × enforcement mode 2축, archive=optional hygiene |
| DR-025 | Commit Gate Runtime Enforcement | 2026-06-06 | Accepted | harness | DR-024 child. bundling 대상={T15,T16}, hard-stop=local-only 증명 기준(불가 시 degrade), override=commit-trailer sentinel, 구현은 downstream 위임 |
| DR-026 | `/repo-decision` → `/record-decision` Rename | 2026-06-07 | Accepted | harness | product·harness 양쪽 포괄. 원래 이름 복원, no-alias clean cut |
| DR-027 | Troubleshooting / Retrospective 파일 최소 스펙 | 2026-06-07 | Accepted | harness | frontmatter(symptom/track/category/status, date/track/type/scope/author) 도입. category·type은 예시 열거, 열거형 제한 없음 |
| DR-028 | Versioning Policy — Git Tag SSoT + Semver 기준 | 2026-06-08 | Accepted | harness | git tag(`ai-workflow-v{X.Y.Z}`)가 버전 SSoT, VERSION은 bare semver mirror. semver는 scaffold consumer contract 대상. Phase 2=1.1.0(MINOR) |
| DR-029 | DR Registration Triage + Draft DR Lifecycle Completion | 2026-06-09 | Accepted | harness | DR 등록 3-way triage(Accepted/Draft/OQ·backlog) + Question routing table + Draft 승격 절차·`Draft (Dropped)`·repo-health hygiene surfacing. 기존 lifecycle 참조 |
| DR-030 | Language / i18n Strategy for Native and English Users | 2026-06-09 | Draft | harness | adopter-facing/scaffold 출력 언어(i18n) 정책. 옵션 ①현행 ②source-facing 정리 ③scaffold `--lang en` ④full i18n. 1차 청중·수요 signal 미결 — DR-007 amend 후보 |
| DR-031 | Product Track Structure — Symmetric PRODUCT.md + Optional Phase | 2026-06-09 | Accepted (Amended) | harness | product backlog/work를 harness와 대칭(`PRODUCT.md`/`works/product/`)으로, phase는 optional migration. PHASE{n} 네이밍 충돌 해소. branch 단축 `feature/prod-{topic}` |
| DR-032 | Phase Model De-formalization — Descriptive Optional Label | 2026-06-10 | Accepted | harness | harness "Phase"를 descriptive+optional 라벨로 de-formalize. 완료 criteria 게이트 제거, 전환=Recent Decisions 기록, Work Done=진실 단위(phase 경계 비강제). T3 재정의, dangling `Phase completion criteria` 참조 정정, scaffold phaseless-default 정합 |
| DR-033 | Shipped DR Reference Closure | 2026-06-10 | Accepted | harness | shipped 표면 문서는 scaffold seed에 닫힌 DR만 참조. mode-a(canonical) self-describe / mode-b(shipped DR 파일) Linked DRs frontmatter 격리. seed SSoT=create-harness.sh 파생. source-only static check로 작성 시점 사전 강제 |
