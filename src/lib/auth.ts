import { SignJWT, jwtVerify } from "jose";
import { hash, compare } from "bcryptjs";
import { NextRequest, NextResponse } from "next/server";
import prisma from "./prisma";

const JWT_SECRET = new TextEncoder().encode(
  process.env.JWT_SECRET || "tandem-dev-secret-change-in-production"
);

export interface JWTPayload {
  userId: string;
  email: string;
  coupleId: string | null;
}

export async function createToken(payload: JWTPayload): Promise<string> {
  return new SignJWT({ ...payload })
    .setProtectedHeader({ alg: "HS256" })
    .setIssuedAt()
    .setExpirationTime("30d")
    .sign(JWT_SECRET);
}

export async function verifyToken(token: string): Promise<JWTPayload | null> {
  try {
    const { payload } = await jwtVerify(token, JWT_SECRET);
    return payload as unknown as JWTPayload;
  } catch {
    return null;
  }
}

export async function hashPassword(password: string): Promise<string> {
  return hash(password, 12);
}

export async function verifyPassword(
  password: string,
  hashed: string
): Promise<boolean> {
  return compare(password, hashed);
}

export function getTokenFromRequest(req: NextRequest): string | null {
  const authHeader = req.headers.get("authorization");
  if (authHeader?.startsWith("Bearer ")) {
    return authHeader.slice(7);
  }
  return null;
}

export async function authenticateRequest(
  req: NextRequest
): Promise<{ user: JWTPayload } | { error: NextResponse }> {
  const token = getTokenFromRequest(req);
  if (!token) {
    return {
      error: NextResponse.json({ error: "Unauthorized" }, { status: 401 }),
    };
  }

  const payload = await verifyToken(token);
  if (!payload) {
    return {
      error: NextResponse.json(
        { error: "Invalid or expired token" },
        { status: 401 }
      ),
    };
  }

  // Refresh coupleId from DB in case it changed since token was issued
  const user = await prisma.user.findUnique({
    where: { id: payload.userId },
    select: { id: true, email: true, coupleId: true },
  });

  if (!user) {
    return {
      error: NextResponse.json({ error: "User not found" }, { status: 401 }),
    };
  }

  return {
    user: {
      userId: user.id,
      email: user.email,
      coupleId: user.coupleId,
    },
  };
}

export function requireCouple(
  auth: JWTPayload
): { coupleId: string } | { error: NextResponse } {
  if (!auth.coupleId) {
    return {
      error: NextResponse.json(
        { error: "You need to pair with a partner first" },
        { status: 400 }
      ),
    };
  }
  return { coupleId: auth.coupleId };
}

export function generateInviteCode(): string {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return code;
}
