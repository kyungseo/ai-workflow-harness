package io.kyungseo.msa.todo.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("io.kyungseo.msa.todo.mapper")
public class MyBatisConfig {
}
