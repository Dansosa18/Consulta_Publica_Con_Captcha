import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import ChatbotWidgetScript from "./ChatbotWidgetScript";

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
  const chatbotWidgetUrl =
    process.env.NEXT_PUBLIC_CHATBOT_WIDGET_URL ??
    "http://localhost:3000/widget.js";

  return (
    <html lang="es" className={`${geistSans.variable} ${geistMono.variable}`}>
      <body>
        {children}
        <ChatbotWidgetScript src={chatbotWidgetUrl} />
      </body>
    </html>
  );
}
