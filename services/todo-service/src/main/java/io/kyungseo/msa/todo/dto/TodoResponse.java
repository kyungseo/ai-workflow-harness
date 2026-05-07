package io.kyungseo.msa.todo.dto;

import io.kyungseo.msa.todo.domain.Todo;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Schema(description = "할 일 응답")
@Getter
@Builder
public class TodoResponse {

    @Schema(description = "할 일 ID")
    private Long id;

    @Schema(description = "소유자 사용자 ID")
    private Long userId;

    @Schema(description = "제목", example = "Spring Boot 공부하기")
    private String title;

    @Schema(description = "상세 설명", example = "Swagger 어노테이션 추가까지")
    private String description;

    @Schema(description = "완료 여부", example = "false")
    private Boolean completed;

    @Schema(description = "생성 일시")
    private LocalDateTime createdAt;

    @Schema(description = "수정 일시")
    private LocalDateTime updatedAt;

    public static TodoResponse from(Todo todo) {
        return TodoResponse.builder()
                .id(todo.getId())
                .userId(todo.getUserId())
                .title(todo.getTitle())
                .description(todo.getDescription())
                .completed(todo.getCompleted())
                .createdAt(todo.getCreatedAt())
                .updatedAt(todo.getUpdatedAt())
                .build();
    }
}
