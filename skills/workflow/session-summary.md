# session-summary

Canonical workflow procedure for `/session-summary`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/session-summary.md` |
| Codex | `.agents/skills/workflow-session-summary/SKILL.md` |
| Antigravity | Codex adapter 재사용: `.agents/skills/workflow-session-summary/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

**이 명령은 세션을 종료할 때만 실행한다.** 작업 하나가 끝나면 Work 파일 checkpoint/Done 처리, 필요한 state-change proposal, commit gate만 수행하고 다음 작업으로 이어가면 된다. `/session-summary`은 여러 작업을 마친 후 세션 전체를 정리할 때 쓴다.

**Work를 완료하고 싶다면** `/work-close`를 먼저 실행해줘. `/work-close`는 Work Done 처리만 수행하고 세션은 계속된다. `/session-summary`은 Work Done 처리 없이 세션 요약만 출력한다.

이번 세션에서 진행한 내용을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. 다음 세션에서 먼저 볼 파일
6. docs/STATUS.md 업데이트 필요 여부
   - 필요하다면 즉시 수정하지 말고 Approval Matrix state rules에 맞는 제안을 제시해.
   - Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 제안으로 충분하다.
   - Current phase/focus, Recent Decisions 변경은 `STATUS Update Proposal`로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 제시해.
   - commit/PR 전 STATUS Finalization이 완료되었는지 확인해. Active Work pointer, Current phase/focus, Blockers/OQ, Next Actions, Recent Decisions, Active Work Discovery 최신성을 기준으로 `STATUS.md` 변경 필요 yes/no와 이유를 보고해.
   - commit/PR 전 Tracking Finalization이 완료되었는지 확인해.
     연결된 backlog 항목의 Status/Done Criteria/Verification, Work 파일 frontmatter/status/Checkpoints/Discovery,
     Work index README 위치, 관련 DR의 Status/Supersedes/Linked Backlog Items,
     완료된 Quick Mode 작업이 backlog Candidate로 남은 여부를 확인해.
     backlog/Work/DR tracker 변경 필요 yes/no와 이유를 보고해.
   - Recent Decisions 변경 제안에는 후속 행동을 바꾸는 운영/기술 판단만 포함해. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둬.
   - Recent Decisions는 최근 8개 rolling window를 유지하고, 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인해.
   - 사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해.
7. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
8. troubleshooting 기록 필요 여부
   - 이번 작업에서 원인 불명의 이슈(환경 설정 문제, 재현 어려운 오류, 불명확한 원인)를 해결했으면 `docs/troubleshooting/`에 기록 여부를 물어봐.
   - 이미 관련 파일이 있으면 업데이트 필요 여부를 확인해.
9. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT 또는 FAIL/RECOVER 필요 여부
10. Commit 상태
   - commit 전 branch isolation check: `git branch --show-current` 확인. `develop` 또는 `main`에서 protected workflow 파일이 staged되어 있으면 FAIL — `feature/*` branch 생성을 제안한다. `.git/MERGE_HEAD` 존재 시(merge commit) 면제.
   - commit 수행 여부
   - commit하지 않았다면 이유와 남은 risk
   - git repository가 없는 bootstrap 초기 상태에서는 이 단계를 `Not Applicable`로 보고한다.
   - commit 전 필요한 경우 `git status -> git add <files> -> git status -> git diff --cached` 순서 확인

11. Active Work Pause Discovery 확인
   - Active Work가 있으면 해당 Work 파일의 Discovery 섹션에 현재 진행 상황이 기록되어 있는지 확인한다.
   - 미기록 상태(비어 있거나 마지막 기록 이후 진행된 내용이 있는 경우)라면 기록할 내용을 제안하고 기록 여부를 묻는다.
   - 사용자가 기록 불필요 확인 시 그대로 진행한다.
   - Work를 완료하고 싶다면: `/work-close`를 먼저 실행해 Work Done 처리를 완료한 뒤, 다시 `/session-summary`을 실행해 세션 요약을 완성한다.

다음 세션의 시작 프롬프트로 바로 사용할 수 있는 짧은 문장도 마지막에 작성해줘.
