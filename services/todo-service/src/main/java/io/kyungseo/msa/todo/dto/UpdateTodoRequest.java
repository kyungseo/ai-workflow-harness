package io.kyungseo.msa.todo.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Schema(description = "할 일 전체 수정 요청 (title/description/completed 모두 필요)")
@Getter
public class UpdateTodoRequest {

    @Schema(description = "제목 (최대 255자)", example = "Spring Boot 공부하기 (수정)")
    @NotBlank(message = "제목은 필수입니다.")
    @Size(max = 255, message = "제목은 255자를 초과할 수 없습니다.")
    private String title;

    @Schema(description = "상세 설명 (최대 1000자)", example = "완료 후 리뷰까지")
    @Size(max = 1000, message = "설명은 1000자를 초과할 수 없습니다.")
    private String description;

    @Schema(description = "완료 여부", example = "false")
    @NotNull(message = "완료 상태는 필수입니다.")
    private Boolean completed;
}
