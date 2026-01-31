import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest } from "@/lib/auth";

export async function POST(req: NextRequest) {
  try {
    const auth = await authenticateRequest(req);
    if ("error" in auth) return auth.error;

    if (auth.user.coupleId) {
      return NextResponse.json(
        { error: "You are already paired with a partner" },
        { status: 400 }
      );
    }

    const { code } = await req.json();

    if (!code) {
      return NextResponse.json(
        { error: "Invite code is required" },
        { status: 400 }
      );
    }

    const invite = await prisma.partnerInvite.findUnique({
      where: { code: code.toUpperCase() },
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

    if (invite.senderId === auth.user.userId) {
      return NextResponse.json(
        { error: "You cannot accept your own invite" },
        { status: 400 }
      );
    }

    const sender = await prisma.user.findUnique({
      where: { id: invite.senderId },
    });

    if (!sender) {
      return NextResponse.json(
        { error: "Invite sender not found" },
        { status: 404 }
      );
    }

    if (sender.coupleId) {
      return NextResponse.json(
        { error: "The person who sent this invite is already paired" },
        { status: 400 }
      );
    }

    const trialEndsAt = new Date();
    trialEndsAt.setDate(trialEndsAt.getDate() + 14);

    const couple = await prisma.$transaction(async (tx) => {
      const newCouple = await tx.couple.create({
        data: {
          trialEndsAt,
        },
      });

      await tx.user.update({
        where: { id: auth.user.userId },
        data: { coupleId: newCouple.id },
      });

      await tx.user.update({
        where: { id: invite.senderId },
        data: { coupleId: newCouple.id },
      });

      await tx.partnerInvite.update({
        where: { id: invite.id },
        data: { used: true },
      });

      return newCouple;
    });

    return NextResponse.json({
      coupleId: couple.id,
      partnerName: sender.name,
    });
  } catch (error) {
    console.error("Join partner error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
