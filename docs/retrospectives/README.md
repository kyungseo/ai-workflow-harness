# Retrospectives

AI Workflow Harness 회고 인덱스.

cascade 감사 시 최신 1개 또는 해당 topic 관련 1개만 참조한다. 전체 목록 스캔은 하지 않는다.
archive 기준: 연관 Work/Phase가 archive되고 insights가 canonical 문서에 반영된 경우 (사용자 승인 후).

공개 전 이전 회고(2026-05-12 ~ 2026-05-22) 전체를 `docs/archive/docs/retrospectives/`로 archive했다. 아카이브 인덱스: [`docs/archive/docs/retrospectives/README.md`](../archive/docs/retrospectives/README.md)

## Frontmatter 스펙 (DR-027)

```yaml
---
date: YYYY-MM-DD
track: harness | product
type: {e.g. session, phase, incident, process, …}
scope: {무엇에 대한 회고인지 한 줄}
author: "agent:{model-name} | human"
related_work: []
---
```

`track`: harness = AI workflow·프로세스 회고 / product = 적용 프로젝트의 기능·개발 회고
`type`: 예시 목록이며 열거형으로 제한하지 않는다.

섹션 구성 최솟값: **결론** (필수) → 내용 (자유) → **Revisit Triggers** (권장) → **연결** (해당 시)

## 인덱스

| 날짜 | 파일 | 주제/Scope | 핵심 결론 |
|------|------|-----------|---------|
| 2026-06-15 | [harness-v1-2-readiness-retrospective-20260615.md](harness-v1-2-readiness-retrospective-20260615.md) | v1.2.0 readiness — W1~W5 완료 후 종합 회고 | 내부 조직 표준화 후보로는 강하나 공개 범용 제품성은 아직 무거움. 다음 병목은 managed upgrade와 happy path 압축 |

> 토론·방향성(brief) 성격의 live 문서는 `docs/briefs/`로 재분류됐다(2026-06-15). 인덱스: [`docs/briefs/README.md`](../briefs/README.md). 이동 대상: harness-identity-policy-first, harness-distribution-plugin-model, harness-internal-managed-upgrade, harness-workflow-engine-vs-manual-first.
