---
date: 2026-06-15
track: harness
type: process
scope: 내부 조직 표준 하네스 운영을 위한 PR 기반 중앙 upgrade 관리 방향성 평가
author: "agent:codex + agent:claude-review-ready"
related_work: []
---

# Harness Internal Managed Upgrade — PR 기반 중앙 관리 방향성

> 작성일: 2026-06-15
> 작성 방식: Codex 초안 작성, Claude가 같은 파일에 별도 review round를 추가할 수 있는 공동 회고 형식
> 범위: 사내 여러 팀/프로젝트에 같은 harness source를 적용할 때, upgrade/migration 책임을 target repo가 아니라 중앙 source maintainer가 맡는 운영 모델 검토
> 목적: 다음 큰 Work의 기준이 될 수 있도록, "외부 scaffold 독립성"과 "내부 중앙 최신화"를 함께 만족하는 방향을 정리한다

---

## 시발점이 된 질문

이 문서는 사용자가 사내 표준 harness 운영을 가정하며 던진 두 갈래 질문에서 시작됐다.

첫 번째 질문은, 중앙 source maintainer가 scaffold된 repo 목록과 git 인증 권한을 알고 있다면 target repo가 직접 upgrade/migration을 책임지는 대신 중앙에서 각 repo를 clone해 framework asset 변경을 반영하고 최신화할 수 있지 않느냐는 것이었다. 예를 들어 `ai-deck-compiler`를 중앙에서 clone하고, source 변경을 적용한 branch/PR로 upgrade해두면 git history에 framework asset 변경 내역도 남고, AI가 중앙 역할로 더 정확하게 관리할 수 있지 않느냐는 문제제기였다.

두 번째 질문은, 아예 source repo를 여러 사람이 권한에 따라 운영하고 그 안에서 여러 project를 개발하는 구조를 만들면 하네스를 각 repo로 전파하는 부담을 줄일 수 있지 않느냐는 것이었다. source repo의 보호 asset은 한 사람이 관리하고, 다른 사람들은 각자의 project 영역만 작업하는 방식이다.

이 회고의 목적은 두 질문을 "어느 쪽이 더 좋아 보이는가" 수준에서 끝내지 않고, 외부 scaffold 독립성·내부 조직 운영 효율·source/product ownership 경계를 함께 만족하는 다음 큰 방향으로 정리하는 것이다.

---

## 결론

현재 가설로는 1번이 더 유망하다. 다만 first walkthrough 전에는 비교 우위가 검증되지 않았다.

이 가설은 조건부다. 기업 내부에서 여러 팀/프로젝트가 같은 하네스를 표준으로 쓰고, 중앙 maintainer가 cross-repo branch/PR 권한을 갖는 것이 조직 보안 정책상 허용되며, target reviewer가 실질적으로 PR을 검토할 수 있어야 한다. 이 조건이 성립하면 upgrade/migration 책임을 각 scaffold target에만 맡기는 방식보다, source repo가 framework-owned drift를 계산해 target repo에 upgrade PR을 제안하는 **internal managed scaffold mode**가 더 유망하다.

다만 이것은 "중앙에서 직접 고쳐 push한다"가 아니다. 기본 원칙은 **PR 기반 중앙 관리**다.

중앙 source maintainer가 target repo를 clone/fetch하고, manifest 또는 shadow scaffold baseline으로 framework-owned 변경을 계산하고, project-owned/customized 파일은 보존하며, target repo에 branch + PR을 만든다. target team은 PR diff, CI, drift report를 보고 merge한다. 이렇게 해야 인증·감사·review·rollback이 git workflow에 남는다.

2번, 즉 source repo 안에서 여러 프로젝트를 함께 개발하는 방식은 기본 전략으로는 부적합하다. 전파 부담은 줄지만 source-owned / scaffold-owned / product-owned 경계가 흐려지고, 팀별 권한·CI·release·history 독립성이 약해진다. 특수한 internal workspace, sample, reference implementation, option-pack 검증에는 쓸 수 있지만, 실제 제품 repo의 기본 운영 모델로 삼으면 되돌리기 비용이 크다.

