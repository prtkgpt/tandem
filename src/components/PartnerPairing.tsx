"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useSession } from "next-auth/react";

export default function PartnerPairing({
  inviteCode,
}: {
  inviteCode: string;
}) {
  const router = useRouter();
  const { update } = useSession();
  const [partnerCode, setPartnerCode] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [copied, setCopied] = useState(false);

  const handleCopy = async () => {
    await navigator.clipboard.writeText(inviteCode);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handlePair = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await fetch("/api/partner", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ inviteCode: partnerCode }),
      });

      const data = await res.json();

      if (!res.ok) {
        setError(data.error || "Pairing failed");
        setLoading(false);
        return;
      }

      // Update the session with coupleId
      await update({ coupleId: data.couple.id });
      router.refresh();
    } catch {
      setError("Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-lg">
      <div className="card mb-6">
        <h2 className="section-header mb-4 flex items-center gap-2">
          <span>🔗</span> Your Invite Code
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Share this code with your partner so they can connect with you.
        </p>
        <div className="flex items-center gap-3">
          <div className="flex-1 rounded-xl bg-gray-50 border-2 border-dashed border-gray-300 px-6 py-4 text-center">
            <span className="text-2xl font-mono font-bold tracking-[0.3em] text-gray-900">
              {inviteCode}
            </span>
          </div>
          <button
            onClick={handleCopy}
            className="btn-secondary px-4 py-4 shrink-0"
          >
            {copied ? "Copied!" : "Copy"}
          </button>
        </div>
      </div>

      <div className="card">
        <h2 className="section-header mb-4 flex items-center gap-2">
          <span>💕</span> Pair with Partner
        </h2>
        <p className="text-sm text-gray-600 mb-4">
          Got your partner&apos;s invite code? Enter it below to connect.
        </p>

        <form onSubmit={handlePair} className="space-y-4">
          {error && (
            <div className="rounded-xl bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
              {error}
            </div>
          )}

          <input
            type="text"
            value={partnerCode}
            onChange={(e) => setPartnerCode(e.target.value.toUpperCase())}
            className="input text-center text-lg font-mono tracking-[0.2em]"
            placeholder="ENTER CODE"
            maxLength={6}
            required
          />

          <button
            type="submit"
            disabled={loading || partnerCode.length !== 6}
            className="btn-primary w-full"
          >
            {loading ? "Connecting..." : "Connect with Partner"}
          </button>
        </form>
      </div>
    </div>
  );
}
