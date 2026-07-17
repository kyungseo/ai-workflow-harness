# Local Repo Map (source-only)

운영자 로컬 환경(machine-local) 기준의 adopter·관련 repo 위치/관계 map이다.
scaffold 어떤 옵션에서도 배포되지 않는다(DR-021 source-only). 경로는 이 machine에서만 유효하므로 사용 전 실재를 확인한다.
living data(harness_version·baseline·profile·UF 채널 보유 여부)는 `docs/backlog/HARNESS.md` "Adopter evidence set" 표가 소유한다 — 이 파일에는 정적 사실(위치·역할·관계)만 둔다.

| Path | Role | 관계 / 비고 |
| --- | --- | --- |
| `~/dev-home/vibe/ai-workflow-harness` | source | harness source repo (이 repo) |
| `~/dev-home/vibe/base-msa-template` | origin mirror | harness의 모태 — mirror해서 시작. adopter 아님(scaffold target evidence set 제외, backlog fleet 표 참조) |
| `~/dev-home/vibe/spring-modular-template` | adopter | |
| `~/dev-home/vibe/ai-deck-compiler` | adopter | 대화에서 `ai-deck`으로 축약 언급되곤 함 |
| `~/dev-home/vibe/toolstead` | adopter | tool 중앙 저장소 — Skillstead/SessionCue 멀티 product 운용 |
| `~/dev-home/rfx-hub` | adopter | **`vibe/` 밖 위치 주의** |
| `~/dev-home/vibe/public-release-playbook` | reference | release-gate 참고용으로 생성한 repo |
| `~/dev-home/vibe/ref` | reference | 외부 참고용 저장소 모음 — upstream clone이며 수정·push하지 않는다. 구체 목록은 이 파일에 기록하지 않고, 각 분석 brief가 대상 repo와 snapshot을 소유한다 |
| `~/dev-home/vibe/claude-personal` | personal config | Claude Code 전역 지침·개인 skill SSoT — `~/.claude`에 symlink 설치 (private, 2026-07-17 생성) |
| `~/dev-home/vibe/codex-personal` | personal config | Codex 전역 AGENTS.md·개인 skill SSoT — `~/.codex`에 symlink 설치 (private, 2026-07-17 생성) |

## Adopter Consumption

이 파일이 fleet 위치 정보의 SSoT다 — adopter로 복제하지 않는다(drift 방지).

- 운영자가 scaffold한 adopter는 자기 repo의 `docs/STATUS.md` Current State 표에 pointer row 1줄을 둔다. Current State는 4개 도구 전부가 매 세션 로드하는 유일한 adopter-owned 표면이라 trigger 가시성이 확보된다(조건부 로드인 `docs/PLAN-SUMMARY.md`에 두면 cross-repo 경로 질문에서 pointer가 발화하지 않음이 실측됨 — 2026-07-14 toolstead 세션). 권장 문구:
  > `| Local repo map | ~/dev-home/vibe/ai-workflow-harness/docs/maintainer/REPO-MAP.md (machine-local — cross-repo 작업 시 로드) |`
- 외부 adopter에는 해당 없음 — scaffold는 이 파일을 배포하지 않고 pointer도 생성하지 않는다.
- agent-side 지속 컨텍스트(Claude memory, 전역 config 등)에 이 map을 저장하지 않는다 — `docs/BEHAVIOR-PRINCIPLES.md` §6(repo명·경로는 harness 문서가 SSoT).
