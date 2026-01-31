import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

// GET /api/calendar — list events for couple
export async function GET(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const events = await prisma.coupleEvent.findMany({
    where: { coupleId: couple.coupleId },
    include: {
      createdBy: { select: { id: true, name: true } },
    },
    orderBy: { eventDate: "asc" },
  });

  return NextResponse.json({
    events: events.map((e) => ({
      id: e.id,
      title: e.title,
      emoji: e.emoji,
      eventDate: e.eventDate.toISOString(),
      eventType: e.eventType,
      notes: e.notes,
      createdByUserId: e.createdByUserId,
      createdByName: e.createdBy.name,
      createdAt: e.createdAt.toISOString(),
    })),
  });
}

// POST /api/calendar — create a new event
export async function POST(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const body = await req.json();
  const { title, emoji, eventDate, eventType, notes } = body;

  if (!title || typeof title !== "string" || title.trim().length === 0) {
    return NextResponse.json({ error: "Title is required" }, { status: 400 });
  }

  if (!eventDate) {
    return NextResponse.json(
      { error: "Event date is required" },
      { status: 400 }
    );
  }

  const event = await prisma.coupleEvent.create({
    data: {
      coupleId: couple.coupleId,
      title: title.trim(),
      emoji: emoji || "\u{1F4C5}",
      eventDate: new Date(eventDate),
      eventType: eventType || "date",
      notes: notes || null,
      createdByUserId: auth.user.userId,
    },
    include: {
      createdBy: { select: { id: true, name: true } },
    },
  });

  return NextResponse.json({
    event: {
      id: event.id,
      title: event.title,
      emoji: event.emoji,
      eventDate: event.eventDate.toISOString(),
      eventType: event.eventType,
      notes: event.notes,
      createdByUserId: event.createdByUserId,
      createdByName: event.createdBy.name,
      createdAt: event.createdAt.toISOString(),
    },
  });
}
