package io.kyungseo.msa.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Schema(description = "회원가입 요청")
@Getter
public class RegisterRequest {

    @Schema(description = "사용자 아이디", example = "newuser")
    @NotBlank(message = "username은 필수입니다")
    private String username;

    @Schema(description = "이메일 주소", example = "newuser@example.com")
    @NotBlank(message = "email은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;

    @Schema(description = "비밀번호 (8자 이상, 영문+숫자 조합)", example = "password1")
    @NotBlank(message = "password는 필수입니다")
    @Pattern(
        regexp = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$",
        message = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다"
    )
    private String password;
}
