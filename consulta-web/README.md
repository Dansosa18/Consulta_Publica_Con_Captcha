This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/app/api-reference/cli/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:4000](http://localhost:4000) with your browser to see the result.

You can start editing the page by modifying `app/page.tsx`. The page auto-updates as you edit the file.

This project uses [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Chatbot opcional

El chatbot es un servicio independiente de esta aplicación. La página de
consulta sigue funcionando si el widget no está disponible o no puede cargar.
Configura su URL pública mediante:

```env
NEXT_PUBLIC_CHATBOT_WIDGET_URL=http://localhost:3000/widget.js
```

La aplicación de consulta se sirve en `http://localhost:4000`; el puerto
`3000` se reserva para el widget del chatbot.

## CAPTCHA

En desarrollo local, el CAPTCHA se muestra usando las claves oficiales de
prueba de reCAPTCHA v2. Para usarlo, configura las variables así:

```env
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=tu-site-key-de-prueba
RECAPTCHA_SECRET_KEY=tu-secret-key-de-prueba
DISABLE_CAPTCHA=false
NEXT_PUBLIC_DISABLE_CAPTCHA=false
```

Para producción, registra el dominio en
[Google reCAPTCHA v2](https://www.google.com/recaptcha/admin/create), usa una
clave del tipo **"No soy un robot"** y configura ambas claves:

```env
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=tu-site-key-real
RECAPTCHA_SECRET_KEY=tu-secret-key-real
DISABLE_CAPTCHA=false
NEXT_PUBLIC_DISABLE_CAPTCHA=false
```

La clave secreta nunca debe exponerse al navegador. Las claves genéricas de
prueba o un dominio no registrado pueden hacer que la validación falle aunque
el formulario esté correctamente implementado.
