# DR-042: Adopter/Product DR Namespace Allocation

Date: 2026-06-21
Status: Accepted
Track: harness
Linked DRs: DR-008, DR-034

<!-- Accepted 2026-06-21 (CHORE-20260621-004 Slice A, owner sign-off). ai-deck real-apply rehearsal(CHORE-003)에서 발견된 adopter product DR vs framework DR 번호 충돌을 닫는 정책. owner 조정: product band 800-999(200슬롯), 별도 reserved 제거. -->

## Question

adopter/product-local decision record(DR)와 framework/source DR이 같은 `DR-NNN` 번호 공간을 공유해 충돌한다. adopter가 product DR을 framework와 같은 저번호 대역에서 발급하면, framework가 그 번호를 (다른 의미로) 쓰거나 scaffold가 그 번호의 framework DR을 ship할 때 파일/참조가 충돌한다. 어떻게 namespace를 분리하는가?

## Context

`ai-deck-compiler` real-apply rehearsal(CHORE-20260621-003)에서 실측됐다:

- adopter product DR `DR-014`(PPT 언어정책)가 framework `DR-014`(archive 정책, scaffold seed)와 **파일·번호 충돌**. real apply 시 `docs/decisions/`에 같은 `DR-014` 둘이 공존.
- product `DR-021`/`DR-022`/`DR-023`도 framework `DR-021`(boundary)/`DR-022`(PLAN lifecycle)/`DR-023`(adapter)와 번호 공간 충돌(현재는 framework seed에 미포함이라 잠복, 확대 시 터짐).
- 모든 harness 검사(`check-scaffold-invariants.sh`, `check-shipped-dr-closure.sh`, `docs/maintainer/VERIFICATION-COMMANDS.md`)는 `DR-[0-9]{3}` regex와 `docs/decisions/DR-*.md` 파일명을 전제한다. 이 regex는 boundary-less라 `PDR-014`를 내부 `DR-014`로, `DR-1000`을 `DR-100`으로 오인식한다(실측).

## Decision

1. **Band allocation.**
   - framework/source DR: `DR-001` ~ `DR-799`
   - product/adopter-local DR: `DR-800` ~ `DR-999` (200개 슬롯)
   - 별도 reserved 대역은 두지 않는다(800–999 전체를 product-local에 할당).
2. **정확히 3자리 `DR-NNN`만 허용.** `DR-[0-9]{3}` 도구가 boundary-less이므로 `PDR-` prefix(내부 `DR-NNN` 오인식)와 4자리 `DR-NNNN`(truncate)는 **현행 도구와 비호환이라 비범위**다. `DR-1000` 이상 4자리 확장과 `PDR-` 같은 prefix namespace는 `check-scaffold-invariants`/`check-shipped-dr-closure`/`VERIFICATION-COMMANDS`/template·index rule을 함께 바꾸는 **별도 namespace expansion Work**에서만 도입한다. product-local이 `DR-950`에 도달하거나 200개를 초과해 800번대가 부족해지면 그 expansion Work를 연다.
3. **SSoT = `docs/HARNESS-NAMING-RULES.md` §DR ID.** ID 발급 규칙은 그 문서가 단일 출처다. 이 정책은 그 §를 갱신한다.
4. **도구 무변경.** `DR-800`~`DR-999`는 3자리라 기존 `DR-[0-9]{3}` 도구가 그대로 인식한다(실측: regex truncate 없음, 숫자 상한 가정 없음). 추가 도구 작업 없이 단기 적용 가능하다.

## Options Considered

| Option | 장점 | 단점 | Draft 판단 |
| --- | --- | --- | --- |
| A. high-band(`DR-800~999`, 200슬롯) | 기존 `DR-[0-9]{3}` 도구 무변경, 즉시 적용, framework와 영구 분리 | 의미가 prefix만큼 선명하진 않음, 4자리 확장은 별도 Work | **Draft 채택** |
| B. `PDR-` prefix namespace | 의미 선명 | 현행 regex가 `PDR-014`를 `DR-014`로 오인식, 모든 검사·template·index cascade 선행 필요 | 장기 후보(별도 Work) |
| C. band-aid renumber(`DR-024` 등) | 즉시 | 다음 framework 확대 시 재충돌(021/022/023 미해결) | 채택 안 함 |
| D. per-repo 완전 분리 schema | 강함 | 과설계, 도구·schema 대공사 | 채택 안 함 |

## Consequences

- adopter/product repo는 product-local DR을 `DR-800`~`DR-999`(200슬롯)에서 발급한다. framework DR(`DR-001`~`DR-799`)과 번호가 겹치지 않는다.
- 기존 adopter(ai-deck 등)의 저번호 product DR은 정책 적용 시 high-band로 renumber해야 한다(참조 cascade 비용 — 별도 실행 Slice).
- harness 검사 도구는 변경 없음. `PDR-`/4자리는 명시적으로 금지되어 검사 blind spot(`PDR-014`=`DR-014` 오인식)을 막는다.
- 이 정책 자체(DR-042)는 maintainer/source-facing 결정이며 scaffold seed에 추가하지 않는다. allocation 규칙은 `HARNESS-NAMING-RULES.md`가 self-describe하므로 adopter는 shipped 문서만으로 product DR 대역을 안다(shipped-DR-closure 준수).

## Policy Horizon / Deferred Successor

<!-- Amendment 2026-06-22 (CHORE-20260622-001 / brief dr-namespace-redesign-20260622). high-band 결정은 유지하고, 정책 수명과 후속 후보만 명시. -->

high-band 결정은 그대로 유지한다. 아래는 그 결정의 수명과 후속 방향을 명시하는 보강이며, 본 정책을 영구 최적해로 못박지 않기 위한 것이다.

- **High-band는 1.x 단기/현실 비용 최적화 정책**이다. 현재 adopter 수·도구 blast radius·기존 high-band 작업(ai-deck)의 매몰 비용을 고려한 선택이며, 영구 최적 namespace 구조 주장이 아니다.
- **product-only prefix(framework=`DR-`, product=`PDR-`)는 rejected가 아니라 deferred successor option**이다. directory namespace도 successor 후보로 보존한다. Options Considered의 B(`PDR-`)는 "현행 도구 비호환"으로 보류된 것이지 방향이 부정된 것이 아니다.
- **재검토 trigger:** product DR friction이 반복되거나, adopter 수가 늘거나, product DR이 일정 수 이상 누적되면 successor 전환(token-grammar spike)을 재검토한다.
- **전환 방식 전제:** prefix 전환을 열 경우 regex snippet 단발 수정이 아니라 **fixture-driven token-grammar spike**로 진행한다. 특히 `PDR-001` 내부의 `DR-001`을 오인식하지 않는 boundary fixture가 **선행**되어야 한다(현행 `DR-[0-9]{3}` 검사의 알려진 blind spot).
- **`--check` product tracking은 이번 결정에서 제외(Deferred).** product/project-owned decision surface를 `--check`가 보고할지는 namespace 결정과 분리된 별도 기능 결정이며, 본 amendment 범위가 아니다.

## Reversal Cost

Low — convention 추가이고 도구 변경이 없어 정책 자체는 되돌리기 쉽다. 다만 적용 후 adopter product DR을 renumber하면 그 repo의 참조 cascade 되돌림 비용이 생긴다.

## Linked Work

- CHORE-20260621-004
- CHORE-20260621-003
- CHORE-20260622-001 (high-band 유지 결정 + Policy Horizon amendment)
