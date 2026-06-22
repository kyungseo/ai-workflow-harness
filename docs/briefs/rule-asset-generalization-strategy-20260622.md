---
date: 2026-06-22
track: harness
type: strategy
scope: stack/safety rule 자산(java-spring/testing/infra/safety-critical)의 일반화 + 멀티에이전트 option-pack 재설계 전략
author: "agent:claude-opus-4-8 | human"
related_work: []
---

# Rule 자산 일반화 + 멀티에이전트 Option-Pack 전략

## 결론

현재 stack/safety rule 자산은 **두 개의 서로 다른 축이 한 폴더에 섞여 있다.** 이를 분리해 각각 다른 방향으로 처리하는 것을 권고한다.

- **공통 기반:** `skills/workflow/`에서 확립한 **canonical SSoT + thin adapter 원칙을 재사용**한다. 단 workflow는 호출형 procedure이고 rule은 상시/path-scoped 적용이므로, **원칙만 재사용하고 저장 위치·적용 메커니즘은 별도로 설계한다**(§3). canonical 위치는 `skills/{domain}/*.md`를 기본값으로 두되, 이는 Codex skill(`.agents/skills/`)이 아니라 **canonical rule document**임을 명시한다(대안 namespace는 미해결 결정).
- **축 A — stack-agnostic 안전 레이어 (`infra` + `safety-critical`):** 이미 보편적이므로 **source-first**로 통합·정규화하고 **4개 툴 모두에 적용**한다. 현재 Claude(`infra.md`, path-scoped)와 Cursor(`safety-critical.mdc`, always)에 **다른 메커니즘·다른 범위로 갈라져 있고 Codex/Antigravity엔 아예 없는** 비대칭이 핵심 결함이다. 축 A는 다시 **A1(destructive/privileged/secret, always)** 과 **A2(infra/deploy/environment, path-scoped)** 로 나뉜다(§1). (Codex/AG는 always-rule surface가 없어 `AGENTS.md` entry contract가 로드하는 shared safety doc 경로가 필요 — §3 참조.)
- **축 B — stack-specific 컨벤션 팩 (`java-spring` + `testing`):** 실제 product에서 검증돼야 하므로 **product-first**로 `spring-modular-template`에서 정제한 뒤 source로 **import**한다. 네이밍을 pack 체계로 재설계하고(`testing`→`spring-testing` 등), canonical convention doc + 툴별 adapter의 멀티에이전트 구조로 만든다.

즉 **"삭제 후 재import"가 아니라, 축 A는 지금 끌어올리고(승격), 축 B만 product 검증 경로로 내보낸다(위임).** 단순 5파일 삭제는 축 A의 안전 자산까지 같이 버리는 실수가 된다.

이 문서는 방향 비교이며 실행 결정을 확정하지 않는다. 실제 착수는 별도 Work로 분리하고 `/work-plan`에서 재검토한다.

---

## 질문 / 배경

발단: `.claude/rules/`의 `java-spring.md`, `testing.md`, `infra.md`가 `base-msa-template` 잔재로 남아 있어 "삭제해도 되지 않나"라는 질문에서 출발했다. 검토 중 이것이 단순 정리가 아니라 **rule 자산 전체를 어떻게 일반화하고 멀티에이전트 option-pack으로 재설계할지**의 전략 문제임이 드러났다.

답해야 할 핵심 질문:

1. 현재 자산이 각 툴별로 무엇을 담고, 어디가 비대칭인가?
2. 무엇이 stack-agnostic(보편)이고 무엇이 stack-specific(Spring 전용)인가?
3. 네이밍을 어떻게 정확하게 바꿀까? (`testing`은 너무 광의)
4. 멀티에이전트(Claude/Codex/Antigravity/Cursor) option-pack 구조는 어떤 모양인가?
5. 구현 소유 방향은 source-first인가 product-first import인가?

---

## 현황 인벤토리

### Claude (`.claude/rules/`, path-scoped frontmatter)

