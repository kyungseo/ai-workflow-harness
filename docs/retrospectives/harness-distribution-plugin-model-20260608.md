---
date: 2026-06-08
track: harness
type: process
scope: 현재 scaffold 배포/업그레이드 방식의 한계와 plugin 모델 전환 가능성 평가
author: "agent:claude-sonnet-4-6"
related_work: []
---

# Harness 배포·업그레이드 방식 — Plugin 모델 전환 가능성 평가

> 작성일: 2026-06-08
> 범위: 현재 shell script scaffold 방식의 구조적 한계, plugin 모델 전환 시 장단점, 전환 타이밍 판단
> 목적: adopter(`ai-deck-compiler`)가 생기면서 upgrade/migration 경로가 실질 과제로 부상했다. 배포 방식 자체를 바꾸는 것이 이 문제를 해결하는 올바른 경로인지 평가하고, 향후 work 선정 시 참고할 방향 판단을 기록한다.

---

## 결론

**plugin 모델 전환은 타당하지만 지금 시점에 착수할 이유가 약하다. 현재 병목은 배포 방식이 아니라 upgrade/migration 로직 자체다. shell script에서 해당 로직을 먼저 구현하고, adopter가 늘어나는 시점에 npm wrapping을 검토하는 순서가 맞다.**

추가 판단: harness는 구조적으로 "plugin"이 아니라 "파일 템플릿 시스템(scaffolding tool)"이다. 이 구분을 인식하고 설계해야 plugin 모델 도입 시 개념 충돌을 피할 수 있다.

---

## 1. 현재 방식과 한계

### 현재 배포 구조

```
사용자 → source repo clone → create-harness.sh 실행 → target repo에 파일 생성
```

- `--dry-run`: 생성 예정 파일 목록 확인
- `--existing`: 기존 project overlay (신규 파일만 추가, 기존 파일 덮어쓰지 않음)
- `--check <target>`: manifest 기반 drift 감지 (in-sync / source-updated / locally-modified)
- **upgrade/migration: 미구현** — `--check` 이후 수동 selective migration만 가능

### 실질 한계

| 영역 | 현재 상태 | 문제 |
|------|-----------|------|
| Discovery | source repo URL을 알아야만 진입 | 신규 adopter 유입 경로 없음 |
| Versioning | `VERSION` 파일 존재하나 target에 version pin 없음 | "어느 버전으로 scaffold했는가" 불명확 |
| Upgrade | `--check`로 drift 감지 후 수동 적용 | 변경 이유와 매핑을 migration note에서 별도 확인해야 함 |
| Migration | 미구현 | adopter가 major 변경을 수용할 공식 경로 없음 |

adopter `ai-deck-compiler`의 등장 이전에는 "source = adopter"였으므로 이 한계가 드러나지 않았다. 외부 adopter가 생기면서 upgrade/migration 경로 부재가 실질 리스크가 됐다.

---

## 2. 구조적 전제: harness는 "파일 템플릿 시스템"

plugin 논의 전에 이 구분을 명확히 해야 한다.

| | 일반 plugin | harness (scaffolding tool) |
|--|------------|--------------------------|
| 설치 결과 | host 환경에서 실행되는 바이너리/모듈 | target repo 안에 파일로 내재화 |
| 설치 후 연결 | plugin manager가 지속 관리 | 물리적 연결 끊김, 파일은 target 소유 |
| 업그레이드 | plugin manager가 교체 | framework-owned vs. project-owned 파일을 구분해 선택적 업데이트 |

유사 선례: `create-react-app`, `rails new`, `cookiecutter`. 업계에서는 이것들을 plugin이 아닌 scaffolding tool로 분류한다.

"plugin 모델"이라는 표현을 쓸 때 실제로 얻으려는 것은 **배포·버전 관리·upgrade UX**이지, plugin의 실행 모델은 아니다. 이 점을 혼동하면 설계 방향이 틀어진다.

---

## 3. Plugin 방식 장단점

### 장점

- **Discovery**: marketplace 검색 → 설치. 현재는 이 repo URL을 알아야만 진입 가능
- **Versioning**: semver + lockfile로 "어느 버전으로 scaffold했는가" 명확
- **Upgrade UX**: `npm update` / `brew upgrade` 같은 표준 흐름 — `--check` + 수동 적용보다 월등한 경험
- **Migration hook**: 패키지 버전 간 post-install 스크립트로 migration 자동화 가능한 구조

### 단점

