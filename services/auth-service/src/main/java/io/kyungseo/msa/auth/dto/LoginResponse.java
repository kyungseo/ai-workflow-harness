package io.kyungseo.msa.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Schema(description = "로그인 응답")
@Getter
@Builder
public class LoginResponse {

    @Schema(description = "Access Token (유효시간 15분)")
    private String accessToken;

    @Schema(description = "Refresh Token (유효시간 7일)")
    private String refreshToken;

    @Schema(description = "토큰 타입", example = "Bearer")
    private String tokenType;
}
