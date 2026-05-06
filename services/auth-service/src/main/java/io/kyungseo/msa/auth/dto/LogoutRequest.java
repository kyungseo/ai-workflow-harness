package io.kyungseo.msa.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class LogoutRequest {

    @NotBlank(message = "deviceId는 필수입니다")
    private String deviceId;
}
