# HARNESS-NAMING-RULES.md

`docs/HARNESS-PROTOCOL.md` §9에서 추출한 Naming Rules policy slice다.
Work ID 부여·검증, OQ/DR ID, 파일명 규칙 확인이 필요할 때만 로드한다.
`/session-start`, `/work-select`, 일반 status 확인, cascade 검증에서는 로드하지 않는다.

---

## Work ID

신규 Work ID 형식:

```
<TYPE>-<YYYYMMDD>-<NNN>
```

| TYPE | 대상 | branch guidance (default) |
| --- | --- | --- |
| `FEAT` | product/user-visible feature work | 프로젝트 통합 branch 기준 `feature/*` |
| `PATCH` | non-emergency correction, release-prep patch | 프로젝트 통합 branch 기준 `feature/*` 또는 `feature/release-prep-*` |
| `HOTFIX` | urgent fix (security, data integrity, service outage) | 프로젝트 release branch 기준 `hotfix/*` (있는 경우) |
| `CHORE` | harness/process/docs/tooling maintenance | 프로젝트 통합 branch 기준 `feature/*` |

> Branch guidance는 harness default다. source repository는 현재 Gitflow(`feature/* → develop → main`)를 사용하지만, scaffold product repository는 project-specific `docs/GIT-WORKFLOW.md`에서 branch/release 정책을 override할 수 있다.

규칙:

- AI는 현재 branch에서 보이는 Work 파일 기준으로 다음 NNN을 제안한다.
- 병렬 branch 병합 시 같은 `<TYPE>-<YYYYMMDD>-<NNN>`이 충돌하면 NNN을 재배정한다. 날짜는 착수/등록일 의미를 보존하므로 변경하지 않는다.
- 이미 리뷰 진행 중이거나 외부 참조가 있는 경우 변경 비용을 보고하고 사용자 승인 후 조정한다.
- `feature/release-prep-*` branch Work: 기본 `CHORE`. non-emergency public release correction이면 `PATCH`. urgent main/release-line fix이면 `HOTFIX`.
- ID를 다른 의미로 재사용하지 않는다.
- scaffold/product repo가 Jira, Linear, GitHub Issues 등 external tracker를 사용하는 경우, project-specific tracker policy가 하네스 기본값보다 우선할 수 있다. 단, Work 파일과 STATUS.md에는 external ID와 harness Work ID 중 어느 것을 SSoT로 쓸지 명시해야 한다 (예: `JIRA-123` → harness Work ID `FEAT-20260601-001`로 매핑하거나 대체).

### NNN 재배정 절차

PR merge 시 같은 `<TYPE>-<YYYYMMDD>-<NNN>`이 충돌하면 아래 순서로 처리한다.

1. merge 대상 branch(`develop` 등)의 `docs/works/` 파일 목록 기준으로 다음 NNN을 결정한다.
2. 외부 참조(PR description, commit body)가 이미 있으면 변경 비용을 보고하고 사용자 승인 후 조정한다.
3. Work 파일명·frontmatter `id`·STATUS pointer·Work index row를 새 NNN으로 일괄 업데이트한다.
4. 날짜(`<YYYYMMDD>`)는 착수/등록일 의미를 보존하므로 변경하지 않는다.

### Branch Naming과 Work ID 확정 순서

권장 순서: **Work ID 확정 → branch 생성** (`feature/<type>-<YYYYMMDD>-<NNN>-<slug>`).

Work ID 확정 전 branch를 먼저 생성해야 하는 경우:
- branch 이름에 임시 slug만 사용하거나(`feature/<type>-<slug>`)
- Work ID 확정 후 branch를 rename한다.
- Branch rename 대신 slug만 유지하는 방식도 허용된다. 이 경우 Work 파일 및 STATUS가 Work ID의 SSoT다.

## Backlog Candidate ID

backlog 후보는 제목/slug만 유지한다. Work 파일 생성(착수 승인) 시 ID를 확정하고 backlog row를 갱신한다. 착수 전 ID 선점은 병렬 branch 충돌 가능성을 높이고 phantom ID를 만드므로 하지 않는다.

## OQ ID

| 범위 | 형식 | 비고 |
| --- | --- | --- |
| Work 파일 내부 | `OQ-1`, `OQ-2` | Work-local numbering |
| 전역 참조 | `<WORK-ID>/OQ-1` | 필요 시에만 |
| STATUS Blockers 또는 DR 승격 | 별도 ID 검토 | Global OQ registry 없음 |

## DR ID

`DR-NNN` 체계를 유지한다. DR은 repository-wide decision record로 Work ID와 다른 lifecycle을 가진다. Work frontmatter `related_dr` 또는 본문 링크로 연결한다.

병렬 branch merge 시 DR 번호가 충돌하면 먼저 merge된 DR이 해당 번호를 유지한다. 나중에 merge되는 DR은 번호를 재배정한다. 외부 참조(PR description, commit body)가 있으면 변경 비용을 보고하고 사용자 승인 후 조정한다.

## Historical ID Prefixes

신규 Work에는 사용하지 않는다.

아래 prefix는 기존 archive/history에 보존되며 rewrite하지 않는다. 신규 Work는 위 Work ID 형식을 사용한다.

| Prefix | 과거 의미 |
| --- | --- |
| `HRN-*` | Harness hardening |
| `HRF-*` | Harness refactor |
| `PRE-*` | Phase entry prerequisite |
| `DOC-*` | Documentation task |
| `P{n}-NNN` | Phase Product track backlog |

## File Naming

| Location | Rule | Example |
| --- | --- | --- |
| `docs/` root | UPPERCASE-HYPHENATED | `HARNESS-PROTOCOL.md` |
| `docs/backlog/` | UPPERCASE-HYPHENATED | `PHASE2.md` |
| `docs/decisions/` | `DR-{NNN}-{topic}.md` | `DR-013-work-file-spec.md` |
| `docs/works/{category}/` | `{ID}-{lowercase-topic}.md` | `CHORE-20260527-001-id-tracker-rule.md` |
| `docs/archive/docs/` | 원본 상대 경로와 파일명 mirror | `docs/archive/docs/WORKFLOW-MANUAL-ai-workflow-v1.0.0.md` |
| `docs/archive/snapshots/` | `{topic}-{YYYYMMDD}` | `harness-refactor-20260514/` |
| `docs/retrospectives/` | `{topic}-{YYYYMMDD}.md` | `ai-workflow-complexity-review-20260518.md` |
| `docs/presentations/` | artifact/deck version naming | `harness-v1-team-intro-v1.1.pptx` |

기존 media asset은 의미 보존을 우선한다. 신규 media 파일은 가능하면 lowercase-hyphenated를 사용하되, 사용자 표시명이나 외부 산출물 이름을 보존해야 하면 예외로 둔다.