| 파일 | 적용 경로 | 성격 | 내용 요약 |
| --- | --- | --- | --- |
| `docs-workflow.md` | `docs/**`, `CLAUDE.md`, `.claude/**` | **core** (논외) | command intent 라우팅, README 인덱스 규칙 등 |
| `git-workflow.md` | `**` | **core** (별도 thin-adapter backlog) | branch isolation, commit approval 등 |
| `infra.md` | `infra/**`, Dockerfile, docker-compose | **축 A 안전** | dry-run 우선, kubectl/terraform 무승인 금지, secret 미추가, Actuator 비노출 |
| `java-spring.md` | `**/*.java`, build.gradle.kts 등 | **축 B stack** | MyBatis `#{}`, Lombok 선별, common-core 경계, Javadoc 정책 |
| `testing.md` | `**/src/test/**/*.java` | **축 B stack** | 레이어별 어노테이션, AssertJ, BDD given/willReturn |

### Cursor (`.cursor/rules/`, `alwaysApply` frontmatter)

| 파일 | apply | 성격 | 비고 |
| --- | --- | --- | --- |
| `behavior-principles`, `coding`, `execution`, `output-format`, `git-commit`, `workflow`, `role-harness-maintainer`, `debugging` | always/scoped | **core** (논외) | BEHAVIOR-PRINCIPLES·AGENT-WORKFLOW 미러 |
| `safety-critical.mdc` | **always** | **축 A 안전** | `rm -rf`/`sudo`/`kubectl`/`terraform` 무승인 금지, infra 변경 금지, `.env`/secret 노출 금지 |
| `java-spring.mdc` | scoped | **축 B stack** | Claude `java-spring.md` 미러 |
| `testing.mdc` | scoped | **축 B stack** | Claude `testing.md` 미러 |

### Codex / Antigravity (`.agents/skills/`)

- `workflow-*` skill 12개만 존재. **stack/safety 대응 surface가 0개.**
- 즉 Codex/Antigravity는 현재 **repo-local stack/safety rule surface로는** 이 규칙들을 받지 않는다(시스템/개발자 레벨 안전 지침은 별개로 존재하므로 "전혀 없음"은 아니다).

### 비대칭 요약 (전략의 중심)

```
                  Claude            Cursor              Codex/Antigravity
축 A 안전 ──────  infra.md          safety-critical.mdc   ✗ 없음
                  (path-scoped)     (always, 더 넓음)
                  ↑ always 룰 없음   ↑ infra 안전 포함+초과

축 B stack ─────  java-spring.md    java-spring.mdc       ✗ 없음
                  testing.md        testing.mdc           ✗ 없음
```

- **축 A:** 같은 안전 의도가 Claude(path-scoped, 좁음)와 Cursor(always, 넓음)로 **메커니즘·범위가 불일치**, Codex/Antigravity엔 **부재**. Claude는 `infra/**` 경로 밖에서 `rm -rf`/`sudo`/secret 안전망이 rule로는 없다(BEHAVIOR-PRINCIPLES·memory feedback에 의존).
- **축 B:** Claude+Cursor 미러는 있으나 Codex/Antigravity 부재. "멀티에이전트 option-pack" 명분의 실체.

---

## 비교 / 분석

### 1. 일반화 축 분리

| | 축 A: 안전 레이어 | 축 B: stack 컨벤션 |
| --- | --- | --- |
| 대상 | `infra` + `safety-critical` | `java-spring` + `testing` |
| 보편성 | stack 무관, 모든 repo 해당 | Spring/JVM 전용 |
| 핵심 결함 | 툴 간 메커니즘·범위 불일치, Codex/AG 부재 | Codex/AG 부재, 네이밍 부정확, base-msa 잔재 |
| 검증 원천 | 보편 안전 원칙 (source가 SSoT) | 실제 product 관례 (product가 SSoT) |
| 방향 | **source-first 승격** (always, 4툴) | **product-first import** |
| 시급성 | 높음 (도구간 비대칭 해소) | 낮음 (option-pack 트리거 대기) |

**축 A 하위 분할 (A1/A2):** 축 A는 적용 메커니즘이 다른 두 층이 섞여 있어 다시 나눈다.

