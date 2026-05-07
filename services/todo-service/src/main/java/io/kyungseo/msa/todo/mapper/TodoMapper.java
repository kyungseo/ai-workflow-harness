package io.kyungseo.msa.todo.mapper;

import io.kyungseo.msa.todo.domain.Todo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Optional;

@Mapper
public interface TodoMapper {

    List<Todo> findAllByUserId(@Param("userId") Long userId,
                               @Param("offset") int offset,
                               @Param("size") int size,
                               @Param("completed") Boolean completed);

    long countByUserId(@Param("userId") Long userId,
                       @Param("completed") Boolean completed);

    Optional<Todo> findById(@Param("id") Long id);

    void insert(Todo todo);

    void update(Todo todo);

    void updateCompleted(@Param("id") Long id, @Param("completed") Boolean completed);

    void deleteById(@Param("id") Long id);
}