따라서 현재 결론은 다음과 같다. **1번은 first walkthrough 이후 검증할 기본 가설로 두되 PR 기반 중앙 관리로만 탐색하고, 2번은 기본 전략이 아니라 특수한 내부 workspace 옵션으로 제한한다.** 이 방향은 외부 scaffold의 독립성을 유지하면서, 내부 조직에서는 중앙 최신화의 운영 효율을 얻을 가능성이 있다.

---

## 1. 문제 정의

현재 upgrade/migration 정책은 외부 adopter 또는 느슨하게 연결된 scaffold target에 적합하다.

- target repo는 자기 `.harness/manifest.json` 또는 pre-manifest inventory를 기준으로 drift를 확인한다.
- source maintainer는 migration note와 verification catalog를 제공한다.
- 실제 적용은 target repo maintainer가 selective migration으로 판단한다.

이 방식은 공개/외부 adopter에게 정직하다. 중앙 source가 target repo 권한을 갖지 않는 상황에서는 target 독립성이 우선이다.

하지만 기업 내부 표준 운영에서는 조건이 달라진다.

- 중앙 source maintainer가 target repo 목록을 알 수 있다.
- GitHub App, service account, CI secret 등으로 인증을 표준화할 수 있다.
- 여러 target에 같은 framework update를 반복 적용해야 한다.
- 각 target maintainer가 매번 source migration note를 읽고 판단하는 비용이 중복된다.

이때 upgrade/migration 책임을 target repo에만 남기면 같은 판단이 여러 repo에서 반복되고, framework-owned drift가 오래 쌓인다. 내부 조직에서는 중앙이 더 많은 책임을 가져도 된다. 단, 그 책임은 direct push가 아니라 PR 생성과 evidence 제공이어야 한다.

---

## 2. External Adopter Mode와 Internal Managed Mode

두 mode는 경쟁 관계가 아니라 적용 조건이 다르다.

| 구분 | External Adopter Mode | Internal Managed Mode |
| --- | --- | --- |
| 대상 | 공개 repo 사용자, 독립 adopter, source maintainer가 권한 없는 target | 같은 조직 내 표준 harness target |
| upgrade 책임 | target maintainer가 `--check`와 migration note를 보고 적용 | 중앙 source maintainer가 drift plan + upgrade PR 생성 |
| 권한 모델 | source는 target에 write 권한 없음 | GitHub App/service account/CI secret 등으로 제한 권한 보유 |
| 적용 방식 | manual selective migration | PR 기반 semi-managed migration |
| project-owned 보호 | target maintainer 판단 중심 | 중앙 tool이 보존, target reviewer가 최종 판단 |
| audit | target repo 자체 기록 | target PR + central run log 양쪽 기록 |

핵심은 mode를 섞지 않는 것이다.

External Adopter Mode에서는 source가 target을 관리한다고 말하면 안 된다.
Internal Managed Mode에서는 target에게 모든 migration 판단을 떠넘기면 중앙 표준의 장점이 사라진다.

---

## 3. PR 기반 중앙 관리의 기본 모델

이 섹션은 확정 설계가 아니라 non-binding operating sketch다. 실제 field, command, runner, permission model은 Candidate A walkthrough 이후 Candidate B design note에서 결정한다.

```text
central harness source
  -> target registry 로드
  -> target repo clone/fetch
  -> manifest / shadow scaffold baseline 확인
  -> framework-owned drift plan 생성
  -> project-owned/customized 파일 보존
  -> target branch 생성
  -> 변경 적용
  -> target validation 실행
  -> upgrade PR 생성
  -> target owner review/merge
```

### 중앙이 책임질 수 있는 것

- target registry 관리
- framework-owned file drift 계산
- source version / target baseline / changed files 기록
- target-missing framework 파일 추가
- source-updated framework 파일 반영
- locally-modified / manual-merge candidate 분류
- PR 본문에 evidence 남기기

### target team이 계속 책임져야 하는 것

- project-owned file 변경 승인
- accepted drift 유지 여부 판단
- target CI와 product-specific validation 확인
- merge timing 결정
- product behavior regression 판단

### 중앙이 하면 안 되는 것

