package io.kyungseo.msa.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Schema(description = "사용자 응답")
@Getter
@Builder
public class UserResponse {

    @Schema(description = "사용자 ID")
    private Long id;

    @Schema(description = "사용자 아이디", example = "admin")
    private String username;

    @Schema(description = "이메일 주소", example = "admin@example.com")
    private String email;

    @Schema(description = "역할 (ROLE_ADMIN / ROLE_USER)", example = "ROLE_USER")
    private String role;

    @Schema(description = "계정 활성화 여부", example = "true")
    private Boolean enabled;

    @Schema(description = "생성 일시")
    private LocalDateTime createdAt;

    @Schema(description = "수정 일시")
    private LocalDateTime updatedAt;
}
