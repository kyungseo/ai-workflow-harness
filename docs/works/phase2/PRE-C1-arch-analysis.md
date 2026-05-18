---
id: PRE-C1
priority: P0
status: Candidate
risk: Low
scope: Phase 1 아키텍처 현황 분석 — 레이어 일관성, common-core, gateway, 테스트 커버리지
appetite: 3d
planned_start:
planned_end:
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

Phase 1 구현 결과를 분석하여 Phase 2 설계의 기반을 마련한다.
코드를 직접 읽고 실제 상태를 파악한다 — 문서 기반 추정 금지.

분석 범위:
- 레이어 일관성 (Controller → Service → Repository 패턴 준수 여부)
- common-core 모듈 구조 및 의존성 방향
- gateway 라우팅 및 필터 체계
- 테스트 커버리지 (단위/통합 비율, 누락 영역)
- 개선 필요 항목 목록화

**Alternatives 검토:**
- 문서만 보고 분석 — 실제 코드와 문서 불일치 가능성 높음, 채택 안 함
- Phase 2 착수 후 분석 병행 — 설계 기반 없이 착수하면 재작업 위험, 채택 안 함

## Done Criteria

- [ ] 레이어 구조 일관성 분석 완료 (위반 항목 목록화)
- [ ] common-core 모듈 의존성 방향 검증
- [ ] gateway 라우팅/필터 현황 정리
- [ ] 테스트 커버리지 현황 파악 (`./gradlew test` 결과 기반)
- [ ] 개선 필요 항목 → `docs/backlog/PHASE2.md` 또는 신규 DR 반영

## Verification

```bash
./gradlew test
./gradlew build
```

분석 결과 문서: `docs/backlog/PHASE2.md` 업데이트 또는 별도 분석 메모 생성

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | 레이어 구조 분석 | Todo |
| 2  | common-core / gateway 분석 | Todo |
| 3  | 테스트 커버리지 분석 | Todo |
| 4  | 결과 → backlog 반영 | Todo |

## Discovery

(착수 후 기록)
