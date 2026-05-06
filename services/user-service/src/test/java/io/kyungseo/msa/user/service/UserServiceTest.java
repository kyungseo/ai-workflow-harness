package io.kyungseo.msa.user.service;

import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.user.domain.User;
import io.kyungseo.msa.user.dto.RegisterRequest;
import io.kyungseo.msa.user.dto.UpdateUserRequest;
import io.kyungseo.msa.user.dto.UserResponse;
import io.kyungseo.msa.user.exception.UserErrorCode;
import io.kyungseo.msa.user.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.BDDMockito.given;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class UserServiceTest {

    @Mock private UserMapper userMapper;
    @Mock private PasswordEncoder passwordEncoder;

    @InjectMocks private UserService userService;

    private User sampleUser;

    @BeforeEach
    void setUp() {
        sampleUser = User.builder()
                .id(1L)
                .username("alice")
                .email("alice@example.com")
                .password("encoded_pw")
                .role("ROLE_USER")
                .enabled(true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
    }

    @Test
    @DisplayName("회원가입 성공")
    void register_success() {
        RegisterRequest req = mockRegisterRequest("alice", "alice@example.com", "Password1");
        given(userMapper.existsByEmail("alice@example.com")).willReturn(false);
        given(passwordEncoder.encode("Password1")).willReturn("encoded_pw");

        UserResponse result = userService.register(req);

        verify(userMapper).insert(any(User.class));
        assertThat(result.getEmail()).isEqualTo("alice@example.com");
        assertThat(result.getRole()).isEqualTo("ROLE_USER");
    }

    @Test
    @DisplayName("이메일 중복 시 DUPLICATE_EMAIL 예외")
    void register_duplicateEmail() {
        RegisterRequest req = mockRegisterRequest("alice", "alice@example.com", "Password1");
        given(userMapper.existsByEmail("alice@example.com")).willReturn(true);

        assertThatThrownBy(() -> userService.register(req))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getErrorCode())
                .isEqualTo(UserErrorCode.DUPLICATE_EMAIL);
    }

    @Test
    @DisplayName("사용자 목록 조회 (ADMIN)")
    void getUsers_success() {
        given(userMapper.count()).willReturn(1L);
        given(userMapper.findAll(0, 20)).willReturn(List.of(sampleUser));

        PageResponse<UserResponse> result = userService.getUsers(0, 20);

        assertThat(result.getTotalElements()).isEqualTo(1L);
        assertThat(result.getContent()).hasSize(1);
    }

    @Test
    @DisplayName("본인 조회 성공")
    void getUser_self() {
        given(userMapper.findById(1L)).willReturn(Optional.of(sampleUser));

        UserResponse result = userService.getUser(1L, 1L, "ROLE_USER");

        assertThat(result.getId()).isEqualTo(1L);
    }

    @Test
    @DisplayName("타인 조회 시 ADMIN이 아니면 FORBIDDEN")
    void getUser_forbiddenForNonAdmin() {
        assertThatThrownBy(() -> userService.getUser(2L, 1L, "ROLE_USER"))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getErrorCode().getCode())
                .isEqualTo("COMMON-0004");
    }

    @Test
    @DisplayName("존재하지 않는 사용자 조회 시 USER_NOT_FOUND")
    void getUser_notFound() {
        given(userMapper.findById(99L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> userService.getUser(99L, 1L, "ROLE_ADMIN"))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getErrorCode())
                .isEqualTo(UserErrorCode.USER_NOT_FOUND);
    }

    @Test
    @DisplayName("본인 정보 수정 성공")
    void updateUser_self() {
        UpdateUserRequest req = mockUpdateRequest("bob", null);
        User updated = User.builder().id(1L).username("bob").email("alice@example.com")
                .role("ROLE_USER").enabled(true).createdAt(sampleUser.getCreatedAt())
                .updatedAt(LocalDateTime.now()).build();
        given(userMapper.findById(1L))
                .willReturn(Optional.of(sampleUser))
                .willReturn(Optional.of(updated));

        UserResponse result = userService.updateUser(1L, req, 1L, "ROLE_USER");

        verify(userMapper).update(any(User.class));
        assertThat(result.getUsername()).isEqualTo("bob");
    }

    @Test
    @DisplayName("ADMIN 계정 삭제 성공")
    void deleteUser_admin() {
        given(userMapper.findById(1L)).willReturn(Optional.of(sampleUser));

        userService.deleteUser(1L);

        verify(userMapper).deleteById(1L);
    }

    @Test
    @DisplayName("존재하지 않는 사용자 삭제 시 USER_NOT_FOUND")
    void deleteUser_notFound() {
        given(userMapper.findById(99L)).willReturn(Optional.empty());

        assertThatThrownBy(() -> userService.deleteUser(99L))
                .isInstanceOf(BusinessException.class)
                .extracting(e -> ((BusinessException) e).getErrorCode())
                .isEqualTo(UserErrorCode.USER_NOT_FOUND);
    }

    private RegisterRequest mockRegisterRequest(String username, String email, String password) {
        RegisterRequest req = org.mockito.Mockito.mock(RegisterRequest.class);
        given(req.getUsername()).willReturn(username);
        given(req.getEmail()).willReturn(email);
        given(req.getPassword()).willReturn(password);
        return req;
    }

    private UpdateUserRequest mockUpdateRequest(String username, String password) {
        UpdateUserRequest req = org.mockito.Mockito.mock(UpdateUserRequest.class);
        given(req.getUsername()).willReturn(username);
        given(req.getPassword()).willReturn(password);
        return req;
    }
}
