package io.kyungseo.msa.todo.service;

import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.exception.CommonErrorCode;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.todo.domain.Todo;
import io.kyungseo.msa.todo.dto.CreateTodoRequest;
import io.kyungseo.msa.todo.dto.TodoResponse;
import io.kyungseo.msa.todo.dto.UpdateTodoRequest;
import io.kyungseo.msa.todo.exception.TodoErrorCode;
import io.kyungseo.msa.todo.mapper.TodoMapper;
import io.kyungseo.msa.todo.mapper.UserExistenceMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class TodoService {

    private final TodoMapper todoMapper;
    private final UserExistenceMapper userExistenceMapper;

    @Transactional(readOnly = true)
    public PageResponse<TodoResponse> getTodos(Long userId, int page, int size, Boolean completed) {
        int offset = page * size;
        long total = todoMapper.countByUserId(userId, completed);
        List<TodoResponse> content = todoMapper.findAllByUserId(userId, offset, size, completed)
                .stream()
                .map(TodoResponse::from)
                .toList();
        int totalPages = (int) Math.ceil((double) total / size);
        return PageResponse.<TodoResponse>builder()
                .content(content)
                .page(page)
                .size(size)
                .totalElements(total)
                .totalPages(totalPages)
                .build();
    }

    @Transactional
    public TodoResponse createTodo(CreateTodoRequest request, Long userId) {
        if (!userExistenceMapper.existsById(userId)) {
            throw new BusinessException(CommonErrorCode.FORBIDDEN);
        }
        Todo todo = Todo.builder()
                .userId(userId)
                .title(request.getTitle())
                .description(request.getDescription())
                .completed(false)
                .build();
        todoMapper.insert(todo);
        return todoMapper.findById(todo.getId())
                .map(TodoResponse::from)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
    }

    @Transactional(readOnly = true)
    public TodoResponse getTodo(Long id, Long userId) {
        Todo todo = todoMapper.findById(id)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
        validateOwnership(todo, userId);
        return TodoResponse.from(todo);
    }

    @Transactional
    public TodoResponse updateTodo(Long id, UpdateTodoRequest request, Long userId) {
        Todo existing = todoMapper.findById(id)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
        validateOwnership(existing, userId);
        Todo toUpdate = Todo.builder()
                .id(id)
                .title(request.getTitle())
                .description(request.getDescription())
                .completed(request.getCompleted())
                .build();
        todoMapper.update(toUpdate);
        return todoMapper.findById(id)
                .map(TodoResponse::from)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
    }

    @Transactional
    public TodoResponse toggleComplete(Long id, Long userId) {
        Todo todo = todoMapper.findById(id)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
        validateOwnership(todo, userId);
        todoMapper.updateCompleted(id, !todo.getCompleted());
        return todoMapper.findById(id)
                .map(TodoResponse::from)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
    }

    @Transactional
    public void deleteTodo(Long id, Long userId) {
        Todo todo = todoMapper.findById(id)
                .orElseThrow(() -> new BusinessException(TodoErrorCode.TODO_NOT_FOUND));
        validateOwnership(todo, userId);
        todoMapper.deleteById(id);
    }

    private void validateOwnership(Todo todo, Long requestUserId) {
        if (!todo.getUserId().equals(requestUserId)) {
            throw new BusinessException(TodoErrorCode.TODO_NOT_OWNED);
        }
    }
}
