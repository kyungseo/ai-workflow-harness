# record-decision

Canonical workflow procedure for `/record-decision`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/record-decision.md` |
| Codex | `.agents/skills/workflow-record-decision/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

$ARGUMENTS 또는 현재 대화에서 다룬 결정·질문을 DR로 기록해줘.

Product decision(ORM 선택, API 설계 방향, 외부 서비스 연동 정책, 데이터 모델 결정 등)과 harness/workflow decision(명령 개명, 게이트 정책, 프로토콜 변경 등) 모두 이 절차로 기록한다. track과 무관하게 DR-worthy 기준을 충족하면 등록한다.

**0. Registration Triage (DR-029).** 기록 전 입력의 성숙도를 먼저 분기해 제안해. DR-worthy 판정은 아래 §DR-Worthy Criteria를 재사용한다(재서술하지 않는다).

| 입력 성격 | 목적지 |
| --- | --- |
| DR-worthy + 결정 완료 | Accepted DR — 아래 1~7 진행 |
| DR-worthy + 선택 보류(signal·data·논의 대기) | Draft DR — Status: Draft, 아래 §Draft DR 참조 |
| non-DR-worthy + 운영·근시일·blocking | STATUS `Blockers And Open Questions` |
| non-DR-worthy + 전략·roadmap horizon | PLAN `§9 Open Questions` |
| non-DR-worthy + 실행 후보 작업 | backlog (`PRODUCT.md` / `HARNESS.md`) |

DR(Accepted 또는 Draft)로 분기된 경우에만 아래 단계를 진행한다.

1. `docs/decisions/` 디렉토리의 기존 DR 목록을 확인하고 다음 번호를 결정해.
   - 병렬 branch 환경: Accepted 처리 또는 PR merge 직전에 `docs/decisions/` 목록을 재확인해. 번호 충돌이 발견되면 나중에 merge되는 DR이 번호를 재배정하고, DR 파일명·문서 내부 DR 번호/상태 표기·연결 Work/backlog reference를 새 번호로 업데이트해 (docs/HARNESS-PARALLEL-WORK-CONTROLS.md §DR Global Sequence 충돌 해소).
2. 이번 대화에서 결정된 내용을 아래 형식으로 요약해:
   - 결정 제목과 DR 번호
   - Track (harness | product)
   - 검토한 선택지
   - 채택 이유
   - 되돌리기 비용 (Low / Medium / High)
3. `docs/decisions/DR-{번호}-{topic}.md` 초안을 제시해.
   - DR 파일은 DR-007 Bilingual Rules 적용 대상이다. 섹션 타이틀은 영문 Title Case를 유지한다.
4. 승인 후 파일을 생성해.
5. Accepted DR마다 `docs/STATUS.md`의 Recent Decisions 업데이트 필요 여부를 반드시 판정해.
   - 필요하면 Approval Matrix의 고영향 상태 변경으로 보고하고 `STATUS Update Proposal`로 별도 제안해.
   - 불필요하면 이유를 closeout 또는 commit 전 summary에 명시해.
   - 후속 행동을 바꾸는 운영/기술 판단만 포함해. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둬.
   - 최근 8개 rolling window를 유지해. 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인해.
6. PLAN/HARNESS-ARCHITECTURE/HARNESS-MAINTAINER-GUIDE/backlog cascade 대상이 있는지 확인하고 제안해. (HARNESS-ARCHITECTURE·HARNESS-MAINTAINER-GUIDE는 optional pack — minimal scaffold에 없으면 해당 대상 N/A.)

7. **PLAN impact 확인 (T5 — recommended/warning soft):** 이 DR이 `docs/PLAN.md`의 roadmap/milestone 방향에 영향을 주는지 판단한다. 영향 있으면 PLAN 갱신/후속 작업을 Approval Matrix proposal로 제안하고, 없으면 "PLAN 영향 없음" 1줄 보고. PLAN 작성 완료를 DR 등록의 hard-stop으로 강제하지 않는다(recommended/warning). PLAN lifecycle/drain 규칙이 있으면 `docs/PLAN.md`의 Roadmap Lifecycle 규칙을 따른다. PLAN 변경이 있으면 `docs/PLAN-SUMMARY.md` stale 여부도 함께 판정한다.

