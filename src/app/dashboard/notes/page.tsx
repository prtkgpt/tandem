"use client";

import { useState, useEffect } from "react";
import { useSession } from "next-auth/react";

interface Note {
  id: string;
  content: string;
  emoji: string;
  createdAt: string;
  author: {
    id: string;
    name: string;
  };
}

const NOTE_EMOJIS = ["💌", "💕", "💖", "💗", "💝", "✨", "🌹", "🦋", "🌙", "☀️"];

export default function NotesPage() {
  const { data: session } = useSession();
  const [notes, setNotes] = useState<Note[]>([]);
  const [content, setContent] = useState("");
  const [emoji, setEmoji] = useState("💌");
  const [loading, setLoading] = useState(false);
  const [showEmojiPicker, setShowEmojiPicker] = useState(false);

  useEffect(() => {
    fetchNotes();
  }, []);

  const fetchNotes = async () => {
    const res = await fetch("/api/notes");
    const data = await res.json();
    if (data.notes) setNotes(data.notes);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;
    setLoading(true);

    try {
      const res = await fetch("/api/notes", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content, emoji }),
      });

      const data = await res.json();
      if (data.note) {
        setNotes([data.note, ...notes]);
        setContent("");
        setEmoji("💌");
      }
    } catch (err) {
      console.error("Failed to send note:", err);
    } finally {
      setLoading(false);
    }
  };

  const isFromMe = (authorId: string) => authorId === session?.user?.id;

  return (
    <div>
      <div className="mb-8">
        <h1 className="page-header flex items-center gap-2">
          <span>💌</span> Love Notes
        </h1>
        <p className="text-gray-600 mt-1">
          Send sweet messages to your partner
        </p>
      </div>

      {/* Compose Note */}
      <div className="card mb-8">
        <form onSubmit={handleSubmit}>
          <div className="flex items-start gap-3 mb-4">
            <button
              type="button"
              onClick={() => setShowEmojiPicker(!showEmojiPicker)}
              className="text-3xl hover:scale-110 transition-transform mt-1"
            >
              {emoji}
            </button>
            <textarea
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="input min-h-[100px] resize-none"
              placeholder="Write a love note..."
              required
            />
          </div>

          {showEmojiPicker && (
            <div className="flex flex-wrap gap-2 mb-4 p-3 bg-gray-50 rounded-xl">
              {NOTE_EMOJIS.map((e) => (
                <button
                  key={e}
                  type="button"
                  onClick={() => {
                    setEmoji(e);
                    setShowEmojiPicker(false);
                  }}
                  className={`text-2xl p-2 rounded-lg transition-all hover:scale-110 ${
                    emoji === e ? "bg-rose-100 scale-110" : "hover:bg-gray-100"
                  }`}
                >
                  {e}
                </button>
              ))}
            </div>
          )}

          <div className="flex justify-end">
            <button
              type="submit"
              disabled={loading || !content.trim()}
              className="btn-primary"
            >
              {loading ? "Sending..." : "Send Note 💌"}
            </button>
          </div>
        </form>
      </div>

      {/* Notes Feed */}
      <div className="space-y-4">
        {notes.length === 0 ? (
          <div className="card text-center py-12">
            <span className="text-5xl mb-4 block">💌</span>
            <p className="text-gray-500">
              No notes yet. Send your first love note!
            </p>
          </div>
        ) : (
          notes.map((note) => (
            <div
              key={note.id}
              className={`card ${
                isFromMe(note.author.id)
                  ? "ml-8 bg-gradient-to-br from-rose-50 to-pink-50 border-rose-100"
                  : "mr-8"
              }`}
            >
              <div className="flex gap-3">
                <span className="text-2xl">{note.emoji}</span>
                <div className="flex-1">
                  <p className="text-gray-900 whitespace-pre-wrap">
                    {note.content}
                  </p>
                  <div className="flex items-center gap-2 mt-3">
                    <span className="text-xs font-medium text-gray-500">
                      {isFromMe(note.author.id) ? "You" : note.author.name}
                    </span>
                    <span className="text-xs text-gray-400">·</span>
                    <span className="text-xs text-gray-400">
                      {new Date(note.createdAt).toLocaleDateString("en-US", {
                        month: "short",
                        day: "numeric",
                        hour: "numeric",
                        minute: "2-digit",
                      })}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
