package io.kyungseo.msa.auth.exception;

import io.kyungseo.msa.common.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum AuthErrorCode implements ErrorCode {

    LOGIN_FAILED("AUTH-0001", HttpStatus.BAD_REQUEST, "아이디 또는 비밀번호가 올바르지 않습니다"),
    TOKEN_EXPIRED("AUTH-0002", HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다"),
    INVALID_TOKEN("AUTH-0003", HttpStatus.UNAUTHORIZED, "유효하지 않은 토큰입니다"),
    BLACKLISTED_TOKEN("AUTH-0004", HttpStatus.UNAUTHORIZED, "로그아웃된 토큰입니다"),
    REFRESH_TOKEN_NOT_FOUND("AUTH-0005", HttpStatus.UNAUTHORIZED, "Refresh Token을 찾을 수 없습니다. 다시 로그인해 주세요");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;
}
