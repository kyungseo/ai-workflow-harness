package io.kyungseo.msa.user.service;

import io.kyungseo.msa.common.response.PageResponse;
import io.kyungseo.msa.common.exception.BusinessException;
import io.kyungseo.msa.user.domain.User;
import io.kyungseo.msa.user.dto.RegisterRequest;
import io.kyungseo.msa.user.dto.UpdateUserRequest;
import io.kyungseo.msa.user.dto.UserResponse;
import io.kyungseo.msa.user.exception.UserErrorCode;
import io.kyungseo.msa.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public UserResponse register(RegisterRequest request) {
        if (userMapper.existsByEmail(request.getEmail())) {
            throw new BusinessException(UserErrorCode.DUPLICATE_EMAIL);
        }
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role("ROLE_USER")
                .enabled(true)
                .build();
        userMapper.insert(user);
        return UserResponse.from(user);
    }

    @Transactional(readOnly = true)
    public PageResponse<UserResponse> getUsers(int page, int size) {
        int offset = page * size;
        long total = userMapper.count();
        List<UserResponse> content = userMapper.findAll(offset, size).stream()
                .map(UserResponse::from)
                .toList();
        int totalPages = (int) Math.ceil((double) total / size);
        return PageResponse.<UserResponse>builder()
                .content(content)
                .page(page)
                .size(size)
                .totalElements(total)
                .totalPages(totalPages)
                .build();
    }

    @Transactional(readOnly = true)
    public UserResponse getUser(Long targetUserId, Long requesterId, String requesterRole) {
        if (!targetUserId.equals(requesterId) && !"ROLE_ADMIN".equals(requesterRole)) {
            throw new BusinessException(io.kyungseo.msa.common.exception.CommonErrorCode.FORBIDDEN);
        }
        return userMapper.findById(targetUserId)
                .map(UserResponse::from)
                .orElseThrow(() -> new BusinessException(UserErrorCode.USER_NOT_FOUND));
    }

    @Transactional
    public UserResponse updateUser(Long targetUserId, UpdateUserRequest request,
                                   Long requesterId, String requesterRole) {
        if (!targetUserId.equals(requesterId) && !"ROLE_ADMIN".equals(requesterRole)) {
            throw new BusinessException(io.kyungseo.msa.common.exception.CommonErrorCode.FORBIDDEN);
        }
        User existing = userMapper.findById(targetUserId)
                .orElseThrow(() -> new BusinessException(UserErrorCode.USER_NOT_FOUND));

        User toUpdate = User.builder()
                .id(existing.getId())
                .username(StringUtils.hasText(request.getUsername()) ? request.getUsername() : existing.getUsername())
                .password(StringUtils.hasText(request.getPassword())
                        ? passwordEncoder.encode(request.getPassword())
                        : null)
                .build();
        userMapper.update(toUpdate);
        return userMapper.findById(targetUserId)
                .map(UserResponse::from)
                .orElseThrow(() -> new BusinessException(UserErrorCode.USER_NOT_FOUND));
    }

    @Transactional
    public void deleteUser(Long targetUserId) {
        if (!userMapper.findById(targetUserId).isPresent()) {
            throw new BusinessException(UserErrorCode.USER_NOT_FOUND);
        }
        userMapper.deleteById(targetUserId);
    }
}
