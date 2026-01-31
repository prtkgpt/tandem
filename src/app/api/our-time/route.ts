import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";
import { getWeekStart, getWeekEnd, todayDate } from "@/lib/helpers";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const weekStart = getWeekStart();
    const weekEnd = getWeekEnd();

    const timeLogs = await prisma.ourTime.findMany({
      where: {
        coupleId: couple.coupleId,
        date: {
          gte: weekStart,
          lte: weekEnd,
        },
      },
      include: {
        loggedBy: {
          select: { id: true, name: true },
        },
      },
      orderBy: { date: "desc" },
    });

    return NextResponse.json({
      timeLogs: timeLogs.map((log) => ({
        id: log.id,
        activityName: log.activityName,
        durationMinutes: log.durationMinutes,
        date: log.date,
        loggedByUserId: log.loggedByUserId,
        loggedByName: log.loggedBy.name,
        createdAt: log.createdAt,
      })),
    });
  } catch (error) {
    console.error("Get our-time error:", error);
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

    const { activityName, durationMinutes, date } = await req.json();

    if (!activityName || !activityName.trim()) {
      return NextResponse.json(
        { error: "Activity name is required" },
        { status: 400 }
      );
    }

    if (!durationMinutes || durationMinutes <= 0) {
      return NextResponse.json(
        { error: "Duration must be a positive number" },
        { status: 400 }
      );
    }

    const logDate = date ? new Date(date) : todayDate();

    const timeLog = await prisma.ourTime.create({
      data: {
        coupleId: couple.coupleId,
        loggedByUserId: auth.user.userId,
        activityName: activityName.trim(),
        durationMinutes: Math.round(durationMinutes),
        date: logDate,
      },
      include: {
        loggedBy: {
          select: { id: true, name: true },
        },
      },
    });

    return NextResponse.json({
      timeLog: {
        id: timeLog.id,
        activityName: timeLog.activityName,
        durationMinutes: timeLog.durationMinutes,
        date: timeLog.date,
        loggedByUserId: timeLog.loggedByUserId,
        loggedByName: timeLog.loggedBy.name,
        createdAt: timeLog.createdAt,
      },
    });
  } catch (error) {
    console.error("Create our-time error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
