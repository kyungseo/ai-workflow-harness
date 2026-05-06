package io.kyungseo.msa.common.exception;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BusinessExceptionTest {

    @Test
    void constructor_withErrorCode_setsMessageFromErrorCode() {
        BusinessException ex = new BusinessException(CommonErrorCode.RESOURCE_NOT_FOUND);

        assertThat(ex.getErrorCode()).isEqualTo(CommonErrorCode.RESOURCE_NOT_FOUND);
        assertThat(ex.getMessage()).isEqualTo(CommonErrorCode.RESOURCE_NOT_FOUND.getMessage());
    }

    @Test
    void constructor_withDetail_overridesMessage() {
        BusinessException ex = new BusinessException(CommonErrorCode.RESOURCE_NOT_FOUND, "User not found");

        assertThat(ex.getErrorCode()).isEqualTo(CommonErrorCode.RESOURCE_NOT_FOUND);
        assertThat(ex.getMessage()).isEqualTo("User not found");
    }
}
