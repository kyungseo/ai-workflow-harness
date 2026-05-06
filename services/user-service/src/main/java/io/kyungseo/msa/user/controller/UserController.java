package io.kyungseo.msa.user.controller;

import io.kyungseo.msa.common.response.ApiResponse;
import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.user.dto.RegisterRequest;
import io.kyungseo.msa.user.dto.UpdateUserRequest;
import io.kyungseo.msa.user.dto.UserResponse;
import io.kyungseo.msa.user.service.UserService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ApiResponse<UserResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ApiResponse.success(userService.register(request));
    }

    @GetMapping
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    public ApiResponse<PageResponse<UserResponse>> getUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ApiResponse.success(userService.getUsers(page, size));
    }

    @GetMapping("/{id}")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<UserResponse> getUser(@PathVariable Long id) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        Long requesterId = (Long) auth.getPrincipal();
        String role = auth.getAuthorities().iterator().next().getAuthority();
        return ApiResponse.success(userService.getUser(id, requesterId, role));
    }

    @PatchMapping("/{id}")
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("isAuthenticated()")
    public ApiResponse<UserResponse> updateUser(@PathVariable Long id,
                                                @Valid @RequestBody UpdateUserRequest request) {
        var auth = SecurityContextHolder.getContext().getAuthentication();
        Long requesterId = (Long) auth.getPrincipal();
        String role = auth.getAuthorities().iterator().next().getAuthority();
        return ApiResponse.success(userService.updateUser(id, request, requesterId, role));
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @SecurityRequirement(name = "bearerAuth")
    @PreAuthorize("hasRole('ADMIN')")
    public void deleteUser(@PathVariable Long id) {
        userService.deleteUser(id);
    }
}
