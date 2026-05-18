# BLOCK 2 — common-core

> 선행 조건: BLOCK 1 완료
> 목적: 모든 서비스가 의존하는 공통 모듈 구현
> 원칙: "모든 서비스가 무조건 필요한 것만" 포함. 하나라도 의문이 생기면 넣지 않는다.

---

## Lombok 사용 원칙 (전 서비스 공통)

| 어노테이션 | 용도 | 비고 |
|-----------|------|------|
| `@Getter` | 필드 getter 생성 | 기본 사용 |
| `@Builder` | 빌더 패턴 | DTO, 도메인 객체 생성 시 |
| `@RequiredArgsConstructor` | final 필드 생성자 주입 | `@Autowired` 대신 사용 |
| `@Slf4j` | 로거 선언 | `private static final Logger log` 대체 |
| `@NoArgsConstructor` | 기본 생성자 | MyBatis ResultMap, JSON 역직렬화 시 필요 |
| ~~`@Data`~~ | **사용 금지** | equals/hashCode 부작용, 양방향 관계 무한루프 위험 |

> `@Builder` + `@NoArgsConstructor` 함께 쓸 때는 `@AllArgsConstructor` 도 함께 선언해야 컴파일 오류 없음.

## MapStruct 사용 원칙 (전 서비스 공통)

- DTO ↔ 도메인 객체 변환에 사용. 수동 변환 코드(`setXxx`) 작성 금지
- Mapper 인터페이스는 `io.kyungseo.msa.{service}.mapper` 패키지에 위치
- `@Mapper(componentModel = "spring")` — Spring Bean으로 등록
- `build.gradle.kts` annotation processor 순서: **`lombok` → `mapstruct`** (순서 바뀌면 컴파일 오류)

```kotlin
// build.gradle.kts
annotationProcessor(libs.lombok)           // 반드시 먼저
annotationProcessor(libs.mapstruct.processor)  // 반드시 나중에
```

## GlobalExceptionHandler 처리 전략 (옵션 A 확정)

- `common-core`의 `GlobalExceptionHandler` 단일 핸들러가 **모든 서비스의 모든 `BusinessException`** 처리
- 각 서비스는 서비스별 `ErrorCode`를 `BusinessException`에 담아 throw만 하면 됨
- 각 서비스에 별도 `@RestControllerAdvice` 클래스 생성 **금지**
- 서비스별 특수 처리가 필요한 경우: `GlobalExceptionHandler`에 메서드 추가 (상속 금지)

## 테스트 픽스처 전략

- `common-core`의 `src/test/java` 하위에 `TestFixture` 클래스 구현
- 전 서비스 테스트에서 재사용 가능한 도메인 객체 팩토리 메서드 제공
- `@Sql` 어노테이션보다 `TestFixture` + `@BeforeEach` 조합 우선 사용

```java
// 예시
public class TestFixture {
    public static User adminUser() { return User.builder()... }
    public static Todo sampleTodo(Long userId) { return Todo.builder()... }
}
```

## Pagination 응답 형식 (Phase 1 기준)

- offset/limit 방식 사용 (커서 기반은 Phase 2)
- `ApiResponse<T>`의 페이징 메타데이터 구조를 지금 확정하여 클라이언트 수정 방지

```java
// PageResponse<T> — common-core에 추가
public class PageResponse<T> {
    private List<T> content;
    private int page;       // 현재 페이지 (0-based)
    private int size;       // 페이지 크기
    private long totalElements;
    private int totalPages;
}
// ApiResponse<PageResponse<TodoResponse>> 형태로 사용
```

---

## 포함 항목

```
common-core/src/main/java/io/kyungseo/msa/common/
├── response/
│   ├── ApiResponse<T>
│   └── ErrorResponse
├── exception/
│   ├── BusinessException
│   ├── ErrorCode (enum)
│   └── GlobalExceptionHandler
├── logging/
│   ├── MdcFilter
│   └── LoggingConstants
├── security/
│   └── JwtProperties
└── util/
    └── DateTimeUtils
```

## 포함하지 않는 항목 (혼동 방지)

| 항목 | 이유 |
|------|------|
| JWT 발급/검증 로직 | auth-service 전담 |
| Redis 연동 코드 | 서비스마다 용도 상이 |
| MyBatis 설정 | 각 서비스 독립 DataSource |
| Spring Security Config | 서비스마다 보안 정책 상이 |
| 도메인 모델 (User, Todo 등) | 도메인은 각 서비스 소유 |
| Swagger/OpenAPI 설정 | 서비스마다 그룹·설명 상이 |

---

## 구현 태스크

