package io.kyungseo.msa.auth.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("io.kyungseo.msa.auth.mapper")
public class MyBatisConfig {
}
