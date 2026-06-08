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
| 2026-05-24 | [harness-pre-public-review-claude-20260524.md](harness-pre-public-review-claude-20260524.md) | 공개 전 최종 리뷰 | tool surface 4방향 정렬 완료, scaffold 실행 검증 후 공개 준비 완료 |
| 2026-05-24 | [harness-pre-public-review-codex-20260524.md](harness-pre-public-review-codex-20260524.md) | 공개 전 Codex 최종 리뷰 | scaffold 검증 통과, `harness-*` skill 체계 적합, fresh Codex 세션 trigger 확인만 남음 |
| 2026-06-06 | [harness-workflow-strictness-20260606.md](harness-workflow-strictness-20260606.md) | source repo workflow 엄격성 평가 | solo 관례 대비 엄격하나 이 repo엔 정합·저비용(과설계 아님), finalization gate의 standalone tracking-only 처리 1곳은 보정 가치 |
| 2026-06-08 | [harness-identity-policy-first-20260608.md](harness-identity-policy-first-20260608.md) | harness 정체성 — policy-first 방향성, orchestration 확장 범위 | workflow engine 아닌 policy document 시스템. orchestration 정책 정의는 harness 역할, 메커니즘 구현은 도구 역할. 기업 확장도 동일 경계 유지 |
| 2026-06-08 | [harness-distribution-plugin-model-20260608.md](harness-distribution-plugin-model-20260608.md) | scaffold 배포·업그레이드 방식 한계와 plugin 모델 전환 가능성 | plugin 전환 타당하나 지금은 시기상조. 핵심 병목은 upgrade/migration 로직. shell에서 먼저 구현 후 npm wrapping 검토 순서 |
