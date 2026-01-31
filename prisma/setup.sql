-- ═══════════════════════════════════════════════════════════════════
-- Tandem — Full Database Setup
-- Paste this ENTIRE block into Neon SQL Editor and click "Run"
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. TABLES ───────────────────────────────────────────────────

CREATE TABLE "Couple" (
    "id" TEXT NOT NULL,
    "relationshipStartDate" TIMESTAMP(3),
    "weeklyGoalHours" INTEGER NOT NULL DEFAULT 7,
    "lastTopicCategory" TEXT NOT NULL DEFAULT 'Dreams',
    "subscriptionStatus" TEXT NOT NULL DEFAULT 'trial',
    "trialEndsAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Couple_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "coupleId" TEXT,
    "notificationHour" INTEGER NOT NULL DEFAULT 18,
    "notificationMin" INTEGER NOT NULL DEFAULT 30,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "PartnerInvite" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "senderId" TEXT NOT NULL,
    "used" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "PartnerInvite_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Question" (
    "id" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    CONSTRAINT "Question_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "TableTopic" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "askedDate" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "TableTopic_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "TopicResponse" (
    "id" TEXT NOT NULL,
    "topicId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "TopicResponse_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "Appreciation" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Appreciation_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "OurTime" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "loggedByUserId" TEXT NOT NULL,
    "activityName" TEXT NOT NULL,
    "durationMinutes" INTEGER NOT NULL,
    "date" DATE NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "OurTime_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "DateNight" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'planning',
    "agreedIdea" TEXT,
    "agreedBudget" DOUBLE PRECISION,
    "scheduledDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "DateNight_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "DateIdea" (
    "id" TEXT NOT NULL,
    "dateNightId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "idea" TEXT NOT NULL,
    "budget" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "DateIdea_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "SavingsGoal" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "targetAmount" DOUBLE PRECISION NOT NULL,
    "currentAmount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "emoji" TEXT NOT NULL DEFAULT '💰',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "SavingsGoal_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "GoalContribution" (
    "id" TEXT NOT NULL,
    "goalId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "addedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "GoalContribution_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "WeeklySummary" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "weekStartDate" DATE NOT NULL,
    "totalTimeMinutes" INTEGER NOT NULL,
    "totalAppreciations" INTEGER NOT NULL,
    "wins" TEXT[],
    "nudge" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "WeeklySummary_pkey" PRIMARY KEY ("id")
);

-- ─── 2. UNIQUE CONSTRAINTS ──────────────────────────────────────

CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "PartnerInvite_code_key" ON "PartnerInvite"("code");
CREATE UNIQUE INDEX "TableTopic_coupleId_askedDate_key" ON "TableTopic"("coupleId", "askedDate");
CREATE UNIQUE INDEX "TopicResponse_topicId_userId_key" ON "TopicResponse"("topicId", "userId");
CREATE UNIQUE INDEX "WeeklySummary_coupleId_weekStartDate_key" ON "WeeklySummary"("coupleId", "weekStartDate");

-- ─── 3. INDEXES ──────────────────────────────────────────────────

CREATE INDEX "User_coupleId_idx" ON "User"("coupleId");
CREATE INDEX "User_email_idx" ON "User"("email");
CREATE INDEX "PartnerInvite_code_idx" ON "PartnerInvite"("code");
CREATE INDEX "Question_category_idx" ON "Question"("category");
CREATE INDEX "TableTopic_coupleId_idx" ON "TableTopic"("coupleId");
CREATE INDEX "Appreciation_coupleId_createdAt_idx" ON "Appreciation"("coupleId", "createdAt");
CREATE INDEX "OurTime_coupleId_date_idx" ON "OurTime"("coupleId", "date");
CREATE INDEX "DateNight_coupleId_status_idx" ON "DateNight"("coupleId", "status");
CREATE INDEX "SavingsGoal_coupleId_idx" ON "SavingsGoal"("coupleId");
CREATE INDEX "WeeklySummary_coupleId_idx" ON "WeeklySummary"("coupleId");

-- ─── 4. FOREIGN KEYS ────────────────────────────────────────────

ALTER TABLE "User" ADD CONSTRAINT "User_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "PartnerInvite" ADD CONSTRAINT "PartnerInvite_senderId_fkey"
    FOREIGN KEY ("senderId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "TableTopic" ADD CONSTRAINT "TableTopic_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TableTopic" ADD CONSTRAINT "TableTopic_questionId_fkey"
    FOREIGN KEY ("questionId") REFERENCES "Question"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "TopicResponse" ADD CONSTRAINT "TopicResponse_topicId_fkey"
    FOREIGN KEY ("topicId") REFERENCES "TableTopic"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TopicResponse" ADD CONSTRAINT "TopicResponse_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Appreciation" ADD CONSTRAINT "Appreciation_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Appreciation" ADD CONSTRAINT "Appreciation_fromUserId_fkey"
    FOREIGN KEY ("fromUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "OurTime" ADD CONSTRAINT "OurTime_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "OurTime" ADD CONSTRAINT "OurTime_loggedByUserId_fkey"
    FOREIGN KEY ("loggedByUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "DateNight" ADD CONSTRAINT "DateNight_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DateIdea" ADD CONSTRAINT "DateIdea_dateNightId_fkey"
    FOREIGN KEY ("dateNightId") REFERENCES "DateNight"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "DateIdea" ADD CONSTRAINT "DateIdea_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "SavingsGoal" ADD CONSTRAINT "SavingsGoal_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GoalContribution" ADD CONSTRAINT "GoalContribution_goalId_fkey"
    FOREIGN KEY ("goalId") REFERENCES "SavingsGoal"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "GoalContribution" ADD CONSTRAINT "GoalContribution_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "WeeklySummary" ADD CONSTRAINT "WeeklySummary_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- ─── 5. PRISMA MIGRATIONS TRACKING ──────────────────────────────
-- This tells Prisma the schema is already set up

CREATE TABLE IF NOT EXISTS "_prisma_migrations" (
    "id" VARCHAR(36) NOT NULL,
    "checksum" VARCHAR(64) NOT NULL,
    "finished_at" TIMESTAMP(3),
    "migration_name" VARCHAR(255) NOT NULL,
    "logs" TEXT,
    "rolled_back_at" TIMESTAMP(3),
    "started_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "applied_steps_count" INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY ("id")
);

INSERT INTO "_prisma_migrations" ("id", "checksum", "migration_name", "finished_at", "applied_steps_count")
VALUES (gen_random_uuid()::text, 'manual_neon_setup', '20240101000000_init', CURRENT_TIMESTAMP, 1);

-- ─── 6. SEED DATA — 100 Table Topics Questions ──────────────────

INSERT INTO "Question" ("id", "text", "category") VALUES
-- Dreams (17)
(gen_random_uuid()::text, 'If we could live anywhere in the world for a year, where would you pick?', 'Dreams'),
(gen_random_uuid()::text, 'What''s a skill you''ve always wanted to learn together?', 'Dreams'),
(gen_random_uuid()::text, 'If money were no object, what would our dream home look like?', 'Dreams'),
(gen_random_uuid()::text, 'What''s a career path you''ve secretly fantasized about?', 'Dreams'),
(gen_random_uuid()::text, 'If we could take a sabbatical together, how would we spend it?', 'Dreams'),
(gen_random_uuid()::text, 'What''s a dream trip you want us to take before we''re 50?', 'Dreams'),
(gen_random_uuid()::text, 'If we could start a business together, what would it be?', 'Dreams'),
(gen_random_uuid()::text, 'What''s something on your bucket list you haven''t told me about?', 'Dreams'),
(gen_random_uuid()::text, 'If we could master any hobby as a couple, what would you choose?', 'Dreams'),
(gen_random_uuid()::text, 'What does your ideal regular Tuesday look like five years from now?', 'Dreams'),
(gen_random_uuid()::text, 'If you could go back to school for anything, what would you study?', 'Dreams'),
(gen_random_uuid()::text, 'What''s a creative project you''d love for us to tackle together?', 'Dreams'),
(gen_random_uuid()::text, 'If we could attend any event in the world, what would it be?', 'Dreams'),
(gen_random_uuid()::text, 'What kind of legacy do you want us to build together?', 'Dreams'),
(gen_random_uuid()::text, 'If we had a year off with no responsibilities, what would we do first?', 'Dreams'),
(gen_random_uuid()::text, 'What''s a personal dream of yours that I could help you with?', 'Dreams'),
(gen_random_uuid()::text, 'If we could design our perfect weekend routine, what would it include?', 'Dreams'),
-- Money (17)
(gen_random_uuid()::text, 'If we had an extra $500 right now, what would we do with it?', 'Money'),
(gen_random_uuid()::text, 'What''s a purchase you think we should make this year?', 'Money'),
(gen_random_uuid()::text, 'What''s one financial goal you''d love us to hit in the next 12 months?', 'Money'),
(gen_random_uuid()::text, 'If we won $10,000 in a lottery, how should we split between saving and spending?', 'Money'),
(gen_random_uuid()::text, 'What''s a money habit from your family that you want to keep — or break?', 'Money'),
(gen_random_uuid()::text, 'What''s one thing we spend money on that feels totally worth it?', 'Money'),
(gen_random_uuid()::text, 'Is there something we spend on that you think we could cut back?', 'Money'),
(gen_random_uuid()::text, 'What''s a financial risk you''d be comfortable taking together?', 'Money'),
(gen_random_uuid()::text, 'How would you feel about setting up a shared ''fun fund'' for spontaneous adventures?', 'Money'),
(gen_random_uuid()::text, 'What was the best money we ever spent as a couple?', 'Money'),
(gen_random_uuid()::text, 'If we could invest in one experience this year, what would it be?', 'Money'),
(gen_random_uuid()::text, 'What does financial security look like to you?', 'Money'),
(gen_random_uuid()::text, 'Do you think we should splurge more or save more right now?', 'Money'),
(gen_random_uuid()::text, 'What''s a subscription or expense we''ve been meaning to cancel?', 'Money'),
(gen_random_uuid()::text, 'If one of us got a big raise, what should we do with the extra income?', 'Money'),
(gen_random_uuid()::text, 'What''s the most valuable thing money can''t buy in our relationship?', 'Money'),
(gen_random_uuid()::text, 'What''s one area where you wish we were more aligned financially?', 'Money'),
-- Memories (17)
(gen_random_uuid()::text, 'What''s your favorite memory of us from the past month?', 'Memories'),
(gen_random_uuid()::text, 'What moment made you fall deeper in love with me?', 'Memories'),
(gen_random_uuid()::text, 'What''s the first thing you noticed about me when we met?', 'Memories'),
(gen_random_uuid()::text, 'What''s a small moment between us that you think about often?', 'Memories'),
(gen_random_uuid()::text, 'What''s the hardest thing we''ve gotten through together?', 'Memories'),
(gen_random_uuid()::text, 'What''s your favorite trip we''ve taken?', 'Memories'),
(gen_random_uuid()::text, 'When did you first realize you were in love with me?', 'Memories'),
(gen_random_uuid()::text, 'What''s the funniest thing that''s ever happened to us?', 'Memories'),
(gen_random_uuid()::text, 'What''s a meal we shared that you still think about?', 'Memories'),
(gen_random_uuid()::text, 'What''s a time I surprised you in a good way?', 'Memories'),
(gen_random_uuid()::text, 'What''s your favorite photo of us and why?', 'Memories'),
(gen_random_uuid()::text, 'What''s a date night you''d love to recreate?', 'Memories'),
(gen_random_uuid()::text, 'What''s a song that always reminds you of us?', 'Memories'),
(gen_random_uuid()::text, 'What''s a holiday or celebration we nailed as a couple?', 'Memories'),
(gen_random_uuid()::text, 'What''s a challenge we faced that actually made us stronger?', 'Memories'),
(gen_random_uuid()::text, 'What''s the best gift I''ve ever given you?', 'Memories'),
(gen_random_uuid()::text, 'What''s a random ordinary day with me that stands out in your memory?', 'Memories'),
-- Fun (17)
(gen_random_uuid()::text, 'If we could swap lives with another couple for a day, who would you pick?', 'Fun'),
(gen_random_uuid()::text, 'What''s the most spontaneous thing we''ve ever done?', 'Fun'),
(gen_random_uuid()::text, 'If we had to compete on a reality TV show together, which one would we win?', 'Fun'),
(gen_random_uuid()::text, 'What''s a weird food combination you want me to try?', 'Fun'),
(gen_random_uuid()::text, 'If we were characters in a movie, what genre would our story be?', 'Fun'),
(gen_random_uuid()::text, 'What''s something silly you love about me that you''ve never mentioned?', 'Fun'),
(gen_random_uuid()::text, 'If we could have dinner with any couple — real or fictional — who would it be?', 'Fun'),
(gen_random_uuid()::text, 'What''s a dare you''d give me right now?', 'Fun'),
(gen_random_uuid()::text, 'If we could only listen to one artist for the rest of our lives, who would you pick?', 'Fun'),
(gen_random_uuid()::text, 'What''s the most embarrassing thing we''ve done together?', 'Fun'),
(gen_random_uuid()::text, 'If we opened a restaurant, what would we call it and what would we serve?', 'Fun'),
(gen_random_uuid()::text, 'What''s a guilty pleasure show or movie we should binge together?', 'Fun'),
(gen_random_uuid()::text, 'If you could give me a supranormal power, what would it be?', 'Fun'),
(gen_random_uuid()::text, 'What''s a new date night idea you''ve been wanting to try?', 'Fun'),
(gen_random_uuid()::text, 'If we had to pick new names for each other, what would you choose?', 'Fun'),
(gen_random_uuid()::text, 'What''s something you think we''d be hilariously bad at doing together?', 'Fun'),
(gen_random_uuid()::text, 'If we time-traveled back to our first date, what would you do differently?', 'Fun'),
-- Future (16)
(gen_random_uuid()::text, 'Where do you see us in 5 years?', 'Future'),
(gen_random_uuid()::text, 'What tradition should we start?', 'Future'),
(gen_random_uuid()::text, 'What''s one thing you want us to do differently next year?', 'Future'),
(gen_random_uuid()::text, 'How do you want us to handle disagreements better going forward?', 'Future'),
(gen_random_uuid()::text, 'What''s a relationship goal you''d like us to set for this month?', 'Future'),
(gen_random_uuid()::text, 'If we could redesign our daily routine, what would you change?', 'Future'),
(gen_random_uuid()::text, 'What''s something new you''d like us to try in the next 30 days?', 'Future'),
(gen_random_uuid()::text, 'How do you want to celebrate our next anniversary?', 'Future'),
(gen_random_uuid()::text, 'What''s a conversation you think we need to have soon?', 'Future'),
(gen_random_uuid()::text, 'What does growing old together look like to you?', 'Future'),
(gen_random_uuid()::text, 'What''s one habit you''d love for us to build together?', 'Future'),
(gen_random_uuid()::text, 'If we could volunteer for a cause together, what would it be?', 'Future'),
(gen_random_uuid()::text, 'What''s something you want to make sure we never stop doing?', 'Future'),
(gen_random_uuid()::text, 'How do you want us to support each other''s individual growth?', 'Future'),
(gen_random_uuid()::text, 'What does your ideal holiday season look like for us?', 'Future'),
(gen_random_uuid()::text, 'What''s one promise you''d like us to make to each other right now?', 'Future'),
-- Gratitude (16)
(gen_random_uuid()::text, 'What''s something I do that you''re proud of?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s something small I do that makes your day better?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s a quality of mine that you admire most?', 'Gratitude'),
(gen_random_uuid()::text, 'When did I last make you feel really loved?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s something I''ve taught you — even without realizing it?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s a way I''ve helped you grow as a person?', 'Gratitude'),
(gen_random_uuid()::text, 'What do you appreciate most about how I show up for you?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s something about our relationship that you never want to take for granted?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s a time I supported you that really meant a lot?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s your favorite thing about the way we communicate?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s something about our life together that makes you feel grateful?', 'Gratitude'),
(gen_random_uuid()::text, 'How have I surprised you in a good way recently?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s something I do for others that makes you proud to be with me?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s a strength of our relationship that other people might not see?', 'Gratitude'),
(gen_random_uuid()::text, 'What''s one thing about me that you''d never want to change?', 'Gratitude'),
(gen_random_uuid()::text, 'What are you most thankful for about us right now, in this moment?', 'Gratitude');

-- ─── 7. NUDGE TABLE (Thinking of You) ──────────────────────────────

CREATE TABLE "Nudge" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "fromUserId" TEXT NOT NULL,
    "emoji" TEXT NOT NULL DEFAULT '💭',
    "message" TEXT NOT NULL DEFAULT 'is thinking of you',
    "seen" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "Nudge_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "Nudge_coupleId_seen_idx" ON "Nudge"("coupleId", "seen");

ALTER TABLE "Nudge" ADD CONSTRAINT "Nudge_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Nudge" ADD CONSTRAINT "Nudge_fromUserId_fkey"
    FOREIGN KEY ("fromUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ─── 8. OUR BOARD (Shared Responsibilities) ─────────────────────

CREATE TABLE "BoardItem" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "category" TEXT NOT NULL DEFAULT 'life',
    "emoji" TEXT NOT NULL DEFAULT '✨',
    "createdByUserId" TEXT NOT NULL,
    "claimedByUserId" TEXT,
    "isComplete" BOOLEAN NOT NULL DEFAULT false,
    "completedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "BoardItem_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "BoardItem_coupleId_isComplete_idx" ON "BoardItem"("coupleId", "isComplete");

ALTER TABLE "BoardItem" ADD CONSTRAINT "BoardItem_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "BoardItem" ADD CONSTRAINT "BoardItem_createdByUserId_fkey"
    FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "BoardItem" ADD CONSTRAINT "BoardItem_claimedByUserId_fkey"
    FOREIGN KEY ("claimedByUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- ─── 9. OUR MOMENTS (Shared Calendar) ──────────────────────────

CREATE TABLE "CoupleEvent" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "emoji" TEXT NOT NULL DEFAULT '📅',
    "eventDate" TIMESTAMP(3) NOT NULL,
    "eventType" TEXT NOT NULL DEFAULT 'date',
    "notes" TEXT,
    "createdByUserId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "CoupleEvent_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "CoupleEvent_coupleId_eventDate_idx" ON "CoupleEvent"("coupleId", "eventDate");

ALTER TABLE "CoupleEvent" ADD CONSTRAINT "CoupleEvent_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "CoupleEvent" ADD CONSTRAINT "CoupleEvent_createdByUserId_fkey"
    FOREIGN KEY ("createdByUserId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ─── 10. MOOD CHECK-IN ─────────────────────────────────────────

CREATE TABLE "MoodCheckin" (
    "id" TEXT NOT NULL,
    "coupleId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "mood" TEXT NOT NULL,
    "note" TEXT,
    "date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "MoodCheckin_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "MoodCheckin_userId_date_key" ON "MoodCheckin"("userId", "date");
CREATE INDEX "MoodCheckin_coupleId_date_idx" ON "MoodCheckin"("coupleId", "date");

ALTER TABLE "MoodCheckin" ADD CONSTRAINT "MoodCheckin_coupleId_fkey"
    FOREIGN KEY ("coupleId") REFERENCES "Couple"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "MoodCheckin" ADD CONSTRAINT "MoodCheckin_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- ═══════════════════════════════════════════════════════════════════
-- DONE! All 17 tables + indexes + foreign keys + 100 seed questions
-- ═══════════════════════════════════════════════════════════════════
