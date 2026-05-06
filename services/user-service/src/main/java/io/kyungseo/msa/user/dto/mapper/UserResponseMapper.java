package io.kyungseo.msa.user.dto.mapper;

import io.kyungseo.msa.user.domain.User;
import io.kyungseo.msa.user.dto.UserResponse;
import org.mapstruct.Mapper;

/**
 * MapStruct: User 도메인 → UserResponse DTO 변환.
 * password 필드는 UserResponse에 없으므로 자동으로 제외된다.
 */
@Mapper(componentModel = "spring")
public interface UserResponseMapper {
    UserResponse toResponse(User user);
}
