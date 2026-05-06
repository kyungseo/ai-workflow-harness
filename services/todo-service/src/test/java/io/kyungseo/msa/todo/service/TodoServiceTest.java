package io.kyungseo.msa.todo.service;

import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.todo.domain.Todo;
import io.kyungseo.msa.todo.dto.CreateTodoRequest;
import io.kyungseo.msa.todo.dto.TodoResponse;
import io.kyungseo.msa.todo.dto.UpdateTodoRequest;
import io.kyungseo.msa.todo.exception.TodoErrorCode;
import io.kyungseo.msa.todo.mapper.TodoMapper;
import io.kyungseo.msa.todo.mapper.UserExistenceMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class TodoServiceTest {

    @Mock private TodoMapper todoMapper;
    @Mock private UserExistenceMapper userExistenceMapper;
    @InjectMocks private TodoService todoService;

    private static final Long USER_ID = 1L;
    private static final Long OTHER_USER_ID = 2L;
    private static final Long TODO_ID = 10L;

    private Todo buildTodo(Long id, Long userId, boolean completed) {
        return Todo.builder()
                .id(id)
                .userId(userId)
                .title("Test Todo")
                .description("Description")
                .completed(completed)
                .build();
    }

    @Test
    void getTodos_returnsPaged() {
        Todo todo = buildTodo(TODO_ID, USER_ID, false);
        given(todoMapper.countByUserId(USER_ID, null)).willReturn(1L);
        given(todoMapper.findAllByUserId(USER_ID, 0, 20, null)).willReturn(List.of(todo));

        var result = todoService.getTodos(USER_ID, 0, 20, null);

        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getTotalElements()).isEqualTo(1L);
    }

    @Test
    void createTodo_success() {
        given(userExistenceMapper.existsById(USER_ID)).willReturn(true);
        given(todoMapper.findById(any())).willReturn(Optional.of(buildTodo(TODO_ID, USER_ID, false)));

        CreateTodoRequest request = new CreateTodoRequest();
        setField(request, "title", "New Todo");
        setField(request, "description", "Desc");

        TodoResponse response = todoService.createTodo(request, USER_ID);

        verify(todoMapper).insert(any(Todo.class));
        assertThat(response.getTitle()).isEqualTo("Test Todo");
    }

    @Test
    void createTodo_userNotFound_throwsForbidden() {
        given(userExistenceMapper.existsById(USER_ID)).willReturn(false);

        CreateTodoRequest request = new CreateTodoRequest();
        setField(request, "title", "New Todo");

        assertThatThrownBy(() -> todoService.createTodo(request, USER_ID))
                .isInstanceOf(BusinessException.class);
    }

    @Test
    void getTodo_notFound_throwsError() {
        given(todoMapper.findById(TODO_ID)).willReturn(Optional.empty());

        assertThatThrownBy(() -> todoService.getTodo(TODO_ID, USER_ID))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(TodoErrorCode.TODO_NOT_FOUND));
    }

    @Test
    void getTodo_notOwned_throwsError() {
        given(todoMapper.findById(TODO_ID)).willReturn(Optional.of(buildTodo(TODO_ID, OTHER_USER_ID, false)));

        assertThatThrownBy(() -> todoService.getTodo(TODO_ID, USER_ID))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(TodoErrorCode.TODO_NOT_OWNED));
    }

    @Test
    void toggleComplete_falseToTrue() {
        Todo todo = buildTodo(TODO_ID, USER_ID, false);
        Todo toggled = buildTodo(TODO_ID, USER_ID, true);
        given(todoMapper.findById(TODO_ID))
                .willReturn(Optional.of(todo))
                .willReturn(Optional.of(toggled));

        TodoResponse response = todoService.toggleComplete(TODO_ID, USER_ID);

        verify(todoMapper).updateCompleted(TODO_ID, true);
        assertThat(response.getCompleted()).isTrue();
    }

    @Test
    void toggleComplete_trueToFalse() {
        Todo todo = buildTodo(TODO_ID, USER_ID, true);
        Todo toggled = buildTodo(TODO_ID, USER_ID, false);
        given(todoMapper.findById(TODO_ID))
                .willReturn(Optional.of(todo))
                .willReturn(Optional.of(toggled));

        TodoResponse response = todoService.toggleComplete(TODO_ID, USER_ID);

        verify(todoMapper).updateCompleted(TODO_ID, false);
        assertThat(response.getCompleted()).isFalse();
    }

    @Test
    void deleteTodo_notOwned_throwsError() {
        given(todoMapper.findById(TODO_ID)).willReturn(Optional.of(buildTodo(TODO_ID, OTHER_USER_ID, false)));

        assertThatThrownBy(() -> todoService.deleteTodo(TODO_ID, USER_ID))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(TodoErrorCode.TODO_NOT_OWNED));
    }

    @Test
    void deleteTodo_success() {
        given(todoMapper.findById(TODO_ID)).willReturn(Optional.of(buildTodo(TODO_ID, USER_ID, false)));

        todoService.deleteTodo(TODO_ID, USER_ID);

        verify(todoMapper).deleteById(TODO_ID);
    }

    @Test
    void updateTodo_notOwned_throwsError() {
        given(todoMapper.findById(TODO_ID)).willReturn(Optional.of(buildTodo(TODO_ID, OTHER_USER_ID, false)));

        UpdateTodoRequest request = new UpdateTodoRequest();
        setField(request, "title", "Updated");
        setField(request, "completed", false);

        assertThatThrownBy(() -> todoService.updateTodo(TODO_ID, request, USER_ID))
                .isInstanceOf(BusinessException.class)
                .satisfies(ex -> assertThat(((BusinessException) ex).getErrorCode())
                        .isEqualTo(TodoErrorCode.TODO_NOT_OWNED));
    }

    private void setField(Object target, String fieldName, Object value) {
        try {
            var field = target.getClass().getDeclaredField(fieldName);
            field.setAccessible(true);
            field.set(target, value);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
