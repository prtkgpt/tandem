"use client";

import { useState, useEffect } from "react";
import { useSession } from "next-auth/react";

interface Mood {
  id: string;
  emoji: string;
  note: string | null;
  createdAt: string;
  user: {
    id: string;
    name: string;
  };
}

const MOOD_OPTIONS = [
  { emoji: "😍", label: "In Love" },
  { emoji: "😊", label: "Happy" },
  { emoji: "🥰", label: "Grateful" },
  { emoji: "😌", label: "Peaceful" },
  { emoji: "🤗", label: "Affectionate" },
  { emoji: "😎", label: "Confident" },
  { emoji: "🤔", label: "Thoughtful" },
  { emoji: "😴", label: "Tired" },
  { emoji: "😅", label: "Stressed" },
  { emoji: "😢", label: "Sad" },
  { emoji: "😤", label: "Frustrated" },
  { emoji: "🥺", label: "Missing You" },
];

export default function MoodsPage() {
  const { data: session } = useSession();
  const [moods, setMoods] = useState<Mood[]>([]);
  const [selectedMood, setSelectedMood] = useState<string | null>(null);
  const [note, setNote] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchMoods();
  }, []);

  const fetchMoods = async () => {
    const res = await fetch("/api/moods");
    const data = await res.json();
    if (data.moods) setMoods(data.moods);
  };

  const handleSubmit = async () => {
    if (!selectedMood) return;
    setLoading(true);

    try {
      const res = await fetch("/api/moods", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ emoji: selectedMood, note }),
      });

      const data = await res.json();
      if (data.mood) {
        setMoods([data.mood, ...moods]);
        setSelectedMood(null);
        setNote("");
      }
    } catch (err) {
      console.error("Failed to check in:", err);
    } finally {
      setLoading(false);
    }
  };

  const isFromMe = (userId: string) => userId === session?.user?.id;

  // Group moods by date
  const groupedMoods: Record<string, Mood[]> = {};
  moods.forEach((mood) => {
    const date = new Date(mood.createdAt).toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
    if (!groupedMoods[date]) groupedMoods[date] = [];
    groupedMoods[date].push(mood);
  });

  return (
    <div>
      <div className="mb-8">
        <h1 className="page-header flex items-center gap-2">
          <span>😊</span> Mood Check-in
        </h1>
        <p className="text-gray-600 mt-1">
          How are you feeling? Share with your partner.
        </p>
      </div>

      {/* Mood Picker */}
      <div className="card mb-8">
        <h2 className="section-header mb-4">How are you feeling right now?</h2>
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3 mb-4">
          {MOOD_OPTIONS.map(({ emoji, label }) => (
            <button
              key={emoji}
              onClick={() =>
                setSelectedMood(selectedMood === emoji ? null : emoji)
              }
              className={`flex flex-col items-center gap-1.5 p-3 rounded-xl transition-all ${
                selectedMood === emoji
                  ? "bg-rose-100 border-2 border-rose-300 scale-105"
                  : "bg-gray-50 border-2 border-transparent hover:bg-gray-100 hover:scale-105"
              }`}
            >
              <span className="text-3xl">{emoji}</span>
              <span className="text-xs font-medium text-gray-600">{label}</span>
            </button>
          ))}
        </div>

        {selectedMood && (
          <div className="space-y-3 animate-fade-in">
            <textarea
              value={note}
              onChange={(e) => setNote(e.target.value)}
              className="input min-h-[80px] resize-none"
              placeholder="Add a note (optional)..."
            />
            <div className="flex justify-end">
              <button
                onClick={handleSubmit}
                disabled={loading}
                className="btn-primary"
              >
                {loading ? "Sharing..." : "Share Mood"}
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Mood History */}
      {Object.keys(groupedMoods).length === 0 ? (
        <div className="card text-center py-12">
          <span className="text-5xl mb-4 block">😊</span>
          <p className="text-gray-500">
            No mood check-ins yet. How are you feeling today?
          </p>
        </div>
      ) : (
        <div className="space-y-6">
          {Object.entries(groupedMoods).map(([date, dateMoods]) => (
            <div key={date}>
              <h3 className="text-sm font-medium text-gray-500 mb-3">
                {date}
              </h3>
              <div className="space-y-3">
                {dateMoods.map((mood) => (
                  <div
                    key={mood.id}
                    className={`card py-4 ${
                      isFromMe(mood.user.id)
                        ? "bg-gradient-to-br from-rose-50 to-pink-50 border-rose-100"
                        : ""
                    }`}
                  >
                    <div className="flex items-start gap-3">
                      <span className="text-3xl">{mood.emoji}</span>
                      <div className="flex-1">
                        <p className="text-sm font-medium text-gray-900">
                          {isFromMe(mood.user.id) ? "You" : mood.user.name}
                        </p>
                        {mood.note && (
                          <p className="text-sm text-gray-600 mt-1">
                            {mood.note}
                          </p>
                        )}
                        <p className="text-xs text-gray-400 mt-1">
                          {new Date(mood.createdAt).toLocaleTimeString("en-US", {
                            hour: "numeric",
                            minute: "2-digit",
                          })}
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
