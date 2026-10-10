package com.example.consulta.ratelimit;

import com.example.consulta.exception.TooManyRequestsException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitInterceptor implements HandlerInterceptor {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final int capacity;
    private final long refillSeconds;
    private final long expirationNanos;

    public RateLimitInterceptor(
            @Value("${ratelimit.capacity}") int capacity,
            @Value("${ratelimit.refill-seconds}") long refillSeconds
    ) {
        if (capacity <= 0 || refillSeconds <= 0) {
            throw new IllegalArgumentException("Rate limit capacity and refill seconds must be positive");
        }
        this.capacity = capacity;
        this.refillSeconds = refillSeconds;
        this.expirationNanos = Duration.ofSeconds(refillSeconds).toNanos();
    }

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler
    ) {
        String clientIp = request.getRemoteAddr();
        long now = System.nanoTime();
        removeExpiredBuckets(now);

        Bucket bucket = buckets.computeIfAbsent(clientIp, ignored -> new Bucket(capacity, now));
        long retryAfterSeconds;
        synchronized (bucket) {
            bucket.refill(now, capacity, refillSeconds);
            if (bucket.tokens < 1) {
                retryAfterSeconds = bucket.secondsUntilNextToken(now, refillSeconds);
            } else {
                bucket.tokens--;
                bucket.lastSeenNanos = now;
                return true;
            }
        }

        throw new TooManyRequestsException(retryAfterSeconds);
    }

    private void removeExpiredBuckets(long now) {
        buckets.entrySet().removeIf(entry -> now - entry.getValue().lastSeenNanos > expirationNanos);
    }

    private static final class Bucket {

        private double tokens;
        private long lastRefillNanos;
        private long lastSeenNanos;

        private Bucket(int capacity, long now) {
            this.tokens = capacity;
            this.lastRefillNanos = now;
            this.lastSeenNanos = now;
        }

        private void refill(long now, int capacity, long refillSeconds) {
            long elapsedNanos = now - lastRefillNanos;
            if (elapsedNanos <= 0) {
                return;
            }

            double refill = (double) elapsedNanos / Duration.ofSeconds(refillSeconds).toNanos() * capacity;
            tokens = Math.min(capacity, tokens + refill);
            lastRefillNanos = now;
            lastSeenNanos = now;
        }

        private long secondsUntilNextToken(long now, long refillSeconds) {
            double missingFraction = 1 - tokens;
            long nanosUntilToken = (long) Math.ceil(
                    missingFraction * Duration.ofSeconds(refillSeconds).toNanos()
            );
            long elapsedNanos = Math.max(0, now - lastRefillNanos);
            long remainingNanos = Math.max(0, nanosUntilToken - elapsedNanos);
            return Math.max(1, (long) Math.ceil(remainingNanos / 1_000_000_000.0));
        }
    }
}
