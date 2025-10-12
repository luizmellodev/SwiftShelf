import type React from "react"
import type { Metadata } from "next"
import { Inter } from "next/font/google"
import { ToastProvider } from "@/components/ui/toast"
import "./globals.css"

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
})

export const metadata: Metadata = {
  title: "SwiftShelf",
  description: "A curated collection of reusable SwiftUI components",
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
  },
}

export const viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: "cover",
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`dark ${inter.variable} antialiased`}>
      <body>
        <ToastProvider>
          {children}
        </ToastProvider>
      </body>
    </html>
  )
}
