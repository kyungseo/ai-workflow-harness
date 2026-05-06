package io.kyungseo.msa.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class RegisterRequest {

    @NotBlank(message = "username은 필수입니다")
    private String username;

    @NotBlank(message = "email은 필수입니다")
    @Email(message = "올바른 이메일 형식이 아닙니다")
    private String email;

    @NotBlank(message = "password는 필수입니다")
    @Pattern(
        regexp = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$",
        message = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다"
    )
    private String password;
}
