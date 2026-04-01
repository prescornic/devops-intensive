package com.example.demo.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

/**
 * Custom metrics for business operations
 * Publishes metrics to Prometheus (and via OTLP to Grafana Cloud)
 */
@Component
public class ApplicationMetrics {

    private final MeterRegistry meterRegistry;
    private final Counter usersCreated;
    private final Counter usersRetrieved;
    private final Counter apiErrors;
    private final Timer userCreationTimer;
    private final Timer userRetrievalTimer;

    public ApplicationMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        // Counters for tracking event counts
        this.usersCreated = Counter.builder("app.users.created.total")
            .description("Total number of users created")
            .tag("service", "backend")
            .register(meterRegistry);

        this.usersRetrieved = Counter.builder("app.users.retrieved.total")
            .description("Total number of user retrieval requests")
            .tag("service", "backend")
            .register(meterRegistry);

        this.apiErrors = Counter.builder("app.api.errors.total")
            .description("Total number of API errors")
            .tag("service", "backend")
            .register(meterRegistry);

        // Timers for measuring operation durations
        this.userCreationTimer = Timer.builder("app.user.creation.duration")
            .description("Time taken to create a user")
            .tag("service", "backend")
            .publishPercentiles(0.5, 0.95, 0.99)
            .register(meterRegistry);

        this.userRetrievalTimer = Timer.builder("app.user.retrieval.duration")
            .description("Time taken to retrieve users")
            .tag("service", "backend")
            .publishPercentiles(0.5, 0.95, 0.99)
            .register(meterRegistry);
    }

    /**
     * Record a new user creation
     */
    public void recordUserCreated() {
        usersCreated.increment();
    }

    /**
     * Record a user retrieval operation
     */
    public void recordUserRetrieved() {
        usersRetrieved.increment();
    }

    /**
     * Record an API error
     */
    public void recordError() {
        apiErrors.increment();
    }

    /**
     * Record the time taken for user creation
     */
    public Timer.Sample recordUserCreationStart() {
        return Timer.start(meterRegistry);
    }

    public void recordUserCreationEnd(Timer.Sample sample) {
        sample.stop(userCreationTimer);
    }

    /**
     * Record the time taken for user retrieval
     */
    public Timer.Sample recordUserRetrievalStart() {
        return Timer.start(meterRegistry);
    }

    public void recordUserRetrievalEnd(Timer.Sample sample) {
        sample.stop(userRetrievalTimer);
    }

    /**
     * Gauge for tracking active request count
     */
    public void registerGauge(String name, java.util.function.Supplier<Number> supplier) {
        io.micrometer.core.instrument.Gauge.builder(name, supplier)
            .tag("service", "backend")
            .register(meterRegistry);
    }
}
