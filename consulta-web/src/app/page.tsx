"use client";

import ReCAPTCHA from "react-google-recaptcha";
import {
  FormEvent,
  useRef,
  useState,
  useSyncExternalStore,
} from "react";
import type { AccountStatusResponse } from "@/lib/consultaClient";
import styles from "./page.module.css";

type ApiError =
  | { error: "invalid_code" }
  | { error: "not_found" }
  | { error: "rate_limited"; retryAfter?: number }
  | { error: "captcha_failed" }
  | { error: "captcha_unavailable" }
  | { error: "service_unavailable" }
  | { error: "internal" };

const currencyFormatter = new Intl.NumberFormat("es-GT", {
  style: "currency",
  currency: "GTQ",
});

const dateFormatter = new Intl.DateTimeFormat("es-GT", {
  dateStyle: "long",
});

export default function Home() {
  const [meterCode, setMeterCode] = useState("");
  const [account, setAccount] = useState<AccountStatusResponse | null>(null);
  const [error, setError] = useState<ApiError["error"] | null>(null);
  const [retryAfter, setRetryAfter] = useState<number | undefined>();
  const [isLoading, setIsLoading] = useState(false);
  const [captchaToken, setCaptchaToken] = useState<string | null>(null);
  const recaptchaRef = useRef<ReCAPTCHA>(null);
  const captchaEnabled = process.env.NEXT_PUBLIC_DISABLE_CAPTCHA !== "true";
  const isHydrated = useSyncExternalStore(
    () => () => {},
    () => true,
    () => false
  );

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setAccount(null);
    setError(null);
    setRetryAfter(undefined);
    setIsLoading(true);

    try {
      const response = await fetch("/api/consulta", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          meterCode: meterCode.trim(),
          captchaToken,
        }),
      });
      const body = (await response.json()) as
        | AccountStatusResponse
        | ApiError;

      if (response.ok) {
        setAccount(body as AccountStatusResponse);
      } else {
        const apiError = body as ApiError;
        setError(apiError.error);
        if (apiError.error === "rate_limited") {
          setRetryAfter(apiError.retryAfter);
        }
      }
    } catch {
      setError("internal");
    } finally {
      setCaptchaToken(null);
      recaptchaRef.current?.reset();
      setIsLoading(false);
    }
  }

  return (
    <main className={styles.page}>
      <div className={styles.glow} aria-hidden="true" />
      <section className={styles.shell}>
        <div className={styles.card}>
          <header className={styles.header}>
            <div className={styles.brandRow}>
              <div className={styles.brandIcon} aria-hidden="true">
                💧
              </div>
              <span>Oficina de agua</span>
            </div>

            <div className={styles.heroWrap}>
              <div className={styles.heroText}>
                <p className={styles.eyebrow}>Portal de servicios</p>
                <h1>Consulta tu estado de cuenta</h1>
                <p className={styles.subtitle}>
                  Ingresa el código de tu medidor para revisar tu saldo actual,
                  movimientos recientes y el estado de tu servicio.
                </p>
              </div>

              <div className={styles.heroBadge}>
                <span className={styles.badgeDot} aria-hidden="true" />
                Atención en línea
              </div>
            </div>
          </header>

          <form className={styles.searchForm} onSubmit={handleSubmit}>
            <div className={styles.field}>
              <label htmlFor="meterCode">Código del medidor</label>
              <input
                id="meterCode"
                name="meterCode"
                value={meterCode}
                onChange={(event) => setMeterCode(event.target.value)}
                placeholder="Ej. CNT-0001"
                autoComplete="off"
                maxLength={50}
                required
                disabled={isLoading}
              />
            </div>

            {!isHydrated ? (
              <p className={styles.devNotice}>Preparando verificación...</p>
            ) : captchaEnabled ? (
              <div className={styles.captcha}>
                <ReCAPTCHA
                  ref={recaptchaRef}
                  sitekey={process.env.NEXT_PUBLIC_RECAPTCHA_SITE_KEY ?? ""}
                  onChange={setCaptchaToken}
                  onExpired={() => setCaptchaToken(null)}
                  onErrored={() => setCaptchaToken(null)}
                />
              </div>
            ) : (
              <p className={styles.devNotice}>Verificación omitida en desarrollo</p>
            )}

            <button
              type="submit"
              disabled={
                isLoading || !isHydrated || (captchaEnabled && !captchaToken)
              }
            >
              {isLoading ? "Consultando..." : "Consultar"}
            </button>
          </form>

          {error && <ErrorMessage error={error} retryAfter={retryAfter} />}
          {account && <AccountResult account={account} />}
        </div>
      </section>
    </main>
  );
}

