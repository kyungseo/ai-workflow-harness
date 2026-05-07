package io.kyungseo.msa.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

@Schema(description = "토큰 갱신 응답")
@Getter
@Builder
public class RefreshResponse {

    @Schema(description = "새로 발급된 Access Token (유효시간 15분)")
    private String accessToken;

    @Schema(description = "새로 발급된 Refresh Token (유효시간 7일, Rotation 적용)")
    private String refreshToken;
}
