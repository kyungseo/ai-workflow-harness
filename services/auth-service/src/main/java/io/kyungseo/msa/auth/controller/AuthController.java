package io.kyungseo.msa.auth.controller;

import io.kyungseo.msa.auth.dto.LoginRequest;
import io.kyungseo.msa.auth.dto.LoginResponse;
import io.kyungseo.msa.auth.dto.LogoutRequest;
import io.kyungseo.msa.auth.dto.RefreshRequest;
import io.kyungseo.msa.auth.dto.RefreshResponse;
import io.kyungseo.msa.auth.exception.AuthErrorCode;
import io.kyungseo.msa.auth.service.AuthService;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.common.response.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Auth", description = "인증 API")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "로그인", description = "username/password로 JWT 발급")
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.login(request)));
    }

    @Operation(summary = "토큰 갱신", description = "Refresh Token으로 새 Access/Refresh Token 발급")
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<RefreshResponse>> refresh(@Valid @RequestBody RefreshRequest request) {
        return ResponseEntity.ok(ApiResponse.success(authService.refresh(request)));
    }

    @Operation(summary = "로그아웃", description = "Access Token 블랙리스트 등록 + Refresh Token 삭제")
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(
            @RequestHeader(value = "Authorization", required = false) String authorizationHeader,
            @Valid @RequestBody LogoutRequest request) {

        String token = extractBearerToken(authorizationHeader);
        authService.logout(token, request);
        return ResponseEntity.ok(ApiResponse.success());
    }

    private String extractBearerToken(String header) {
        if (!StringUtils.hasText(header) || !header.startsWith("Bearer ")) {
            throw new BusinessException(AuthErrorCode.INVALID_TOKEN);
        }
        return header.substring(7);
    }
}
