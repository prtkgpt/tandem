import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";
import { getWeekStart, getWeekEnd, daysBetween } from "@/lib/helpers";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const coupleRecord = await prisma.couple.findUnique({
      where: { id: couple.coupleId },
      include: {
        users: {
          where: { id: { not: auth.user.userId } },
          select: { name: true },
        },
      },
    });

    if (!coupleRecord) {
      return NextResponse.json(
        { error: "Couple not found" },
        { status: 404 }
      );
    }

    const daysOnTandem = daysBetween(coupleRecord.createdAt, new Date());

    const totalAppreciations = await prisma.appreciation.count({
      where: { coupleId: couple.coupleId },
    });

    const weekStart = getWeekStart();
    const weekEnd = getWeekEnd();

    const weekTimeLogs = await prisma.ourTime.aggregate({
      where: {
        coupleId: couple.coupleId,
        date: {
          gte: weekStart,
          lte: weekEnd,
        },
      },
      _sum: { durationMinutes: true },
    });

    const totalTimeThisWeek = weekTimeLogs._sum.durationMinutes ?? 0;

    const totalDateNights = await prisma.dateNight.count({
      where: {
        coupleId: couple.coupleId,
        status: "completed",
      },
    });

    const partnerName = coupleRecord.users[0]?.name ?? "Partner";

    return NextResponse.json({
      stats: {
        daysOnTandem,
        totalAppreciations,
        totalTimeThisWeek,
        totalDateNights,
        weeklyGoalHours: coupleRecord.weeklyGoalHours,
        partnerName,
      },
    });
  } catch (error) {
    console.error("Get stats error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
