---
id: CHORE-20260615-002
priority: P2
status: Done
actual_end: 2026-06-15
risk: L2
scope: 언어 정책을 DR-007 단일 SSoT로 통합한다. (1) DR-007에 commit message·PR body·agent console(behavioral)·default/override를 흡수, (2) 산재한 정의(WORKFLOW-MANUAL Appendix C, HARNESS-MAINTAINER-GUIDE, GIT-WORKFLOW §5, rules)를 actionable directive+DR-007 pointer로 정리, (3) AGENTS.md에 commit/PR/console directive 인라인(Codex 근본 fix), (4) BEHAVIOR-PRINCIPLES에 console behavioral 1줄(전 도구 도달), (5) README adopter 기대치 pointer. DR-030은 전략-only로 경계 명시(Draft 유지). 메커니즘(--lang) 미구축.
appetite: 0.5d
planned_start: 2026-06-15
related_dr: [DR-007, DR-030, DR-037]
related_work: [CHORE-20260615-001]
---

# CHORE-20260615-002: 언어 정책 DR-007 SSoT 통합

## Top Summary

- **목표:** 흩어진 언어 규칙을 DR-007 단일 SSoT로 통합하고, ① Codex commit/PR 영어 ② Claude console 영어의 근본 원인(정책 scope가 파일유형 경계 밖에서 누수 + Codex lazy-pointer 도달 실패)을 닫는다.
- **강제 실태:** `tools/git-hooks/commit-msg` + CI advisory는 Conventional Commits **구조(type prefix)만** 강제하고 한국어 subject는 미강제 → 문제①은 enforcement 공백이 아니라 instruction 도달 문제(DR-037이 language policy를 ⛔ behavioral로 분류한 것과 정합). 따라서 조치는 enforcement 신설이 아니라 **도달 보장 + SSoT 정리**다.

## Background (원인 규명)

- **문제①:** commit 언어 규칙이 Codex(`AGENTS.md`)엔 조건부 lazy pointer로만 도달(`AGENTS.md:49`), Document Language Policy 목록에 commit/PR 누락. PR body 언어는 전 도구 무규정.
- **문제②:** agent 사용자 노출 출력(진행 narration·tool description·echo 라벨) 언어를 규율하는 규칙이 repo에 전무(grep 0건). DR-007은 persisted 파일만 규율.

## Language Surface Census (전수 조사, 2026-06-15)

archive 제외. 분류: **D**=정의/재서술(중복·정리 대상), **P**=올바른 pointer, **E**=검증/강제 surface, **J**=도메인 하위 규칙.

