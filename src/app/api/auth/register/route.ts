import { NextRequest, NextResponse } from "next/server";
import prisma from "@/lib/prisma";
import { hashPassword, createToken } from "@/lib/auth";

export async function POST(req: NextRequest) {
  try {
    const { name, email, password, inviteCode } = await req.json();

    if (!name || !email || !password) {
      return NextResponse.json(
        { error: "Name, email, and password are required" },
        { status: 400 }
      );
    }

    if (password.length < 6) {
      return NextResponse.json(
        { error: "Password must be at least 6 characters" },
        { status: 400 }
      );
    }

    const existing = await prisma.user.findUnique({
      where: { email: email.toLowerCase() },
    });

    if (existing) {
      return NextResponse.json(
        { error: "An account with this email already exists" },
        { status: 409 }
      );
    }

    const hashedPassword = await hashPassword(password);

    // If invite code provided, validate and auto-join couple
    if (inviteCode) {
      const invite = await prisma.partnerInvite.findUnique({
        where: { code: inviteCode.toUpperCase() },
        include: { sender: { select: { id: true, name: true, coupleId: true } } },
      });

      if (!invite || invite.used || invite.expiresAt < new Date()) {
        return NextResponse.json(
          { error: "Invalid or expired invite code" },
          { status: 400 }
        );
      }

      if (invite.sender.coupleId) {
        return NextResponse.json(
          { error: "The person who sent this invite is already paired" },
          { status: 400 }
        );
      }

      const trialEndsAt = new Date();
      trialEndsAt.setDate(trialEndsAt.getDate() + 14);

      const result = await prisma.$transaction(async (tx) => {
        const newCouple = await tx.couple.create({
          data: { trialEndsAt },
        });

        const newUser = await tx.user.create({
          data: {
            name,
            email: email.toLowerCase(),
            password: hashedPassword,
            coupleId: newCouple.id,
          },
        });

        await tx.user.update({
          where: { id: invite.senderId },
          data: { coupleId: newCouple.id },
        });

        await tx.partnerInvite.update({
          where: { id: invite.id },
          data: { used: true },
        });

        return { user: newUser, coupleId: newCouple.id };
      });

      const token = await createToken({
        userId: result.user.id,
        email: result.user.email,
        coupleId: result.coupleId,
      });

      return NextResponse.json({
        token,
        user: {
          id: result.user.id,
          name: result.user.name,
          email: result.user.email,
          coupleId: result.coupleId,
        },
        paired: true,
        partnerName: invite.sender.name,
      });
    }

    // Normal registration (no invite code)
    const user = await prisma.user.create({
      data: {
        name,
        email: email.toLowerCase(),
        password: hashedPassword,
      },
    });

    const token = await createToken({
      userId: user.id,
      email: user.email,
      coupleId: null,
    });

    return NextResponse.json({
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        coupleId: null,
      },
      paired: false,
    });
  } catch (error) {
    console.error("Register error:", error);
    return NextResponse.json(
      { error: "Internal server error" },
      { status: 500 }
    );
  }
}
