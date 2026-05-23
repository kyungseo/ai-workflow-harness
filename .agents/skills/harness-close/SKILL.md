---
name: "harness-close"
description: "Work Done 처리 전용. Done Criteria 확인, status/actual_end 기입, README Active→Done, STATUS pointer 제거 제안. 세션 종료 없음"
---

# harness-close

Use this skill when the user asks to invoke the harness workflow `close`.

## Command Template

**Work 완료 처리 명령이다. 세션을 종료하지 않는다.**

Work Done 처리가 끝나면 다음 작업을 계속 진행하면 된다.
세션 전체 요약이 필요하면 이후에 `/done`을 실행한다.

## Work Done Processing

**1. 대상 Work 확인**

Active Work가 여러 개면 대상 Work ID를 먼저 확인한다. 하나뿐이면 그대로 진행한다.

**2. Done Criteria 확인**

Work 파일의 Done Criteria를 전부 체크했는지 확인한다.
미충족 항목이 있으면 사용자에게 보고하고 진행 여부를 묻는다.
Done Criteria에 사용자 최종 리뷰, final review, 검토 후 Done 같은 명시적 리뷰 조건이 있으면 해당 리뷰 확인을 완료하기 전 Done 처리하지 않는다.
전역 사용자 리뷰를 모든 Work에 강제하지 않는다.

**3. Work 파일 Done 처리 (Approval Matrix state detail — 사용자 확인 후)**

대상 Work ID를 명시하고 사용자 확인을 받은 뒤:

- Work 파일 frontmatter: `status: Done`, `actual_end: YYYY-MM-DD` 기입
- Done Criteria 항목을 전부 체크 표시로 업데이트

**4. Work Index 업데이트 (Work 파일 상태 변경)**

`docs/works/{category}/README.md`에서 해당 Work를 Active → Done (archive pending) 테이블로 이동한다.

**5. STATUS Active Work pointer 제거 제안 (Approval Matrix state detail)**

대상 Work ID를 명시한 1줄 제안 후 승인을 받은 뒤 `docs/STATUS.md` Active Work 행을 제거한다.

**6. Commit/PR finalization 관계 확인**

`/close`는 Work Done 처리이며 commit/PR finalization gate를 대체하지 않는다.
이미 commit 또는 PR이 필요한 변경이 있으면 commit/PR 전 gate(`/done` 또는 git workflow rule)에서 STATUS Finalization과 Tracking Finalization을 별도로 보고한다.

**[옵션] close 상태 변경을 마지막 작업 커밋에 번들하기**

작업 마지막 커밋 직전이고 사용자가 Done 처리를 확정한 경우, close 상태 변경(Work 파일 Done, Work Index, STATUS pointer 제거)을 별도 커밋 대신 마지막 작업 커밋에 포함할 수 있다.
- 적용 시점: 마지막 작업 커밋 직전 + 사용자가 명시적으로 번들 요청 시
- 기본값: 별도 close 커밋 (작업 커밋 이후 `/close` 실행하는 일반 흐름)

---

## Archive Processing (Optional)

Done 처리 완료 후 아래 질문을 한다:

> 지금 바로 archive하겠습니까? (아니면 다음 `/start`·`/resume` 시 처리)

**사용자가 지금 archive 승인하면:**

1. Work 파일 frontmatter `status: Archived` 기입
2. Discovery에 archive 이유와 일자 기록
3. `git mv docs/works/{category}/{file}.md docs/archive/docs/works/{category}/`
4. `docs/works/{category}/README.md`: Done → Archived 테이블로 이동하고 Work 파일 경로를 `docs/archive/docs/works/{category}/{file}.md`로 업데이트

**사용자가 나중으로 미루면:** 그대로 둔다. `/start`·`/resume`에서 archive 대기로 보고된다.

---

## Completion Report

Done 처리 후 아래 형식으로 보고하고 세션을 계속한다.

```
Work Done 완료: {Work ID}

- 대상 Work: {ID}
- Done 처리: status: Done, actual_end: {날짜}
- Archive: {지금 처리 / 보류}
- STATUS.md: Active Work {ID} pointer 제거 {승인 대기 / 완료}
- Commit/PR Finalization: 별도 gate에서 STATUS/Tracking 확인 {필요 / 해당 없음}
```