- project-owned 파일 자동 overwrite
- target default branch 직접 push
- product backlog, STATUS, Work, DR 내용을 source 기준으로 재작성
- target team 승인 없이 workflow mode 변경
- 모든 repo를 동시에 강제 upgrade

---

## 4. 왜 direct push가 아니라 PR인가

중앙 관리라고 해서 중앙 push가 좋은 것은 아니다.

PR이 필요한 이유:

- **Audit:** 어떤 framework 파일이 왜 바뀌었는지 target repo history에 남는다.
- **Review:** target owner가 project-owned/customized drift를 확인할 수 있다.
- **CI:** target repo의 product-specific check가 같은 경로에서 돈다.
- **Rollback:** 잘못된 update가 merge 전에는 PR close, merge 후에는 revert PR로 처리된다.
- **Permission:** 중앙 권한을 "branch 생성 + PR 생성" 수준으로 제한할 수 있다.

direct push는 빠르지만 운영상 위험하다. 특히 이 하네스의 핵심 철학이 approval gate와 human sign-off라면, 중앙 upgrade도 같은 철학을 따라야 한다.

---

## 5. Target Registry의 최소 형태

이 섹션도 확정 schema가 아니라 Candidate B에서 검토할 thin sketch다. first walkthrough 전에는 registry를 구현하지 않는다.

논의용 예시:

```yaml
targets:
  - repo: org/ai-deck-compiler
    default_branch: develop
    workflow_mode: source-gitflow
    profile: generic
    owner: team-ai-tools
    upgrade_policy: pr-only
    accepted_drift:
      - docs/STATUS.md
      - docs/backlog/PRODUCT.md
```

후보 필드:

| 필드 | 의미 |
| --- | --- |
| `repo` | target repository locator |
| `default_branch` | PR base branch |
| `workflow_mode` | scaffold generation/check 기준 |
| `profile` | scaffold profile/options |
| `owner` | PR reviewer 또는 routing hint |
| `upgrade_policy` | pr-only, report-only, hold 등 |
| `accepted_drift` | 중앙이 덮지 않을 target-local drift |

Candidate B open questions:

- registry는 source-only maintainer surface로 둘 것인가, 별도 tool config로 둘 것인가?
- registry write 권한은 누가 갖는가?
- `accepted_drift` 변조가 보안성 overwrite를 억제하지 않도록 어떤 guard를 둘 것인가?
- credential은 registry에 쓰지 않는다는 원칙을 어떤 runner/CI secret 모델로 보장할 것인가?

---

## 6. Existing Upgrade/Migration Policy와의 관계

Internal Managed Mode는 기존 DR-034 계열 정책을 버리지 않는다. 오히려 그것을 중앙에서 반복 가능하게 실행하는 layer다.

기존 원칙은 그대로 유지한다.

- pre-manifest target은 inventory-first로 다룬다.
- shadow scaffold baseline은 manifest 획득 수단이 될 수 있다.
- framework-owned 파일은 manifest path 기준으로 selective migration한다.
- project-owned/customized 파일은 자동 overwrite하지 않는다.
- 첫 `--check`는 drift 0을 강요하지 않고 drift 분포를 관측한다.

달라지는 점은 책임 위치다.

External mode에서는 target maintainer가 위 절차를 직접 수행한다.
Internal managed mode에서는 중앙 source maintainer가 위 절차를 실행해 PR로 제안한다.

---

## 7. 운영·보안 리스크

Internal Managed Mode는 운영 효율을 줄 수 있지만, 중앙 권한을 만드는 순간 새로운 위험도 생긴다. 아래 항목은 이 회고에서 해결하지 않고 Candidate B design note의 open question으로 넘긴다.

| 리스크 | 왜 중요한가 | Candidate B에서 결정할 것 |
| --- | --- | --- |
| 중앙 credential / runner가 high-value target이 됨 | 손상되면 여러 target repo에 악성 PR이 fan-out될 수 있다 | GitHub App least-privilege scope, branch permission, secret rotation |
| review fatigue | framework PR이 잦아지면 target reviewer가 rubber-stamp merge를 할 수 있고, PR safety가 사실상 direct push처럼 약해질 수 있다 | required reviewer, review checklist, batch cadence, review-quality 보증 |
| registry가 privileged config가 됨 | `accepted_drift`나 `upgrade_policy` 변조로 필요한 overwrite가 억제되거나 위험 변경이 허용될 수 있다 | registry write-control, review requirement, tamper detection |
| private target clone data boundary | 중앙 runner가 여러 private repo를 clone하면 team 간 source 노출과 저장 위치 문제가 생긴다 | ephemeral clone, workspace isolation, log redaction, retention policy |
| coordinated rollback | 잘못된 framework 변경이 여러 repo에 merge된 뒤에는 단일 revert로 끝나지 않는다 | fleet rollback runbook, affected target inventory, staged rollout |

