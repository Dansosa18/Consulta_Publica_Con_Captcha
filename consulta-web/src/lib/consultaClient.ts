export interface RecentReading {
  date: string;
  consumptionLiters: number;
  amount: number;
}

export interface RecentPayment {
  paymentDate: string;
  amount: number;
  receiptNumber: string;
}

export interface AccountStatusResponse {
  meterCode: string;
  holderName: string;
  meterActive: boolean;
  pendingBalance: number;
  recentReadings: RecentReading[];
  recentPayments: RecentPayment[];
}

export interface ErrorResponse {
  timestamp: string;
  status: number;
  error: string;
  message: string;
  path: string;
}

export type AccountStatusResult =
  | { ok: true; data: AccountStatusResponse }
  | { ok: false; status: number; retryAfter?: number };

const METER_CODE_PATTERN = /^[A-Za-z0-9][A-Za-z0-9_-]*$/;
const REQUEST_TIMEOUT_MS = 5_000;

export async function getAccountStatus(
  meterCode: string,
  clientIp: string
): Promise<AccountStatusResult> {
  if (
    meterCode.length === 0 ||
    meterCode.length > 50 ||
    !METER_CODE_PATTERN.test(meterCode)
  ) {
    return { ok: false, status: 400 };
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const apiUrl = process.env.CONSULTA_API_URL ?? "http://localhost:8081";
    const endpoint = `${apiUrl.replace(/\/+$/, "")}/api/v1/public/accounts/${encodeURIComponent(meterCode)}`;
    const response = await fetch(endpoint, {
      headers: {
        "X-Forwarded-For": clientIp,
        "X-Internal-Token": process.env.INTERNAL_TOKEN ?? "",
      },
      cache: "no-store",
      signal: controller.signal,
    });

    if (response.ok) {
      const data = (await response.json()) as AccountStatusResponse;
      return { ok: true, data };
    }

    return {
      ok: false,
      status: response.status,
      ...(response.status === 429
        ? { retryAfter: parseRetryAfter(response.headers.get("Retry-After")) }
        : {}),
    };
  } catch (error) {
    return {
      ok: false,
      status: error instanceof DOMException && error.name === "AbortError" ? 504 : 502,
    };
  } finally {
    clearTimeout(timeout);
  }
}

function parseRetryAfter(value: string | null): number | undefined {
  if (!value) {
    return undefined;
  }

  const seconds = Number.parseInt(value, 10);
  return Number.isInteger(seconds) && seconds >= 0 ? seconds : undefined;
}
