# session-start

Canonical workflow procedure for `/session-start`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/session-start.md` |
| Codex | `.agents/skills/workflow-session-start/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

docs/STATUS.md의 Current State, Active Work, Blockers And Open Questions, Next Actions만 확인해줘.
`docs/BOOTSTRAP.md` 존재 여부는 확인하지 마. 다만 Next Actions가 scaffold bootstrap/onboarding을 명시하면 후속 작업에서 `docs/BOOTSTRAP.md`를 로드해야 한다고 알려줘.
그다음 `docs/works/*/*.md` 중 `status: Done`이지만 archive되지 않은 Work 파일이 있는지 파일명과 frontmatter 수준으로만 확인해줘.
Done이지만 archive되지 않은 Work 파일이 5개 이상이면, 섹션 6(리스크와 확인 질문)에 PLAN 누적 드리프트 가능성을 soft warning으로 포함한다. 개별 Work마다 T5 판정이 "영향 없음"이었더라도 여러 Work가 완료되면서 `docs/PLAN.md`와 실제 진행 방향 간 괴리가 생길 수 있다. 주기적 PLAN 현행화 검토(`/work-select` 또는 별도 세션)를 권장한다.
Phase 1 또는 refactor 이전 상세가 필요하고 해당 경로가 실제 존재하는 경우에만 docs/archive/ 또는 docs/archive/snapshots/harness-refactor-20260514/를 추가로 참고해줘.

**Idle-State Rule:** Active Work 없음 + Next Actions 없음 + archive 대기 Work 없음인 경우,
- Blockers And Open Questions에 Open 항목이 있으면 section 4에서 idle-state 안내보다 먼저 노출한다.
- Open Blocker도 없으면 section 4를 아래 형식으로 출력한다. 닫힌 milestone을 next candidate로 자동 확장하지 않는다.
  ```
  현재 repository는 Active Work와 Next Actions가 없는 clean idle 상태입니다.
  다음 작업을 고르려면: /work-select
  새 작업을 등록하려면: /work-register
  다른 프로젝트에 harness를 적용하려는 source repo 작업이라면 README Section 10 New Project Adoption을 참고하세요.
  ```

아래 형식으로 현재 상태를 요약해줘.

1. 결론
2. 현재 Active Work
3. Archive 대기 Work 파일
4. 다음으로 진행할 후보 작업
5. 필요한 추가 문서
6. 리스크와 확인 질문

아직 구현은 시작하지 말고, 진행할 작업을 먼저 제안해줘.
Archive 대기 Work가 있으면 사용자 승인 전에는 `git mv`를 실행하지 말고 archive 여부만 제안해줘.
(Done 상태 Work는 이전 세션에서 `/work-close`로 완료 처리된 것이다. 재개가 필요하면 `/work-resume`을 쓰되, Done Work는 재개하지 않고 후속 작업을 신규 Work로 분리한다.)
