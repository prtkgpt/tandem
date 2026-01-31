import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

export async function POST(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const { id } = await params;

    const goal = await prisma.savingsGoal.findFirst({
      where: { id, coupleId: couple.coupleId },
    });

    if (!goal) {
      return NextResponse.json(
        { error: "Savings goal not found" },
        { status: 404 }
      );
    }

    const { amount } = await req.json();

    if (!amount || amount <= 0) {
      return NextResponse.json(
        { error: "Amount must be a positive number" },
        { status: 400 }
      );
    }

    const updatedGoal = await prisma.$transaction(async (tx) => {
      await tx.goalContribution.create({
        data: {
          goalId: id,
          userId: auth.user.userId,
          amount,
        },
      });

      return tx.savingsGoal.update({
        where: { id },
        data: {
          currentAmount: {
            increment: amount,
          },
        },
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
      });
    });

    return NextResponse.json({
      goal: {
        id: updatedGoal.id,
        name: updatedGoal.name,
        targetAmount: updatedGoal.targetAmount,
        currentAmount: updatedGoal.currentAmount,
        emoji: updatedGoal.emoji,
        createdAt: updatedGoal.createdAt,
        contributions: updatedGoal.contributions.map((c) => ({
          id: c.id,
          amount: c.amount,
          userId: c.userId,
          userName: c.user.name,
          addedAt: c.addedAt,
        })),
      },
    });
  } catch (error) {
    console.error("Contribute to goal error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
