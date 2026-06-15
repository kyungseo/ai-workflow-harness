# Briefs

AI Workflow Harness 방향·비교·포지션 문서 인덱스.

`docs/briefs/`는 "무슨 일이 있었고 무엇을 배웠는가"를 남기는 회고가 아니라,
**옵션 비교, 경계 정리, 전략 방향, 현재 포지션**을 정리하는 문서를 둔다.
Accepted 결정 자체는 `docs/decisions/DR-*.md`가 맡고, 세션/Phase/incident 회고는 `docs/retrospectives/`가 맡는다.

cascade 감사나 planning 참고 시에는 최신 1개 또는 관련 topic 1개만 선택적으로 확인한다. 전체 목록 스캔은 하지 않는다.

## 분류 기준

| 문서 유형 | 위치 | 질문 |
| --- | --- | --- |
| Brief | `docs/briefs/` | "지금 어떤 방향/포지션/옵션 비교가 더 타당한가?" |
| Retrospective | `docs/retrospectives/` | "최근 실제로 무엇이 있었고, 무엇을 배웠는가?" |
| Decision Record | `docs/decisions/DR-*.md` | "어떤 결정을 채택했고, 왜이며, 되돌리기 비용은 무엇인가?" |

## Frontmatter 스펙

```yaml
---
date: YYYY-MM-DD
track: harness | product
type: {e.g. strategy, comparison, position, evaluation, process, …}
scope: {무엇에 대한 brief인지 한 줄}
author: "agent:{model-name} | human"
related_work: []
---
```

`track`: harness = AI workflow·프로세스 방향 문서 / product = 적용 프로젝트의 방향·비교 문서
`type`: 예시 목록이며 열거형으로 제한하지 않는다.

섹션 구성 최솟값: **결론** (필수) → **질문/배경** → **비교·분석** → **Revisit Triggers** (권장) → **연결** (해당 시)

## 인덱스

| 날짜 | 파일 | 주제/Scope | 핵심 결론 |
|------|------|-----------|---------|
| 2026-06-08 | [harness-identity-policy-first-20260608.md](harness-identity-policy-first-20260608.md) | harness 정체성 — policy-first 방향성, orchestration 확장 범위 | harness의 본질은 인프라가 아니라 policy layer. orchestration 메커니즘은 도구가 소유하고 harness는 승인·경계·거버넌스를 소유 |
| 2026-06-08 | [harness-distribution-plugin-model-20260608.md](harness-distribution-plugin-model-20260608.md) | scaffold 배포·업그레이드 방식 한계와 plugin 모델 전환 가능성 | plugin 전환 타당성은 있으나 현재 병목은 배포 방식이 아니라 upgrade/migration 로직 자체 |
| 2026-06-15 | [harness-internal-managed-upgrade-20260615.md](harness-internal-managed-upgrade-20260615.md) | 내부 조직 표준 하네스 운영을 위한 PR 기반 중앙 upgrade 관리 방향성 | internal managed mode는 유망한 가설이나 first walkthrough 전 비교 우위는 미검증. direct push가 아니라 PR 기반 중앙 관리가 전제 |
| 2026-06-15 | [harness-workflow-engine-vs-manual-first-20260615.md](harness-workflow-engine-vs-manual-first-20260615.md) | workflow engine vs. manual-first(policy-document) harness 특성·장단 비교와 좌표 | binary가 아닌 spectrum(강제 강도 × 운영 무게). 다만 적용 층위(source/default scaffold/source-gitflow)를 분리해 읽어야 하며 engine은 slice별 하위 메커니즘으로 결합될 수 있음 |
| 2026-06-16 | [harness-sub-agent-concurrency-and-multi-user-tracking-20260616.md](harness-sub-agent-concurrency-and-multi-user-tracking-20260616.md) | sub-agent 병렬 실행과 scaffold target multi-user 운영에서 tracking truth와 finalization ownership을 어떻게 나눌지 | 병렬 실행은 허용 가능하지만 tracking surface와 finalization은 기본적으로 단일 writer + 직렬 확정이 맞다. 핵심 문제는 동시성 자체보다 shared mutable tracking ownership이다 |
