package com.example.demo;

import java.net.URI;
import java.util.Objects;
import java.util.List;

import com.example.demo.metrics.ApplicationMetrics;
import io.micrometer.core.instrument.Timer;
import io.micrometer.tracing.Span;
import io.micrometer.tracing.Tracer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
public class UserController {
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final UserRepository userRepository;
    private final ApplicationMetrics metrics;
    private final Tracer tracer;

    public UserController(UserRepository userRepository, ApplicationMetrics metrics, Tracer tracer) {
        this.userRepository = userRepository;
        this.metrics = metrics;
        this.tracer = tracer;
    }

    @GetMapping
    public List<User> listUsers() {
        Span operationSpan = tracer.nextSpan().name("users.list").start();
        Timer.Sample sample = metrics.recordUserRetrievalStart();
        try (Tracer.SpanInScope operationScope = tracer.withSpan(operationSpan)) {
            operationSpan.tag("app.operation", "list-users");
            operationSpan.event("users.list.started");
            logger.info(
                "Listing all users - traceId={} spanId={}",
                operationSpan.context().traceId(),
                operationSpan.context().spanId()
            );

            Span repositorySpan = tracer.nextSpan(operationSpan).name("users.list.repository.findAll").start();
            try (Tracer.SpanInScope repositoryScope = tracer.withSpan(repositorySpan)) {
                List<User> users = userRepository.findAll();
                metrics.recordUserRetrieved();

                operationSpan.tag("app.users.count", String.valueOf(users.size()));
                operationSpan.event("users.list.completed");
                logger.info(
                    "Retrieved {} users - traceId={} spanId={}",
                    users.size(),
                    operationSpan.context().traceId(),
                    operationSpan.context().spanId()
                );
                return users;
            } catch (Exception e) {
                repositorySpan.error(e);
                throw e;
            } finally {
                repositorySpan.end();
            }
        } catch (Exception e) {
            operationSpan.error(e);
            logger.error(
                "Error retrieving users - traceId={} spanId={}",
                operationSpan.context().traceId(),
                operationSpan.context().spanId(),
                e
            );
            metrics.recordError();
            throw e;
        } finally {
            metrics.recordUserRetrievalEnd(sample);
            operationSpan.end();
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<User> getUser(@PathVariable long id) {
        Span operationSpan = tracer.nextSpan().name("users.get").start();
        Timer.Sample sample = metrics.recordUserRetrievalStart();
        try (Tracer.SpanInScope operationScope = tracer.withSpan(operationSpan)) {
            operationSpan.tag("app.operation", "get-user");
            operationSpan.tag("app.user.id", String.valueOf(id));
            operationSpan.event("users.get.started");
            logger.info(
                "Fetching user with id={} - traceId={} spanId={}",
                id,
                operationSpan.context().traceId(),
                operationSpan.context().spanId()
            );

            Span repositorySpan = tracer.nextSpan(operationSpan).name("users.get.repository.findById").start();
            try (Tracer.SpanInScope repositoryScope = tracer.withSpan(repositorySpan)) {
                ResponseEntity<User> response = userRepository.findById(id)
                        .map(user -> {
                            logger.info(
                                "User {} found - traceId={} spanId={}",
                                id,
                                operationSpan.context().traceId(),
                                operationSpan.context().spanId()
                            );
                            metrics.recordUserRetrieved();
                            operationSpan.event("users.get.found");
                            return ResponseEntity.ok(user);
                        })
                        .orElseGet(() -> {
                            logger.warn(
                                "User {} not found - traceId={} spanId={}",
                                id,
                                operationSpan.context().traceId(),
                                operationSpan.context().spanId()
                            );
                            operationSpan.event("users.get.not_found");
                            return ResponseEntity.notFound().build();
                        });
                return response;
            } catch (Exception e) {
                repositorySpan.error(e);
                throw e;
            } finally {
                repositorySpan.end();
            }
        } catch (Exception e) {
            operationSpan.error(e);
            logger.error(
                "Error retrieving user id={} - traceId={} spanId={}",
                id,
                operationSpan.context().traceId(),
                operationSpan.context().spanId(),
                e
            );
            metrics.recordError();
            throw e;
        } finally {
            metrics.recordUserRetrievalEnd(sample);
            operationSpan.end();
        }
    }

    @PostMapping
    public ResponseEntity<User> createUser(@RequestBody User user) {
        Span operationSpan = tracer.nextSpan().name("users.create").start();
        Timer.Sample sample = metrics.recordUserCreationStart();
        try (Tracer.SpanInScope operationScope = tracer.withSpan(operationSpan)) {
            operationSpan.tag("app.operation", "create-user");
            operationSpan.event("users.create.started");
            logger.info(
                "Creating new user name={} - traceId={} spanId={}",
                user.getName(),
                operationSpan.context().traceId(),
                operationSpan.context().spanId()
            );

            Span repositorySpan = tracer.nextSpan(operationSpan).name("users.create.repository.save").start();
            try (Tracer.SpanInScope repositoryScope = tracer.withSpan(repositorySpan)) {
                User saved = userRepository.save(new User(user.getName(), user.getEmail()));
                metrics.recordUserCreated();

                operationSpan.tag("app.user.id", String.valueOf(saved.getId()));
                operationSpan.event("users.create.completed");
                logger.info(
                    "User created successfully id={} - traceId={} spanId={}",
                    saved.getId(),
                    operationSpan.context().traceId(),
                    operationSpan.context().spanId()
                );
                URI location = Objects.requireNonNull(URI.create("/api/users/" + saved.getId()));
                return ResponseEntity.created(location).body(saved);
            } catch (Exception e) {
                repositorySpan.error(e);
                throw e;
            } finally {
                repositorySpan.end();
            }
        } catch (Exception e) {
            operationSpan.error(e);
            logger.error(
                "Error creating user name={} - traceId={} spanId={}",
                user.getName(),
                operationSpan.context().traceId(),
                operationSpan.context().spanId(),
                e
            );
            metrics.recordError();
            throw e;
        } finally {
            metrics.recordUserCreationEnd(sample);
            operationSpan.end();
        }
    }
}
