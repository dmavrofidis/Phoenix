import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { headers } from "next/headers";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export async function generateMetadata(): Promise<Metadata> {
  const requestHeaders = await headers();
  const host =
    requestHeaders.get("x-forwarded-host") ?? requestHeaders.get("host");
  const protocol = requestHeaders.get("x-forwarded-proto") ?? "https";
  const metadataBase = host
    ? new URL(protocol + "://" + host)
    : undefined;

  return {
    metadataBase,
    title: "Phoenix — Local fitness στο iPhone σου",
    description:
      "Εγκατάστησε το ιδιωτικό, offline-first Phoenix στο iPhone σου.",
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
      images: metadataBase
        ? [new URL("/og.png", metadataBase).toString()]
        : undefined,
    },
  };
}

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
