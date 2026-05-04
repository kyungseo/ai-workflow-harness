package io.kyungseo.msa.common.logging;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.assertj.core.api.Assertions.assertThat;

class MdcFilterTest {

    private final MdcFilter filter = new MdcFilter();

    @AfterEach
    void clearMdc() {
        MDC.clear();
    }

    @Test
    void existingCorrelationId_isPreservedInMdc() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader(LoggingConstants.CORRELATION_ID, "test-id-123");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) ->
                assertThat(MDC.get(LoggingConstants.CORRELATION_ID)).isEqualTo("test-id-123")
        );
    }

    @Test
    void missingCorrelationId_generatesUuid() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> {
            String correlationId = MDC.get(LoggingConstants.CORRELATION_ID);
            assertThat(correlationId).isNotNull().isNotBlank();
        });
    }

    @Test
    void afterFilter_mdcIsCleared() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> {});

        assertThat(MDC.get(LoggingConstants.CORRELATION_ID)).isNull();
    }

    @Test
    void correlationId_isPropagatedToResponseHeader() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader(LoggingConstants.CORRELATION_ID, "propagate-me");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> {});

        assertThat(response.getHeader(LoggingConstants.CORRELATION_ID)).isEqualTo("propagate-me");
    }
}
