import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";

// Unauthenticated — validates invite code and returns sender's name
export async function POST(req: NextRequest) {
  try {
    const { code } = await req.json();

    if (!code) {
      return NextResponse.json(
        { error: "Invite code is required" },
        { status: 400 }
      );
    }

    const invite = await prisma.partnerInvite.findUnique({
      where: { code: code.toUpperCase() },
      include: {
        sender: {
          select: { id: true, name: true },
        },
      },
    });

    if (!invite) {
      return NextResponse.json(
        { error: "Invalid invite code" },
        { status: 404 }
      );
    }

    if (invite.used) {
      return NextResponse.json(
        { error: "This invite code has already been used" },
        { status: 400 }
      );
    }

    if (invite.expiresAt < new Date()) {
      return NextResponse.json(
        { error: "This invite code has expired" },
        { status: 400 }
      );
    }

    return NextResponse.json({
      valid: true,
      senderName: invite.sender.name,
    });
  } catch (error) {
    console.error("Validate code error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
