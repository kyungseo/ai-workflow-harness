---
name: "harness-start"
description: "세션 시작 시 STATUS.md 현재 섹션과 Done 미archive Work를 요약하고 다음 후보를 제안한다"
---

# harness-start

Use this skill when the user asks to invoke the harness workflow `start`.

## Command Template

docs/STATUS.md의 Current State, Active Work, Blockers And Open Questions, Next Actions만 확인해줘.
`docs/BOOTSTRAP.md` 존재 여부는 확인하지 마. 다만 Next Actions가 scaffold bootstrap/onboarding을 명시하면 후속 작업에서 `docs/BOOTSTRAP.md`를 로드해야 한다고 알려줘.
그다음 `docs/works/*/*.md` 중 `status: Done`이지만 archive되지 않은 Work 파일이 있는지 파일명과 frontmatter 수준으로만 확인해줘.
Phase 1 또는 refactor 이전 상세가 필요하고 해당 경로가 실제 존재하는 경우에만 docs/archive/ 또는 docs/archive/snapshots/harness-refactor-20260514/를 추가로 참고해줘.

아래 형식으로 현재 상태를 요약해줘.

1. 결론
2. 현재 Active Work
3. Archive 대기 Work 파일
4. 다음으로 진행할 후보 작업
5. 필요한 추가 문서
6. 리스크와 확인 질문

아직 구현은 시작하지 말고, 진행할 작업을 먼저 제안해줘.
Archive 대기 Work가 있으면 사용자 승인 전에는 `git mv`를 실행하지 말고 archive 여부만 제안해줘.
(Done 상태 Work는 이전 세션에서 `/close`로 완료 처리된 것이다. 재개가 필요하면 `/resume`을 쓰되, Done Work는 재개하지 않고 후속 작업을 신규 Work로 분리한다.)
