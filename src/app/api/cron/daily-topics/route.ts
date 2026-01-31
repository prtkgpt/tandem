import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { getNextCategory, todayDate, daysAgo } from "@/lib/helpers";

function verifyCronAuth(req: NextRequest): boolean {
  // Check for Vercel cron header
  const vercelCron = req.headers.get("x-vercel-cron");
  if (vercelCron) return true;

  // Check for CRON_SECRET in Authorization header
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

    const today = todayDate();
    const ninetyDaysAgo = daysAgo(90);

    const couples = await prisma.couple.findMany({
      select: {
        id: true,
        lastTopicCategory: true,
      },
    });

    let created = 0;
    let skipped = 0;

    for (const couple of couples) {
      // Check if a topic already exists for today
      const existing = await prisma.tableTopic.findUnique({
        where: {
          coupleId_askedDate: {
            coupleId: couple.id,
            askedDate: today,
          },
        },
      });

      if (existing) {
        skipped++;
        continue;
      }

      const nextCategory = getNextCategory(couple.lastTopicCategory);

      // Find question IDs asked to this couple in the last 90 days
      const recentTopics = await prisma.tableTopic.findMany({
        where: {
          coupleId: couple.id,
          askedDate: { gte: ninetyDaysAgo },
        },
        select: { questionId: true },
      });

      const recentQuestionIds = recentTopics.map((t) => t.questionId);

      // Find a question from the next category that hasn't been asked recently
      const question = await prisma.question.findFirst({
        where: {
          category: nextCategory,
          id: { notIn: recentQuestionIds.length > 0 ? recentQuestionIds : [] },
        },
      });

      if (!question) {
        // Fallback: pick any question from the category
        const fallbackQuestion = await prisma.question.findFirst({
          where: { category: nextCategory },
        });

        if (!fallbackQuestion) {
          console.error(`No questions found for category: ${nextCategory}`);
          continue;
        }

        await prisma.$transaction([
          prisma.tableTopic.create({
            data: {
              coupleId: couple.id,
              questionId: fallbackQuestion.id,
              askedDate: today,
            },
          }),
          prisma.couple.update({
            where: { id: couple.id },
            data: { lastTopicCategory: nextCategory },
          }),
        ]);
      } else {
        await prisma.$transaction([
          prisma.tableTopic.create({
            data: {
              coupleId: couple.id,
              questionId: question.id,
              askedDate: today,
            },
          }),
          prisma.couple.update({
            where: { id: couple.id },
            data: { lastTopicCategory: nextCategory },
          }),
        ]);
      }

      created++;
    }

    return NextResponse.json({
      success: true,
      created,
      skipped,
      total: couples.length,
    });
  } catch (error) {
    console.error("Daily topics cron error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
