package io.kyungseo.msa.user.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Gateway가 주입한 X-User-Id / X-User-Role 헤더로 SecurityContext를 구성한다.
 * 헤더가 없으면 anonymous로 처리 — 공개 엔드포인트(회원가입)는 Security 설정에서 허용.
 *
 * [Header Spoofing 설계 범위]
 * Phase 1: Gateway가 JWT 검증 후 헤더를 주입하며, user-service는 Gateway 경유만 허용한다고
 * 가정한다(네트워크 레벨 격리). 외부에서 이 헤더를 직접 위조하는 것은 Gateway 앞단의 인프라
 * 제어로 방어한다.
 * Phase 2: K8s NetworkPolicy로 user-service → Gateway 트래픽만 허용하여 강제한다.
 */
@Slf4j
public class UserContextFilter extends OncePerRequestFilter {

    static final String HEADER_USER_ID = "X-User-Id";
    static final String HEADER_USER_ROLE = "X-User-Role";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String userIdHeader = request.getHeader(HEADER_USER_ID);
        String roleHeader = request.getHeader(HEADER_USER_ROLE);

        if (StringUtils.hasText(userIdHeader) && StringUtils.hasText(roleHeader)) {
            try {
                Long userId = Long.parseLong(userIdHeader);
                var authority = new SimpleGrantedAuthority(roleHeader);
                var auth = new UsernamePasswordAuthenticationToken(userId, null, List.of(authority));
                SecurityContextHolder.getContext().setAuthentication(auth);
            } catch (NumberFormatException e) {
                log.warn("Invalid X-User-Id header value: {}", userIdHeader);
            }
        }

        try {
            filterChain.doFilter(request, response);
        } finally {
            SecurityContextHolder.clearContext();
        }
    }
}
