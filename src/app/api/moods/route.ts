import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import prisma from "@/lib/prisma";

export async function GET() {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const user = await prisma.user.findUnique({
      where: { id: session.user.id },
    });

    // Get moods for both users in the couple
    let moods;
    if (user?.coupleId) {
      const coupleUsers = await prisma.user.findMany({
        where: { coupleId: user.coupleId },
        select: { id: true },
      });
      const userIds = coupleUsers.map((u) => u.id);

      moods = await prisma.mood.findMany({
        where: { userId: { in: userIds } },
        include: {
          user: {
            select: { id: true, name: true },
          },
        },
        orderBy: { createdAt: "desc" },
        take: 30,
      });
    } else {
      moods = await prisma.mood.findMany({
        where: { userId: session.user.id },
        include: {
          user: {
            select: { id: true, name: true },
          },
        },
        orderBy: { createdAt: "desc" },
        take: 30,
      });
    }

    return NextResponse.json({ moods });
  } catch (error) {
    console.error("Moods fetch error:", error);
    return NextResponse.json(
      { error: "Something went wrong" },
      { status: 500 }
    );
  }
}

export async function POST(req: Request) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { emoji, note } = await req.json();

    if (!emoji) {
      return NextResponse.json(
        { error: "Mood emoji is required" },
        { status: 400 }
      );
    }

    const mood = await prisma.mood.create({
      data: {
        emoji,
        note: note?.trim() || null,
        userId: session.user.id,
      },
      include: {
        user: {
          select: { id: true, name: true },
        },
      },
    });

    return NextResponse.json({ mood }, { status: 201 });
  } catch (error) {
    console.error("Mood creation error:", error);
    return NextResponse.json(
      { error: "Something went wrong" },
      { status: 500 }
    );
  }
}
