import { getAccountStatus } from "@/lib/consultaClient";
import { NextRequest, NextResponse } from "next/server";

const METER_CODE_PATTERN = /^[A-Za-z0-9][A-Za-z0-9_-]*$/;
const CAPTCHA_VERIFY_URL =
  "https://www.google.com/recaptcha/api/siteverify";
const CAPTCHA_TIMEOUT_MS = 5_000;

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();

    if (
      typeof body?.meterCode !== "string" ||
      body.meterCode.length === 0 ||
      body.meterCode.length > 50 ||
      !METER_CODE_PATTERN.test(body.meterCode)
    ) {
      return NextResponse.json({ error: "invalid_code" }, { status: 400 });
    }

    const clientIp = getClientIp(request);
    const captchaResult = await verifyCaptcha(body?.captchaToken, clientIp);
    if (captchaResult === "failed") {
      return NextResponse.json({ error: "captcha_failed" }, { status: 403 });
    }
    if (captchaResult === "unavailable") {
      return NextResponse.json(
        { error: "captcha_unavailable" },
        { status: 503 }
      );
    }

    const result = await getAccountStatus(body.meterCode, clientIp);

    if (result.ok) {
      return NextResponse.json(result.data, { status: 200 });
    }

    switch (result.status) {
      case 400:
        return NextResponse.json({ error: "invalid_code" }, { status: 400 });
      case 404:
        return NextResponse.json(
          { error: "not_found" },
          { status: 404 }
        );
      case 429: {
        const headers = new Headers();
        if (result.retryAfter !== undefined) {
          headers.set("Retry-After", String(result.retryAfter));
        }
        return NextResponse.json(
          {
            error: "rate_limited",
            ...(result.retryAfter !== undefined
              ? { retryAfter: result.retryAfter }
              : {}),
          },
          { status: 429, headers }
        );
      }
      case 504:
        return NextResponse.json(
          { error: "service_unavailable" },
          { status: 504 }
        );
      case 502:
      default:
        return NextResponse.json(
          { error: "service_unavailable" },
          { status: 502 }
        );
    }
  } catch (error) {
    console.error("Consulta request failed", error);
    return NextResponse.json({ error: "internal" }, { status: 500 });
  }
}

async function verifyCaptcha(
  token: unknown,
  clientIp: string
): Promise<"valid" | "failed" | "unavailable"> {
  if (process.env.NODE_ENV !== "production" && process.env.DISABLE_CAPTCHA === "true") {
    return "valid";
  }

  if (typeof token !== "string" || token.length === 0) {
    return "failed";
  }

  const secret = process.env.RECAPTCHA_SECRET_KEY;
  if (!secret) {
    return "unavailable";
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), CAPTCHA_TIMEOUT_MS);

  try {
    const params = new URLSearchParams({
      secret,
      response: token,
      remoteip: clientIp,
    });
    const response = await fetch(CAPTCHA_VERIFY_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: params.toString(),
      cache: "no-store",
      signal: controller.signal,
    });

    if (!response.ok) {
      return "unavailable";
    }

    const result = (await response.json()) as { success?: boolean };
    return result.success === true ? "valid" : "failed";
  } catch {
    return "unavailable";
  } finally {
    clearTimeout(timeout);
  }
}

function getClientIp(request: NextRequest): string {
  const forwardedFor = request.headers.get("x-forwarded-for");
  return forwardedFor?.split(",")[0].trim() || "unknown";
}
