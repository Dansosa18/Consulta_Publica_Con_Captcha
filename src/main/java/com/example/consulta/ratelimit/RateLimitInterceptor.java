package com.example.consulta.ratelimit;

import com.example.consulta.exception.TooManyRequestsException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitInterceptor implements HandlerInterceptor {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();
    private final int capacity;
    private final long refillSeconds;
    private final long expirationNanos;
    private final byte[] internalToken;

    public RateLimitInterceptor(
            @Value("${ratelimit.capacity}") int capacity,
            @Value("${ratelimit.refill-seconds}") long refillSeconds,
            @Value("${internal.token}") String internalToken
    ) {
        if (capacity <= 0 || refillSeconds <= 0 || internalToken.isBlank()) {
            throw new IllegalArgumentException("Rate limit capacity and refill seconds must be positive");
        }
        this.capacity = capacity;
        this.refillSeconds = refillSeconds;
        this.expirationNanos = Duration.ofSeconds(refillSeconds).toNanos();
        this.internalToken = internalToken.getBytes(StandardCharsets.UTF_8);
    }

    @Override
    public boolean preHandle(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler
    ) {
        String clientIp = resolveClientIp(request);
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

    private String resolveClientIp(HttpServletRequest request) {
        String forwardedFor = request.getHeader("X-Forwarded-For");
        String internalTokenHeader = request.getHeader("X-Internal-Token");
        if (isValidInternalToken(internalTokenHeader) && forwardedFor != null) {
            String forwardedIp = forwardedFor.split(",")[0].trim();
            if (isIpAddress(forwardedIp)) {
                return forwardedIp;
            }
        }
        return request.getRemoteAddr();
    }

    private boolean isValidInternalToken(String candidate) {
        return candidate != null
                && MessageDigest.isEqual(
                internalToken,
                candidate.getBytes(StandardCharsets.UTF_8)
        );
    }

    private boolean isIpAddress(String value) {
        if (value.isBlank()) {
            return false;
        }
        if (value.contains(":")) {
            try {
                return InetAddress.getByName(value).getHostAddress().contains(":");
            } catch (UnknownHostException exception) {
                return false;
            }
        }
        String[] octets = value.split("\\.", -1);
        if (octets.length != 4) {
            return false;
        }
        for (String octet : octets) {
            if (octet.isEmpty() || !octet.chars().allMatch(Character::isDigit)) {
                return false;
            }
            try {
                if (Integer.parseInt(octet) > 255) {
                    return false;
                }
            } catch (NumberFormatException exception) {
                return false;
            }
        }
        return true;
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
