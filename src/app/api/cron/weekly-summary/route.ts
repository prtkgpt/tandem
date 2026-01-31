import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { getWeekStart, getWeekEnd, daysAgo } from "@/lib/helpers";

function verifyCronAuth(req: NextRequest): boolean {
  const vercelCron = req.headers.get("x-vercel-cron");
  if (vercelCron) return true;

  const authHeader = req.headers.get("authorization");
  const cronSecret = process.env.CRON_SECRET;

  if (cronSecret && authHeader === `Bearer ${cronSecret}`) {
    return true;
  }

  return false;
}

export async function GET(req: NextRequest) {
  try {
    if (!verifyCronAuth(req)) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const weekStart = getWeekStart();
    const weekEnd = getWeekEnd();
    const threeWeeksAgo = daysAgo(21);

    const couples = await prisma.couple.findMany({
      select: { id: true },
    });

    let created = 0;
    let skipped = 0;

    for (const couple of couples) {
      // Check if summary already exists for this week
      const existing = await prisma.weeklySummary.findUnique({
        where: {
          coupleId_weekStartDate: {
            coupleId: couple.id,
            weekStartDate: weekStart,
          },
        },
      });

      if (existing) {
        skipped++;
        continue;
      }

      // Total time this week
      const timeAgg = await prisma.ourTime.aggregate({
        where: {
          coupleId: couple.id,
          date: { gte: weekStart, lte: weekEnd },
        },
        _sum: { durationMinutes: true },
      });
      const totalTimeMinutes = timeAgg._sum.durationMinutes ?? 0;

      // Total appreciations this week
      const totalAppreciations = await prisma.appreciation.count({
        where: {
          coupleId: couple.id,
          createdAt: { gte: weekStart, lte: weekEnd },
        },
      });

      // Generate wins from appreciations and time logs
      const wins: string[] = [];

      const recentAppreciations = await prisma.appreciation.findMany({
        where: {
          coupleId: couple.id,
          createdAt: { gte: weekStart, lte: weekEnd },
        },
        orderBy: { createdAt: "desc" },
        take: 3,
        include: {
          fromUser: { select: { name: true } },
        },
      });

      const timeLogs = await prisma.ourTime.findMany({
        where: {
          coupleId: couple.id,
          date: { gte: weekStart, lte: weekEnd },
        },
        orderBy: { durationMinutes: "desc" },
        take: 3,
      });

      if (totalAppreciations > 0) {
        wins.push(
          `Shared ${totalAppreciations} appreciation${totalAppreciations > 1 ? "s" : ""} this week`
        );
      }

      if (totalTimeMinutes > 0) {
        const hours = Math.floor(totalTimeMinutes / 60);
        const mins = totalTimeMinutes % 60;
        const timeStr = hours > 0 ? `${hours}h ${mins}m` : `${mins}m`;
        wins.push(`Spent ${timeStr} of quality time together`);
      }

      if (timeLogs.length > 0) {
        const topActivity = timeLogs[0].activityName;
        wins.push(`Top activity: ${topActivity}`);
      }

      // If no wins at all, add an encouraging one
      if (wins.length === 0) {
        wins.push("A new week to build your connection together!");
      }

      // Generate nudge if no date night in 3+ weeks
      let nudge: string | null = null;

      const recentDateNight = await prisma.dateNight.findFirst({
        where: {
          coupleId: couple.id,
          status: "completed",
          updatedAt: { gte: threeWeeksAgo },
        },
      });

      if (!recentDateNight) {
        nudge =
          "It's been a while since your last date night. How about planning one this week?";
      }

      await prisma.weeklySummary.create({
        data: {
          coupleId: couple.id,
          weekStartDate: weekStart,
          totalTimeMinutes,
          totalAppreciations,
          wins,
          nudge,
        },
      });

      created++;
    }

    return NextResponse.json({
      success: true,
      created,
      skipped,
      total: couples.length,
    });
  } catch (error) {
    console.error("Weekly summary cron error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
