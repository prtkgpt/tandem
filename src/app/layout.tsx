import type { Metadata } from "next";
import "./globals.css";
import Providers from "@/components/Providers";

export const metadata: Metadata = {
  title: "Tandem — OS for Couples",
  description:
    "Your shared space to stay connected. Love notes, shared lists, mood check-ins, and more — together.",
  keywords: ["couples", "relationship", "love", "notes", "shared", "together"],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="font-sans">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
