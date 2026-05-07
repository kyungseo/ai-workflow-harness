package io.kyungseo.msa.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Schema(description = "토큰 갱신 요청")
@Getter
public class RefreshRequest {

    @Schema(description = "현재 보유 중인 Refresh Token")
    @NotBlank(message = "refreshToken은 필수입니다")
    private String refreshToken;

    @Schema(description = "디바이스 식별자", example = "dev-local-001")
    @NotBlank(message = "deviceId는 필수입니다")
    private String deviceId;
}
