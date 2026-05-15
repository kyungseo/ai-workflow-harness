고품질 발표/보고 자료를 만들기 위한 workflow다.

대상 예시:

- 발표자료, deck, PPT/PPTX, slide
- 보고서, review package, decision brief
- executive summary, technical review, external review material

자연어 요청에서 발표, 보고, 리뷰 패키지, decision brief, 외부 공유용 문서, 품질 높은 문서 산출물 생성 문맥이 보이면 이 절차를 따른다.
단순 README 수정, 기존 문서 일부 편집, 오탈자 수정처럼 source 문서 자체를 고치는 작업은 일반 문서 작업으로 처리한다.

## 1. Brief 먼저 확정

바로 최종 파일을 만들지 말고 아래 brief를 먼저 확정해줘.
명확하지 않은 항목은 최대 3개까지만 질문해줘.

| 항목 | 확인 내용 |
| --- | --- |
| Purpose | 발표, 의사결정, 리뷰, 보고, 교육 중 무엇인가 |
| Audience | 경영진, 기술 리더, 개발팀, 외부 리뷰어 등 |
| Format | `pptx`, slide outline, `md`, `docx`, pdf-ready 등 |
| Source | STATUS, backlog, DR, code diff, retrospective, 사용자 메모 |
| Length | slide/page 수, 발표 시간, 요약 깊이 |
| Tone | executive, technical, reviewer-facing, tutorial 등 |
| Output path | 사용자가 지정하지 않으면 `docs/presentations/` 또는 `docs/reports/` 제안 |
| Quality bar | narrative, evidence, visual density, source traceability, review 기준 |

## 2. Context Loading

항상 필요한 최소 문서만 읽어줘.

| 필요 | 로드 |
| --- | --- |
| 현재 상태/작업 결과 기반 | `docs/STATUS.md` |
| 기술 스택/아키텍처 요약 | `docs/PLAN-SUMMARY.md` |
| 상세 근거 또는 L3 아키텍처 판단 | `docs/PLAN.md` |
| 결정 근거 | 관련 `docs/decisions/DR-*.md` |
| 하네스/워크플로우 주제 | `docs/HARNESS-PROTOCOL.md`, 필요한 `docs/harness-protocol/*.md` |
| 회고/리뷰 기반 | 관련 `docs/retrospectives/` 1개 |
| 이슈 해결 기반 | 관련 `docs/troubleshooting/` 파일 |

자료 출처가 불분명하면 먼저 source 후보를 제안하고 승인받아.

## 3. Output Routing

| Format | 기본 위치 |
| --- | --- |
| 발표자료, deck, PPT/PPTX, slide source | `docs/presentations/` |
| 보고서, review package, decision brief, markdown summary | `docs/reports/` |
| 임시 outline 또는 초안 | 사용자가 지정한 경로 또는 `docs/reports/` |

새 디렉터리를 만들거나 STATUS에 참조를 추가해야 하면 즉시 수정하지 말고 `STATUS Update Proposal` 또는 계획에 포함해.

## 4. Production Rules

1. 먼저 brief와 outline을 제안한다.
2. 사용자가 승인하면 산출물을 만든다.
3. 발표자료는 narrative first로 작성한다.
   - 각 slide는 한 가지 message를 가져야 한다.
   - title은 topic label이 아니라 결론에 가깝게 쓴다.
   - audience가 의사결정자면 detail보다 implication과 recommendation을 우선한다.
4. 보고서는 source traceability를 유지한다.
   - 어떤 STATUS/DR/backlog/diff에 근거했는지 남긴다.
   - 불확실한 내용은 inference로 표시한다.
5. 사용 가능한 presentation/document 도구가 있으면 우선 사용한다.
   - PPT/deck: presentation-capable tool, PowerPoint, Canva 등 사용 가능 여부 확인
   - 문서 보고서: document-capable tool 또는 Markdown
   - 도구가 없으면 outline, speaker notes, asset checklist, production spec을 만든다.
6. 3rd-party 연계는 사용자가 명시했거나 현재 환경에 연결되어 있을 때만 사용한다.

## 5. Verification

완료 전 아래를 확인해줘.

- Purpose와 audience에 맞는가
- Story arc가 있는가
- 핵심 메시지가 slide/page마다 분명한가
- Source traceability가 있는가
- 숫자, 결정, 일정, 상태가 최신 source와 맞는가
- 시각 자료가 있다면 render/preview 또는 사용 가능한 검증을 했는가
- `docs/STATUS.md`, DR, TODO, 문서 cascade 필요 여부를 확인했는가

## 6. 완료 보고

완료 보고에는 아래를 포함해줘.

1. 산출물 경로
2. 사용한 source
3. format과 audience
4. 검증 결과
5. 남은 리스크
6. STATUS Update Proposal 필요 여부
