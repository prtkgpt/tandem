import { NextResponse } from "next/server";
import { getServerSession } from "next-auth";
import { authOptions } from "@/lib/auth";
import prisma from "@/lib/prisma";

export async function POST(req: Request) {
  try {
    const session = await getServerSession(authOptions);
    if (!session?.user?.id) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    const { inviteCode } = await req.json();

    if (!inviteCode) {
      return NextResponse.json(
        { error: "Invite code is required" },
        { status: 400 }
      );
    }

    const currentUser = await prisma.user.findUnique({
      where: { id: session.user.id },
    });

    if (currentUser?.coupleId) {
      return NextResponse.json(
        { error: "You are already paired with a partner" },
        { status: 400 }
      );
    }

    const partner = await prisma.user.findUnique({
      where: { inviteCode: inviteCode.toUpperCase() },
    });

    if (!partner) {
      return NextResponse.json(
        { error: "Invalid invite code" },
        { status: 404 }
      );
    }

    if (partner.id === session.user.id) {
      return NextResponse.json(
        { error: "You cannot pair with yourself" },
        { status: 400 }
      );
    }

    if (partner.coupleId) {
      return NextResponse.json(
        { error: "This person is already paired" },
        { status: 400 }
      );
    }

    const couple = await prisma.couple.create({
      data: {
        users: {
          connect: [{ id: session.user.id }, { id: partner.id }],
        },
      },
    });

    // Clear invite codes after pairing
    await prisma.user.updateMany({
      where: { id: { in: [session.user.id, partner.id] } },
      data: { inviteCode: null },
    });

    return NextResponse.json({
      couple: {
        id: couple.id,
        partnerName: partner.name,
      },
    });
  } catch (error) {
    console.error("Partner pairing error:", error);
    return NextResponse.json(
      { error: "Something went wrong" },
      { status: 500 }
    );
  }
}
