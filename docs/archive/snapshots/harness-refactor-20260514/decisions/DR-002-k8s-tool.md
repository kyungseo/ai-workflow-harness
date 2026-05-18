# DR-002: K8s 배포 도구 선택 — Helm vs Kustomize

Date: 2026-05-11
Status: Draft

## Question

`infra/k8s/` 매니페스트를 Helm chart 방식으로 관리할 것인가, Kustomize overlay 방식으로 관리할 것인가?

## Decision

(결정 후 작성)

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| **Kustomize** | `kubectl` 내장, YAML 그대로 유지, `base/overlays` 구조 단순, 학습 곡선 낮음 | 조건부 로직 없음, 복잡한 템플릿 어려움 |
| **Helm** | 풍부한 차트 생태계, 조건부/반복 템플릿, `values.yaml` 환경별 오버라이드 | YAML을 템플릿 언어로 변환하므로 디버깅 어려움 |

## Rationale

(결정 후 작성)

## Consequences

- **Kustomize**: `infra/k8s/base/` + `infra/k8s/overlays/{dev,stg,prd}/` 현재 디렉토리 구조 그대로 사용. P2-005 즉시 착수 가능.
- **Helm**: `infra/helm/` 디렉토리 구조로 재설계 필요. `Chart.yaml`, `values.yaml`, `templates/` 구조.

## Reversal Cost

Medium — Kustomize로 시작 후 Helm 전환은 전체 매니페스트 재작성 수준.

## Linked Backlog Items

- P2-004 (K8s 배포 도구 선택)
- P2-005 (K8s manifests baseline)
