package io.kyungseo.msa.common.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {

    INVALID_INPUT("COMMON-0001", HttpStatus.BAD_REQUEST, "잘못된 요청 파라미터"),
    VALIDATION_FAILED("COMMON-0002", HttpStatus.BAD_REQUEST, "입력값 유효성 검증 실패"),
    UNAUTHORIZED("COMMON-0003", HttpStatus.UNAUTHORIZED, "인증이 필요합니다"),
    FORBIDDEN("COMMON-0004", HttpStatus.FORBIDDEN, "권한이 없습니다"),
    RESOURCE_NOT_FOUND("COMMON-0005", HttpStatus.NOT_FOUND, "리소스를 찾을 수 없습니다"),
    INTERNAL_ERROR("COMMON-0006", HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;
}
