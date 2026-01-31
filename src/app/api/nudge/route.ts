import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

export async function POST(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const nudge = await prisma.nudge.create({
      data: {
        coupleId: couple.coupleId,
        fromUserId: auth.user.userId,
      },
      include: {
        fromUser: {
          select: { id: true, name: true },
        },
      },
    });

    return NextResponse.json({
      nudge: {
        id: nudge.id,
        emoji: nudge.emoji,
        message: nudge.message,
        fromUserName: nudge.fromUser.name,
        createdAt: nudge.createdAt,
      },
    });
  } catch (error) {
    console.error("Send nudge error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    // Find unseen nudges sent BY the partner TO the current user
    const unseenNudges = await prisma.nudge.findMany({
      where: {
        coupleId: couple.coupleId,
        fromUserId: { not: auth.user.userId },
        seen: false,
      },
      include: {
        fromUser: {
          select: { id: true, name: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    // Mark them as seen
    if (unseenNudges.length > 0) {
      await prisma.nudge.updateMany({
        where: {
          id: { in: unseenNudges.map((n) => n.id) },
        },
        data: { seen: true },
      });
    }

    return NextResponse.json({
      nudges: unseenNudges.map((n) => ({
        id: n.id,
        emoji: n.emoji,
        message: n.message,
        fromUserName: n.fromUser.name,
        createdAt: n.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get nudges error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