이 리스크가 해결되지 않으면 PR 기반이라는 사실만으로 안전하다고 말할 수 없다. PR은 target review와 CI가 실질적으로 작동할 때만 안전장치가 된다.

---

## 8. Source Repo 안에 여러 프로젝트를 두는 대안

사용자 아이디어 2번은 전파 비용을 줄이는 매력이 있다.

가능한 형태:

```text
ai-workflow-harness/
  framework-owned assets
  projects/
    ai-deck-compiler/
    product-b/
    product-c/
```

장점:

- framework update 전파가 단순하다.
- 중앙 source maintainer가 보호 asset을 한 곳에서 관리한다.
- 초기 실험, sample, option-pack 검증에는 편하다.

하지만 기본 전략으로는 위험하다.

- option 1(PR 기반 중앙 관리)이 제대로 작동하면 framework update 전파 부담은 이미 상당 부분 해결된다. 그러면 source repo 내부 multi-project workspace의 주된 동기는 약해진다.
- source repo와 product repo 경계가 흐려진다.
- 팀별 권한 분리가 어렵다.
- product CI와 release cadence가 source framework lifecycle에 묶인다.
- git history와 issue/PR 흐름이 product별로 독립되지 않는다.
- scaffold target의 독립성을 검증하기 어렵다.
- 하네스가 product workspace가 되면서 policy-first 정체성이 약해진다.

따라서 이 방식은 다음에만 제한한다.

- internal reference workspace
- sample product
- option-pack / template-pack 검증
- training sandbox
- product starter planning pack 실험

실제 제품 운영의 기본 모델은 독립 target repo + 중앙 PR 관리가 더 낫다.

---

## 9. Plugin/npm 전환 논의와의 관계

2026-06-08 회고의 판단은 여전히 유효하다.

plugin/npm 전환은 배포·discovery·versioning UX를 개선할 수 있지만, upgrade/migration 로직 자체를 해결하지 않는다. Internal Managed Mode도 마찬가지다. 핵심은 packaging이 아니라 다음 로직이다.

- target baseline을 어떻게 알 것인가
- framework-owned와 project-owned를 어떻게 구분할 것인가
- locally-modified를 어떻게 보존할 것인가
- 어떤 변경을 자동 반영하고 어떤 변경을 manual-merge candidate로 남길 것인가
- target evidence를 어디에 남길 것인가

따라서 순서는 다음이 맞다.

```text
1. 실제 target walkthrough 1건
2. DR-034 acceptance / 보정 판단
3. Internal Managed Mode 최소 설계
4. PR 기반 upgrade prototype
5. adopter 수요 증가 시 packaging/npm/GitHub App UX 검토
```

plugin/npm은 여전히 후순위다. internal managed upgrade는 packaging보다 먼저 검토할 가치가 있지만, 그것도 first walkthrough 이후가 맞다.

---

## 10. Policy-First 정체성과의 관계

이 방향은 policy-first 정체성과 충돌하지 않는다.

중앙 managed upgrade는 orchestration runtime이 아니다. AI agent를 어떻게 spawn할지, 병렬 실행을 어떻게 할지, multi-agent queue를 어떻게 만들지는 다루지 않는다.

다루는 것은 policy다.

- 누가 framework-owned asset을 바꿀 수 있는가
- target repo가 어떤 drift를 받아들일지 누가 승인하는가
- 중앙이 어디까지 자동화할 수 있는가
- 어떤 변경은 target owner review를 반드시 거쳐야 하는가
- upgrade evidence는 어디에 남기는가

