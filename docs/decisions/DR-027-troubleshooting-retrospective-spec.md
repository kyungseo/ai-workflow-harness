# DR-027: Troubleshooting / Retrospective 파일 최소 스펙

Date: 2026-06-07
Status: Accepted
Track: harness

## Question

troubleshooting과 retrospective 파일이 무엇에 관한 기록인지 — track(harness vs product), 분류, 상태 — 를 문서 열람 없이 알 수 없다. 최소한의 frontmatter 스펙을 정형화해야 하는가?

## Decision

두 문서 유형에 YAML frontmatter를 도입한다. Work 파일(DR-013)만큼 무겁지 않지만, 분류와 상태를 인덱스 없이도 파악할 수 있도록 최솟값을 정한다.

`track` 필드는 Decision Record 인덱스와 동일한 축(`harness | product`)을 사용하여 AI workflow 관련 기록과 적용 프로젝트 기록을 구분한다.

`category`(troubleshooting)와 `type`(retrospectives)은 예시 목록을 제공하되 열거형으로 제한하지 않는다. 다양한 프로젝트와 상황에 맞게 자유 기입을 허용한다.

### Troubleshooting Frontmatter

```yaml
---
symptom: {한 줄 증상}
track: harness | product
category: {e.g. workflow, scaffold, command, git, tool, feature, api, data, infra, …}
environment: {e.g. Claude Code, Codex, Antigravity, Cursor, 공통, 기타}
status: Resolved | Unresolved | Workaround
related_dr: []
---
```

섹션 구성(기존): 증상 → 원인 → 조치 → 검증 → 변경 내역 → 관련 문서

### Retrospectives Frontmatter

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

섹션 구성 최솟값:
- **결론** (필수)
- 내용 (자유 형식)
- **Revisit Triggers** (권장)
- **연결** (해당 시)

## Consequences

- `docs/troubleshooting/README.md`와 `docs/retrospectives/README.md`에 frontmatter 스펙 추가
- 기존 파일에 frontmatter 소급 적용
- `docs/HARNESS-PROTOCOL.md` T8 — DR-027 스펙 참조 추가
- `docs/HARNESS-PROTOCOL.md` — T8b(retrospective 기록 trigger) 신규 추가
- AI tool 정렬: HARNESS-PROTOCOL Document Role Distinction과 Update Rules에 DR-027 명시

## Rationale

Work 파일(DR-013), Decision Record, 기타 문서는 모두 분류 메타데이터를 가지고 있으나 troubleshooting과 retrospective만 자유 형식이었다. `track` 필드 없이는 harness 이슈인지 product 이슈인지 파일을 열어야만 알 수 있다. 단일 harness repository에서는 문제가 없었으나, `scripts/create-harness.sh`로 적용된 프로젝트에서 두 트랙이 공존하면 인덱스만으로 구분이 불가능하다.

`category`와 `type`을 열거형으로 제한하지 않는 이유: 적용 프로젝트마다 도메인이 다르고, harness 내부도 시간이 지남에 따라 새 분류가 생길 수 있다. 예시 목록은 공통 패턴을 안내하는 용도로만 둔다.

## Reversal Cost

Low — frontmatter 제거는 기계적으로 처리 가능. 기존 인덱스 테이블 구조는 변경 없음.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| frontmatter 도입 (채택) | 파일 열람 없이 track/분류/상태 파악, 인덱스 자동화 가능 | 기존 파일 소급 적용 필요 |
| README 인덱스 컬럼 확장만 | 파일 미수정 | 파일 내부와 인덱스 이중 관리, 인덱스 누락 시 정보 소실 |
| 현행 유지 | 변경 없음 | product track 도입 시 두 트랙 혼재로 분류 불가 |
