# BLOCK 10 — 문서화 및 마무리

> 선행 조건: BLOCK 9 완료
> 목적: 전체 구현 최종 점검 + README 작성

---

## 구현 태스크

- [ ] `README.md` 작성
  - 프로젝트 개요 및 기술 스택 요약
  - 사전 요구사항 (Docker Desktop, JDK 21, VS Code)
  - 빠른 시작 (`make run` 한 줄)
  - 서비스 포트 및 주요 엔드포인트 목록
  - DevContainer 실행 방법
  - 환경변수 설정 방법 (`.env.example` 기반)
  - 테스트 실행 방법 (`make test`)
  - 신규 서비스 추가 방법 (`make create-service`)

- [ ] `docs/PLAN.md` / `docs/ARCHITECTURE.md` 내용과 실제 구현 간 불일치 점검
  - 변경된 포트, URL, 설정값 업데이트
  - 구현 과정에서 결정된 사항 반영

- [ ] 전체 테스트 통과 확인
  ```bash
  make test
  # ./gradlew test — 전체 모듈
  ```

- [ ] 전체 스택 최종 기동 확인
  ```bash
  make run
  # docker compose up — 전체 서비스
  ```

---

## 최종 체크리스트

- [ ] 모든 서비스 `SPRING_PROFILES_ACTIVE=local` 기동 정상
- [ ] `make run` (Docker Compose 전체) 기동 정상
- [ ] `tests/http/` 전체 케이스 실행 정상
- [ ] `.env` 없이 기동 시 명확한 오류 메시지 출력 확인 (환경변수 누락 감지)
- [ ] Swagger UI local 프로파일 활성 / stg 프로파일 비활성 확인
- [ ] `docs/PLAN.md`와 실제 구현 일치 확인

---

## 완료 조건

- [ ] `make test` 전체 통과
- [ ] `make run` 전체 기동 성공
- [ ] README.md 작성 완료

## Phase 2 전환

BLOCK 10 완료 → `docs/decisions/PHASE2-BACKLOG.md` 참조하여 Phase 2 계획 수립
