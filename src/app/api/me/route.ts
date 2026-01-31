import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest } from "@/lib/auth";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const user = await prisma.user.findUnique({
      where: { id: auth.user.userId },
      select: {
        id: true,
        name: true,
        email: true,
        coupleId: true,
        notificationHour: true,
        notificationMin: true,
        createdAt: true,
        couple: {
          select: {
            id: true,
            relationshipStartDate: true,
            weeklyGoalHours: true,
            subscriptionStatus: true,
            trialEndsAt: true,
            createdAt: true,
            users: {
              where: { id: { not: auth.user.userId } },
              select: { id: true, name: true },
            },
          },
        },
      },
    });

    if (!user) {
      return NextResponse.json({ error: "User not found" }, { status: 404 });
    }

    const partnerName = user.couple?.users?.[0]?.name ?? null;

    return NextResponse.json({
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        coupleId: user.coupleId,
        notificationHour: user.notificationHour,
        notificationMin: user.notificationMin,
        createdAt: user.createdAt,
      },
      couple: user.couple
        ? {
            id: user.couple.id,
            relationshipStartDate: user.couple.relationshipStartDate,
            weeklyGoalHours: user.couple.weeklyGoalHours,
            subscriptionStatus: user.couple.subscriptionStatus,
            createdAt: user.couple.createdAt,
          }
        : null,
      partnerName,
    });
  } catch (error) {
    console.error("Get me error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
