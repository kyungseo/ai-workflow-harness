package io.kyungseo.msa.user.dto;

import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class UpdateUserRequest {

    private String username;

    @Pattern(
        regexp = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$",
        message = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다"
    )
    private String password;
}
