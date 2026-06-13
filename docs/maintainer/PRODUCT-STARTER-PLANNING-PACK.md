# PRODUCT-STARTER-PLANNING-PACK.md (source-only)

source repo 기준의 **product starter planning pack** 설계 기준이다.
대상은 `ai-workflow-harness` source maintainer / AI driver이며, scaffolded target repo에 그대로 배포하지 않는다.

> **이 문서의 역할:**
> 이것은 새 product 착수 전 **무엇을 source에서 template/skeleton으로 먼저 준비하고**, scaffolded project에서 **무엇을 product-local로 concrete화**하며, 그 결과 중 **무엇을 source option-pack 후보로 되가져올지**를 정의하는 기준 문서다.
>
> - 실행 순서(runbook): `docs/maintainer/SOURCE-REPO-OPERATIONS.md`
> - 검증 명령/criteria: `docs/maintainer/VERIFICATION-COMMANDS.md` Layer U
> - 실제 Work/승인/closeout 절차: `skills/workflow/work-plan.md`, `docs/AGENT-WORKFLOW.md`

## 1. 왜 필요한가

W2의 upgrade/migration(CHORE-20260611-010)과 docs cascade(CHORE-20260611-011)가 닫힌 뒤, 다음 실제 product 착수의 핵심 gap은 아래 두 가지다.

1. source repo가 product 시작 전에 어떤 planning template/skeleton을 제공해야 하는가
2. scaffolded project에서 실제 사용 후 일반화 가능한 산출물만 무엇으로 추려 source option-pack 후보로 승격할 수 있는가

이 문서는 그 경계를 명확히 하기 위해 존재한다.

> **정직한 전제:** 아직 검증된 실제 import candidate 사례는 없다. 따라서 여기의 import loop와 review aid는 **첫 실제 product 사용 전 provisional skeleton**이며, 첫 product가 concrete화 단계에 도달한 뒤 반드시 재검토해야 한다.

## 2. 범위와 비범위

### 이 문서가 다루는 것

- source-first planning template/skeleton의 최소 집합
- source-owned / product-owned / import-candidate 경계
- template 분석 include/exclude 기준
- human-in-the-loop 경계
- product repo -> source repo import 후보 검토 형식

### 이 문서가 다루지 않는 것

- README / MANUAL / GUIDE류의 user-facing readability rewrite
- scaffold multi-user clone verification
- `scripts/create-harness.sh` 또는 신규 helper/script 구현
- option-pack 실제 생성 또는 source repo 편입
- product repo의 실제 구현/운영 절차

## 3. 핵심 원칙

1. **source는 template/skeleton을 제안하고, product repo는 실제 내용을 채운다.**
   source repo가 product PRD/TRD의 실질 내용을 대신 작성하지 않는다.
2. **import는 자동이 아니라 승격 심사다.**
   product repo에서 잘 동작했다는 사실만으로 source option-pack으로 자동 편입하지 않는다.
3. **문서와 코드의 경계를 함께 본다.**
   planning pack은 문서만이 아니라 module shape, test shape, infra assumptions까지 본다.
4. **helper/script는 반복 패턴이 확인된 뒤에만 추가한다.**
   W2 첫 slice에서는 criteria와 review aid를 먼저 고정한다.

## 4. 산출물 분류

### A. Source-first seed pack

source repo에서 먼저 **template/skeleton 형태로** 준비하고 scaffolded project에 주입할 수 있는 최소 집합이다.

| 산출물 | source가 먼저 둘 수 있는 것 | product repo에서 확정할 것 | owner |
| --- | --- | --- | --- |
| Product brief / PRD template | 질문 프레임, section skeleton, 필수 검토 항목 | 실제 문제/사용자/요구사항 내용 | source seed |
| TRD / architecture brief template | 구조/제약/선택 이유를 묻는 skeleton | 실제 runtime/module/deploy 결정 | source seed |
| Delivery plan / task map skeleton | tranche/done criteria 기본 틀 | 실제 일정/분해/우선순위 | source seed |
| Test structure seed | unit/integration/e2e 계층 제안 | 실제 테스트 전략과 시나리오 | source seed |
| `loop.md` skeleton | 반복 실행 절차와 human gate 기본 구조 | product 맥락에 맞는 concrete loop | source seed, harness-aware |
| Open questions / assumptions starter | 자주 빠지는 질문 목록과 검증 경로 틀 | 실제 미결정 사항과 실험 계획 | source seed |