- [ ] `ApiResponse<T>` 구현
  - `{ code, message, data }` 구조
  - 정적 팩토리: `ApiResponse.success(data)`, `ApiResponse.error(errorCode)`
  - `code`는 HTTP 상태코드가 아닌 `ErrorCode` enum 값 사용

- [ ] `ErrorResponse` 구현
  - `{ code, message, errors[] }` 구조
  - `errors`: 필드 유효성 검증 실패 목록 (`field`, `message`)

- [ ] `ErrorCode` enum 구현 (COMMON 공통 코드)
  - `COMMON-0001` 잘못된 요청 파라미터 (400)
  - `COMMON-0002` 입력값 유효성 검증 실패 (400)
  - `COMMON-0003` 인증 필요 (401)
  - `COMMON-0004` 권한 없음 (403)
  - `COMMON-0005` 리소스 없음 (404)
  - `COMMON-0006` 서버 내부 오류 (500)
  - 각 enum 값에 `httpStatus`, `message` 필드 포함

- [ ] `BusinessException` 구현
  - `ErrorCode`를 인자로 받는 런타임 예외
  - 추가 메시지(detail) 필드 선택적 포함

- [ ] `GlobalExceptionHandler` 구현 (`@RestControllerAdvice`)
  - `BusinessException` → `ErrorCode` 기반 `ApiResponse` 반환
  - `MethodArgumentNotValidException` → `COMMON-0002` + `errors[]` 반환
  - `AccessDeniedException` → `COMMON-0004` 반환
  - `Exception` fallback → `COMMON-0006` 반환 (스택트레이스 로그 기록)

- [ ] `LoggingConstants` 구현
  - MDC key 상수 정의: `CORRELATION_ID = "X-Correlation-ID"`, `USER_ID = "userId"`

- [ ] `MdcFilter` 구현 (`OncePerRequestFilter`)
  - `X-Correlation-ID` 헤더 추출 (없으면 UUID v4 생성)
  - MDC 저장: `LoggingConstants.CORRELATION_ID`
  - 응답 헤더 전파: `X-Correlation-ID`
  - `finally` 블록에서 `MDC.clear()` (메모리 누수 방지 필수)

- [ ] `JwtProperties` 구현 (`@ConfigurationProperties(prefix = "jwt")`)
  - `secret`: String
  - `accessTokenExpiry`: Long (초 단위, 기본값 900)
  - `refreshTokenExpiry`: Long (초 단위, 기본값 604800)
  - `@Validated` 적용 (`@NotBlank`, `@Positive`)

- [ ] `DateTimeUtils` 구현
  - 공통 날짜 포맷 상수 및 변환 유틸

- [ ] `PageResponse<T>` 구현 (Pagination 응답 래퍼)
  - `content`, `page`, `size`, `totalElements`, `totalPages` 필드
  - `ApiResponse<PageResponse<T>>` 형태로 사용

- [ ] `BaseMapper<S, T>` MapStruct 베이스 인터페이스 (선택적)
  - 전 서비스 Mapper가 참조할 공통 변환 인터페이스 정의

- [ ] `SlowQueryInterceptor` 구현 (MyBatis Interceptor, `local`/`dev` 전용)
  - 100ms 초과 쿼리 `WARN` 레벨 로깅
  - SQL 파라미터 민감 필드 마스킹 후 출력
  - `local`/`dev` 프로파일에서만 Bean 등록 (`@Profile("local", "dev")`)

---

## 단위 테스트 (구현과 함께 작성)

- [ ] `ApiResponseTest`: `success()`, `error()` 정적 팩토리 검증
- [ ] `ErrorCodeTest`: HTTP 상태 코드 매핑 검증
- [ ] `BusinessExceptionTest`: ErrorCode 전달 및 message 확인
- [ ] `MdcFilterTest`:
  - Correlation-ID 헤더 있을 때 → 해당 값 MDC 저장 확인
  - Correlation-ID 헤더 없을 때 → UUID 생성 및 MDC 저장 확인
  - 요청 완료 후 MDC 정리 확인 (메모리 누수 방지)
- [ ] `GlobalExceptionHandlerTest` (`@WebMvcTest` 슬라이스):
  - `BusinessException` → 올바른 code/message 응답
  - `MethodArgumentNotValidException` → `COMMON-0002` + errors[] 응답

---

## 완료 조건

- [ ] `./gradlew :common:common-core:test` 전체 통과
- [ ] 각 서비스에서 `implementation(project(":common:common-core"))` 의존성 추가 후 컴파일 통과

## 다음 단계

BLOCK 2 완료 → **BLOCK 3 (도메인 모델 + schema.sql)** 진행