function ErrorMessage({
  error,
  retryAfter,
}: {
  error: ApiError["error"];
  retryAfter?: number;
}) {
  const messages: Record<ApiError["error"], string> = {
    invalid_code: "Ingresa un código de medidor válido.",
    not_found: "No encontramos una cuenta con ese código de medidor.",
    rate_limited: retryAfter
      ? `Has realizado demasiadas consultas. Intenta de nuevo en ${retryAfter} segundos.`
      : "Has realizado demasiadas consultas. Intenta nuevamente más tarde.",
    captcha_failed: "Confirma que no eres un robot para continuar.",
    captcha_unavailable:
      "No pudimos validar el captcha. Intenta nuevamente más tarde.",
    service_unavailable:
      "El servicio no está disponible en este momento. Intenta nuevamente más tarde.",
    internal: "No pudimos completar la consulta. Intenta nuevamente.",
  };

  return (
    <div className={styles.alert} role="alert">
      {messages[error]}
    </div>
  );
}

function AccountResult({ account }: { account: AccountStatusResponse }) {
  const latestReading = account.recentReadings[0];

  return (
    <section className={styles.results} aria-live="polite">
      <div className={styles.resultHeader}>
        <div>
          <p className={styles.label}>Cuenta activa</p>
          <h2>{account.holderName}</h2>
        </div>
        <span
          className={account.meterActive ? styles.pillActive : styles.pillInactive}
        >
          {account.meterActive ? "Medidor activo" : "Medidor inactivo"}
        </span>
      </div>

      <div className={styles.summary}>
        <div className={styles.statBox}>
          <p className={styles.label}>Saldo pendiente</p>
          <p className={styles.balance}>{formatCurrency(account.pendingBalance)}</p>
        </div>
        <div className={styles.statBox}>
          <p className={styles.label}>Última lectura</p>
          <p className={styles.value}>
            {latestReading
              ? `${latestReading.consumptionLiters.toLocaleString("es-GT")} L`
              : "Sin registro"}
          </p>
        </div>
        <div className={styles.statBox}>
          <p className={styles.label}>Último pago</p>
          <p className={styles.value}>
            {account.recentPayments[0]
              ? formatCurrency(account.recentPayments[0].amount)
              : "Sin pagos"}
          </p>
        </div>
      </div>

      <div className={styles.tableGrid}>
        <DataTable
          title="Lecturas recientes"
          emptyMessage="No hay lecturas recientes."
          headers={["Fecha", "Consumo", "Monto"]}
          rows={account.recentReadings.map((reading) => [
            formatDate(reading.date),
            `${reading.consumptionLiters.toLocaleString("es-GT")} L`,
            formatCurrency(reading.amount),
          ])}
        />

        <DataTable
          title="Pagos recientes"
          emptyMessage="No hay pagos recientes."
          headers={["Fecha", "Monto", "Recibo"]}
          rows={account.recentPayments.map((payment) => [
            formatDate(payment.paymentDate),
            formatCurrency(payment.amount),
            payment.receiptNumber,
          ])}
        />
      </div>
    </section>
  );
}

function DataTable({
  title,
  headers,
  rows,
  emptyMessage,
}: {
  title: string;
  headers: string[];
  rows: string[][];
  emptyMessage: string;
}) {
  return (
    <section className={styles.tableSection}>
      <div className={styles.tableHead}>
        <h2>{title}</h2>
      </div>
      {rows.length > 0 ? (
        <div className={styles.tableWrapper}>
          <table>
            <thead>
              <tr>
                {headers.map((header) => (
                  <th key={header} scope="col">
                    {header}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {rows.map((row, rowIndex) => (
                <tr key={`${title}-${rowIndex}`}>
                  {row.map((cell, cellIndex) => (
                    <td key={`${title}-${rowIndex}-${cellIndex}`}>{cell}</td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      ) : (
        <p className={styles.empty}>{emptyMessage}</p>
      )}
    </section>
  );
}

function formatCurrency(amount: number) {
  return currencyFormatter.format(amount);
}

function formatDate(date: string) {
  const parsedDate = new Date(`${date}T00:00:00`);
  return Number.isNaN(parsedDate.getTime())
    ? date
    : dateFormatter.format(parsedDate);
}
