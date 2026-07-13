# DR-043: Product Constants Home And AGENT-WORKFLOW Framework-Pure Policy

Date: 2026-06-24
Status: Accepted (Amended)
Track: harness
Linked DRs: DR-034

<!-- Accepted 2026-06-24 (CHORE-20260624-002, cross-review R0 Codex F5 권고 + owner 승인). CHORE-20260624-001 spring upgrade에서 남은 단일 accepted-drift(docs/AGENT-WORKFLOW.md)의 근본 원인을 닫는 정책. -->
<!-- Amended 2026-06-24: canonical home을 PLAN.md → PLAN-SUMMARY Implementation Baseline으로 정정. scaffold 템플릿이 이미 PLAN-SUMMARY에 owned Implementation Baseline/Verification Defaults를 생성하고 BOOTSTRAP/SCAFFOLD-BOOTSTRAP가 그 경로를 전제하므로, PLAN.md로 옮기면 불필요한 scaffold/adopter migration이 발생한다. existing scaffold reality 보존 최소 변경 채택(EXECUTE 전 발견). -->

## Question

framework-owned core 운영 문서 `docs/AGENT-WORKFLOW.md`가 `Project Constants`(Runtime/Framework/Build/Architecture/Base package)와 `Verification Defaults`에 **product-specific 값**을 함께 담는다. adopter는 이 값을 자기 stack(예: Java/Spring/Gradle)으로 커스터마이즈하므로, 이 파일은 source와 영구히 갈린다. 그 결과 adopter upgrade마다 `docs/AGENT-WORKFLOW.md`가 `accepted-drift`로 남고 scaffold invariant `[5]`를 반복적으로 깬다(CHORE-20260624-001 R1에서 실측). product 값의 canonical home을 어디에 두고, 이 core 문서를 어떻게 framework-pure로 만드는가?

## Context

CHORE-20260624-001 spring framework upgrade에서 실측됐다:

- 11개 framework 파일은 v1.4.0으로 정합화됐으나 `docs/AGENT-WORKFLOW.md`만 `[locally-modified]` accepted-drift로 남았다. 원인은 framework 운영 규칙 문서에 product runtime/build/architecture 값이 혼재한다는 점이다.
- `docs/PLAN-SUMMARY.md`는 `PLAN.md`/`STATUS.md`에서 파생된 **derived cache**(독립 이력·결정 저장소 아님)로 명시되어 있어 canonical home 역할과 충돌한다.
- `docs/AGENT-WORKFLOW.md` `Verification Defaults`의 항목 대부분(Documentation-only / Workflow·protocol·tool-surface / Scaffold / Public release)은 **framework operating defaults**이며 product-specific이 아니다.
- `Project Constants`의 `Active state file: docs/STATUS.md`는 product 값이 아니라 framework convention이다.

## Decision

1. **Framework-pure policy.** framework-owned core 문서(`docs/AGENT-WORKFLOW.md` 등)는 product-specific 값을 본문에 담지 않는다. product 값은 pointer로만 참조한다.
2. **Canonical home = `docs/PLAN-SUMMARY.md` Implementation Baseline (amended).** product runtime/framework/build/architecture/base-package + project-specific verification 명령(예: `./gradlew test`/`build`)의 operational home은 `docs/PLAN-SUMMARY.md`의 `Implementation Baseline` / `Verification Defaults` 섹션이다(scaffold 템플릿이 이미 생성하는 owned 섹션). PLAN.md로 옮기는 추가 migration은 하지 않는다.

   **PLAN-SUMMARY derived 경계 (충돌 방지).** `PLAN-SUMMARY.md`의 일반 roadmap/decision/history는 여전히 `PLAN.md`/`STATUS.md`/DR에서 파생된 derived summary다. **예외:** `Implementation Baseline`과 product `Verification Defaults` 섹션은 scaffold target/adopter repo에서 **product-owned operational home**이다(derived-only 규칙의 예외). source repo 자체에서는 이 섹션을 두더라도 "source project constants summary"로 좁히고, L3 decision 근거·변경 이력은 `PLAN.md`/DR에 둔다.
3. **필드 분류.**
   - product: Runtime / Framework / Build / Architecture / Base package + project verification 명령 → `PLAN-SUMMARY.md` Implementation Baseline/Verification Defaults, `AGENT-WORKFLOW.md`는 pointer.
   - framework: `Active state file` convention + Verification Defaults의 Documentation/Workflow/Scaffold/Public release defaults → `AGENT-WORKFLOW.md`에 유지.
4. **One-time migration 필수(자동 추론 금지).** 기존 adopter는 `docs/AGENT-WORKFLOW.md` drift를 단순 overwrite로 닫지 않는다. `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`의 분류 gate(constants/verification-only 여부 분류 → 그 외 local edit은 merge/blocker)와 값 보존 확인 절차를 거친 뒤에만 `accepted-drift`를 `framework-update`로 정리한다.

## Consequences

- adopter는 향후 `docs/AGENT-WORKFLOW.md`를 framework-update로 깨끗이 받을 수 있고, accepted-drift로 인한 invariant `[5]` 반복 실패가 사라진다(one-time migration 완료 후).
- cascade 대상: `docs/AGENT-WORKFLOW.md`(product 필드 pointer화), `docs/PLAN-SUMMARY.md`(source 자신 Implementation Baseline + 경계 note), `scripts/create-harness.sh`/`docs/BOOTSTRAP.md`/`docs/SCAFFOLD-BOOTSTRAP.md`(onboarding 중복 제거 — product 값은 PLAN-SUMMARY로만), maintainer playbook/verification. **scaffold PLAN-SUMMARY 템플릿은 이미 Implementation Baseline을 가지므로 신규 생성 변경 최소.**
- DR-034(upgrade ownership)에는 본 정책으로의 cross-pointer만 추가한다.
- 실제 source 전환·cascade·migration 절차 구현은 CHORE-20260624-002에서 수행한다.

## Reversal Cost

Medium. source 문서 재배치이며 feature branch + PR로 revertable하나, scaffold/adopter cascade와 onboarding 안내까지 걸쳐 있어 되돌리려면 동일 cascade를 역으로 풀어야 한다.
