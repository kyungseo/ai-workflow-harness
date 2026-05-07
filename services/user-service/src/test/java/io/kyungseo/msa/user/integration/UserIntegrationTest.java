package io.kyungseo.msa.user.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.List;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 통합 테스트: 로컬 실행 중인 PostgreSQL 컨테이너 사용 (test 프로파일).
 * 사전 조건: docker compose up postgres 기동 상태
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserIntegrationTest {

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;

    private UsernamePasswordAuthenticationToken adminAuth() {
        return new UsernamePasswordAuthenticationToken(1L, null,
                List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));
    }

    private UsernamePasswordAuthenticationToken userAuth(Long userId) {
        return new UsernamePasswordAuthenticationToken(userId, null,
                List.of(new SimpleGrantedAuthority("ROLE_USER")));
    }

    @Test
    void register_and_getUser_fullFlow() throws Exception {
        // 1. 회원가입
        MvcResult registerResult = mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"newuser","email":"newuser@example.com","password":"Password1"}
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.code").value("SUCCESS"))
                .andExpect(jsonPath("$.data.email").value("newuser@example.com"))
                .andExpect(jsonPath("$.data.role").value("ROLE_USER"))
                .andReturn();

        Long userId = objectMapper.readTree(registerResult.getResponse().getContentAsString())
                .get("data").get("id").asLong();

        // 2. 본인 조회
        mockMvc.perform(get("/api/v1/users/" + userId)
                        .with(authentication(userAuth(userId))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(userId));

        // 3. ADMIN으로 사용자 삭제
        mockMvc.perform(delete("/api/v1/users/" + userId)
                        .with(authentication(adminAuth())))
                .andExpect(status().isNoContent());

        // 4. 삭제 후 조회 시 404
        mockMvc.perform(get("/api/v1/users/" + userId)
                        .with(authentication(adminAuth())))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("USER-0002"));
    }

    @Test
    void register_duplicateEmail_returns409() throws Exception {
        String body = """
                {"username":"dupuser","email":"test@example.com","password":"Password1"}
                """;

        // test@example.com은 test-schema.sql에 이미 존재
        mockMvc.perform(post("/api/v1/users")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("USER-0001"));
    }

    @Test
    void getUsers_admin_returnsList() throws Exception {
        mockMvc.perform(get("/api/v1/users")
                        .with(authentication(adminAuth())))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.content").isArray());
    }

    @Test
    void updateUser_self_success() throws Exception {
        // testuser(id=1) 정보 수정
        mockMvc.perform(patch("/api/v1/users/1")
                        .with(authentication(userAuth(1L)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"username":"testuser_updated"}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value("testuser_updated"));
    }
}
