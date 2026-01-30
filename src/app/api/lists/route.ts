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

    if (!user?.coupleId) {
      return NextResponse.json({ lists: [] });
    }

    const lists = await prisma.list.findMany({
      where: { coupleId: user.coupleId },
      include: {
        items: {
          orderBy: { createdAt: "asc" },
        },
        creator: {
          select: { id: true, name: true },
        },
      },
      orderBy: { updatedAt: "desc" },
    });

    return NextResponse.json({ lists });
  } catch (error) {
    console.error("Lists fetch error:", error);
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

    const user = await prisma.user.findUnique({
      where: { id: session.user.id },
    });

    if (!user?.coupleId) {
      return NextResponse.json(
        { error: "You need to pair with a partner first" },
        { status: 400 }
      );
    }

    const { title, icon } = await req.json();

    if (!title?.trim()) {
      return NextResponse.json(
        { error: "List title is required" },
        { status: 400 }
      );
    }

    const list = await prisma.list.create({
      data: {
        title: title.trim(),
        icon: icon || "📝",
        creatorId: session.user.id,
        coupleId: user.coupleId,
      },
      include: {
        items: true,
        creator: {
          select: { id: true, name: true },
        },
      },
    });

    return NextResponse.json({ list }, { status: 201 });
  } catch (error) {
    console.error("List creation error:", error);
    return NextResponse.json(
      { error: "Something went wrong" },
      { status: 500 }
    );
  }
}
