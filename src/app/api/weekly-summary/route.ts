import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const summary = await prisma.weeklySummary.findFirst({
      where: { coupleId: couple.coupleId },
      orderBy: { weekStartDate: "desc" },
    });

    if (!summary) {
      return NextResponse.json({ summary: null });
    }

    return NextResponse.json({
      summary: {
        id: summary.id,
        weekStartDate: summary.weekStartDate,
        totalTimeMinutes: summary.totalTimeMinutes,
        totalAppreciations: summary.totalAppreciations,
        wins: summary.wins,
        nudge: summary.nudge,
        createdAt: summary.createdAt,
      },
    });
  } catch (error) {
    console.error("Get weekly summary error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
