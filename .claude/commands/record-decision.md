---
description: "확정된 기술적 의사결정을 DR 파일로 기록한다"
argument-hint: "[decision-topic]"
disable-model-invocation: true
---

$ARGUMENTS 또는 현재 대화에서 확정된 기술적 의사결정 사항을 DR로 기록해줘.

1. `docs/decisions/` 디렉토리의 기존 DR 목록을 확인하고 다음 번호를 결정해.
2. 이번 대화에서 결정된 내용을 아래 형식으로 요약해:
   - 결정 제목과 DR 번호
   - 검토한 선택지
   - 채택 이유
   - 되돌리기 비용 (Low / Medium / High)
3. `docs/decisions/DR-{번호}-{topic}.md` 초안을 제시해.
   - DR 파일은 DR-007 Bilingual Rules 적용 대상이다. 섹션 타이틀은 영문 Title Case를 유지한다.
4. 승인 후 파일을 생성해.
5. Accepted DR마다 `docs/STATUS.md`의 Recent Decisions 업데이트 필요 여부를 반드시 판정해.
   - 필요하면 Approval Matrix의 고영향 상태 변경으로 보고하고 `STATUS Update Proposal`로 별도 제안해.
   - 불필요하면 이유를 closeout 또는 commit 전 summary에 명시해.
   - 후속 행동을 바꾸는 운영/기술 판단만 포함해. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둬.
   - 최근 8개 rolling window를 유지해. 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인해.
6. PLAN/ARCHITECTURE/DEVELOPER-GUIDE/backlog cascade 대상이 있는지 확인하고 제안해.

승인 없이 파일을 생성하지 마.
승인 없이 STATUS.md를 수정하지 마.

STATUS Update Proposal에는 아래 항목을 포함해줘.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.

## DR-Worthy Criteria (if one or more applies)
- 도구·프레임워크 선택 (예: Checkstyle vs Spotless, Helm vs Kustomize)
- 아키텍처 경계·정책 결정 (예: CI job 분리, 파일 헤더 없음 정책)
- 되돌리기 비용 Medium 이상
- 두 개 이상 컴포넌트 또는 개발자에 영향

## DR Not Required
- 구현 세부사항, 버그 수정, 마이너 config 조정
