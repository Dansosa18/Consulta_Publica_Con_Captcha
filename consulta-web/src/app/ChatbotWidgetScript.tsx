"use client";

import Script from "next/script";

export default function ChatbotWidgetScript({ src }: { src: string }) {
  return (
    <Script
      src={src}
      strategy="afterInteractive"
      onError={() => undefined}
    />
  );
}
