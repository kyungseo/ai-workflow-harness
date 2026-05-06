package io.kyungseo.msa.user.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.exception.CommonErrorCode;
import io.kyungseo.msa.common.exception.GlobalExceptionHandler;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.user.dto.UserResponse;
import io.kyungseo.msa.user.exception.UserErrorCode;
import io.kyungseo.msa.user.service.UserService;
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

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.BDDMockito.willThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(
        controllers = UserController.class,
        excludeAutoConfiguration = SecurityAutoConfiguration.class
)
@Import(GlobalExceptionHandler.class)
class UserControllerTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @MockitoBean UserService userService;

    @AfterEach
    void clearSecurityContext() {
        SecurityContextHolder.clearContext();
    }

    private void setAuth(Long userId, String role) {
        var auth = new UsernamePasswordAuthenticationToken(userId, null,
                List.of(new SimpleGrantedAuthority(role)));
        SecurityContextHolder.getContext().setAuthentication(auth);
    }

    private UserResponse sampleUser() {
        return UserResponse.builder()
                .id(1L).username("alice").email("alice@example.com")
                .role("ROLE_USER").enabled(true)
                .createdAt(LocalDateTime.now()).updatedAt(LocalDateTime.now())
                .build();
    }

    @Test
    void register_success_returns201() throws Exception {
        given(userService.register(any())).willReturn(sampleUser());

        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"alice","email":"alice@example.com","password":"Password1"}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("SUCCESS"))
                .andExpect(jsonPath("$.data.email").value("alice@example.com"));
    }

    @Test
    void register_duplicateEmail_returns409() throws Exception {
        given(userService.register(any())).willThrow(new BusinessException(UserErrorCode.DUPLICATE_EMAIL));

        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"alice","email":"alice@example.com","password":"Password1"}
                                """))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("USER-0001"));
    }

    @Test
    void register_invalidPassword_returns400() throws Exception {
        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"alice","email":"alice@example.com","password":"weak"}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("COMMON-0002"));
    }

    @Test
    void getUsers_adminRole_returns200() throws Exception {
        setAuth(1L, "ROLE_ADMIN");
        PageResponse<UserResponse> page = PageResponse.<UserResponse>builder()
                .content(List.of(sampleUser())).page(0).size(20).totalElements(1).totalPages(1)
                .build();
        given(userService.getUsers(0, 20)).willReturn(page);

        mockMvc.perform(get("/api/v1/users"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.totalElements").value(1));
    }

    @Test
    void getUser_self_returns200() throws Exception {
        setAuth(1L, "ROLE_USER");
        given(userService.getUser(eq(1L), eq(1L), anyString())).willReturn(sampleUser());

        mockMvc.perform(get("/api/v1/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(1));
    }

    @Test
    void getUser_forbidden_returns403() throws Exception {
        setAuth(1L, "ROLE_USER");
        given(userService.getUser(eq(2L), eq(1L), anyString()))
                .willThrow(new BusinessException(CommonErrorCode.FORBIDDEN));

        mockMvc.perform(get("/api/v1/users/2"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.code").value("COMMON-0004"));
    }

    @Test
    void deleteUser_returns204() throws Exception {
        setAuth(1L, "ROLE_ADMIN");

        mockMvc.perform(delete("/api/v1/users/1"))
                .andExpect(status().isNoContent());
    }

    @Test
    void deleteUser_notFound_returns404() throws Exception {
        setAuth(1L, "ROLE_ADMIN");
        willThrow(new BusinessException(UserErrorCode.USER_NOT_FOUND))
                .given(userService).deleteUser(99L);

        mockMvc.perform(delete("/api/v1/users/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("USER-0002"));
    }
}
