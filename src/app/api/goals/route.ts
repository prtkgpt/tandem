import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const goals = await prisma.savingsGoal.findMany({
      where: { coupleId: couple.coupleId },
      include: {
        contributions: {
          include: {
            user: {
              select: { id: true, name: true },
            },
          },
          orderBy: { addedAt: "desc" },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return NextResponse.json({
      goals: goals.map((g) => ({
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: g.currentAmount,
        emoji: g.emoji,
        createdAt: g.createdAt,
        contributions: g.contributions.map((c) => ({
          id: c.id,
          amount: c.amount,
          userId: c.userId,
          userName: c.user.name,
          addedAt: c.addedAt,
        })),
      })),
    });
  } catch (error) {
    console.error("Get goals error:", error);
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

    const { name, targetAmount, emoji } = await req.json();

    if (!name || !name.trim()) {
      return NextResponse.json(
        { error: "Goal name is required" },
        { status: 400 }
      );
    }

    if (!targetAmount || targetAmount <= 0) {
      return NextResponse.json(
        { error: "Target amount must be a positive number" },
        { status: 400 }
      );
    }

    const goal = await prisma.savingsGoal.create({
      data: {
        coupleId: couple.coupleId,
        name: name.trim(),
        targetAmount,
        emoji: emoji || undefined,
      },
      include: {
        contributions: true,
      },
    });

    return NextResponse.json({
      goal: {
        id: goal.id,
        name: goal.name,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        emoji: goal.emoji,
        createdAt: goal.createdAt,
        contributions: [],
      },
    });
  } catch (error) {
    console.error("Create goal error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
