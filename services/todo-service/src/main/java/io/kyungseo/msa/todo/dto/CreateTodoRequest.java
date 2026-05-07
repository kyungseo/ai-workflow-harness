package io.kyungseo.msa.todo.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Schema(description = "할 일 생성 요청")
@Getter
public class CreateTodoRequest {

    @Schema(description = "제목 (최대 255자)", example = "Spring Boot 공부하기")
    @NotBlank(message = "제목은 필수입니다.")
    @Size(max = 255, message = "제목은 255자를 초과할 수 없습니다.")
    private String title;

    @Schema(description = "상세 설명 (최대 1000자, 선택)", example = "Swagger 어노테이션 추가까지")
    @Size(max = 1000, message = "설명은 1000자를 초과할 수 없습니다.")
    private String description;
}
