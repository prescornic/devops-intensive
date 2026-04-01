package com.example.demo.config;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.api.common.Attributes;
import io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporter;
import io.opentelemetry.sdk.OpenTelemetrySdk;
import io.opentelemetry.sdk.resources.Resource;
import io.opentelemetry.sdk.trace.SdkTracerProvider;
import io.opentelemetry.sdk.trace.export.BatchSpanProcessor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

@Configuration
public class OtelGrpcTracingConfig {

    @Value("${spring.application.name:demo-api}")
    private String applicationName;

    @Value("${app.environment:dev}")
    private String environment;

    @Value("${OTLP_TRACES_ENDPOINT:https://tempo-prod-10-prod-eu-west-2.grafana.net:443}")
    private String tracesEndpoint;

    @Value("${OTLP_TRACES_AUTH_HEADER:${OTLP_AUTH_HEADER:}}")
    private String tracesAuthHeader;

    @Bean
    public Resource otelResource() {
        return Resource.getDefault().merge(
            Resource.create(
                Attributes.builder()
                    .put("service.name", applicationName)
                    .put("service.version", "1.0.0")
                    .put("environment", environment)
                    .build()
            )
        );
    }

    @Bean
    public OtlpGrpcSpanExporter otlpGrpcSpanExporter() {
        OtlpGrpcSpanExporterBuilderFacade builder = new OtlpGrpcSpanExporterBuilderFacade(tracesEndpoint);
        if (StringUtils.hasText(tracesAuthHeader)) {
            builder.addAuthorizationHeader(tracesAuthHeader);
        }
        return builder.build();
    }

    @Bean
    public SdkTracerProvider sdkTracerProvider(Resource otelResource, OtlpGrpcSpanExporter spanExporter) {
        return SdkTracerProvider.builder()
            .addSpanProcessor(BatchSpanProcessor.builder(spanExporter).build())
            .setResource(otelResource)
            .build();
    }

    @Bean
    public OpenTelemetry openTelemetry(SdkTracerProvider tracerProvider) {
        return OpenTelemetrySdk.builder()
            .setTracerProvider(tracerProvider)
            .build();
    }

    // Small wrapper keeps configuration code concise and testable.
    static class OtlpGrpcSpanExporterBuilderFacade {
        private final io.opentelemetry.exporter.otlp.trace.OtlpGrpcSpanExporterBuilder delegate;

        OtlpGrpcSpanExporterBuilderFacade(String endpoint) {
            this.delegate = OtlpGrpcSpanExporter.builder().setEndpoint(endpoint);
        }

        void addAuthorizationHeader(String headerValue) {
            delegate.addHeader("Authorization", headerValue);
        }

        OtlpGrpcSpanExporter build() {
            return delegate.build();
        }
    }
}