### B. Product-local expansion pack

source에서 seed를 줄 수는 있지만, 실제 내용은 scaffolded project에서 concrete화해야 하는 집합이다.

| 산출물 | source에서 줄 수 있는 것 | product repo에서 확정할 것 | owner |
| --- | --- | --- | --- |
| Code conventions | 공통 품질 기준, naming/architecture guardrail | 팀/스택별 예외, formatter/linter 실제 규칙 | product-owned with source seed |
| User flow | 흐름 템플릿, 질문 프레임 | 실제 persona/flow/path | product-owned |
| DB design | logical model skeleton, ownership 질문 | physical schema, migration, indexing | product-owned |
| Screen / screen flow | artifact 종류와 해상도 기준 | 실제 IA, wireframe, state transition | product-owned |
| API contract shape | resource/command/query 분류 기준 | endpoint, payload, auth detail | product-owned |

### C. Import candidate set

product repo에서 검증된 뒤 source option-pack 후보로 되가져올 수 있는 집합이다.

| 후보 | 승격 조건 | source target 예시 |
| --- | --- | --- |
| planning artifact template | product-specific 토큰 제거 후 다른 product에도 재사용 가능 | `docs/maintainer/` 또는 optional pack 문서 |
| code/test structure template | 특정 도메인 의존성 없이 stack pattern으로 일반화 가능 | future stack/profile pack |
| workflow loop template | tool-neutral + domain-neutral 반복 구조로 정리 가능 | optional pack doc 또는 prompt seed |
| import mapping/report format | 두 번째 product에도 동일하게 쓸 수 있음 | `docs/maintainer/VERIFICATION-COMMANDS.md` Layer U 또는 helper candidate |

## 5. 작성 순서

권장 순서는 아래와 같다.

1. Product brief / PRD template
2. TRD / architecture brief template
3. Open questions / assumptions
4. Delivery plan / task map skeleton
5. Test structure
6. `loop.md` skeleton
7. 필요 시 product-local expansion seed(code conventions, user flow, DB design, screen flow)

원칙:

- source는 template/skeleton을 먼저 정의하고, product repo가 실제 내용을 채운다.
- PRD template 없이 screen flow부터 강제하지 않는다.
- architecture brief template 없이 DB design을 source pack 핵심으로 확정하지 않는다.
- source에서 모든 artifact를 완성본으로 만들려 하지 않는다.

## 6. Source -> Product -> Source loop

```text
source planning template/skeleton 정의
  -> scaffolded project 생성
  -> source pack 주입
  -> product-local concrete화
  -> 실행/검증
  -> import candidate 정리
  -> source repo 별도 Work에서 승격 판단
```

### Step 1. source planning template/skeleton 정의

- source repo에서 seed pack(A)을 작성한다.
- product-local expansion(B)은 seed만 둘지, 아예 product repo로 미룰지 결정한다.

### Step 2. scaffolded project 생성

- core scaffold만 먼저 생성한다.
- stack/profile pack은 실제 선택 이유가 있을 때만 추가한다.

### Step 3. source pack 주입

- planning pack 산출물을 product-owned 경로에 주입한다.
- 이 시점에는 source option-pack으로 되돌릴 경로를 확정하지 않는다.

### Step 4. product-local concrete화

- product repo AI/개발자가 실제 요구사항·도메인·화면·데이터 모델을 concrete화한다.
- source에서 준 skeleton이 과하거나 부족한지 이 단계에서 검증한다.

### Step 5. import candidate 정리

- product repo에서 아래 표를 유지해 일반화 가능 항목만 따로 추린다.
- 이 표는 **첫 실제 product 사용 전에는 provisional review aid**다. 첫 concrete 사례가 생기면 유지 항목/열 구성을 다시 검토한다.

| artifact | owner | generalizable? | 왜 일반화 가능한가 | product-specific residue | proposed source target |
| --- | --- | --- | --- | --- | --- |
| (예시) | source/product/shared | Y/N | 다른 product에도 재사용 가능한 이유 | 제거해야 할 도메인 흔적 | maintainer/optional/script candidate |

### Step 6. source repo 별도 Work에서 승격 판단

- import 후보는 source repo의 **별도 Work**에서만 승격 판단한다.
- 이번 product Work에서 source option-pack을 바로 수정하지 않는다.

