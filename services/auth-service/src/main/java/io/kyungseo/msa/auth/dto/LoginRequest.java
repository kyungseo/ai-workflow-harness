package io.kyungseo.msa.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class LoginRequest {

    @NotBlank(message = "username은 필수입니다")
    private String username;

    @NotBlank(message = "password는 필수입니다")
    private String password;

    @NotBlank(message = "deviceId는 필수입니다")
    private String deviceId;
}
