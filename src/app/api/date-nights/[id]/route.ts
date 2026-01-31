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

    const dateNight = await prisma.dateNight.findFirst({
      where: { id, coupleId: couple.coupleId },
    });

    if (!dateNight) {
      return NextResponse.json(
        { error: "Date night not found" },
        { status: 404 }
      );
    }

    const { ideas } = await req.json();

    if (!ideas || !Array.isArray(ideas) || ideas.length === 0) {
      return NextResponse.json(
        { error: "At least one idea is required" },
        { status: 400 }
      );
    }

    await prisma.dateIdea.createMany({
      data: ideas.map((item: { idea: string; budget?: number }) => ({
        dateNightId: id,
        userId: auth.user.userId,
        idea: item.idea,
        budget: item.budget ?? null,
      })),
    });

    const updated = await prisma.dateNight.findUnique({
      where: { id },
      include: {
        ideas: {
          include: {
            user: {
              select: { id: true, name: true },
            },
          },
        },
      },
    });

    return NextResponse.json({
      dateNight: {
        id: updated!.id,
        status: updated!.status,
        agreedIdea: updated!.agreedIdea,
        agreedBudget: updated!.agreedBudget,
        scheduledDate: updated!.scheduledDate,
        createdAt: updated!.createdAt,
        updatedAt: updated!.updatedAt,
        ideas: updated!.ideas.map((idea) => ({
          id: idea.id,
          idea: idea.idea,
          budget: idea.budget,
          userId: idea.userId,
          userName: idea.user.name,
          createdAt: idea.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error("Submit date ideas error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}

export async function PATCH(
  req: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    const couple = requireCouple(auth.user);
    if ("error" in couple) return couple.error;

    const { id } = await params;

    const dateNight = await prisma.dateNight.findFirst({
      where: { id, coupleId: couple.coupleId },
    });

    if (!dateNight) {
      return NextResponse.json(
        { error: "Date night not found" },
        { status: 404 }
      );
    }

    const body = await req.json();
    const updateData: Record<string, unknown> = {};

    if (body.agreedIdea !== undefined) updateData.agreedIdea = body.agreedIdea;
    if (body.agreedBudget !== undefined) updateData.agreedBudget = body.agreedBudget;
    if (body.scheduledDate !== undefined)
      updateData.scheduledDate = new Date(body.scheduledDate);
    if (body.status !== undefined) updateData.status = body.status;

    const updated = await prisma.dateNight.update({
      where: { id },
      data: updateData,
      include: {
        ideas: {
          include: {
            user: {
              select: { id: true, name: true },
            },
          },
        },
      },
    });

    return NextResponse.json({
      dateNight: {
        id: updated.id,
        status: updated.status,
        agreedIdea: updated.agreedIdea,
        agreedBudget: updated.agreedBudget,
        scheduledDate: updated.scheduledDate,
        createdAt: updated.createdAt,
        updatedAt: updated.updatedAt,
        ideas: updated.ideas.map((idea) => ({
          id: idea.id,
          idea: idea.idea,
          budget: idea.budget,
          userId: idea.userId,
          userName: idea.user.name,
          createdAt: idea.createdAt,
        })),
      },
    });
  } catch (error) {
    console.error("Update date night error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
