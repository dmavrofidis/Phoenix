import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

const publicOrigin = "https://phoenix-fitness-local.d-mavrofidis.chatgpt.site";

export const metadata: Metadata = {
  metadataBase: new URL(publicOrigin),
  title: "Phoenix — Local fitness στο κινητό σου",
  description:
    "Ιδιωτική, local-first εφαρμογή άσκησης και διατροφής για την καθημερινότητα.",
  icons: {
    icon: "/app/favicon.png",
    shortcut: "/app/favicon.png",
    apple: "/app/icons/Icon-192.png",
  },
  openGraph: {
    type: "website",
    title: "Phoenix — Μικρά βήματα. Μεγάλη αλλαγή.",
    description:
      "Η local-first εφαρμογή fitness που κρατά τα δεδομένα στη συσκευή σου.",
    images: [new URL("/og.png", publicOrigin).toString()],
  },
};

export const viewport: Viewport = {
  colorScheme: "dark",
  themeColor: "#090D0F",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="el">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
