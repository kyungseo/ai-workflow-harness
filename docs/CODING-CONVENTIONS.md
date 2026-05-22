# CODING-CONVENTIONS.md - AI Workflow Harness

> 이 문서는 AI Workflow Harness repository의 documentation, prompt, and script convention이다.
> Programming-language-specific convention은 core harness가 아닌 optional example pack에 위치한다.

---

## 1. Language Policy

DR-007을 따른다.

- Commit type prefix는 English.
- Commit subject/body는 Korean primary, technical term은 English 허용.
- Entry instruction과 tool rule은 instruction 준수에 유리한 경우 English를 사용할 수 있다.
- User-facing Korean 문서는 section 이름과 technical term을 English로 유지한다.

## 2. Documentation Style

- 공유 규칙은 entrypoint에 중복하지 않고 canonical docs에 둔다.
- `AGENTS.md`와 `CLAUDE.md`는 얇게 유지한다.
- `docs/STATUS.md`는 dashboard 전용으로 사용한다.
- 작업 세부사항, checkpoint, discovery는 Work 파일에 기록한다.
- 명시적으로 요청받지 않는 한 historical snapshot을 재작성하지 않는다.
- live 문서가 변경되면 quick reference, manual, prompt, rule, scaffold surface의 정렬이 필요한지 확인한다.

## 3. Work File Convention

Work 파일은 `docs/works/{category}/` 아래에 위치한다.

필수 frontmatter:

```yaml
---
id:
priority:
status:
risk:
scope:
appetite:
planned_start:
planned_end:
actual_end:
---
```

필수 섹션:

- Context
- Plan
- Done Criteria
- Checkpoints
- Discovery

## 4. Prompt Convention

Task prompt frontmatter에 포함해야 하는 key:

- `id`
- `purpose`
- `portability`
- `difficulty`
- `inputs`
- `output_contract`

Generic prompt는 특정 framework를 가정하지 않는다. Stack-specific prompt는
`prompts/README.md`에서 optional/example content로 명시해야 한다.

## 5. Shell Script Convention

- bash script는 `bash -n` 검증을 수행한다.
- 실용적인 범위에서 idempotent하게 작성한다.
- scaffold 또는 filesystem을 변경하는 script는 dry-run을 지원하는 것을 권장한다.
- secret이나 local machine-specific path를 embed하지 않는다.
- scaffold 생성 후 다음으로 필요한 manual step을 출력한다.

## 6. Markdown Hygiene

- repository 문서에는 relative link를 사용한다.
- table은 간결하고 한눈에 파악할 수 있게 유지한다.
- command에는 fenced code block을 사용한다.
- 복잡한 state 또는 flow diagram에는 Mermaid를 사용한다.
- commit 전 `git diff --check`를 실행한다.

## 7. Tool Surface Alignment

workflow 동작을 변경할 때 다음 surface를 확인한다:

- canonical docs
- Claude commands/rules
- Cursor rules
- Codex entrypoint/prompt
- user-facing manual/README
- scaffold output

변경된 동작의 live mirror에 해당하는 surface만 업데이트한다. 모든 surface를 일괄 수정하지 않는다.