## 7. Human-in-the-loop 경계

| 단계 | 자동 허용 | 인간 판단 필수 |
| --- | --- | --- |
| scaffold 생성 | `scripts/create-harness.sh` 실행 | 어떤 profile/option을 쓸지 |
| planning artifact skeleton 생성 | 템플릿 복사, 빈 문서 생성 | 내용 채우기, 우선순위 확정 |
| base template 조사 | 파일 목록/grep/구조 나열 | include/exclude 판단, gap 해석 |
| import candidate 수집 | 표 채우기, diff 수집 | generalizable 판정, source target 결정 |
| source 승격 | 없음 | 별도 Work 승인, 경계 검토 |

## 8. Template 분석 기준 (generic)

이 섹션은 특정 template를 planning pack seed 관점에서 읽을 때의 **generic 기준**이다.
특정 repo의 실제 파일/경로 inventory는 이 문서가 아니라 해당 Work의 Discovery 또는 작업 메모에 남긴다.

### include: planning pack seed로 볼 자산

| 영역 | 파일/경로 예시 | 보는 이유 |
| --- | --- | --- |
| 제품/기술 목표 | root README, plan/summary 문서 | 목표, 스택, phase 방향 |
| 구조/흐름 | architecture/developer guide 계열 문서 | 모듈 경계, request/auth flow |
| 코드 규약 | coding conventions / quality guide | code conventions seed |
| 모듈 shape | root build graph, module/service 디렉토리 | module/package/test shape |
| infra/test 예시 | infra, compose, http/e2e test 예시 | local/dev/test baseline |
| open gap evidence | product backlog, open decisions | enterprise gap과 미완료 hardening 확인 |

### exclude: planning pack seed로 직접 쓰지 않을 자산

| 영역 | 파일/경로 예시 | 제외 이유 |
| --- | --- | --- |
| harness/agent 운영 문서 | agent workflow, harness protocol, prompts, tool rules | product planning pack이 아니라 운영 표면 |
| live tracking | status, works, harness backlog | 세션/작업 추적 정보 |
| historical/archive | archive, retrospectives | seed보다 history 성격이 강함 |
| 과거 결정 원문 | decisions 전부 | seed 직접 복사보다 rationale 참고용 |

### reference-only: gap 분석 근거로만 쓰는 자산

| 영역 | 파일/경로 예시 | 사용 방식 |
| --- | --- | --- |
| product backlog | product backlog / roadmap | 아직 비어 있는 보안/배포/운영 gap 확인 |
| troubleshooting | troubleshooting 기록 | 반복 환경 문제 참고 |
| historical snapshots | snapshots / archived plans | 필요할 때만 drift 배경 확인 |

## 9. Template gap을 읽는 법

어떤 template든 바로 option-pack으로 승격하면 안 된다. 아래 신호를 gap evidence로 취급한다.

1. backlog에 아직 P0/P1 candidate가 많은 영역
   - 예: token storage, rate limiting IP, internal service auth, K8s 도구 선택
2. sample implementation이 특정 demo domain에 묶인 영역
   - 예: CRUD sample, demo frontend
3. local/dev 편의가 강하고 production 운영 기준이 아직 선택 단계인 영역
   - 예: docker-compose 중심 구조, observability/k8s backlog 미완료

planning pack은 이 gap을 숨기지 않고, "현재 seed로 줄 수 있는 것"과 "product repo에서 다시 판단해야 하는 것"을 분리해야 한다.

## 10. 승격 금지 신호

아래 중 하나라도 해당하면 source option-pack으로 바로 올리지 않는다.

- product 이름, 도메인 엔티티, 특정 조직 규칙이 남아 있음
- 두 번째 product에서 재사용해보지 않았음
- 수동 설명 없이는 왜 필요한지 이해되지 않음
- source-owned / product-owned 책임이 분리되지 않음
- helper/script를 추가해야만 겨우 유지되는 구조임

## 11. 관련 업데이트 트리거

- Layer U가 executable path check로 승격되면 이 문서의 산출물 표와 동기화한다.
- 두 번째 product 적용에서 반복 패턴이 확인되면 import mapping을 형식 규약 또는 helper 후보로 승격 검토한다.
- 실제 stack/profile option-pack이 생기면 section 4C의 source target 예시를 구체화한다.
