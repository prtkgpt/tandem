import { getCurrentUser, getPartner, daysSince } from "@/lib/helpers";
import prisma from "@/lib/prisma";
import Link from "next/link";
import PartnerPairing from "@/components/PartnerPairing";

export default async function DashboardPage() {
  const user = await getCurrentUser();

  if (!user) return null;

  const partner = getPartner(user);
  const isPaired = !!user.coupleId;

  // If not paired, show pairing screen
  if (!isPaired) {
    return (
      <div>
        <h1 className="page-header mb-2">Welcome, {user.name}! 👋</h1>
        <p className="text-gray-600 mb-8">
          Let&apos;s connect you with your partner to get started.
        </p>
        <PartnerPairing inviteCode={user.inviteCode || ""} />
      </div>
    );
  }

  // Fetch dashboard data
  const [recentNotes, recentMoods, upcomingEvents, lists] = await Promise.all([
    prisma.note.findMany({
      where: { coupleId: user.coupleId! },
      include: { author: { select: { id: true, name: true } } },
      orderBy: { createdAt: "desc" },
      take: 3,
    }),
    prisma.mood.findMany({
      where: {
        userId: {
          in: (
            await prisma.user.findMany({
              where: { coupleId: user.coupleId! },
              select: { id: true },
            })
          ).map((u) => u.id),
        },
      },
      include: { user: { select: { id: true, name: true } } },
      orderBy: { createdAt: "desc" },
      take: 4,
    }),
    prisma.event.findMany({
      where: {
        coupleId: user.coupleId!,
        date: { gte: new Date() },
      },
      orderBy: { date: "asc" },
      take: 3,
    }),
    prisma.list.findMany({
      where: { coupleId: user.coupleId! },
      include: {
        items: true,
      },
      orderBy: { updatedAt: "desc" },
      take: 3,
    }),
  ]);

  const daysTogetherCount = daysSince(user.couple!.createdAt);

  return (
    <div>
      {/* Header */}
      <div className="mb-8">
        <h1 className="page-header mb-1">
          Hey {user.name} 👋
        </h1>
        <p className="text-gray-600">
          You &amp; {partner?.name || "your partner"} —{" "}
          <span className="font-medium text-rose-600">
            {daysTogetherCount} days on Tandem
          </span>
        </p>
      </div>

      {/* Quick Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <StatCard emoji="💕" label="Days Together" value={daysTogetherCount.toString()} />
        <StatCard emoji="💌" label="Love Notes" value={recentNotes.length.toString()} />
        <StatCard emoji="📋" label="Active Lists" value={lists.length.toString()} />
        <StatCard emoji="📅" label="Upcoming" value={upcomingEvents.length.toString()} />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Recent Notes */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-header flex items-center gap-2">
              <span>💌</span> Recent Notes
            </h2>
            <Link
              href="/dashboard/notes"
              className="text-sm text-rose-600 hover:text-rose-700 font-medium"
            >
              View all →
            </Link>
          </div>
          {recentNotes.length > 0 ? (
            <div className="space-y-3">
              {recentNotes.map((note) => (
                <div
                  key={note.id}
                  className="flex gap-3 p-3 rounded-xl bg-gray-50"
                >
                  <span className="text-lg">{note.emoji}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm text-gray-900 line-clamp-2">
                      {note.content}
                    </p>
                    <p className="text-xs text-gray-500 mt-1">
                      from {note.author.name}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <EmptyState
              emoji="💌"
              text="No notes yet. Send your first love note!"
              href="/dashboard/notes"
            />
          )}
        </div>

        {/* Mood Check-ins */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-header flex items-center gap-2">
              <span>😊</span> Recent Moods
            </h2>
            <Link
              href="/dashboard/moods"
              className="text-sm text-rose-600 hover:text-rose-700 font-medium"
            >
              Check in →
            </Link>
          </div>
          {recentMoods.length > 0 ? (
            <div className="space-y-3">
              {recentMoods.map((mood) => (
                <div
                  key={mood.id}
                  className="flex items-center gap-3 p-3 rounded-xl bg-gray-50"
                >
                  <span className="text-2xl">{mood.emoji}</span>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900">
                      {mood.user.name}
                    </p>
                    {mood.note && (
                      <p className="text-xs text-gray-500">{mood.note}</p>
                    )}
                  </div>
                  <span className="text-xs text-gray-400">
                    {new Date(mood.createdAt).toLocaleDateString()}
                  </span>
                </div>
              ))}
            </div>
          ) : (
            <EmptyState
              emoji="😊"
              text="No moods shared yet. How are you feeling?"
              href="/dashboard/moods"
            />
          )}
        </div>

        {/* Shared Lists */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-header flex items-center gap-2">
              <span>📋</span> Shared Lists
            </h2>
            <Link
              href="/dashboard/lists"
              className="text-sm text-rose-600 hover:text-rose-700 font-medium"
            >
              View all →
            </Link>
          </div>
          {lists.length > 0 ? (
            <div className="space-y-3">
              {lists.map((list) => {
                const done = list.items.filter((i) => i.completed).length;
                const total = list.items.length;
                return (
                  <Link
                    key={list.id}
                    href="/dashboard/lists"
                    className="flex items-center gap-3 p-3 rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors"
                  >
                    <span className="text-lg">{list.icon}</span>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">
                        {list.title}
                      </p>
                      <p className="text-xs text-gray-500">
                        {done}/{total} completed
                      </p>
                    </div>
                  </Link>
                );
              })}
            </div>
          ) : (
            <EmptyState
              emoji="📋"
              text="No lists yet. Create one together!"
              href="/dashboard/lists"
            />
          )}
        </div>

        {/* Upcoming Events */}
        <div className="card">
          <div className="flex items-center justify-between mb-4">
            <h2 className="section-header flex items-center gap-2">
              <span>📅</span> Upcoming Events
            </h2>
            <Link
              href="/dashboard/events"
              className="text-sm text-rose-600 hover:text-rose-700 font-medium"
            >
              View all →
            </Link>
          </div>
          {upcomingEvents.length > 0 ? (
            <div className="space-y-3">
              {upcomingEvents.map((event) => {
                const daysUntil = Math.ceil(
                  (new Date(event.date).getTime() - Date.now()) /
                    (1000 * 60 * 60 * 24)
                );
                return (
                  <div
                    key={event.id}
                    className="flex items-center gap-3 p-3 rounded-xl bg-gray-50"
                  >
                    <span className="text-lg">{event.emoji}</span>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">
                        {event.title}
                      </p>
                      <p className="text-xs text-gray-500">
                        {new Date(event.date).toLocaleDateString()}
                      </p>
                    </div>
                    <span className="badge bg-rose-100 text-rose-700">
                      {daysUntil === 0
                        ? "Today!"
                        : daysUntil === 1
                        ? "Tomorrow"
                        : `${daysUntil}d`}
                    </span>
                  </div>
                );
              })}
            </div>
          ) : (
            <EmptyState
              emoji="📅"
              text="No upcoming events. Plan a date night!"
              href="/dashboard/events"
            />
          )}
        </div>
      </div>
    </div>
  );
}

function StatCard({
  emoji,
  label,
  value,
}: {
  emoji: string;
  label: string;
  value: string;
}) {
  return (
    <div className="card text-center py-5">
      <div className="text-2xl mb-1">{emoji}</div>
      <div className="text-2xl font-bold text-gray-900">{value}</div>
      <div className="text-xs text-gray-500 mt-0.5">{label}</div>
    </div>
  );
}

function EmptyState({
  emoji,
  text,
  href,
}: {
  emoji: string;
  text: string;
  href: string;
}) {
  return (
    <Link
      href={href}
      className="flex flex-col items-center py-6 text-center rounded-xl bg-gray-50 hover:bg-gray-100 transition-colors"
    >
      <span className="text-3xl mb-2 opacity-50">{emoji}</span>
      <p className="text-sm text-gray-500">{text}</p>
    </Link>
  );
}