| 하위축 | 대상 | 적용 | 예 |
| --- | --- | --- | --- |
| **A1 실행 안전** | destructive/privileged/secret | **always** (모든 경로) | `rm -rf`, `sudo`, secret 노출 금지 (Cursor `safety-critical.mdc` 계열) |
| **A2 infra 안전** | infra/deploy/environment | **path-scoped** (infra 파일 진입 시 강화) | Docker, Actuator, kubectl/terraform, dry-run (Claude `infra.md` 계열) |

A1은 "항상 적용되는 실행 안전", A2는 "infra 파일을 만질 때 강화되는 경계"다. 하나의 `safety-critical`로 합치면 두 성격이 섞이므로 명칭·적용·rollback 단위를 분리해 설계한다.

### 2. 네이밍 재설계

| 현재 | 문제 | 후보 (확정 아님 — 축 B는 착수 시 결정) |
| --- | --- | --- |
| `testing` | 너무 광의 — 실제론 Spring slice + AssertJ/Mockito/BDD/naming 혼재 | `spring-test-conventions`, 또는 `jvm-test-style`(stack-agnostic 스타일) + `spring-test-slices`(slice 어노테이션) **분리** |
| `java-spring` | 범위 불명확 | `spring-backend-conventions` (pack: `spring-boot`) |
| `infra` (Claude) | path-scoped라 경로 밖 공백 | **축 A2**로 (A1과 분리) |
| `safety-critical` (Cursor) | A1엔 맞지만 infra/deploy 전체 명칭으론 애매 | **A1=실행 안전 / A2=infra 안전** 별도 명칭 |

### 3. 멀티에이전트 아키텍처 — `skills/` 표준 재사용

**기본 방향: workflow canonical화에서 얻은 SSoT+adapter 문제의식을 재사용해, rule 자산도 `skills/{domain}/*.md`를 SSoT로 두고 툴별 adapter는 thin하게 만든다(단 적용 메커니즘은 아래 "메커니즘 주의" 참조 — workflow와 다르다).** 현재는 canonical 없이 각 툴 surface에 내용이 직접 박혀 중복된 상태(workflow를 canonical화하기 전과 같은 문제)다.

```
skills/{domain}/{name}.md  (canonical SSoT)   ← 내용의 단일 출처
   ├── .claude/rules/{name}.md                ← path-scoped / always adapter (thin pointer)
   ├── .cursor/rules/{name}.mdc               ← alwaysApply / glob adapter (thin pointer)
   └── Codex/Antigravity surface              ← ↓ 메커니즘 주의
```

예: `skills/safety/safety-critical.md`(SSoT), `skills/spring/spring-conventions.md`, `skills/spring/spring-testing.md`.

**메커니즘 주의 — workflow와 다른 점 (반드시 설계 시 반영):**
- workflow는 *호출형*(slash command/skill)이라 `.agents/skills/workflow-*/`로 깔끔히 미러된다.
- 안전/컨벤션 rule은 *always-apply / path-scoped* **적용**이다. **Codex 당사자 확인 결과**: `.agents/skills/*/SKILL.md`는 intent 매칭/명시 호출 시 로드되는 workflow adapter이지 always/path-scoped rule surface가 **아니다**(`.codex/hooks.json`도 Stop hook만 보유, safety hook 없음). Codex에서 상시 적용에 가장 가까운 경로는 **root `AGENTS.md` entry contract**이며, 이 파일이 세션 시작 시 `docs/BEHAVIOR-PRINCIPLES.md`·`docs/AGENT-WORKFLOW.md`·`docs/STATUS.md`를 읽게 한다. 따라서 Codex용 safety는 `.agents/skills`가 아니라 **`AGENTS.md`가 로드하는 shared doc**에 둔다.
- 단 `AGENTS.md`는 **thin-entry 원칙**이 있어 안전 rule 본문을 길게 인라인하지 않고, `docs/BEHAVIOR-PRINCIPLES.md` 실행 안전 절 또는 **별도 canonical safety 문서로 라우팅**한다. (현재 BEHAVIOR-PRINCIPLES엔 `rm -rf`/`sudo` 같은 실행 guard가 없어 `safety-critical`은 독립 가치가 있다.)
- **Antigravity:** repo contract상 root `AGENTS.md` auto-load + `.agents/skills/workflow-*` 소비다. 단 이는 *contract 기준*이며 **실제 AG runtime 검증은 별도 필요**(Codex가 AG runtime을 직접 검증한 것은 아님).
- 툴별 "강화 포인트": 공통 원칙은 canonical에, 특정 툴에서만 더 강하게 둘 guard는 해당 adapter에만(예: Claude는 auto-load라 안전 룰을 always로 더 강하게).

