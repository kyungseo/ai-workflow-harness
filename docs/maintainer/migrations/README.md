# Migrations

source repo의 framework surface 변경을 이미 scaffold된 target repo가 수용할 때 참고하는 migration note 인덱스다. 모두 source-only maintainer 문서이며 scaffold 대상이 아니다.

파일명: lowercase-hyphenated (`{topic}.md`).

| Topic | 파일 | 대상 변경 |
| --- | --- | --- |
| Canonical Adapter / Command Rename | `canonical-adapter-rename.md` | canonical workflow 전환 + no-alias command rename (CHORE-20260606-001) |
| Manifest Check Baseline | `manifest-check-baseline.md` | pre-manifest target이 `.harness/manifest.json` / `--check` baseline을 수용하는 절차 |
| Product Track Rename | `product-track-rename.md` | `PHASE{n}` → `PRODUCT` 대칭 전환 (DR-031, CHORE-20260609-005) |
