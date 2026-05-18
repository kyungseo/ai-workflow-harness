---
id: PRE-B
priority: P0
status: Active
risk: Low
scope: 개발환경 전략 결정 — 로컬 실행 구조(B-1), Windows 지원(B-2), devcontainer(B-3), mono-repo(B-4)
appetite: 1d
planned_start: 2026-05-18
planned_end:
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

Phase 2 실행에 앞서 팀 개발환경 전제 조건을 명확히 결정한다.
결정이 불분명한 채로 Wave 1~3 작업을 시작하면 K8s overlay, Dockerfile 개선, devcontainer 방향이 엇갈릴 수 있다.
코드 구현 없이 현황 파악 → 결정 → 기록으로 완료한다.

### 현재 상태 (착수 시점)

| 항목 | 현황 |
|---|---|
| 로컬 실행 | `scripts/Makefile` + `infra/docker/docker-compose.yml` — `make run`으로 전체 스택 기동 |
| devcontainer | `.devcontainer/` 존재. java:1-21-bookworm + docker-in-docker + PostgreSQL/Redis 포함 |
| Windows 지원 | README에 Docker Desktop 4.x+ 요건만 명시. WSL2 언급 없음 |
| mono-repo | Gradle multi-module 구조 유지 중 |

### 결정 항목 (B-1 ~ B-4)

**B-1: 로컬 실행 구조**
- docker-compose (`make run`) vs devcontainer 중 무엇을 1차 진입점으로 삼을 것인가?
- 두 경로 병행 유지 시 가이드 우선순위와 README 정렬 필요

**B-2: Windows 지원 범위**
- WSL2 + Docker Desktop 기준으로 공식 지원할 것인가?
- native Windows(PowerShell/cmd) 지원 여부
- CI는 ubuntu-latest 유지, 로컬은 WSL2 권장으로 범위 한정 가능

**B-3: devcontainer 전략**
- 현재 devcontainer를 Phase 2에서 강화할 것인가, 보조 경로로 유지할 것인가?
- 강화 시: non-root user, postCreate 개선, Cursor/Claude Code 설정 포함 여부
- 현재 `postCreateCommand: ./gradlew build -x test` — Phase 2에서 충분한가?

**B-4: mono-repo 구조 유지**
- 현재 Gradle multi-module mono-repo 구조를 Phase 2 전반에서 유지할 것인가?
- 서비스별 repo 분리 검토 여부 (현재 공유 common-core 의존성 고려)

## Done Criteria

- [ ] B-1: 로컬 실행 1차 진입점 결정 및 README/DEVELOPER-GUIDE 정렬 방향 확정
- [ ] B-2: Windows 지원 범위 결정 (WSL2 공식 지원 여부)
- [ ] B-3: devcontainer Phase 2 전략 결정 (강화 vs 보조 유지)
- [ ] B-4: mono-repo 구조 유지 여부 확정
- [ ] 결정 사항 DR 또는 planning 문서에 반영

## Verification

각 결정 사항이 DR 또는 Work Discovery에 명확히 기록됨을 확인한다.
코드/설정 변경이 동반되는 결정(예: devcontainer 강화)은 후속 작업으로 분리 등록한다.

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | B-1 로컬 실행 구조 결정 | Todo |
| 2  | B-2 Windows 지원 범위 결정 | Todo |
| 3  | B-3 devcontainer 전략 결정 | Todo |
| 4  | B-4 mono-repo 결정 | Todo |
| 5  | 결정 사항 기록 및 후속 작업 등록 | Todo |

## Discovery

### B-3 devcontainer 갭 (2026-05-18, 전환 전 스냅샷)

현재 devcontainer compose에는 postgres + redis만 포함됨. Spring Boot 서비스(auth/user/todo/gateway)는 포함되지 않음.
개발자가 devcontainer에 들어가면 직접 `./gradlew bootRun`으로 서비스를 하나씩 띄워야 하며,
전체 스택 E2E 테스트는 별도 `make run`(infra/docker/docker-compose.yml)을 사용해야 함.

**미결 결정 (B-3 핵심 질문):**
- 방향 A: 단일 서비스 개발 모델 유지 (현재 상태, 코딩용 컨테이너 + DB/Redis만)
- 방향 B: 전체 스택 devcontainer (나머지 서비스 pre-built image 추가, docker-in-docker로 make run 가능하게)
- 방향 C: docker-compose 1차, devcontainer 폐기 또는 IDE 설정 전용 축소

B-1, B-2, B-4는 아직 논의 미착수.
