import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

// GET /api/mood — get today's mood check-ins for the couple
export async function GET(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const checkins = await prisma.moodCheckin.findMany({
    where: {
      coupleId: couple.coupleId,
      date: today,
    },
    include: {
      user: { select: { id: true, name: true } },
    },
    orderBy: { createdAt: "desc" },
  });

  return NextResponse.json({
    checkins: checkins.map((c) => ({
      id: c.id,
      userId: c.userId,
      userName: c.user.name,
      mood: c.mood,
      note: c.note,
      createdAt: c.createdAt.toISOString(),
    })),
  });
}

// POST /api/mood — check in mood (upserts for today)
export async function POST(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const body = await req.json();
  const { mood, note } = body;

  if (!mood || typeof mood !== "string") {
    return NextResponse.json({ error: "Mood is required" }, { status: 400 });
  }

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const checkin = await prisma.moodCheckin.upsert({
    where: {
      userId_date: {
        userId: auth.user.userId,
        date: today,
      },
    },
    update: {
      mood,
      note: note || null,
    },
    create: {
      coupleId: couple.coupleId,
      userId: auth.user.userId,
      mood,
      note: note || null,
      date: today,
    },
    include: {
      user: { select: { id: true, name: true } },
    },
  });

  return NextResponse.json({
    checkin: {
      id: checkin.id,
      userId: checkin.userId,
      userName: checkin.user.name,
      mood: checkin.mood,
      note: checkin.note,
      createdAt: checkin.createdAt.toISOString(),
    },
  });
}
