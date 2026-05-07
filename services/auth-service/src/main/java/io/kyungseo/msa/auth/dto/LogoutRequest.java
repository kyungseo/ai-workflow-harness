package io.kyungseo.msa.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Schema(description = "로그아웃 요청")
@Getter
public class LogoutRequest {

    @Schema(description = "디바이스 식별자", example = "dev-local-001")
    @NotBlank(message = "deviceId는 필수입니다")
    private String deviceId;
}
