# DR-033: Shipped DR Reference Closure

Date: 2026-06-10
Status: Accepted
Track: harness
Linked DRs: DR-021, DR-008

## Question

scaffold는 DR의 **부분 집합**(seed)만 target에 ship한다(DR-021 minimal output). 그런데 shipped 표면 문서(core canonical·shipped DR seed 파일·adapter/rule/prompt)가 seed 밖 DR을 `DR-NNN`으로 인용하면 target에서 dangling reference가 된다. 이 패턴은 작업 중 뒤늦게(scaffold 생성 후 invariant 검증에서) 발견돼 재작업을 반복시켰다(예: CHORE-20260610-003의 `HARNESS-PROTOCOL → DR-032`, 그리고 pre-existing 4건). shipped 문서의 DR 참조 규약을 어떻게 정의하고 사전 강제하는가?

## Decision

shipped 표면의 DR 참조를 **scaffold seed에 대해 closed**되도록 규약화하고, scaffold 생성 없이 검사 가능한 static check로 사전 강제한다.

**1. mode-a (core canonical 문서 → DR).** body 본문은 **seed DR만** 인용한다. seed 밖 DR을 인용해야 하면 **self-describe**한다(해당 개념을 DR 번호 없이 서술). 선례: DR-032 인용을 HARNESS-PROTOCOL에서 self-describe로 처리.

**2. mode-b (shipped DR seed 파일 → DR).** DR 간 lineage cross-reference 중 seed 밖 DR은 **`Linked DRs:` frontmatter 라인에만** 둔다. body 본문은 self-describe한다. closure check는 `Linked DRs:` 라인을 **제외**한다 — 이 라인은 source-side lineage 메타데이터로, target에서 깨져도 무방한 약한 참조로 취급한다.

**3. seed SSoT.** "어떤 DR이 ship되는가"의 SSoT는 `scripts/create-harness.sh`의 기본 adapt 블록(`^adapt .*docs/decisions/DR-`)이다. check는 이를 **파생**해 seed 목록을 만든다. 별도 하드코딩 사본을 두지 않는다(drift 방지).

**4. 사전 강제 (static check).** scaffold 생성 없이 source만으로 검사하는 `scripts/tests/check-shipped-dr-closure.sh`를 둔다. shipped doc set의 DR 참조(`Linked DRs:` 제외)가 seed에 닫혀 있는지 확인한다. `docs/maintainer/VERIFICATION-COMMANDS.md`(HOW·Release Full Sweep), `docs/HARNESS-RECOVERY-VALIDATION.md`(WHETHER/WHEN), `skills/workflow/repo-health.md`(cascade)에 배선한다. 작성 시점 인지를 위해 `.claude/rules/docs-workflow.md`와 `HARNESS-PROTOCOL.md` cascade trigger에도 규약을 둔다.

**5. 사후 검사 정합.** scaffold 생성 후 검사인 `check-scaffold-invariants.sh [1]`도 `Linked DRs:` 제외 규칙을 동일 적용해 static check와 일치시킨다.

## Options Considered

mode-b 처리:

| 선택지 | 장점 | 단점 |
|--------|------|------|
| B-i seed 편입 | 참조 실재화 | target 비대화 + 전이적 폭증, DR-021 minimal 위배 |
| **B-ii Linked DRs 가드 (채택)** | source 추적성 보존, target 정직(body clean), adapt 무변경, 복잡도 최소 | frontmatter에 약한 참조 잔존(허용 tradeoff) |
| B-iii adapt() 자동 정리 | 가장 원칙적·자동 | adapt() 개조 복잡도↑ |
| B-iv report-only 강등 | 단순 | 게이트 약화, target dangling 잔존 |

## Rationale

DR-021은 scaffold output을 minimal로 유지하므로 "모든 참조 DR을 seed에 넣기"(B-i)는 방향이 어긋난다. 따라서 부담은 **참조하는 쪽**(shipped 문서)에 둔다 = seed에 닫힌 참조만 허용. body self-describe(mode-a)와 Linked-DRs frontmatter 격리(mode-b)는 source의 설명력·추적성을 보존하면서 target body를 dangling-free로 만든다. 핵심은 **검출 시점을 scaffold 생성 후(verification) → 작성/작업 중(source-only static check)으로 앞당기는 것**이다. 이로써 "뒤늦게 발견 후 재작업" 루프를 끊는다.

## Consequences

- 신규 `scripts/tests/check-shipped-dr-closure.sh`(source-only). `check-scaffold-invariants.sh [1]`는 `Linked DRs:` 제외로 갱신.
- `docs/maintainer/VERIFICATION-COMMANDS.md`에 Layer + Release Full Sweep 편입, `docs/HARNESS-RECOVERY-VALIDATION.md`에 정책 pointer, `skills/workflow/repo-health.md` cascade 배선, `.claude/rules/docs-workflow.md` + `HARNESS-PROTOCOL.md` trigger에 작성 규약.
- 기존 4건(DR-029→DR-011/030, DR-013/014→DR-031) remediation: body self-describe + `Linked DRs:` 이동.
- 향후 shipped 문서에 DR 인용 시 seed closure를 작성 시점에 확인.

## Reversal Cost

Medium — 정책+스크립트+rule. revert 시 DR-033 폐기 + 배선 제거. branch 단위 단순.

## Linked Backlog Items

- Shipped DR reference closure guard (P1), Shipped DR seed → 비-seed DR dangling 4건 remediation (P2) — CHORE-20260610-005로 통합 착수