- 축 A는 이 구조로 **즉시** 정규화 가능. 축 B는 pack catalog(`provides/requires/modes`) 위에 얹어 import 시 구성.
- 기존 backlog **"Spring modular/product engineering option-pack 후보"**의 pack catalog/resolver 설계와 직접 연결 — 축 B는 그 후보의 한 입력이 된다.

### 3b. planning-pack과의 경계 (축 B에서만 발생)

option-pack과 planning-pack은 **시점이 다른 같은 내용**이 겹친다. 축 B를 재설계할 때 반드시 정리해야 한다.

| | option-pack (rule) | planning-pack (template) |
| --- | --- | --- |
| 시점 | 코딩 중 (실행시점 강제) | 착수 전 (계획·문서화) |
| 형태 | always/path-scoped rule | PRD/TRD/code-conventions 문서 |
| 겹침 | **code conventions** ← 양쪽 다 보유 |

- `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`도 "code conventions"를 산출물로 들고, 축 B `java-spring` rule도 같은 컨벤션을 강제한다.
- 한 가지 유혹은 `skills/{domain}/convention.md`를 단일 SSoT로 두고 planning-pack 문서와 option-pack rule을 **둘 다 거기서 파생**시키는 것이다(3-way 중복 제거).
- 그러나 planning-pack은 *선택지를 만드는 pre-work artifact*이고 option-pack rule은 *실행 중 behavior 제약*이라 성격이 다르다. 단일 SSoT 직접 파생은 **과잉 결합** 위험이 있다.
- 따라서 단일 SSoT 수렴을 결론으로 쓰지 않는다. 기본 대안은 **`shared principles document + separate projections`**(공유 원칙 문서는 두되, planning template과 rule adapter는 각자 투영)이며, 수렴 vs 분리는 축 B 착수 시 비교 결정한다. **축 A(안전)는 planning-pack과 무관하므로 이 논의에서 제외한다.**

### 4. 구현 / 소유 방향

| 자산 | 방향 | 근거 |
| --- | --- | --- |
| 축 A (안전) | **source → 모든 scaffold** | 보편적이라 product 검증 불필요. source가 SSoT. 지금 끌어올림 |
| 축 B (stack) | **product(`spring-modular`) → source import** | 실제 관례가 검증 원천. 성급한 source 일반화 금지(기존 CHORE-20260620-001 원칙) |

---

## 권장 방향

1. **축 A를 먼저 닫는다 (독립, 시급).** `infra` + `safety-critical`을 stack-agnostic 안전 레이어로 통합하되, **A1은 always·A2는 path-scoped로 정규화하고 Codex/AG는 `AGENTS.md → shared safety doc` 경로로 반영**한다(획일적 always가 아니다). → 도구간 비대칭 해소. base-msa와 무관하므로 product 검증을 기다릴 이유 없음.
2. **축 B는 option-pack 트리거에 위임한다.** `java-spring` + `testing`은 즉시 삭제하지 않고, `spring-modular-template` 정제 → source import 경로로 재설계. 네이밍·pack 구조는 기존 option-pack backlog에 흡수. import 전까지 현행 유지(Claude+Cursor) 또는 별도 판단.
3. **단순 5파일 삭제는 채택하지 않는다.** 축 A 안전 자산까지 버리는 실수가 되고, spring-boot profile이 빈 껍데기가 되는 부작용도 동반한다.

### 미해결 결정 (착수 시 정할 것)

