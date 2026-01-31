import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

// PATCH /api/board/:id — claim or complete a board item
export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const { id } = await params;
  const body = await req.json();
  const { action } = body; // "claim", "unclaim", "complete", "reopen"

  const item = await prisma.boardItem.findFirst({
    where: { id, coupleId: couple.coupleId },
  });

  if (!item) {
    return NextResponse.json({ error: "Item not found" }, { status: 404 });
  }

  let updateData: Record<string, unknown> = {};

  switch (action) {
    case "claim":
      updateData = { claimedByUserId: auth.user.userId };
      break;
    case "unclaim":
      updateData = { claimedByUserId: null };
      break;
    case "complete":
      updateData = {
        isComplete: true,
        completedAt: new Date(),
        claimedByUserId: item.claimedByUserId || auth.user.userId,
      };
      break;
    case "reopen":
      updateData = { isComplete: false, completedAt: null };
      break;
    default:
      return NextResponse.json({ error: "Invalid action" }, { status: 400 });
  }

  const updated = await prisma.boardItem.update({
    where: { id },
    data: updateData,
    include: {
      createdBy: { select: { id: true, name: true } },
      claimedBy: { select: { id: true, name: true } },
    },
  });

  return NextResponse.json({
    item: {
      id: updated.id,
      title: updated.title,
      category: updated.category,
      emoji: updated.emoji,
      createdByUserId: updated.createdByUserId,
      createdByName: updated.createdBy.name,
      claimedByUserId: updated.claimedByUserId,
      claimedByName: updated.claimedBy?.name ?? null,
      isComplete: updated.isComplete,
      completedAt: updated.completedAt?.toISOString() ?? null,
      createdAt: updated.createdAt.toISOString(),
    },
  });
}

// DELETE /api/board/:id — delete a board item
export async function DELETE(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  const auth = await authenticateRequest(req);
  if ("error" in auth) return auth.error;

  const couple = requireCouple(auth.user);
  if ("error" in couple) return couple.error;

  const { id } = await params;

  const item = await prisma.boardItem.findFirst({
    where: { id, coupleId: couple.coupleId },
  });

  if (!item) {
    return NextResponse.json({ error: "Item not found" }, { status: 404 });
  }

  await prisma.boardItem.delete({ where: { id } });

  return NextResponse.json({ success: true });
}