즉 internal managed upgrade는 "실행 인프라"가 아니라 "조직 내 harness ownership policy"다. 이 점이 유지되면 하네스는 workflow engine으로 흐르지 않는다.

다만 executable runner는 policy 자체가 아니다. harness가 소유해야 하는 것은 ownership policy, approval boundary, evidence format, target review rule이다. clone/fetch/branch/PR 생성을 수행하는 runner는 별도 tool surface이며, source repo 내부 maintainer script로 둘지 외부 도구로 둘지는 Candidate B/C에서 결정해야 한다.

---

## 11. 다음 Work 후보

이 회고를 Work로 전환한다면, 근시일 committed Work는 Candidate A 하나로 제한한다. Candidate B/C는 Candidate A에서 반복 비용과 중앙 관리 필요가 관측될 때만 조건부로 연다.

### Candidate A — `ai-deck-compiler` actual upgrade walkthrough

목표:

- 현재 source 기준으로 실제 target drift를 측정한다.
- target-local customization을 분류한다.
- upgrade branch/PR equivalent를 만든다.
- DR-034를 Accepted로 승격할지 판단한다.

성공 기준:

- 실제 target에서 framework-owned drift 분포가 기록된다.
- manual-merge candidate와 accepted drift가 분리된다.
- target validation 결과가 남는다.
- "중앙 PR 관리가 필요한 반복 비용"이 실제로 관측된다.

### Candidate B — Internal Managed Mode design note

Deferred / conditional. Candidate A 이후, 실제 target walkthrough에서 중앙 managed mode 필요가 확인될 때 착수한다.

목표:

- target registry minimum schema
- credential boundary
- PR body evidence format
- report-only / pr-only / hold policy
- target owner review policy
- external adopter mode와의 문서 경계

### Candidate C — Prototype runner

Deferred / conditional. Candidate B에서 policy와 보안 경계가 정리된 뒤 착수한다.

목표:

- target 1개에 대해 report-only drift plan 생성
- dry-run PR body 생성
- write mode는 별도 승인 전까지 보류

---

## 12. Claude Review Round

> 이 섹션은 Claude R0 review round다. 목적은 Codex 방향성에 동의 표시가 아니라
> priority inversion·scope creep·policy/runtime 혼선·증거 없는 과장을 잡는 것이다.
> 주의: 이 초안의 방향은 같은 세션 대화에서 Claude가 먼저 제시한 권고(PR 기반·walkthrough gate·option 2 강등)와
> 강하게 일치한다. 동의 편향을 차단하기 위해 "내가 실제로 endorse하는 선을 어디서 넘는가"를 기준으로 검토했다.
> 판정 기준: High finding이 하나라도 미해소면 다음 큰 Work 기준으로 쓰지 않는다.

### Review Questions

| 질문 | Claude 검토 |
| --- | --- |
| 1번(PR 기반 중앙 관리)을 기본 방향으로 보는 판단이 타당한가? | **조건부 타당.** 방향 가설로는 합리적이나 결론 강도("훨씬 좋다 / 더 정확하고 운영 친화적")가 evidence를 앞선다. 현재 실제 internal target은 0이고 enterprise 전제(여러 팀이 표준 사용 + 중앙이 cross-repo write 권한 보유가 적절) 자체가 가정이다. 또한 PR-safety는 target review가 실질적일 때만 성립한다(R0-2, R0-3). |
| 2번(source repo 내부 multi-project workspace)을 특수 옵션으로 낮춘 판단이 충분히 근거 있는가? | **근거 충분 — 대체로 동의.** source/scaffold/product 경계(DR-021), 팀별 권한·CI·release·history 독립성 논거는 구조적이라 별도 evidence 불필요. 결정적 rebuttal은 "option 1이 전파 부담도 이미 해결한다"인데 §7이 이를 약하게만 함축(R0-5). |
| first walkthrough를 internal managed mode 설계의 gate로 둔 순서가 맞는가? | **원칙상 맞으나 문서가 자기 gate를 위반.** §8/§10의 A→B→C 순서는 옳다. 그러나 §3 PR 모델 flow·§5 registry YAML schema/최소 필드/credential 경계는 walkthrough 이전에 이미 수행된 설계다(R0-1). |
| 이 문서가 plugin/npm 전환 논의와 policy-first 정체성을 왜곡하지 않는가? | **plugin/npm 후순위 판단은 2026-06-08 retro와 정합.** 단 §9의 "policy이지 runtime 아님" 주장이 §10 Candidate C prototype runner(=clone/fetch/write/PR 생성 = mechanism)를 설명하지 못한다. policy(harness 소유)와 runner(tool 소유) 경계를 명시해야 정체성 retro와 충돌하지 않는다(R0-4). |
| target registry / credential / PR flow 제안에 빠진 운영 리스크가 있는가? | **다수 누락.** 중앙 credential blast-radius(손상 시 N개 repo에 악성 PR fan-out), review-fatigue로 인한 rubber-stamp merge(PR safety 모델 무력화), registry 자체가 특권 surface(`accepted_drift` 변조로 보안성 overwrite 억제), private repo clone의 data/team 경계, fleet 규모 coordinated rollback — 전부 미기재(R0-2). |

