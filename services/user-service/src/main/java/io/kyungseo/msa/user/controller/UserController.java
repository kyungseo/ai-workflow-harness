package io.kyungseo.msa.user.controller;

import io.kyungseo.msa.common.response.ApiResponse;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.user.dto.RegisterRequest;
import io.kyungseo.msa.user.dto.UpdateUserRequest;
import io.kyungseo.msa.user.dto.UserResponse;
import io.kyungseo.msa.user.service.UserService;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "User", description = "사용자 API")
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @Operation(summary = "회원가입", description = "신규 사용자 등록 (공개)")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success(userService.register(request));
    }

    @Operation(summary = "사용자 목록 조회", description = "전체 사용자 페이징 조회 (ADMIN 전용)")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PageResponse<UserResponse>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(userService.getUsers(page, size));
    }

    @Operation(summary = "사용자 단건 조회", description = "본인 또는 ADMIN만 조회 가능")
    @SecurityRequirement(name = "bearerAuth")
    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<UserResponse> getUser(@PathVariable Long id) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        Long requesterId = (Long) auth.getPrincipal();
        String role = auth.getAuthorities().iterator().next().getAuthority();
        return ApiResponse.success(userService.getUser(id, requesterId, role));
    }

    @Operation(summary = "사용자 정보 수정", description = "본인 또는 ADMIN만 수정 가능. username/password 선택적 입력")
    @SecurityRequirement(name = "bearerAuth")
    @PatchMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<UserResponse> updateUser(@PathVariable Long id,
                                                @Valid @RequestBody UpdateUserRequest request) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        Long requesterId = (Long) auth.getPrincipal();
        String role = auth.getAuthorities().iterator().next().getAuthority();
        return ApiResponse.success(userService.updateUser(id, request, requesterId, role));
    }

    @Operation(summary = "사용자 삭제", description = "ADMIN 전용")
    @SecurityRequirement(name = "bearerAuth")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }
}
