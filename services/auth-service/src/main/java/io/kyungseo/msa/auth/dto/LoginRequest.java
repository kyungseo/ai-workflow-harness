package io.kyungseo.msa.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Schema(description = "로그인 요청")
@Getter
public class LoginRequest {

    @Schema(description = "사용자 아이디", example = "admin")
    @NotBlank(message = "username은 필수입니다")
    private String username;

    @Schema(description = "비밀번호", example = "admin1234")
    @NotBlank(message = "password는 필수입니다")
    private String password;

    @Schema(description = "디바이스 식별자 (클라이언트가 생성한 UUID)", example = "dev-local-001")
    @NotBlank(message = "deviceId는 필수입니다")
    private String deviceId;
}
