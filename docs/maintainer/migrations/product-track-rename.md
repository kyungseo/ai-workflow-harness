# Product Track Rename Migration (PHASE{n} → PRODUCT)

이 문서는 product track backlog/work 네이밍 전환(DR-031, CHORE-20260609-005)을 적용한 source repo 변경을 이미 scaffold된 target repo가 수용할 때 참고하는 migration note다. source-only maintainer 문서이며 scaffold 대상이 아니다.

## Summary

- product track을 harness track과 **대칭**으로 전환했다: `docs/backlog/PHASE{n}.md` → `docs/backlog/PRODUCT.md`, `docs/works/phase{n}/` → `docs/works/product/`.
- phase는 **optional**이다. 단계 운영이 필요한 프로젝트만 backlog를 분할한다(`PRODUCT.md` 단독 OR `PRODUCT-P1.md`부터 연번).
- harness 내부 "Phase"(STATUS `Current phase`, 명령 절차 단계, 리팩토링 milestone)는 **변경하지 않는다.** 이 전환은 product backlog/work 네이밍에만 적용된다.
- canonical/tooling은 phasing-agnostic(glob `PRODUCT*.md`, "단계 시 `PRODUCT-P{n}`")으로 작성되어, 단계 도입 후에도 framework surface는 무수정 동작한다.

## Path Mapping

| Old (target에 존재) | New |
| --- | --- |
| `docs/backlog/PHASE1.md` (단일) | `docs/backlog/PRODUCT.md` |
| `docs/backlog/PHASE{n}.md` (다단계 유지 희망) | `docs/backlog/PRODUCT-P{n}.md` |
| `docs/works/phase{n}/` (전체) | `docs/works/product/` (단일로 통합) |

> Work 파일은 date-based Work ID(`<TYPE>-<YYYYMMDD>-<NNN>`)라 phase에 종속되지 않는다. 여러 `phase{n}/` 디렉토리의 Work 파일을 단일 `product/`로 합쳐도 ID 충돌이 없다(`PRE-*`, `P{n}-*` historical ID 동일).

## Manifest Note

`docs/backlog/*.md`와 `docs/works/*/README.md`는 scaffold가 `write_text`로 생성하는 **project-state(B-class)** 파일이라 `.harness/manifest.json`에 추적되지 않는다. 따라서 `create-harness.sh --check <target>`는 이 rename을 자동으로 감지하지 못한다. **아래 체크리스트로 수동 수행해야 한다.**

## Target Migration Checklist

1. **backlog 파일 rename**
   - 단일 운영: `git mv docs/backlog/PHASE1.md docs/backlog/PRODUCT.md`
   - 단계 유지: `git mv docs/backlog/PHASE{n}.md docs/backlog/PRODUCT-P{n}.md` (n별)
2. **work 디렉토리 통합**: `git mv docs/works/phase{n}/<file> docs/works/product/` (디렉토리 합치고 `docs/works/product/README.md`로 인덱스 통합). 빈 `phase{n}/` 제거.
3. **inbound 참조 갱신** — `rg 'backlog/PHASE|works/phase|PHASE\{n\}|PHASE[0-9]'` 결과를 새 경로로 치환:
   - `docs/STATUS.md` (Current State 포인터, Active Work 행)
   - `docs/works/*/README.md`, 각 Work 파일 Discovery
   - `docs/decisions/*.md` `Linked Backlog Items`
   - `docs/PLAN-SUMMARY.md`, `docs/PLAN.md`, target prompts/docs
4. **framework surface 갱신** — canonical(`skills/workflow/*`)·adapter(`.claude/commands/`, `.agents/skills/`, `.cursor/rules/`)·rule을 source 최신으로 교체한다. 이들은 이미 `PRODUCT.md`/glob을 phasing-agnostic으로 참조하므로 단계 운영 여부와 무관하게 동작한다.
5. **harness "Phase" 보존 확인** — STATUS `Current phase`(descriptive optional 라벨 — DR-032), 명령 절차 "Phase 1-6", 리팩토링 milestone은 그대로 둔다. 오변경하지 않는다.
6. **archive 미수정** — `docs/archive/**`의 과거 `PHASE{n}` 참조는 historical snapshot이므로 재작성하지 않는다(DR-014 immutability).
7. **검증**: `rg --hidden --glob='!docs/archive/**' 'PHASE\{n\}|PHASE[0-9]|backlog/PHASE|works/phase'` 결과가 전환을 설명하는 의도적 참조(예: 본 migration 기록)만 남는지 확인한다.

## Customized Target Note

target은 workflow surface 외에 product-specific 자산을 가질 수 있다. migration은 scaffold 재적용이 아니라 selective migration으로 수행한다.

- product backlog 데이터(`PHASE1.md`의 후보 항목)는 보존하며 파일만 rename한다.
- target이 의도적으로 phase 운영 중이면 `PRODUCT-P{n}.md`로 rename하고, 그렇지 않으면 단일 `PRODUCT.md`로 합친다.
- 단계 도입/해제는 DR-031의 Optional Phasing Migration Checklist를 따른다.
