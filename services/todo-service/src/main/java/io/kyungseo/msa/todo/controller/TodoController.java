package io.kyungseo.msa.todo.controller;

import io.kyungseo.msa.common.response.ApiResponse;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.todo.dto.CreateTodoRequest;
import io.kyungseo.msa.todo.dto.TodoResponse;
import io.kyungseo.msa.todo.dto.UpdateTodoRequest;
import io.kyungseo.msa.todo.service.TodoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Todo", description = "할 일 API")
@RestController
@RequestMapping("/api/v1/todos")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService todoService;

    @Operation(summary = "할 일 목록 조회", description = "본인 소유 할 일 페이징 조회. completed 필터 선택 가능")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PageResponse<TodoResponse>> getTodos(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean completed) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.getTodos(userId, page, size, completed));
    }

    @Operation(summary = "할 일 생성", description = "새 할 일 등록")
    @SecurityRequirement(name = "bearerAuth")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> createTodo(@Valid @RequestBody CreateTodoRequest request) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.createTodo(request, userId));
    }

    @Operation(summary = "할 일 단건 조회", description = "본인 소유 할 일만 조회 가능")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> getTodo(@PathVariable Long id) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.getTodo(id, userId));
    }

    @Operation(summary = "할 일 전체 수정", description = "title/description/completed 전체 교체")
    @SecurityRequirement(name = "bearerAuth")
    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> updateTodo(@PathVariable Long id,
                                                @Valid @RequestBody UpdateTodoRequest request) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.updateTodo(id, request, userId));
    }

    @Operation(summary = "완료 상태 토글", description = "completed 값을 반전")
    @SecurityRequirement(name = "bearerAuth")
    @PatchMapping("/{id}/complete")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> toggleComplete(@PathVariable Long id) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.toggleComplete(id, userId));
    }

    @Operation(summary = "할 일 삭제", description = "본인 소유 할 일만 삭제 가능")
    @SecurityRequirement(name = "bearerAuth")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("isAuthenticated()")
    public void deleteTodo(@PathVariable Long id) {
        Long userId = currentUserId();
        todoService.deleteTodo(id, userId);
    }

    private Long currentUserId() {
        return (Long) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    }
}