승인 없이 파일을 생성하지 마.
승인 없이 STATUS.md를 수정하지 마.

STATUS Update Proposal에는 아래 항목을 포함해줘.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.

## DR Lifecycle

DR 상태는 아래 값만 사용한다. `DECISION-TEMPLATE.md`의 Status 필드 가이드와 일치한다.

| 상태 | 의미 | 처리 |
|---|---|---|
| `Draft` | 초안. 아직 확정 전(선택 보류). | PR merge 전까지 유지 가능. cascade·PLAN 미발동. §Draft DR 참조 |
| `Draft (Dropped)` | 채택하지 않기로 한 Draft. | 폐기 사유 1줄 명시 후 `docs/archive/docs/decisions/`로 이동. 번호 retire(재사용 금지, gap 허용) |
| `Accepted` | 최종 확정. | — |
| `Accepted (Amended)` | 결정 방향은 유지, 세부 사항 수정됨. | 수정 범위를 DR 본문 또는 amending DR 번호로 명시 |
| `Superseded by DR-XXX` | 이 결정 전체가 다른 DR로 대체됨. | `docs/archive/docs/decisions/`로 이동 후보. archive는 사용자 승인 후 처리. |
| `Accepted (partial Superseded by DR-XXX)` | 일부 항목만 대체됨. | 대체된 범위를 본문에 명시. 나머지는 유효. |

**Parent-child DR:** 하위 DR은 `Supersedes: DR-XXX` 필드로 상위 DR을 가리킨다 (예: DR-NNN → DR-MMM).
**Linked DR:** 상호 참조이며 상하위 관계 아님. `Linked DRs:` 필드로 표현.
**Superseded DR archive 타이밍:** PR merge 후 T10(Done Work 발견) 또는 `/session-start` 에서 제안. `docs/archive/docs/decisions/README.md` index에 이동 경로 기록.

## Draft DR (DR-029)

DR-worthy이나 결정을 보류한 경우 `Status: Draft`로 기록한다.

**필수 섹션:** `Question`, `Options Considered`, `Open Points`(미해소 쟁점), `Promotion Conditions`(무엇이 충족되면 Accepted로 승격하는가). `Decision` / `Rationale` / `Consequences`는 승격 시 작성한다(그 전까지 빈 칸).

**승격 (Draft → Accepted):**

1. `Promotion Conditions` 충족 확인, `Open Points` 해소
2. `Decision` / `Rationale` / `Consequences` 작성, Status를 `Accepted`로 변경
3. Recent Decisions 등재 판정 발동(위 Procedure step 5)
4. Draft 동안 보류됐던 PLAN cascade 발동(위 "DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다")
5. 필요 시 관련 DR amend 연결

**폐기 (Dropped):** 결정하지 않기로 하면 Status를 `Draft (Dropped)`로 바꾸고 폐기 사유 1줄을 본문에 남긴 뒤 archive로 이동한다(사용자 승인 후). 번호는 retire한다(재사용 금지).

**누적 관리:** Draft DR 가시성은 `/repo-health`의 soft surfacing이 담당한다(hard gate 아님). cascade 감사는 Accepted-only이며 Draft 내용은 감사·강제 대상이 아니다.

## DR-Worthy Criteria (if one or more applies)

**Product decision 예시 (포함):**
- 데이터베이스·ORM 선택 (PostgreSQL vs MySQL, Prisma vs TypeORM)
- API 설계 방향 (REST vs GraphQL, 버전 관리 전략)
- 외부 서비스 연동 정책 (인증 provider, 결제 게이트웨이)
- 데이터 모델 구조 결정 (단일 테이블 상속 vs 별도 테이블)
- 배포 전략 (blue-green, canary, rolling)

**Harness/workflow decision 예시 (포함):**
- 도구·프레임워크 선택 (예: Checkstyle vs Spotless, Helm vs Kustomize)
- 아키텍처 경계·정책 결정 (예: CI job 분리, 파일 헤더 없음 정책)

**공통 기준:**
- 되돌리기 비용 Medium 이상
- 두 개 이상 컴포넌트 또는 개발자에 영향

## DR Not Required
- 구현 세부사항, 버그 수정, 마이너 config 조정