- 축 A 명칭: A1(실행 안전) / A2(infra 안전) 각각의 명칭 확정 (`safety-critical`은 A1엔 적합, A2엔 별도 필요)
- 축 A를 core 상시 포함으로 둔다(기본). **`--no-safety` opt-out은 안전망 default 가치를 약화하므로 기본 후보에서 제외**하고, 강한 근거가 있을 때만 재검토
- 축 A의 Codex 적용 경로: `AGENTS.md → shared safety doc`(BEHAVIOR-PRINCIPLES 실행 안전 절 vs 별도 canonical safety 문서) 중 택1 — thin-entry 원칙상 인라인은 제외
- canonical namespace: **`skills/{domain}/`을 기본값**으로 두고 "Codex skill 아닌 canonical rule document"임을 명시. 대안(`rules/{domain}`, `docs/rules/{domain}`)은 `.agents/skills`와의 명칭 혼동을 고려해 축 A 착수 시 최종 확정
- **language policy(canonical 위치별 상이):** `.claude/rules/*.md`·`.cursor/rules/*.mdc`·`AGENTS.md`는 English Only, `docs/*.md`·`.agents/skills/*/SKILL.md`는 Korean primary+bilingual. 안전 canonical을 어디 두느냐에 따라 작성 언어가 갈리므로 위치 결정과 함께 정한다
- **rollback 단위:** 축 A와 축 B는 별도 Work. 축 A도 A1/A2를 한 PR로 묶을지 분리할지 착수 시 결정
- 축 B `spring-boot` profile 처리 (빈 분기 유지 vs profile 제거 — option-pack 메커니즘 확정 후 결정)
- 축 B import 시점에 Claude/Cursor 기존 미러를 유지할지, pack 생성물로 교체할지
- 축 B code-conventions: 단일 SSoT 수렴 vs `shared principles + separate projections` (§3b)

---

## Revisit Triggers

- `spring-modular-template`에서 stack 컨벤션이 충분히 정제돼 import 가능해질 때 → 축 B 착수
- 실제 안전 사고(무승인 destructive/infra/secret 노출)가 관측되면 → 축 A를 **P1 내 emergency hardening으로 착수 시급도 상향**(이미 P1이므로 우선순위 승격이 아니라 즉시 착수 트리거)
- option-pack pack catalog/resolver 설계가 시작되면 → 이 brief의 축 B 절을 입력으로 사용

---

## 연결

- 기존 backlog: **"Spring modular/product engineering option-pack 후보"** (축 B의 상위 컨테이너), **"`.claude/rules/git-workflow.md` thin adapter화"** (같은 canonical+adapter 패턴)
- `docs/briefs/harness-identity-policy-first-20260608.md` (canonical-first·policy layer 원칙)
- **검증 영향:** 현재 parity/mirror/invariant 테스트는 이 rule 파일들을 하드 참조하지 않음(`check-surface-mirror-parity.sh`는 **command surface만** 검사). 즉 **rule canonical↔adapter parity를 보는 검사가 없으므로**, 축 A 정규화 시 rule parity check 신설이 필요하다. **최소 검사 범위**(내용 동등성은 과검증이라 제외): canonical 문서 존재 · adapter pointer 존재 · A1(always)/A2(path-scoped) surface 존재 · scaffold copy matrix 포함 여부. 단 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer U stack-marker는 `java-spring.md` 존재에 의존 → 축 B 변경 시 동반 갱신.
- **entry consumption 검증:** 이 brief는 source repo contract 기준이다. 축 A 착수 시 **scaffold target에서 Claude/Codex/Antigravity/Cursor 각 entry가 실제 session start에 안전 canonical을 소비하는지**(특히 `AGENTS.md`가 항상 읽히는지) dry-run 또는 manual simulation으로 확인하는 단계를 둔다.
- **scaffold copy matrix(축 A는 default scaffold 영향):** `scripts/create-harness.sh`는 Claude `infra.md`를 **default로**(line 544), Spring rules를 **profile일 때만**(558–561·665–668), Cursor `safety-critical.mdc`를 **default로**(650 블록) 복사한다. 축 A 수정은 generic 포함 모든 신규 target에 영향. 관련: `docs/WORKFLOW-MANUAL.md` 296·821–823·844.
