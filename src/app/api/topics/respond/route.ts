import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, requireCouple } from "@/lib/auth";
import { todayDate } from "@/lib/helpers";

export async function POST(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const { text } = await req.json();

    if (!text || !text.trim()) {
      return NextResponse.json(
        { error: "Response text is required" },
        { status: 400 }
      );
    }

    const today = todayDate();

    const topic = await prisma.tableTopic.findUnique({
      where: {
        coupleId_askedDate: {
          coupleId: couple.coupleId,
          askedDate: today,
        },
      },
    });

    if (!topic) {
      return NextResponse.json(
        { error: "No topic for today" },
        { status: 404 }
      );
    }

    const existingResponse = await prisma.topicResponse.findUnique({
      where: {
        topicId_userId: {
          topicId: topic.id,
          userId: auth.user.userId,
        },
      },
    });

    if (existingResponse) {
      return NextResponse.json(
        { error: "You have already responded to today's topic" },
        { status: 400 }
      );
    }

    await prisma.topicResponse.create({
      data: {
        topicId: topic.id,
        userId: auth.user.userId,
        text: text.trim(),
      },
    });

    const updatedTopic = await prisma.tableTopic.findUnique({
      where: { id: topic.id },
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

    return NextResponse.json({
      topic: {
        id: updatedTopic!.id,
        questionText: updatedTopic!.question.text,
        category: updatedTopic!.question.category,
        askedDate: updatedTopic!.askedDate,
        responses: updatedTopic!.responses.map((r) => ({
          id: r.id,
          userId: r.userId,
          userName: r.user.name,
          text: r.text,
          createdAt: r.createdAt,
        })),
        bothResponded: updatedTopic!.responses.length >= 2,
      },
    });
  } catch (error) {
    console.error("Topic respond error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
