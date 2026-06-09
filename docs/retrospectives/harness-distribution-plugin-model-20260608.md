---
date: 2026-06-08
track: harness
type: process
scope: simplicity 원칙 하에 외부 harness 트렌드 follow-up 수준 판단 + 현재 scaffold 배포/업그레이드 방식의 한계와 plugin 모델 전환 가능성 평가
author: "agent:claude-sonnet-4-6"
related_work: []
---

# Harness 배포·업그레이드 방식 — Plugin 모델 전환 가능성 평가

> 작성일: 2026-06-08
> 범위: simplicity 원칙과 외부 harness 트렌드 follow-up 수준 판단, 현재 shell script scaffold 방식의 구조적 한계, plugin 모델 전환 시 장단점, 전환 타이밍 판단
> 목적: (1) 100k+ star harness 도구들이 넘쳐나는 상황에서 이 harness가 어느 수준까지 follow-up해야 하는지 판단한다(Q4). (2) adopter(`ai-deck-compiler`)가 생기면서 upgrade/migration 경로가 실질 과제로 부상했다. 배포 방식 자체를 바꾸는 것이 이 문제를 해결하는 올바른 경로인지 평가한다.

---

## 결론

**plugin 모델 전환은 타당하지만 지금 시점에 착수할 이유가 약하다. 현재 병목은 배포 방식이 아니라 upgrade/migration 로직 자체다. shell script에서 해당 로직을 먼저 구현하고, adopter가 늘어나는 시점에 npm wrapping을 검토하는 순서가 맞다.**

추가 판단: harness는 구조적으로 "plugin"이 아니라 "파일 템플릿 시스템(scaffolding tool)"이다. 이 구분을 인식하고 설계해야 plugin 모델 도입 시 개념 충돌을 피할 수 있다.

**Q4 판단 (follow-up 수준)**: 100k+ star harness 도구들에서 배울 것은 **개념**이지 구현이 아니다. versioning 관례·upgrade UX 패턴·migration 알림 개념은 채택한다. plugin 생태계·npm 배포·orchestration 런타임 구현은 "인프라 레이어 = 도구의 영역" 원칙에 따라 따르지 않는다. simplicity 원칙은 경쟁에서 이기기 위한 전략이 아니라 **policy layer에 집중하기 위한 경계**다. 이 경계가 유지되는 한 외부 도구들이 아무리 무거워져도 이 harness의 정체성은 침식되지 않는다.

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

## 6. Simplicity 원칙과 외부 harness 벤치마킹 (Q4)

### 무엇을 follow-up하고 무엇을 하지 않는가

100k+ star harness 도구들(예: LangChain, CrewAI, AutoGen, Semantic Kernel)은 공통적으로 다음을 구현한다:
- agent orchestration runtime (task 분배, 병렬 실행, 상태 관리)
- plugin/extension marketplace (설치·업그레이드 생태계)
- npm/pip 패키지 배포 (버전 관리, dependency 관리)
- 대규모 API 통합 레이어

이것들은 **인프라 레이어**다. §2에서 확인했듯 이 harness는 "무엇을 실행하는가"가 아니라 "어떻게 일하는가"를 정의하는 **policy layer**다. 인프라 레이어의 구현을 따라가면 정체성이 흔들리고 유지 비용만 쌓인다.

### 배울 것과 배우지 않을 것

| 외부 트렌드 | follow-up 여부 | 이유 |
|------------|---------------|------|
| semver 기반 versioning 관례 | ✓ 채택 | 개념만 도입. `VERSION` 파일로 이미 착수 |
| upgrade 알림·`--check` UX 개선 | ✓ 채택 | 내용(policy 변경)을 알리는 것이지 바이너리를 교체하는 것이 아님 |
| migration note 패턴 | ✓ 채택 | `docs/migrations/canonical-adapter-rename.md`가 이미 이 방식 |
| npm/pip 패키지 배포 | △ 타이밍 문제 | adopter 증가 시 재검토. 지금은 shell로 충분 |
| plugin/extension marketplace | ✗ 비해당 | scaffolding tool에 plugin 생태계는 개념 충돌 |
| agent orchestration runtime | ✗ 비해당 | 인프라 레이어. 도구(Claude Code, Codex)의 영역 |
| 대규모 API 통합 레이어 | ✗ 비해당 | workflow engine화 위험. harness의 정체성 침식 |

### simplicity 원칙의 실질적 의미

"simple한 것이 best다"는 경쟁 전략이 아니라 **집중의 원칙**이다.

- 복잡도를 낮추는 것 자체가 목표가 아니다. "policy layer가 아닌 것을 구현하지 않겠다"는 경계가 단순함을 만드는 원인이다.
- 외부 도구들이 무거워질수록 이 harness가 제공하는 "가볍고 읽히는 policy document"의 가치는 상대적으로 높아진다.
- follow-up의 기준: "이것이 팀의 work 방식을 더 명확히 정의하는가?" YES → 채택 대상. "이것이 실행 인프라를 더 풍부하게 하는가?" YES → 도구에 맡긴다.

### 차별화 전략

#### 두 범주를 먼저 구분한다

AI agent 생태계의 harness 도구들은 성격이 전혀 다른 두 범주로 나뉜다.

