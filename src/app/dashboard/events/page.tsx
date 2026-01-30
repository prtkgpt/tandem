"use client";

import { useState, useEffect } from "react";

interface Event {
  id: string;
  title: string;
  date: string;
  type: string;
  emoji: string;
  createdAt: string;
  user: {
    id: string;
    name: string;
  };
}

const EVENT_TYPES = [
  { value: "date", label: "Date Night", emoji: "💑" },
  { value: "milestone", label: "Milestone", emoji: "🎉" },
  { value: "anniversary", label: "Anniversary", emoji: "💍" },
  { value: "reminder", label: "Reminder", emoji: "🔔" },
  { value: "trip", label: "Trip", emoji: "✈️" },
  { value: "birthday", label: "Birthday", emoji: "🎂" },
];

export default function EventsPage() {
  const [events, setEvents] = useState<Event[]>([]);
  const [showCreate, setShowCreate] = useState(false);
  const [title, setTitle] = useState("");
  const [date, setDate] = useState("");
  const [type, setType] = useState("date");
  const [emoji, setEmoji] = useState("💑");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchEvents();
  }, []);

  const fetchEvents = async () => {
    const res = await fetch("/api/events");
    const data = await res.json();
    if (data.events) setEvents(data.events);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !date) return;
    setLoading(true);

    try {
      const res = await fetch("/api/events", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title, date, type, emoji }),
      });

      const data = await res.json();
      if (data.event) {
        setEvents(
          [...events, data.event].sort(
            (a, b) => new Date(a.date).getTime() - new Date(b.date).getTime()
          )
        );
        setTitle("");
        setDate("");
        setType("date");
        setEmoji("💑");
        setShowCreate(false);
      }
    } catch (err) {
      console.error("Failed to create event:", err);
    } finally {
      setLoading(false);
    }
  };

  const now = new Date();
  const upcomingEvents = events.filter(
    (e) => new Date(e.date).getTime() >= now.getTime() - 86400000
  );
  const pastEvents = events
    .filter((e) => new Date(e.date).getTime() < now.getTime() - 86400000)
    .reverse();

  const getDaysUntil = (eventDate: string) => {
    const diff = new Date(eventDate).getTime() - now.getTime();
    return Math.ceil(diff / (1000 * 60 * 60 * 24));
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="page-header flex items-center gap-2">
            <span>📅</span> Events & Dates
          </h1>
          <p className="text-gray-600 mt-1">
            Plan and track your special moments
          </p>
        </div>
        <button
          onClick={() => setShowCreate(!showCreate)}
          className="btn-primary"
        >
          {showCreate ? "Cancel" : "+ New Event"}
        </button>
      </div>

      {/* Create Event Form */}
      {showCreate && (
        <div className="card mb-6 animate-fade-in">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="label">Event Type</label>
              <div className="grid grid-cols-3 sm:grid-cols-6 gap-2">
                {EVENT_TYPES.map((et) => (
                  <button
                    key={et.value}
                    type="button"
                    onClick={() => {
                      setType(et.value);
                      setEmoji(et.emoji);
                    }}
                    className={`flex flex-col items-center gap-1 p-3 rounded-xl transition-all ${
                      type === et.value
                        ? "bg-rose-100 border-2 border-rose-300"
                        : "bg-gray-50 border-2 border-transparent hover:bg-gray-100"
                    }`}
                  >
                    <span className="text-xl">{et.emoji}</span>
                    <span className="text-xs font-medium text-gray-600">
                      {et.label}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            <div>
              <label htmlFor="event-title" className="label">
                What&apos;s the occasion?
              </label>
              <input
                id="event-title"
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                className="input"
                placeholder="e.g., Dinner at our favorite place"
                required
              />
            </div>

            <div>
              <label htmlFor="event-date" className="label">
                Date
              </label>
              <input
                id="event-date"
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                className="input"
                required
              />
            </div>

            <div className="flex justify-end">
              <button
                type="submit"
                disabled={loading || !title.trim() || !date}
                className="btn-primary"
              >
                {loading ? "Creating..." : "Create Event"}
              </button>
            </div>
          </form>
        </div>
      )}

      {events.length === 0 ? (
        <div className="card text-center py-12">
          <span className="text-5xl mb-4 block">📅</span>
          <p className="text-gray-500 mb-4">
            No events yet. Plan your first date night!
          </p>
          <button
            onClick={() => setShowCreate(true)}
            className="btn-primary"
          >
            Create Your First Event
          </button>
        </div>
      ) : (
        <div className="space-y-8">
          {/* Upcoming Events */}
          {upcomingEvents.length > 0 && (
            <div>
              <h2 className="section-header mb-4 flex items-center gap-2">
                <span>🔜</span> Upcoming
              </h2>
              <div className="space-y-3">
                {upcomingEvents.map((event) => {
                  const daysUntil = getDaysUntil(event.date);
                  return (
                    <div key={event.id} className="card py-4">
                      <div className="flex items-center gap-4">
                        <span className="text-3xl">{event.emoji}</span>
                        <div className="flex-1">
                          <h3 className="font-semibold text-gray-900">
                            {event.title}
                          </h3>
                          <p className="text-sm text-gray-500">
                            {new Date(event.date).toLocaleDateString("en-US", {
                              weekday: "long",
                              month: "long",
                              day: "numeric",
                              year: "numeric",
                            })}
                          </p>
                        </div>
                        <div className="text-right">
                          <span
                            className={`badge ${
                              daysUntil <= 0
                                ? "bg-rose-100 text-rose-700"
                                : daysUntil <= 7
                                ? "bg-orange-100 text-orange-700"
                                : "bg-gray-100 text-gray-700"
                            }`}
                          >
                            {daysUntil <= 0
                              ? "Today!"
                              : daysUntil === 1
                              ? "Tomorrow"
                              : `In ${daysUntil} days`}
                          </span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* Past Events */}
          {pastEvents.length > 0 && (
            <div>
              <h2 className="section-header mb-4 flex items-center gap-2 text-gray-500">
                <span>📖</span> Past Events
              </h2>
              <div className="space-y-3 opacity-75">
                {pastEvents.map((event) => (
                  <div key={event.id} className="card py-4">
                    <div className="flex items-center gap-4">
                      <span className="text-2xl">{event.emoji}</span>
                      <div className="flex-1">
                        <h3 className="font-medium text-gray-700">
                          {event.title}
                        </h3>
                        <p className="text-sm text-gray-400">
                          {new Date(event.date).toLocaleDateString("en-US", {
                            month: "long",
                            day: "numeric",
                            year: "numeric",
                          })}
                        </p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
