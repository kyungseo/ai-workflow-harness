package io.kyungseo.msa.user.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("io.kyungseo.msa.user.mapper")
public class MyBatisConfig {
}
