---
name: write-migration
description: PostgreSQL 스키마 변경 마이그레이션 작성 (롤백 포함)
agent: agent
id: write-migration.v1
purpose: 현재 스키마(01-schema.sql)를 기반으로 안전한 DDL 마이그레이션을 작성하고 롤백 절차를 명시하기 위한 프롬프트
portability: base-msa-template
difficulty: intermediate
inputs:
  - table_name
  - change_description
output_contract:
  - 계획
  - DDL
  - 롤백
  - 리스크
---


`{{table_name}}` 테이블에 대한 스키마 변경 마이그레이션을 작성해 줘.

변경 내용: {{change_description}}

작업 순서:

1. `infra/docker/init-sql/01-schema.sql`에서 `{{table_name}}` 현재 스키마 확인
2. `infra/docker/init-sql/02-data.sql`에서 기존 초기 데이터 영향 여부 확인
3. 마이그레이션 DDL 작성 (PostgreSQL 16 방언 기준)
4. 롤백 DDL 작성 (적용 전 상태로 복원)
5. 기존 데이터 호환성 검토 (NOT NULL 추가 시 DEFAULT 필요 여부 등)

규칙:

- `ALTER TABLE`은 트랜잭션 안에서 실행 가능한 DDL만 사용.
- `NOT NULL` 컬럼 추가 시 반드시 `DEFAULT` 또는 `UPDATE` 선행 단계 포함.
- 인덱스 추가는 `CREATE INDEX CONCURRENTLY` 사용 (락 최소화).
- Phase 1은 공유 DB이므로 다른 서비스에서 같은 테이블을 참조하는지 확인.

출력 형식:

1. 현재 스키마 (관련 부분)
2. 마이그레이션 DDL (Up)
3. 롤백 DDL (Down)
4. 데이터 호환성 검토 결과
5. 리스크와 적용 순서
