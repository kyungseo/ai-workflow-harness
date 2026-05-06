package io.kyungseo.msa.todo.exception;

import io.kyungseo.msa.common.exception.ErrorCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum TodoErrorCode implements ErrorCode {

    TODO_NOT_FOUND("TODO-0001", HttpStatus.NOT_FOUND, "할 일을 찾을 수 없습니다."),
    TODO_NOT_OWNED("TODO-0002", HttpStatus.FORBIDDEN, "본인 소유의 할 일이 아닙니다.");

    private final String code;
    private final HttpStatus httpStatus;
    private final String message;
}
