package io.kyungseo.msa.todo.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserExistenceMapper {

    boolean existsById(@Param("userId") Long userId);
}
