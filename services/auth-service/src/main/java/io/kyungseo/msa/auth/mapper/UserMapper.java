package io.kyungseo.msa.auth.mapper;

import io.kyungseo.msa.auth.domain.User;
import org.apache.ibatis.annotations.Mapper;

import java.util.Optional;

@Mapper
public interface UserMapper {
    Optional<User> findByUsername(String username);
    Optional<User> findById(Long id);
}