| | 인프라형 오케스트레이션 프레임워크 | 가드레일형 오케스트레이션 하네스 |
|--|----------------------------------|-------------------------------|
| **대표 도구** | LangGraph, CrewAI, OpenAI Swarm | gstack, superpowers, GSD |
| **방식** | Python/JS 코드로 node·edge·state를 하드코딩 | Markdown, 설정 파일, slash command 기반 |
| **목적** | 멀티 에이전트 시스템의 통신 채널·인프라 구축 | 이미 작동하는 AI 도구(Claude Code, Cursor 등)의 폭주 방지 |
| **사용자** | AI 애플리케이션을 만드는 개발자 | AI와 협업하는 팀/개인 |
| **의존성** | runtime 필수 (Node.js / Python + 패키지) | 없거나 최소 (markdown + 설정) |

이 harness는 **가드레일형 범주**에 속한다. LangGraph·CrewAI는 경쟁 대상이 아니라 다른 레이어다. 실질적인 비교 대상은 gstack·superpowers·GSD다.

#### 가드레일형 도구들의 공통 접근과 각자의 강점

| 도구 | 핵심 가드레일 방식 | 강점 |
|------|-----------------|------|
| **gstack** (Garry Tan) | CEO·EM·QA 등 20여 개 가상 페르소나로 역할을 엄격히 격리. 단계별 리뷰 게이트·투표로 의사결정 조율 | 팀 역할 시뮬레이션 기반 governance. AI가 단독으로 판단·실행하지 못하게 봉쇄 |
| **superpowers** (Jesse Vincent) | 작업 시작 시 독립 git worktree 자동 생성. TDD(RED→GREEN) 절차를 강제하고 테스트 통과 전 다음 단계 차단 | 기술적 품질 게이트. AI가 "다 됐습니다" 거짓말을 못 하도록 컴파일·테스트에 결착 |
| **GSD / Swarm** | 컨텍스트 윈도우 30~40% 이하 유지. 전문 에이전트 간 hand-off로 역할 분리 | 환경 가드레일. AI의 컨텍스트 과부하(환각·성능 저하)를 물리적으로 제어 |

최근 실무에서는 이 도구들을 레이어로 쌓는 **멀티 레이어 아키텍처** 패턴이 자리잡고 있다:
`LangGraph(인프라) → Claude Code(실행) → gstack+superpowers(가드레일)`.

#### 이 harness의 차별화 포인트

같은 가드레일형 범주 안에서 이 harness는 다른 방향을 선택한다.

| | gstack / superpowers / GSD | 이 harness |
|--|--------------------------|-----------|
| **가드레일 대상** | 코드 생성·테스트 품질·컨텍스트 관리 — **기술 프로세스** | 승인 권한·결정 기록·작업 상태 — **거버넌스 정책** |
| **적용 범위** | 코드 작업 중심 | 코드·문서·설계·운영 등 모든 work 유형 |
| **도구 의존성** | 특정 AI 도구(Claude Code 등)에 최적화 | Claude Code·Codex·Cursor 동일 policy로 커버 |
| **커스터마이징** | 도구 제작자의 관점이 내재화됨 | scaffold로 생성된 project-specific policy — 팀이 소유 |
| **지식 축적** | 세션 단위 절차 강제 | DR 체계로 결정 근거가 기록에 남음 |
| **복잡도 방향** | 기능 확장 중심 | 정책 명확화 중심. 정책이 명확할수록 단순해짐 |

**이 harness만 채우는 gap:**

세 도구는 모두 "AI가 더 잘 실행하도록" 만드는 데 집중한다. 하지만 다음 질문에는 아무도 답하지 않는다:

> *"이 팀에서 AI가 자율로 결정할 수 있는 것과 사람이 승인해야 하는 것은 무엇인가? 그 기준은 어디에 기록되는가?"*

Approval Matrix, commit gate, Work tracking, DR 체계 — 이것들은 **팀의 거버넌스 정책**이다. 기술 프로세스 게이트(superpowers)나 역할 시뮬레이션(gstack)이 채울 수 없는 영역이다. 팀마다 다르고, 변경될 때마다 명시적으로 결정되어야 하며, AI가 읽고 따를 수 있는 형식으로 존재해야 한다.

**AI 역량이 높아질수록 이 격차는 커진다.** AI가 더 많은 것을 자율로 실행할 수 있게 될수록, "무엇을 자율로 허용할 것인가"를 정의하는 policy layer의 중요성은 오히려 증가한다.

---

## 7. Revisit Triggers

이 판단을 다시 꺼내 재검토할 시점:

- adopter가 2곳 이상으로 늘어나고 discovery 요구가 실측될 때
- `ai-deck-compiler`에서 upgrade/migration 수동 처리 비용이 실질 마찰로 보고될 때
- shell upgrade/migration 로직이 안정화되고 "배포 방식 개선"이 다음 레버가 될 때
- Node.js 의존성 도입을 감수할 만한 다른 이유(테스트 자동화, cross-platform 지원 등)가 생길 때

---

## 연결

- Q4 질문 원문 및 정체성 논의: [`docs/retrospectives/harness-identity-policy-first-20260608.md`](harness-identity-policy-first-20260608.md)
- 선행 과제: `docs/backlog/HARNESS.md` — "Harness upgrade/migration 메커니즘" (P1 Candidate)
  - selective migration 로직, version marker, backup 정책, dry-run/apply 경로
- 관련 문서: `docs/migrations/canonical-adapter-rename.md` — 현재 upgrade가 수동인 상황에서 target maintainer가 참조하는 migration note. upgrade 자동화 시 이 문서의 역할도 재정의 필요
- 관련 DR: DR-021 (source / framework-vs-project-state boundary — framework-owned vs. project-owned 파일 구분의 설계 근거)
