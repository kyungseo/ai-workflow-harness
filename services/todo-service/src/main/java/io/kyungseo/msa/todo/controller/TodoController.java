package io.kyungseo.msa.todo.controller;

import io.kyungseo.msa.common.response.ApiResponse;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.todo.dto.CreateTodoRequest;
import io.kyungseo.msa.todo.dto.TodoResponse;
import io.kyungseo.msa.todo.dto.UpdateTodoRequest;
import io.kyungseo.msa.todo.service.TodoService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/todos")
@RequiredArgsConstructor
public class TodoController {

    private final TodoService todoService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<PageResponse<TodoResponse>> getTodos(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) Boolean completed) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.getTodos(userId, page, size, completed));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> createTodo(@Valid @RequestBody CreateTodoRequest request) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.createTodo(request, userId));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> getTodo(@PathVariable Long id) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.getTodo(id, userId));
    }

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> updateTodo(@PathVariable Long id,
                                                @Valid @RequestBody UpdateTodoRequest request) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.updateTodo(id, request, userId));
    }

    @PatchMapping("/{id}/complete")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<TodoResponse> toggleComplete(@PathVariable Long id) {
        Long userId = currentUserId();
        return ApiResponse.success(todoService.toggleComplete(id, userId));
    }

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