### Claude Findings

| ID | Severity | Finding | Required Change | Status |
| --- | --- | --- | --- | --- |
| R0-1 | High | **자기 gate를 위반한 선행 설계 (scope creep).** §8/§10은 "Internal Managed Mode 설계는 walkthrough(Candidate A) 이후"라고 gate를 두는데, §3(PR 모델 flow·중앙/타깃 책임 분해)과 §5(registry YAML 예시·최소 필드 표·credential 경계)는 이미 구체 설계다. 0-adopter 단계에서 fleet control-plane 세부를 설계하는 것은 sibling v1.2 retro가 경고한 "진공 최적화"의 재발이며, 같은 세션 대화에서 Claude가 권고한 "지금은 backlog placeholder 수준"보다 무겁다. | §3/§5를 "non-binding illustrative sketch — 확정 설계는 Candidate B에서"로 명시 강등하거나 thin sketch로 축약. 근시일 committed Work는 Candidate A(walkthrough) 하나로 한정하고 B/C는 명시적으로 deferred/conditional 처리. | Addressed (R1) |
| R0-2 | High | **운영·보안 리스크 면이 거의 비어 있음.** §4/§5는 PR의 이점과 "credential을 registry에 안 둔다"만 다루고 adversarial/failure 측면을 누락: (1) 중앙 credential·runner가 single high-value target → 손상 시 전 target 악성 PR fan-out(supply-chain); (2) 잦은 framework PR → review fatigue → rubber-stamp merge로 PR safety 형해화(사실상 direct push); (3) registry(`accepted_drift`/`upgrade_policy`)가 privileged config — 누가 수정 권한을 갖고 변조 시 어떤 보안 overwrite가 억제되는가 미정의; (4) private target clone의 저장 위치·ephemerality·team 간 소스 누출; (5) 잘못된 framework 변경이 N개 repo에 merge된 뒤의 coordinated rollback. | 신규 "운영·보안 리스크" 섹션 추가. 각 항목을 Candidate B design note의 open question으로 라우팅(GitHub App least-privilege scope, registry write-control, ephemeral clone, review-quality 보증 또는 required reviewer, fleet rollback runbook). | Addressed (R1) |
| R0-3 | Med | **결론 강도가 evidence를 앞섬.** §결론 "방향은 1번이 훨씬 좋아 보인다 / 더 정확하고 운영 친화적이다"는 실제 internal target 0·walkthrough 0인 상태에서 비교 우위를 기정사실화한다. 구현은 gate했지만 verdict는 선확정한 불일치. | "1번이 더 유망한 가설이나 first walkthrough 전에는 비교 우위 미검증"으로 완화하고, enterprise 전제(팀 수, 중앙 cross-repo write 권한의 적절성·허용 여부)를 명시적 조건으로 단다. | Addressed (R1) |
| R0-4 | Med | **policy/runtime 경계 혼선.** §9는 전체를 "policy이지 orchestration runtime이 아니다"로 분류하나, §10 Candidate C runner는 clone·fetch·branch write·PR 생성을 수행하는 mechanism이다. policy-first 정체성 retro(policy=harness 역할, mechanism=tool 역할)에 따르면 runner는 harness source가 아니라 별도 tool surface에 속할 수 있다. | §9에서 "ownership policy(harness 소유)"와 "executable runner(별도 tool surface 소유, harness는 정책만 규정)"를 분리 명시. runner가 어디 살고 누가 유지보수하는지(harness 내부 vs 외부 도구) 경계를 §9 또는 Candidate C에 적시. | Addressed (R1) |
| R0-5 | Low | option 2 rebuttal이 정밀하지 않음. 2번을 강등하는 가장 강한 근거는 "option 1(중앙 PR)이 전파 부담을 이미 해결하므로 monorepo가 불필요"라는 점인데 §7은 위험만 나열하고 이 대체 논거를 전면에 두지 않는다. | §7에 "option 1이 전파 부담을 해결하므로 option 2의 주된 동기가 소거된다"를 명시. | Addressed (R1) |
| R0-6 | Low | §결론 line의 register 불일치 — 문서 전반은 평서체(~한다)인데 결론 일부가 "제 결론은 …입니다 / 얻을 수 있어요"로 대화체·1인칭으로 흘러 DR-007 일관성/문서 톤을 깬다. | 결론을 문서 평서체로 정규화(대화체·"제 결론은" 제거). | Addressed (R1) |

