package io.kyungseo.msa.todo.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.exception.GlobalExceptionHandler;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.todo.dto.TodoResponse;
import io.kyungseo.msa.todo.exception.TodoErrorCode;
import io.kyungseo.msa.todo.service.TodoService;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.willThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(
        controllers = TodoController.class,
        excludeAutoConfiguration = SecurityAutoConfiguration.class
)
@Import(GlobalExceptionHandler.class)
class TodoControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @MockitoBean TodoService todoService;

    private static final Long USER_ID = 1L;
    private static final Long TODO_ID = 10L;

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    private void setAuth(Long userId, String role) {
        var auth = new UsernamePasswordAuthenticationToken(userId, null,
                List.of(new SimpleGrantedAuthority(role)));
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    private TodoResponse sampleTodo() {
        return TodoResponse.builder()
                .id(TODO_ID)
                .userId(USER_ID)
                .title("Sample Todo")
                .description("Description")
                .completed(false)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    @Test
    void getTodos_authenticated_returns200() throws Exception {
        setAuth(USER_ID, "ROLE_USER");
        PageResponse<TodoResponse> page = PageResponse.<TodoResponse>builder()
                .content(List.of(sampleTodo()))
                .page(0).size(20).totalElements(1L).totalPages(1)
                .build();
        given(todoService.getTodos(eq(USER_ID), eq(0), eq(20), isNull())).willReturn(page);

        mockMvc.perform(get("/api/v1/todos"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content[0].title").value("Sample Todo"));
    }

    @Test
    void createTodo_validRequest_returns201() throws Exception {
        setAuth(USER_ID, "ROLE_USER");
        given(todoService.createTodo(any(), eq(USER_ID))).willReturn(sampleTodo());

        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", "New Todo"))))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.title").value("Sample Todo"));
    }

    @Test
    void createTodo_blankTitle_returns400() throws Exception {
        setAuth(USER_ID, "ROLE_USER");

        mockMvc.perform(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", ""))))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-0002"));
    }

    @Test
    void getTodo_notOwned_returns403() throws Exception {
        setAuth(USER_ID, "ROLE_USER");
        given(todoService.getTodo(TODO_ID, USER_ID))
                .willThrow(new BusinessException(TodoErrorCode.TODO_NOT_OWNED));

        mockMvc.perform(get("/api/v1/todos/{id}", TODO_ID))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TODO-0002"));
    }

    @Test
    void toggleComplete_notFound_returns404() throws Exception {
        setAuth(USER_ID, "ROLE_USER");
        willThrow(new BusinessException(TodoErrorCode.TODO_NOT_FOUND))
                .given(todoService).toggleComplete(TODO_ID, USER_ID);

        mockMvc.perform(patch("/api/v1/todos/{id}/complete", TODO_ID))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("TODO-0001"));
    }
}
