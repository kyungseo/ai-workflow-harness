package io.kyungseo.msa.auth.dto;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class RefreshResponse {
    private String accessToken;
    private String refreshToken;
}
