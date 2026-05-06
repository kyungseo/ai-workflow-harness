package io.kyungseo.msa.user.exception;

import io.kyungseo.msa.common.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum UserErrorCode implements ErrorCode {

    DUPLICATE_EMAIL("USER-0001", HttpStatus.CONFLICT, "이미 사용 중인 이메일입니다"),
    USER_NOT_FOUND("USER-0002", HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다"),
    PASSWORD_POLICY_VIOLATION("USER-0003", HttpStatus.BAD_REQUEST, "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;
}