| Surface | 분류 | 현재 상태 | 처리 방향 |
| --- | --- | --- | --- |
| `docs/decisions/DR-007-language-policy.md` | D | 파일유형만 정의 | **SSoT로 amend** (commit/PR/console + default/override 흡수) |
| `docs/WORKFLOW-MANUAL.md` Appendix C (893-917) | D | **언어 규칙 표 전체 + Bilingual Rules 중복** | digest+pointer로 축약 or drift 동기화 (B 검토) |
| `docs/HARNESS-MAINTAINER-GUIDE.md §Language Policy (47-54)` | D | commit/entry/user-facing 재서술 | dedup → directive+pointer |
| `.claude/rules/git-workflow.md` Commit Message Format | D | Korean-primary 재서술 (always-loaded) | actionable directive 유지 + PR body 1줄 추가 |
| `scripts/templates/default/.claude/rules/git-workflow.md` | D | 위의 미러 | parity 미러 (verbatim) |
| `.cursor/rules/git-commit.mdc` | D | Korean-primary 재서술 | PR body 1줄 추가 |
| `docs/GIT-WORKFLOW.md §5` + `templates/source-gitflow/...` | D | Korean-primary 재서술 | directive+DR-007 pointer로 축약, PR body 1줄 |
| `docs/decisions/DR-030-language-i18n-strategy.md` | D(전략) | Draft, i18n 미결 | scope 경계 명시 (전략-only), Draft 유지 |
| `AGENTS.md` Document Language Policy (36-43) | P(불완전) | 파일유형 pointer만, commit/PR 누락 | **①의 근본 fix** — commit/PR/console directive 인라인 |
| `.cursor/rules/workflow.mdc §Language Policy` + 템플릿 | P | "English Only … as defined by DR-007" (모범 pointer) | 무변경(참고 모델) |
| `.claude/rules/docs-workflow.md:26` / `AGENT-WORKFLOW.md:162` / `HARNESS-PROTOCOL.md:400` / `record-decision.md:42` | P | DR-007 pointer | 무변경 |
| `docs/BEHAVIOR-PRINCIPLES.md §5` | (신규 P) | 언어 침묵 | **②의 fix** — console behavioral 1줄 (전 도구 공통 도달) |
| `README.md` (Apply/Adopter 부근 + Documentation Map) | (신규 P) | 언어 정책 미언급(`--profile`만) | **adopter 기대치 설정** — 기본 한국어 주체+Bilingual, 단일 override 지점, SSoT=DR-007 (pointer-only, 2~3줄) |
| `docs/maintainer/VERIFICATION-COMMANDS.md` Layer P (830-859, **1447 cascade**) | E | 한글비율/commit type prefix 탐지 | DR-007 scope 확장 반영(commit/PR/console 인지), 1447 trigger 준수 |
| `skills/workflow/repo-health.md (128-130)` | E | Language Rules + Bilingual 위반 점검 | 신규 surface 점검 항목 추가 검토 |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md (78,133)` | E | language policy=screening, F3 보류 | behavioral 유지 근거 재확인(무변경 가능) |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md:54` | E | Layer P 참조 | 무변경 가능 |
| `docs/decisions/DR-037 (25,33,40,49)` | E | language=behavioral, commit format=구조강제 | console behavioral 결정의 선례 근거(무변경) |
| `.claude/rules/testing.md`·`.cursor/rules/testing.mdc (54-55)` | J | method명 English/@DisplayName Korean | DR-007 §domain 정합 확인(무변경 가능) |
| `.claude/rules/java-spring.md`·`.cursor/...java-spring.mdc` | J | `// Korean reason — English term` | DR-007 §Java 정합(무변경) |

> 제외(언어 정책 아님 — programming-language/profile 문맥): WORKFLOW-MANUAL 808/831/862/882, HARNESS-ARCHITECTURE:199, SCAFFOLD-ONBOARDING, create-harness 1034/1086, README:229, PLAN:129, DR-031:52, presentations 폰트.

## Confirmed Decisions (사용자, 2026-06-15)

1. **DR-007 = 운영 규칙 SSoT, DR-030 유지** — DR-007이 결정된 운영 규칙(파일유형+commit+PR+console+default/override)을 통합, DR-030은 미결 전략(1차 청중·수요 signal·`--lang` 메커니즘)만 보유하는 open DR로 잔존.
2. **Configurability = 선언만** — DR-007에 "default=한국어 주체, 이 DR이 단일 override 지점" 명시. 새 메커니즘 미구축, scaffold default 주입 유지.
3. **Console 출력 = behavioral 지침 명시** — 대화 언어를 따른다(기본 한국어), hard-gate 아님(DR-037 선례).

## 설계 원칙: SSoT 정의 + thin actionable 미러

pointer-only 통합 금지 — DR-007(문서)은 always-loaded가 아니라 "모두 DR-007 pointer"로 바꾸면 Codex를 깨뜨린 lazy-pointer 실패가 재발. 따라서 DR-007=정의 SSoT(전체 규칙·rationale 단일 보유), always-loaded instruction surface는 actionable 1줄 directive + DR-007 pointer만 보유(중복 rationale 제거 = "정리").

## 제약 (cascade)