- **dependency 추가**: 현재 bash + markdown, runtime 의존성 제로. npm이면 Node.js 필수. harness의 "runtime 없음" 강점이 희석됨
- **배포 관리 비용**: npm publish, CI/CD, release process 추가
- **소유권 모호**: 설치 후 파일은 target repo 소유인데 "plugin이 관리한다"는 개념이 충돌
- **근본 문제는 그대로**: framework-owned vs. project-owned 파일을 어떻게 구분해 업데이트할 것인가 — 이 로직은 npm이든 shell이든 동일하게 구현해야 한다. 배포 방식을 바꾼다고 쉬워지지 않는다.

---

## 4. 구현 옵션 비교

| 옵션 | 특징 | 트레이드오프 |
|------|------|------------|
| **npm package** (`npx create-ai-workflow-harness`) | scaffolding tool 관행에 가장 부합. 버전 관리·upgrade hook 표준 | Node.js 의존성. npm 계정/CI/release 관리 추가 |
| **GitHub Releases + versioned install.sh** | 현재 구조 유지, 의존성 없음. `VERSION` tag로 버전 pinning 가능. incremental 도입 용이 | marketplace 없음. upgrade 알림·UX 없음 |
| **Homebrew formula** | `brew install` UX 깔끔. upgrade 표준 | macOS 편향. "파일을 repo에 복사하는 툴"과 Homebrew 패키지 모델이 어색하게 맞음 |
| **VS Code / Claude Code extension** | 특정 툴 내 설치 UX | Claude Code + Codex + Cursor 동시 지원이 목적인 harness와 tool lock-in 충돌. 적합하지 않음 |

npm이 현실적으로 가장 자연스러운 선택이지만, shell script 내부 로직을 Node.js로 재작성할 것인가 vs. shell을 그대로 bin으로 expose할 것인가의 결정이 추가로 필요하다.

---

## 5. 전환 타이밍 판단

### 지금 전환할 이유가 약한 세 가지 근거

1. **현재 adopter 규모**: `ai-deck-compiler` 한 곳. marketplace discovery가 지금 당장 필요하지 않다.
2. **핵심 병목은 upgrade/migration 로직**: 배포 방식이 아니다. npm으로 wrapping해도 이 로직이 없으면 upgrade UX는 그대로다.
3. **dependency 비용**: bash + markdown 시스템에 Node.js를 올리면 프로젝트 성격이 바뀐다. 이 결정은 가역 비용이 크다.

### 권장 전환 순서

```
[현재]
shell script scaffold
--check drift 감지 (구현됨)
upgrade/migration: 미구현

     ↓ 선행 과제

[단계 1] shell에서 upgrade/migration 로직 구현
- framework-owned vs. project-owned 파일 업데이트 정책 확정
- version marker 도입 (어느 버전으로 scaffold됐는가)
- selective apply: --check 결과 → 자동/반자동 update
- backup 정책: project-owned 파일 보존

     ↓ adopter 증가 시

[단계 2] 필요에 따라 npm wrapping 또는 GitHub Releases 버전 관리 도입
- 단계 1의 shell 로직을 그대로 활용
- 배포 레이어만 추가
```

GitHub Releases + versioned install.sh는 npm 없이 버전 pinning과 upgrade 알림을 도입할 수 있는 incremental 경로로, 단계 1 완료 후 단계 2 전에 먼저 고려할 수 있다.

---

## 6. Revisit Triggers

이 판단을 다시 꺼내 재검토할 시점:

- adopter가 2곳 이상으로 늘어나고 discovery 요구가 실측될 때
- `ai-deck-compiler`에서 upgrade/migration 수동 처리 비용이 실질 마찰로 보고될 때
- shell upgrade/migration 로직이 안정화되고 "배포 방식 개선"이 다음 레버가 될 때
- Node.js 의존성 도입을 감수할 만한 다른 이유(테스트 자동화, cross-platform 지원 등)가 생길 때

---

## 연결

- 선행 과제: `docs/backlog/HARNESS.md` — "Harness upgrade/migration 메커니즘" (P1 Candidate)
  - selective migration 로직, version marker, backup 정책, dry-run/apply 경로
- 관련 문서: `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md` — 현재 upgrade가 수동인 상황에서 target maintainer가 참조하는 migration note. upgrade 자동화 시 이 문서의 역할도 재정의 필요
- 관련 DR: DR-021 (source / framework-vs-project-state boundary — framework-owned vs. project-owned 파일 구분의 설계 근거)
