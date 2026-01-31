import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const dateNights = await prisma.dateNight.findMany({
      where: { coupleId: couple.coupleId },
      include: {
        ideas: {
          include: {
            user: {
              select: { id: true, name: true },
            },
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    return NextResponse.json({
      dateNights: dateNights.map((dn) => ({
        id: dn.id,
        status: dn.status,
        agreedIdea: dn.agreedIdea,
        agreedBudget: dn.agreedBudget,
        scheduledDate: dn.scheduledDate,
        createdAt: dn.createdAt,
        updatedAt: dn.updatedAt,
        ideas: dn.ideas.map((idea) => ({
          id: idea.id,
          idea: idea.idea,
          budget: idea.budget,
          userId: idea.userId,
          userName: idea.user.name,
          createdAt: idea.createdAt,
        })),
      })),
    });
  } catch (error) {
    console.error("Get date nights error:", error);
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

    const dateNight = await prisma.dateNight.create({
      data: {
        coupleId: couple.coupleId,
        status: "planning",
      },
      include: {
        ideas: true,
      },
    });

    return NextResponse.json({
      dateNight: {
        id: dateNight.id,
        status: dateNight.status,
        agreedIdea: dateNight.agreedIdea,
        agreedBudget: dateNight.agreedBudget,
        scheduledDate: dateNight.scheduledDate,
        createdAt: dateNight.createdAt,
        updatedAt: dateNight.updatedAt,
        ideas: [],
      },
    });
  } catch (error) {
    console.error("Create date night error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