- **DR-030 미seed** → shipped surface(DR-007 본문·템플릿 포함) 본문에 `DR-030` 토큰 인용 금지. Linked DRs frontmatter + self-describe만.
- **parity 가드** `check-default-template-parity.sh` = `.claude/rules/git-workflow.md ↔ templates/default/...` verbatim → 동시 미러 필수.
- **leak-scan** source-gitflow shipped 6파일(`GIT-WORKFLOW.md` 포함) source-only 토큰 0 유지.
- **DR-007 변경 cascade**: VERIFICATION-COMMANDS Layer P 탐지 패턴(1447), HARNESS-PROTOCOL DR trigger 점검.

## Scope / Non-Goals

### Scope
- DR-007 amend (commit/PR/console + Default·Override).
- 산재 정의 정리: WORKFLOW-MANUAL Appendix C, HARNESS-MAINTAINER-GUIDE §Language Policy, GIT-WORKFLOW §5(+템플릿), `.claude/rules/git-workflow`(+템플릿 미러), `.cursor/git-commit`.
- AGENTS.md commit/PR/console directive 인라인.
- BEHAVIOR-PRINCIPLES §5 console behavioral 1줄.
- DR-030 scope 경계 update. decisions/README 행 update.
- README.md adopter 기대치 note(Apply/Adopter 부근) + Documentation Map DR-007 pointer (pointer-only).
- VERIFICATION-COMMANDS Layer P / repo-health 점검 surface 정합.

### Non-Goals
- scaffold `--lang` 등 i18n 메커니즘 구축(DR-030 전략 잔존).
- commit/console 언어 hard-gate(behavioral 유지).
- testing/java-spring 도메인 규칙 재작성(정합 확인만).

## Done Criteria

- [x] DR-007 amend: commit/PR/console + Default·Override 섹션, frontmatter Amended/Linked DRs.
- [x] 산재 정의 정리(중복 rationale 제거, directive+pointer) — MAINTAINER-GUIDE=pure pointer, WORKFLOW-MANUAL Appendix C=최소 digest, GIT-WORKFLOW §5(+템플릿) directive+pointer.
- [x] AGENTS.md commit/PR/console directive 인라인 (English-only, in-context).
- [x] BEHAVIOR-PRINCIPLES §5 console behavioral 1줄 (default conversational convention).
- [x] DR-030 경계 update / decisions/README 정합.
- [x] README.md adopter 언어 기대치 note + Documentation Map DR-007 pointer (pointer-only).
- [x] cascade: Layer P(1447 결론=신규 패턴 없음)·parity(2/2)·leak-scan·shipped-DR-closure 통과, run-harness-checks --all OVERALL PASS.
- [x] Cross-Agent Review 합의(Consensus) 기록 — R1(C1~C6) + R2(C7~C8, B P1/P2 수용) + R3(B 재확인, 릴리즈=PATCH 합의).
- [x] **사용자 최종 승인 (final review)** — 2026-06-15 사용자 승인(패치 릴리즈까지 진행).

## Verification

- `bash scripts/tests/check-shipped-dr-closure.sh` (DR-007 seed ✓, shipped에 DR-030 토큰 부재)
- `bash scripts/tests/check-default-template-parity.sh`
- `bash scripts/tests/run-harness-checks.sh --all` (leak-scan/index/manifest)
- `git diff --check`
- 언어 적합성: DR-007·BEHAVIOR·GIT-WORKFLOW·WORKFLOW-MANUAL = Korean-primary; AGENTS·.claude/rules·.cursor = English-only
- 수동: AGENTS.md가 commit/PR 언어 directive를 in-context 보유, console behavioral이 BEHAVIOR-PRINCIPLES로 전 도구 도달

## Cross-Agent Review And Discussion

