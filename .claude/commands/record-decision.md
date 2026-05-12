$ARGUMENTS 또는 현재 대화에서 확정된 기술적 의사결정 사항을 DR로 기록해줘.

1. `docs/decisions/` 디렉토리의 기존 DR 목록을 확인하고 다음 번호를 결정해.
2. 이번 대화에서 결정된 내용을 아래 형식으로 요약해:
   - 결정 제목과 DR 번호
   - 검토한 선택지
   - 채택 이유
   - 되돌리기 비용 (Low / Medium / High)
3. `docs/decisions/DR-{번호}-{topic}.md` 초안을 제시해.
4. 승인 후 파일을 생성하고 `docs/STATUS.md`의 Recent Decisions 업데이트를 제안해.

승인 없이 파일을 생성하지 마.

## DR-worthy 판단 기준 (하나 이상 해당 시)
- 도구·프레임워크 선택 (예: Checkstyle vs Spotless, Helm vs Kustomize)
- 아키텍처 경계·정책 결정 (예: CI job 분리, 파일 헤더 없음 정책)
- 되돌리기 비용 Medium 이상
- 두 개 이상 컴포넌트 또는 개발자에 영향

## DR 불필요
- 구현 세부사항, 버그 수정, 마이너 config 조정
