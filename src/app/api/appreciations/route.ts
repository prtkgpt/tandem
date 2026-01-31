import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";
import { daysAgo } from "@/lib/helpers";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const thirtyDaysAgo = daysAgo(30);

    const appreciations = await prisma.appreciation.findMany({
      where: {
        coupleId: couple.coupleId,
        createdAt: { gte: thirtyDaysAgo },
      },
      include: {
        fromUser: {
          select: { id: true, name: true },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return NextResponse.json({
      appreciations: appreciations.map((a) => ({
        id: a.id,
        message: a.message,
        fromUserId: a.fromUserId,
        fromUserName: a.fromUser.name,
        createdAt: a.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get appreciations error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

export async function POST(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const { message } = await req.json();

    if (!message || !message.trim()) {
      return NextResponse.json(
        { error: "Message is required" },
        { status: 400 }
      );
    }

    if (message.length > 200) {
      return NextResponse.json(
        { error: "Message must be 200 characters or less" },
        { status: 400 }
      );
    }

    const appreciation = await prisma.appreciation.create({
      data: {
        coupleId: couple.coupleId,
        fromUserId: auth.user.userId,
        message: message.trim(),
      },
      include: {
        fromUser: {
          select: { id: true, name: true },
        },
      },
    });

    return NextResponse.json({
      appreciation: {
        id: appreciation.id,
        message: appreciation.message,
        fromUserId: appreciation.fromUserId,
        fromUserName: appreciation.fromUser.name,
        createdAt: appreciation.createdAt,
      },
    });
  } catch (error) {
    console.error("Create appreciation error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
