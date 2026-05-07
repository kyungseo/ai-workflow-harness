package io.kyungseo.msa.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Schema(description = "사용자 정보 수정 요청 (변경할 항목만 전달)")
@Getter
public class UpdateUserRequest {

    @Schema(description = "변경할 사용자 아이디 (생략 시 유지)", example = "newusername")
    private String username;

    @Schema(description = "변경할 비밀번호 (8자 이상, 영문+숫자 조합. 생략 시 유지)", example = "newpass1")
    @Pattern(
        regexp = "^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$",
        message = "비밀번호는 8자 이상, 영문과 숫자를 포함해야 합니다"
    )
    private String password;
}
