import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { authenticateRequest, generateInviteCode } from "@/lib/auth";

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

    const code = generateInviteCode();
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    const invite = await prisma.partnerInvite.create({
      data: {
        code,
        senderId: auth.user.userId,
        expiresAt,
      },
    });

    return NextResponse.json({
      code: invite.code,
      expiresAt: invite.expiresAt,
    });
  } catch (error) {
    console.error("Create invite error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
