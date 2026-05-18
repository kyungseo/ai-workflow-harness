---
description: "세션 전체 요약을 출력한다. Work Done 처리 없음 — Work 완료는 /close로 먼저 처리할 것"
disable-model-invocation: true
---

**이 명령은 세션을 종료할 때만 실행한다.** 작업 하나가 끝나면 Work 파일 checkpoint/Done 처리, 필요한 state update 제안, commit gate만 수행하고 다음 작업으로 이어가면 된다. `/done`은 여러 작업을 마친 후 세션 전체를 정리할 때 쓴다.

**Work를 완료하고 싶다면** `/close`를 먼저 실행해줘. `/close`는 Work Done 처리만 수행하고 세션은 계속된다. `/done`은 Work Done 처리 없이 세션 요약만 출력한다.

이번 세션에서 진행한 내용을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. 다음 세션에서 먼저 볼 파일
6. docs/STATUS.md 업데이트 필요 여부
   - 필요하다면 즉시 수정하지 말고 Approval Matrix state rules에 맞는 제안을 제시해.
   - Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 제안으로 충분하다.
   - Phase completion criteria, Current phase/focus, Recent Decisions 변경은 `STATUS Update Proposal`로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 제시해.
   - Recent Decisions 변경 제안에는 후속 행동을 바꾸는 운영/기술 판단만 포함해. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둬.
   - Recent Decisions는 최근 8개 rolling window를 유지하고, 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인해.
   - 사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해.
7. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
8. troubleshooting 기록 필요 여부
   - 이번 작업에서 비자명 이슈(환경 설정 문제, 재현 어려운 오류, 비직관적 원인)를 해결했으면 `docs/troubleshooting/`에 기록 여부를 물어봐.
   - 이미 관련 파일이 있으면 업데이트 필요 여부를 확인해.
9. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT 또는 FAIL/RECOVER 필요 여부
10. Commit 상태
   - commit 수행 여부
   - commit하지 않았다면 이유와 남은 risk
   - commit 전 필요한 경우 `git status -> git add <files> -> git status -> git diff --cached` 순서 확인

11. Active Work Pause Discovery 확인
   - Active Work가 있으면 해당 Work 파일의 Discovery 섹션에 현재 진행 상황이 기록되어 있는지 확인한다.
   - 미기록 상태(비어 있거나 마지막 기록 이후 진행된 내용이 있는 경우)라면 기록할 내용을 제안하고 기록 여부를 묻는다.
   - 사용자가 기록 불필요 확인 시 그대로 진행한다.
   - Work를 완료하고 싶다면: `/close`를 먼저 실행해 Work Done 처리를 완료한 뒤, 다시 `/done`을 실행해 세션 요약을 완성한다.

다음 세션의 시작 프롬프트로 바로 사용할 수 있는 짧은 문장도 마지막에 작성해줘.
