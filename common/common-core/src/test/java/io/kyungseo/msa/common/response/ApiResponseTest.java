package io.kyungseo.msa.common.response;

import io.kyungseo.msa.common.exception.ErrorCode;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class ApiResponseTest {

    @Test
    void success_withData_returnsSuccessCodeAndData() {
        ApiResponse<String> response = ApiResponse.success("hello");

        assertThat(response.getCode()).isEqualTo("SUCCESS");
        assertThat(response.getMessage()).isEqualTo("성공");
        assertThat(response.getData()).isEqualTo("hello");
    }

    @Test
    void success_withoutData_returnsNullData() {
        ApiResponse<Void> response = ApiResponse.success();

        assertThat(response.getCode()).isEqualTo("SUCCESS");
        assertThat(response.getData()).isNull();
    }

    @Test
    void error_returnsErrorCodeAndMessage() {
        ApiResponse<Void> response = ApiResponse.error(ErrorCode.RESOURCE_NOT_FOUND);

        assertThat(response.getCode()).isEqualTo("COMMON-0005");
        assertThat(response.getMessage()).isEqualTo("리소스를 찾을 수 없습니다");
        assertThat(response.getData()).isNull();
    }
}