### Roles & Workflow
- **A = Claude** (author/driver): Work+plan 작성, 구현, 결과 정리.
- **B = Codex** (red team reviewer): 내적 정합성을 넘어 **방향 자체의 정당성**을 냉정하고 비판적으로 검토한다. 계획에 기술된 내용의 합당성뿐 아니라 — 더 나은 방안은 없는지, 접근 자체가 정당한지, 필요하면 이 작업의 존재 이유(backlog 요구) 자체도 의심한다.
- **흐름:** A Work+plan → B 검토(R라운드) → 합의 → A 구현 → B 결과 검토 → 사용자 최종 승인 → `/work-close` → commit → PR(`--base develop`) → merge.
- 라운드는 아래 Round Log에 누적, 합의 사항은 Consensus Log에 고정한다.

### Round Log
| Round | 일시 | 주체 | 제기/응답 | 상태 |
| --- | --- | --- | --- | --- |
| R1 | 2026-06-15 | B(Codex) | 방향 타당하나 scope 과다. core=DR-007 SSoT 강화+AGENTS.md 도달 보정; README·digest 계열 축소 권고. Appendix C vs MAINTAINER-GUIDE 차등(후자 pure pointer, 전자 최소 digest). README 최약 항목—증거 없으면 backlog 요구 자체 축소, 남겨도 1줄 pointer. console은 hard rule 아닌 "default conversational convention". DR-007/030 분리 유지. STATUS pointer는 commit 전이라 유지+substantive와 번들 권고. | 반영 |
| R1 | 2026-06-15 | A(Claude) | 대부분 수용: 차등 처리·console convention·DR 분리·STATUS 번들·scope core 잠금 합의. **이견 1건**: README는 A가 만든 backlog 요구가 아니라 사용자 직접 지시(이번 세션) → A 독단 drop 불가, depth만 사용자 재확인. | 합의(README depth 제외) |
| R1.5 | 2026-06-15 | 사용자 | README depth = adopter note 2~3줄(원안) 결정. C6 확정. | 반영 |
| R2 | 2026-06-15 | A(Claude) | 구현 완료 후 B 결과 검토 요청. 변경: DR-007 amend(Non-File Surfaces+Default/Override), AGENTS.md inline, BEHAVIOR §5, MAINTAINER-GUIDE pure pointer, WORKFLOW-MANUAL Appendix C 최소 digest, GIT-WORKFLOW §5+2템플릿, DR-030 경계, decisions/README, README 2곳, Layer P note. 검증 OVERALL PASS. A self-flag 3건 제시. | B 검토 대기 |
| R2 | 2026-06-15 | B(Codex) | **[P1]** DR-007의 "단일 override 지점" 주장이 구현과 모순 — AGENTS.md/GIT-WORKFLOW §5/.claude rules/.cursor가 "한국어 주체"를 inline 고정. DR-007만 영어로 바꿔도 always-loaded surface가 옛 정책 강제, 특히 Codex는 AGENTS.md 직접 따름. README도 잘못된 기대 노출. **[P2]** DR-030 Scope Boundary Update는 "DR-007 amend 범위 해소"라면서 Open Points엔 같은 항목을 미결로 유지 — 무엇이 미결인지 흐림. | 수용 |
| R2 | 2026-06-15 | A(Claude) | **P1/P2 모두 수용.** P1: "단일 override 지점"은 과장 — inline mirror는 도달 신뢰성 위해 의도적(pointer-only는 Codex 실패)이므로 제거 불가. DR-007을 "authoritative SSoT + override 시 함께 고칠 mirror surface 목록 규정"으로 정직하게 재구성, README도 동일 교정. (template 경로는 source-only leak이라 DR-007 본문 목록에서 제외.) P2: DR-030 Open Points를 전략 미결 항목만 남기고 amend 범위·P2(1)은 종결로 정리. 재검증 OVERALL PASS. | 합의 |
| R3 | 2026-06-15 | B(Codex) | P1/P2 수정안에 추가 finding 없음. 릴리즈 질문에 **PATCH(정합성 복구) 권고** — 새 기능 아님, DR-030 전략/`--lang`은 섞지 말 것, 후속 같은 주제 1~2건 있으면만 짧게 묶기. | 합의 |
| R3 | 2026-06-15 | A(Claude) | PATCH 동의(이견 없음). 사용자 최종 승인 획득 → work-close → commit → feature→develop PR → merge 진행. 릴리즈(버전 bump·노트·develop→main·tag)는 사용자 릴리즈 노트 초안 작성 중이라 develop merge 후 대기. | 합의 |

