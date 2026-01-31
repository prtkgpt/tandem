import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";
import { todayDate } from "@/lib/helpers";

export async function GET(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const today = todayDate();

    const topic = await prisma.tableTopic.findUnique({
      where: {
        coupleId_askedDate: {
          coupleId: couple.coupleId,
          askedDate: today,
        },
      },
      include: {
        question: true,
        responses: {
          include: {
            user: {
              select: { id: true, name: true },
            },
          },
        },
      },
    });

    if (!topic) {
      return NextResponse.json({ topic: null });
    }

    return NextResponse.json({
      topic: {
        id: topic.id,
        questionText: topic.question.text,
        category: topic.question.category,
        askedDate: topic.askedDate,
        responses: topic.responses.map((r) => ({
          id: r.id,
          userId: r.userId,
          userName: r.user.name,
          text: r.text,
          createdAt: r.createdAt,
        })),
        bothResponded: topic.responses.length >= 2,
      },
    });
  } catch (error) {
    console.error("Get topic error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
