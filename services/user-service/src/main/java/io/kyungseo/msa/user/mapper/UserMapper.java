package io.kyungseo.msa.user.mapper;

import io.kyungseo.msa.user.domain.User;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface UserMapper {
    List<User> findAll(@Param("offset") int offset, @Param("size") int size);
    long count();
    Optional<User> findById(Long id);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    void insert(User user);
    void update(User user);
    void deleteById(Long id);
}