### Consensus Log
| # | 합의 내용 | 근거 | 라운드 |
| --- | --- | --- | --- |
| C1 | scope core 잠금: DR-007 SSoT amend + AGENTS.md commit/PR/console directive 인라인을 1순위 core로 둔다. | 실제 버그(①도달 실패·②규칙 부재) 직접 해소 | R1 |
| C2 | Appendix C/MAINTAINER-GUIDE **차등 처리**: `HARNESS-MAINTAINER-GUIDE §Language Policy`=pure pointer, `WORKFLOW-MANUAL Appendix C`=독립 가치 있는 **최소 digest만** 유지. | drift 비용 최소화 | R1 |
| C3 | console 규칙은 hard rule이 아니라 **default conversational convention**으로 서술. | DR-037 behavioral, 강제 불가 — 지켜지지 않을 hard rule 추가 방지 | R1 |
| C4 | DR-007(현 효력 운영 SSoT) / DR-030(미래 i18n 전략) **분리 유지**. | "한 군데 정의"=현 효력 운영 규칙 SSoT 하나이지 미래 전략 병합이 아님 | R1 |
| C5 | STATUS Active pointer는 commit 전 상태로 **유지**하고 substantive patch와 동일 commit에 번들(별도 revert 안 함). | 상태변경 gate 정합 + churn 방지 | R1 |
| C6 | README = adopter note 2~3줄(Apply/Adopter) + Documentation Map 1줄 pointer (원안 유지). | 사용자 결정(2026-06-15): 처음 보는 adopter 기대치 설정이 목적, Documentation Map 1줄로는 메시지 미전달. B 축소 권고는 기각. | R1 |
| C7 | "단일 override 지점" 주장 폐기. DR-007 = authoritative SSoT + override 시 함께 고칠 mirror surface **목록을 규정**. inline mirror는 도달 신뢰성 위해 유지(pointer-only=Codex 실패). 자동 동기화 메커니즘은 DR-030 전략 범위. README 동일 교정. | inline directive와 "한 곳 수정 override"는 물리적으로 양립 불가(B P1). 정직한 재구성으로 모순 해소. | R2 |
| C8 | DR-030 Open Points는 전략 미결(1차 청중·수요 signal·mirror 메커니즘)만 유지, "DR-007 amend 범위"·"P2(1)"은 종결 명시. | Draft 내부 모순 제거(B P2). | R2 |
| C9 | 릴리즈는 **독립 PATCH**(정합성 복구)로 출하. DR-030 전략·`--lang` 메커니즘은 섞지 않음. 후속 같은 주제 확정분만 짧게 묶기 허용. | shipped surface 결함 복구는 늦출수록 다음 adopter가 잘못된 정책 수신 — 빨리 닫는 게 정직. | R3 |

## Checkpoints
| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | branch + Work 파일 + census | 완료 |
| CP1 | Cross-agent 합의 (R1: C1~C6) | 완료 |
| CP2 | 구현(DR-007 + 정리 cascade) | 완료 |
| CP3 | 결과 red-team(B R2/R3) + 사용자 최종 승인 | 완료 |

## Discovery
- `/session-start` 후속 사용자 질문(언어 정책 위반 2패턴)에서 출발. 전수 조사로 WORKFLOW-MANUAL Appendix C·MAINTAINER-GUIDE 중복 정의, Layer P cascade(VERIFICATION-COMMANDS:1447), commit-msg hook=구조only(한국어 subject 미강제) 발견.
