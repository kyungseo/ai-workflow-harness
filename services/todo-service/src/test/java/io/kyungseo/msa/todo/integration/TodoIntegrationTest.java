package io.kyungseo.msa.todo.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.util.List;
import java.util.Map;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
@Sql(scripts = "/test-schema.sql", executionPhase = Sql.ExecutionPhase.BEFORE_TEST_METHOD)
class TodoIntegrationTest {

    @Container
    @ServiceConnection
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired JdbcTemplate jdbcTemplate;

    private Authentication userAuth;
    private Authentication otherAuth;

    @BeforeEach
    void setUp() {
        Long userId = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE username = 'testuser'", Long.class);
        Long otherUserId = jdbcTemplate.queryForObject(
                "SELECT id FROM users WHERE username = 'otheruser'", Long.class);
        userAuth = new UsernamePasswordAuthenticationToken(userId, null,
                List.of(new SimpleGrantedAuthority("ROLE_USER")));
        otherAuth = new UsernamePasswordAuthenticationToken(otherUserId, null,
                List.of(new SimpleGrantedAuthority("ROLE_USER")));
    }

    private MockHttpServletRequestBuilder withAuth(MockHttpServletRequestBuilder builder, Authentication auth) {
        return builder.with(authentication(auth));
    }

    @Test
    void createAndGetTodo_success() throws Exception {
        MvcResult createResult = mockMvc.perform(
                withAuth(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "title", "Integration Test Todo",
                                "description", "Test description"))),
                        userAuth))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.title").value("Integration Test Todo"))
                .andReturn();

        Long todoId = objectMapper.readTree(
                createResult.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(withAuth(get("/api/v1/todos/{id}", todoId), userAuth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(todoId));
    }

    @Test
    void toggleComplete_changesState() throws Exception {
        MvcResult createResult = mockMvc.perform(
                withAuth(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", "Toggle Test"))),
                        userAuth))
                .andExpect(status().isCreated())
                .andReturn();

        Long todoId = objectMapper.readTree(
                createResult.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(withAuth(patch("/api/v1/todos/{id}/complete", todoId), userAuth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.completed").value(true));

        mockMvc.perform(withAuth(patch("/api/v1/todos/{id}/complete", todoId), userAuth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.completed").value(false));
    }

    @Test
    void updateAndDeleteTodo_success() throws Exception {
        MvcResult createResult = mockMvc.perform(
                withAuth(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", "To Update"))),
                        userAuth))
                .andExpect(status().isCreated())
                .andReturn();

        Long todoId = objectMapper.readTree(
                createResult.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(withAuth(put("/api/v1/todos/{id}", todoId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of(
                                "title", "Updated Title",
                                "description", "Updated Desc",
                                "completed", false))),
                        userAuth))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.title").value("Updated Title"));

        mockMvc.perform(withAuth(delete("/api/v1/todos/{id}", todoId), userAuth))
                .andExpect(status().isNoContent());

        mockMvc.perform(withAuth(get("/api/v1/todos/{id}", todoId), userAuth))
                .andExpect(status().isNotFound());
    }

    @Test
    void accessOtherUserTodo_returns403() throws Exception {
        MvcResult createResult = mockMvc.perform(
                withAuth(post("/api/v1/todos")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(Map.of("title", "My Todo"))),
                        userAuth))
                .andExpect(status().isCreated())
                .andReturn();

        Long todoId = objectMapper.readTree(
                createResult.getResponse().getContentAsString())
                .path("data").path("id").asLong();

        mockMvc.perform(withAuth(get("/api/v1/todos/{id}", todoId), otherAuth))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("TODO-0002"));
    }
}
