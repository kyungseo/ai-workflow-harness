$ARGUMENTS 또는 현재 대화에서 확정된 기술적 의사결정 사항을 DR로 기록해줘.

1. `docs/decisions/` 디렉토리의 기존 DR 목록을 확인하고 다음 번호를 결정해.
2. 이번 대화에서 결정된 내용을 아래 형식으로 요약해:
   - 결정 제목과 DR 번호
   - 검토한 선택지
   - 채택 이유
   - 되돌리기 비용 (Low / Medium / High)
3. `docs/decisions/DR-{번호}-{topic}.md` 초안을 제시해.
4. 승인 후 파일을 생성해.
5. `docs/STATUS.md`의 Recent Decisions 업데이트가 필요하면 `STATUS Update Proposal`로 별도 제안해.
6. PLAN/ARCHITECTURE/DEVELOPER-GUIDE/backlog cascade 대상이 있는지 확인하고 제안해.

승인 없이 파일을 생성하지 마.
승인 없이 STATUS.md를 수정하지 마.

STATUS Update Proposal에는 아래 항목을 포함해줘.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.

## DR-worthy 판단 기준 (하나 이상 해당 시)
- 도구·프레임워크 선택 (예: Checkstyle vs Spotless, Helm vs Kustomize)
- 아키텍처 경계·정책 결정 (예: CI job 분리, 파일 헤더 없음 정책)
- 되돌리기 비용 Medium 이상
- 두 개 이상 컴포넌트 또는 개발자에 영향

## DR 불필요
- 구현 세부사항, 버그 수정, 마이너 config 조정
