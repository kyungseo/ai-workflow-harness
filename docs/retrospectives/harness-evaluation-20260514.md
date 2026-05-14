# AI Workflow Harness 자체 평가 — 2026-05-14

> 평가 기준일: 2026-05-14
> 평가 대상: Phase1 이후 하네스 리팩토링 결과
> 평가 관점: 냉정하고 정직한 자체 평가

---

## 결론

냉정하게 말하면, **“코드 실행 자동화까지 포함한 하네스 엔진”으로 리팩토링됐다고 보기는 아직 이르다.**
하지만 단순 문서 현행화 수준도 아니다.
현재 결과는 **Phase1의 문서/명령 묶음을 경량 상태 머신 기반 운영 체계로 재구성한 Manual-first Harness v1** 정도로 보는 것이 정확하다.

## 리팩토링 vs 현행화

이번 작업에서 실제로 바뀐 핵심은 “문서 내용 업데이트”보다 **운영 모델의 분리와 기준점 재정의**다.

크게 개선된 점은 있다.

- `STATUS.md`를 live board로 축소하고, Phase1 잔재를 archive/backup으로 격리했다.
- product backlog와 harness backlog를 분리했다: `PHASE2.md` vs `HARNESS.md`.
- `HARNESS-PROTOCOL.md`와 `docs/harness-protocol/`를 만들어 Agent 실행 규칙의 기준점을 분리했다.
- `docs/CLAUDE.md`를 자동 로드용 slim contract로 줄였다. 이는 Claude Code에서는 체감이 크다.
- `/start`, `/pick`, `/work`, `/resume`, `/done`, `/health`가 상태 머신과 backlog routing을 따르도록 정렬됐다.
- Cursor rules와 prompts도 동일한 방향으로 맞췄다.
- “어디에 기록할지” 혼선이 줄었다: STATUS / backlog / TODO / DR / archive / protocol 역할이 더 분명해졌다.
- 실패, 복구, validation, trigger/cascade를 명시한 점은 Phase1보다 확실히 구조적이다.

따라서 **문서만 예쁘게 정리한 작업은 아니고**, “AI가 작업을 시작하고, 고르고, 계획하고, 검증하고, 상태를 남기는 방식”을 재정렬한 작업이다.

## 아직 부족한 점

다만 아직 manual-first다. 즉, 규칙은 좋아졌지만 강제력은 약하다.

부족한 부분은 분명하다.

- `STATUS.md` 갱신 강제 없음
- `VALIDATE 없이 완료 보고 금지` 같은 hard gate 자동화 없음
- `/done` 누락 방지 Stop hook 미구현
- orphan 문서, 중복 문서, stale reference 자동 탐지 미구현
- `.harness/config.json` 같은 SSOT config 미도입
- command/rule/protocol 간 drift를 CI에서 막지 못함
- TODO naming이나 backlog routing도 아직 사람/Agent가 지켜야 하는 규칙 수준
- Phase1 legacy TODO들이 live docs에 일부 남아 있어 완전한 정보 구조 정리는 아직 아님

따라서 “엔진”이라기보다는 **운영 프로토콜 + 도구별 instruction + 문서 상태 시스템**이다.

## Claude Code 사용자 기준 위치

Claude Code를 적극 쓰는 사용자 분포를 기준으로 나누면 대략 다음과 같다.

- 하위 40%: `CLAUDE.md`만 있거나, README/메모 수준. 상태 관리 없음.
- 중간 40%: `CLAUDE.md`, task prompt, 간단한 backlog/plan 문서 있음. 하지만 세션 복구와 문서 lifecycle은 느슨함.
- 상위 15%: slash command, rules, STATUS, DR, backlog, prompt library를 갖추고 있음.
- 상위 5%: hook/CI/검증 스크립트로 상태 갱신, 테스트, 문서 drift를 강제함.

현재 프로젝트는 **상위 15% 안쪽**, 더 엄격히 말하면 **상위 10~15% 사이**로 보인다.
하지만 **상위 5%의 production-grade harness**는 아니다. 그쪽은 자동 검사와 강제 gate가 붙어 있다.

## 현재 구조의 가장 큰 차별점

가장 좋은 점은 “많은 문서”가 아니라 **문서의 역할이 분리되기 시작했다는 것**이다.

- `docs/CLAUDE.md`: 자동 로드 최소 규칙
- `HARNESS-PROTOCOL.md`: 운영 프로토콜 허브
- `harness-protocol/`: 상세 규칙
- `STATUS.md`: 현재 상태
- `PHASE2.md`: product backlog
- `HARNESS.md`: harness backlog
- `WORKFLOW-MANUAL.md`: 사람용 매뉴얼
- `README.md`: GitHub 진입점

