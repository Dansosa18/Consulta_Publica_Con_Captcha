import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Oficina de Agua | Consulta tu estado de cuenta",
  description: "Consulta el saldo y los movimientos recientes de tu cuenta de agua.",
};

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="es" className={`${geistSans.variable} ${geistMono.variable}`}>
      <body>
        {children}
        <Script
          src="https://nelson-lookup-char-calculators.trycloudflare.com/widget.js"
          strategy="afterInteractive"
        />
      </body>
    </html>
  );
}
