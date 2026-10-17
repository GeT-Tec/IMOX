import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Header from "@/components/Header";
import BottomNav from "@/components/BottomNav";

const inter = Inter({
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
  variable: "--font-inter",
});

export const metadata: Metadata = {
  title: "IMOX — Portal Imobiliário Analítico",
  description: "Plataforma analítica imobiliária com inteligência de mercado e histórico de transações.",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  themeColor: "#0A0E14",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="pt-BR" className={`${inter.variable} dark`}>
      <body className="font-sans bg-[#05070A] text-[#E6EDF3] min-h-screen flex flex-col antialiased">
        <div className="w-full max-w-7xl mx-auto min-h-screen bg-[#0A0E14] flex flex-col relative shadow-2xl border-x border-white/[0.08]">
          <Header />
          <main className="flex-1 flex flex-col overflow-y-auto pb-20 w-full">
            {children}
          </main>
          <BottomNav />
        </div>
      </body>
    </html>
  );
}