이 분리는 좋은 방향이다. Phase1보다 훨씬 덜 뭉개져 있다.

## 총평

현재 결과는 **“문서 현행화”보다 한 단계 위**, **“자동화된 workflow engine”보다 한 단계 아래**다.

이름을 붙이면:

> Lightweight Manual-first AI Workflow Harness v1

실전에서 꽤 쓸 만하고, Claude/Cursor/Codex를 오가며 상태를 유지하는 데 유의미하게 도움 된다.
다음 품질 도약은 문서를 더 늘리는 게 아니라, **HRN-001/002처럼 최소 hook과 validation script로 깨지는 지점을 자동 감지하는 것**이다.

## 다음 평가 포인트

- HRN-001/002를 통해 최소 강제 장치가 추가되는가?
- `STATUS.md`가 실제 작업 압박 속에서도 stale 상태가 되지 않는가?
- `/done`, validation, document cascade가 실제 세션 종료 때 반복적으로 지켜지는가?
- prompts와 commands 역할 경계가 더 명확해지는가?
- Phase1 legacy TODO가 archive 또는 새 naming 체계로 정리되는가?

## Protocol Routing Guarantees

현재 하네스의 중요한 현실 인식은 다음과 같다.

사용자가 매번 "이 문서를 읽어라", "저 규칙을 참조하라"고 지정하지 않아도 되도록 설계하는 것이 목표다.
하지만 현재 구조가 모든 상황에서 자동으로 필요한 문서를 강제 로드하는 workflow engine은 아니다.

현재 보장 수준은 다음에 가깝다.

> manual-first protocol + routing table + command scaffold

즉, Agent가 읽어야 할 조건과 경로는 문서와 command에 명시되어 있지만, 그 판단과 준수는 아직 주로 Agent의 실행 규율에 의존한다.

### 현재 routing 근거

- Claude Code는 루트 `CLAUDE.md`와 `docs/CLAUDE.md`를 자동 로드한다.
- 세션 시작 시 `docs/STATUS.md`의 현재 섹션에서 출발하도록 되어 있다.
- `/pick`, `/work`, `/resume`, `/done` command가 product/harness backlog, L3 gate, STATUS update proposal, validation 흐름을 유도한다.
- `.claude/rules/*.md`가 파일 유형별 추가 규칙을 제공한다.
- `docs/HARNESS-PROTOCOL.md`는 protocol hub이고, 상세 판단의 canonical source는 `docs/harness-protocol/*.md`다.

### 사용자 기대치

사용자는 원칙적으로 작업 목표만 말하면 된다.

예:

- "다음 작업 골라줘" → Agent가 `STATUS.md`와 적절한 backlog를 선택해야 한다.
- "HRN-002 진행하자" → Agent가 harness backlog와 관련 protocol 문서를 확인해야 한다.
- "P2-006 하자" → Agent가 product backlog, 관련 DR, 필요 시 PLAN/테스트 규칙을 확인해야 한다.
- "문서 구조를 바꾸자" → Agent가 docs workflow rule, DR-007/DR-008, lifecycle/cascade 문서를 확인해야 한다.

따라서 사용자가 매번 `02-context-loading.md`, `05-triggers-and-cascade.md` 같은 상세 문서를 직접 지정할 필요는 없는 구조가 목표다.

### 한계

현재 보장은 hard enforcement가 아니다.

- Claude Code는 command/rule 구조 덕분에 비교적 잘 유도된다.
- Cursor는 `.cursor/rules`와 prompt에 의존하므로 Claude보다 자동성이 약하다.
- Codex는 `AGENTS.md` 도입 전까지 `prompts/codex-session-start.md` 같은 bootstrap prompt 의존도가 높다.
- "필요한 조건이 생기면 읽는다"는 규칙은 조건 판단 주체와 확인 방법이 더 명확해야 한다.

### 다음 개선 방향

- `docs/CLAUDE.md`에 작업 유형별 routing decision table을 더 선명하게 추가한다.
- `/work`, `/debug` 등 주요 command가 "왜 이 문서를 읽는지"를 먼저 보고하도록 보강한다.
- HRN-002에서 command/rule/protocol 변경 시 필요한 문서 확인 누락을 탐지하는 validation 후보를 검토한다.
- HRN-008에서 Codex용 `AGENTS.md`를 검토해 Codex의 자동 instruction discovery를 보강한다.

핵심 결론:

> 사용자가 매번 참조 문서를 지정하지 않아도 되는 구조를 지향한다.
> 다만 현재는 자동 강제 엔진이 아니라, Agent가 따라야 할 routing 조건을 명시한 manual-first harness다.

*저장일: 2026-05-14*