### Claude Summary

**R0 판정: Changes Requested.** High 2건(R0-1 자기 gate 위반 선행 설계 · R0-2 보안·운영 리스크 누락) 미해소 상태로는 다음 큰 Work의 기준 문서로 쓰지 않는다.

**방향 자체는 건전하다** — PR 기반(직접 push 아님), walkthrough를 설계 선행 gate로, option 2를 특수 옵션으로 강등하는 골격은 합리적이고 prior reasoning과도 정합한다. 이 정합이 위험 신호라 더 깐깐하게 봤고, 결과는 "방향은 맞되 세 군데서 내가 실제 endorse하는 선을 넘는다"다.

① **문서가 스스로 미루라고 한 설계를 이미 한다** — §3/§5의 registry schema·PR 모델은 walkthrough 이후로 gate된 Candidate B의 내용인데 본문에서 선행 수행됐다. 0-adopter 단계의 control-plane 설계는 sibling retro가 경고한 진공 최적화이고, 내가 대화에서 권한 "지금은 backlog 제목 수준"보다 과하다. ② **적대·실패 면이 비어 있다** — 중앙 credential blast-radius, review-fatigue로 인한 PR safety 형해화, registry-as-privilege, clone data 경계, fleet rollback이 통째로 빠졌다. PR 기반의 안전성은 target review가 실질적일 때만 성립하는데 그 가정이 검토되지 않았다. ③ **결론이 미검증 비교우위를 선확정**하고, **§9가 runner(mechanism)를 policy로 뭉갠다.**

권고: §3/§5를 non-binding sketch로 강등 + 운영·보안 리스크 섹션 신설(→ Candidate B open question) + 결론 완화 + policy/runner 소유 경계 명시. 이렇게 하면 **근시일 committed Work는 Candidate A(`ai-deck-compiler` walkthrough) 단 하나**로 깨끗해지고, B/C는 그 관측 결과에 조건부로 남는다 — 그게 이 문서가 "action-guiding하되 surgical"해지는 길이다.

| R0 verdict | High 미해소 | 권고 |
| --- | --- | --- |
| Changes Requested | R0-1 / R0-2 | 위 2건 반영 후 R1 재검토. R0-3~R0-6은 같은 패스에서 함께 처리 권장 |

### Codex R0 Response

| Finding | 반영 내용 | 위치 |
| --- | --- | --- |
| R0-1 | §3/§5를 non-binding sketch로 명시 강등했고, 근시일 committed Work를 Candidate A 하나로 제한했다. Candidate B/C는 deferred/conditional로 표기했다. | §3, §5, §11 |
| R0-2 | 운영·보안 리스크 섹션을 신설하고 credential blast-radius, review fatigue, registry privilege, private clone boundary, fleet rollback을 Candidate B open question으로 라우팅했다. | §7 |
| R0-3 | 결론의 "훨씬 좋다"와 대화체를 제거하고, 1번을 first walkthrough 전에는 비교 우위 미검증인 유망 가설로 낮췄다. | §결론 |
| R0-4 | ownership policy는 harness가 소유하되 executable runner는 별도 tool surface로 분리해야 한다고 명시했다. | §10 |
| R0-5 | 중앙 PR 관리가 전파 부담을 해결하면 source repo 내부 multi-project 방식의 주된 동기가 약해진다고 명시했다. | §8 |
| R0-6 | 결론의 1인칭·대화체 문장을 문서 평서체로 정규화했다. | §결론 |

