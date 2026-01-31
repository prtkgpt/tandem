import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

// GET /api/board — list board items for couple
export async function GET(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const items = await prisma.boardItem.findMany({
    where: { coupleId: couple.coupleId },
    include: {
      createdBy: { select: { id: true, name: true } },
      claimedBy: { select: { id: true, name: true } },
    },
    orderBy: [{ isComplete: "asc" }, { createdAt: "desc" }],
  });

  return NextResponse.json({
    items: items.map((item) => ({
      id: item.id,
      title: item.title,
      category: item.category,
      emoji: item.emoji,
      createdByUserId: item.createdByUserId,
      createdByName: item.createdBy.name,
      claimedByUserId: item.claimedByUserId,
      claimedByName: item.claimedBy?.name ?? null,
      isComplete: item.isComplete,
      completedAt: item.completedAt?.toISOString() ?? null,
      createdAt: item.createdAt.toISOString(),
    })),
  });
}

// POST /api/board — create a new board item
export async function POST(req: NextRequest) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const body = await req.json();
  const { title, category, emoji } = body;

  if (!title || typeof title !== "string" || title.trim().length === 0) {
    return NextResponse.json({ error: "Title is required" }, { status: 400 });
  }

  const item = await prisma.boardItem.create({
    data: {
      coupleId: couple.coupleId,
      title: title.trim(),
      category: category || "life",
      emoji: emoji || "\u2728",
      createdByUserId: auth.user.userId,
    },
    include: {
      createdBy: { select: { id: true, name: true } },
    },
  });

  return NextResponse.json({
    item: {
      id: item.id,
      title: item.title,
      category: item.category,
      emoji: item.emoji,
      createdByUserId: item.createdByUserId,
      createdByName: item.createdBy.name,
      claimedByUserId: null,
      claimedByName: null,
      isComplete: false,
      completedAt: null,
      createdAt: item.createdAt.toISOString(),
    },
  });
}
