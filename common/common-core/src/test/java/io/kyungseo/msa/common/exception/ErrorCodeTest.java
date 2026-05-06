package io.kyungseo.msa.common.exception;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.assertj.core.api.Assertions.assertThat;

class ErrorCodeTest {

    @Test
    void invalidInput_isBadRequest() {
        assertThat(CommonErrorCode.INVALID_INPUT.getHttpStatus()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(CommonErrorCode.INVALID_INPUT.getCode()).isEqualTo("COMMON-0001");
    }

    @Test
    void validationFailed_isBadRequest() {
        assertThat(CommonErrorCode.VALIDATION_FAILED.getHttpStatus()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(CommonErrorCode.VALIDATION_FAILED.getCode()).isEqualTo("COMMON-0002");
    }

    @Test
    void unauthorized_isUnauthorized() {
        assertThat(CommonErrorCode.UNAUTHORIZED.getHttpStatus()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(CommonErrorCode.UNAUTHORIZED.getCode()).isEqualTo("COMMON-0003");
    }

    @Test
    void forbidden_isForbidden() {
        assertThat(CommonErrorCode.FORBIDDEN.getHttpStatus()).isEqualTo(HttpStatus.FORBIDDEN);
        assertThat(CommonErrorCode.FORBIDDEN.getCode()).isEqualTo("COMMON-0004");
    }

    @Test
    void resourceNotFound_isNotFound() {
        assertThat(CommonErrorCode.RESOURCE_NOT_FOUND.getHttpStatus()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(CommonErrorCode.RESOURCE_NOT_FOUND.getCode()).isEqualTo("COMMON-0005");
    }

    @Test
    void internalError_isInternalServerError() {
        assertThat(CommonErrorCode.INTERNAL_ERROR.getHttpStatus()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(CommonErrorCode.INTERNAL_ERROR.getCode()).isEqualTo("COMMON-0006");
    }
}
