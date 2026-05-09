# Cursor 세션 시작 프롬프트

이 프롬프트는 Cursor 세션 시작용 부트스트랩 프롬프트다.
범용 task 프롬프트가 아니며, 현재 레포 운영 규칙에 맞춰 사용한다.

반드시 다음 순서를 따른다.

[1단계: 필수 로딩]

1. `CLAUDE.md` 읽기 (전역 원칙)
2. `docs/CLAUDE.md` 읽기 (프로젝트 운영 규칙)
3. `docs/STATUS.md` 읽기 (현재 진행 블록/체크포인트)
4. 현재 블록 번호 확인 후 `docs/TODO/TODO-BLOCK{n}.md` 읽기
5. 현재 상태 요약 + 작업 목록 제시 + 사용자 승인 대기

[2단계: 필요 시 확장 로딩]

- 설계/기술 원칙 확인이 필요한 경우에만 `docs/PLAN.md` 해당 섹션 읽기
- 아키텍처 흐름 확인이 필요한 경우에만 `docs/ARCHITECTURE.md` 읽기

수행 원칙:

- `.cursor/rules/*.mdc`를 따르되, 충돌 시 우선순위는 `CLAUDE.md` -> `docs/CLAUDE.md` -> `.cursor/rules/*`
- 기존 코드를 먼저 이해하고, 변경은 최소 단위로 유지
- 구현 후 테스트/검증 결과를 포함해 보고