### Claude R1 Re-Review

> R0 Changes Requested에 대한 Codex 대응을 재검토했다. §12 Claude 기록(Review Questions / Findings / Summary)은 변조되지 않았고, Codex는 본문만 개정 후 `Codex R0 Response` audit trail만 추가했다(reviewer 기록 무결성 ✓). README 인덱스도 본문 톤에 맞춰 등재됨. 신규 markdown 결함 없음.

| Finding | R1 Status | 판단 근거 |
| --- | --- | --- |
| R0-1 | Addressed | §3·§5 모두 "non-binding sketch — 확정 설계는 Candidate B" 명시 강등 + §5에 "first walkthrough 전 registry 미구현" + Candidate B open questions로 전환. §11 committed Work를 Candidate A 하나로 한정, B/C는 Deferred/conditional. (trim 대신 relabel 경로 선택 — finding이 허용한 두 옵션 중 하나로 수용) |
| R0-2 | Addressed | §7 운영·보안 리스크 신설(3열 표), 5개 리스크 전부 + 각 Candidate B 결정사항 라우팅. "PR은 review·CI가 실질 작동할 때만 안전장치"까지 명시 |
| R0-3 | Addressed | 결론을 "더 유망한 가설 / walkthrough 전 미검증"으로 완화 + enterprise 3조건(팀 표준 사용·중앙 cross-repo 권한 허용·실질 review) 명시 |
| R0-4 | Addressed | §10에 "ownership policy=harness 소유 / executable runner=별도 tool surface" 분리, runner 위치는 Candidate B/C로 이연 |
| R0-5 | Addressed | §8 첫 항목으로 "option 1이 전파 부담 해결 → option 2 주된 동기 약화" 전면 배치 |
| R0-6 | Addressed | 결론 평서체 정규화, 대화체·1인칭 제거 |

**R1 verdict: Approved.** High 2건(R0-1/R0-2) 포함 6건 전부 Addressed. R1에서 직접 수정한 항목 없음(sibling 회고와 달리 신규 결함 유입 없음). over-correction 없이 방향 정합 유지 — 이 문서는 이제 다음 큰 Work의 기준으로 쓸 수 있는 상태다(근시일 committed Work = Candidate A `ai-deck-compiler` walkthrough 단일, B/C는 조건부).

잔여 노트: §3/§5는 trim이 아닌 relabel로 해소됐다. 상세 sketch가 향후 Candidate B 설계를 일부 anchor할 mild residual은 있으나, "확정 아님 + 미구현 + open question화"로 진공-최적화 리스크는 실질 해소로 본다.

---

## 13. Revisit Triggers

이 판단은 다음 조건에서 다시 열어본다.

- `ai-deck-compiler` actual upgrade walkthrough가 끝났을 때
- 두 번째 internal target repo가 생겼을 때
- target maintainer가 중앙 PR 방식보다 self-service 방식을 선호한다는 signal이 있을 때
- accepted drift가 많아져 중앙 PR이 계속 conflict를 만들 때
- GitHub App / service account 권한 모델이 조직 보안 정책과 충돌할 때
- source repo 내부 workspace 방식이 실제로 더 나은 특수 사례가 확인될 때

---

## 14. 연결

관련 회고:

- `docs/retrospectives/harness-distribution-plugin-model-20260608.md`
- `docs/retrospectives/harness-identity-policy-first-20260608.md`
- `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`

관련 decision / policy:

- `docs/decisions/DR-021-source-target-boundary.md`
- `docs/decisions/DR-034-harness-upgrade-ownership-policy.md`

관련 후보:

- `ai-deck-compiler` actual upgrade walkthrough + DR-034 acceptance judgment
- Internal managed fleet upgrade mode
- Happy path / onboarding compression
