import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

const questions = [
  // ── Dreams (17) ──────────────────────────────────────────────
  { text: "If we could live anywhere in the world for a year, where would you pick?", category: "Dreams" },
  { text: "What's a skill you've always wanted to learn together?", category: "Dreams" },
  { text: "If money were no object, what would our dream home look like?", category: "Dreams" },
  { text: "What's a career path you've secretly fantasized about?", category: "Dreams" },
  { text: "If we could take a sabbatical together, how would we spend it?", category: "Dreams" },
  { text: "What's a dream trip you want us to take before we're 50?", category: "Dreams" },
  { text: "If we could start a business together, what would it be?", category: "Dreams" },
  { text: "What's something on your bucket list you haven't told me about?", category: "Dreams" },
  { text: "If we could master any hobby as a couple, what would you choose?", category: "Dreams" },
  { text: "What does your ideal regular Tuesday look like five years from now?", category: "Dreams" },
  { text: "If you could go back to school for anything, what would you study?", category: "Dreams" },
  { text: "What's a creative project you'd love for us to tackle together?", category: "Dreams" },
  { text: "If we could attend any event in the world, what would it be?", category: "Dreams" },
  { text: "What kind of legacy do you want us to build together?", category: "Dreams" },
  { text: "If we had a year off with no responsibilities, what would we do first?", category: "Dreams" },
  { text: "What's a personal dream of yours that I could help you with?", category: "Dreams" },
  { text: "If we could design our perfect weekend routine, what would it include?", category: "Dreams" },

  // ── Money (17) ───────────────────────────────────────────────
  { text: "If we had an extra $500 right now, what would we do with it?", category: "Money" },
  { text: "What's a purchase you think we should make this year?", category: "Money" },
  { text: "What's one financial goal you'd love us to hit in the next 12 months?", category: "Money" },
  { text: "If we won $10,000 in a lottery, how should we split between saving and spending?", category: "Money" },
  { text: "What's a money habit from your family that you want to keep — or break?", category: "Money" },
  { text: "What's one thing we spend money on that feels totally worth it?", category: "Money" },
  { text: "Is there something we spend on that you think we could cut back?", category: "Money" },
  { text: "What's a financial risk you'd be comfortable taking together?", category: "Money" },
  { text: "How would you feel about setting up a shared 'fun fund' for spontaneous adventures?", category: "Money" },
  { text: "What was the best money we ever spent as a couple?", category: "Money" },
  { text: "If we could invest in one experience this year, what would it be?", category: "Money" },
  { text: "What does financial security look like to you?", category: "Money" },
  { text: "Do you think we should splurge more or save more right now?", category: "Money" },
  { text: "What's a subscription or expense we've been meaning to cancel?", category: "Money" },
  { text: "If one of us got a big raise, what should we do with the extra income?", category: "Money" },
  { text: "What's the most valuable thing money can't buy in our relationship?", category: "Money" },
  { text: "What's one area where you wish we were more aligned financially?", category: "Money" },

  // ── Memories (17) ────────────────────────────────────────────
  { text: "What's your favorite memory of us from the past month?", category: "Memories" },
  { text: "What moment made you fall deeper in love with me?", category: "Memories" },
  { text: "What's the first thing you noticed about me when we met?", category: "Memories" },
  { text: "What's a small moment between us that you think about often?", category: "Memories" },
  { text: "What's the hardest thing we've gotten through together?", category: "Memories" },
  { text: "What's your favorite trip we've taken?", category: "Memories" },
  { text: "When did you first realize you were in love with me?", category: "Memories" },
  { text: "What's the funniest thing that's ever happened to us?", category: "Memories" },
  { text: "What's a meal we shared that you still think about?", category: "Memories" },
  { text: "What's a time I surprised you in a good way?", category: "Memories" },
  { text: "What's your favorite photo of us and why?", category: "Memories" },
  { text: "What's a date night you'd love to recreate?", category: "Memories" },
  { text: "What's a song that always reminds you of us?", category: "Memories" },
  { text: "What's a holiday or celebration we nailed as a couple?", category: "Memories" },
  { text: "What's a challenge we faced that actually made us stronger?", category: "Memories" },
  { text: "What's the best gift I've ever given you?", category: "Memories" },
  { text: "What's a random ordinary day with me that stands out in your memory?", category: "Memories" },

  // ── Fun (17) ─────────────────────────────────────────────────
  { text: "If we could swap lives with another couple for a day, who would you pick?", category: "Fun" },
  { text: "What's the most spontaneous thing we've ever done?", category: "Fun" },
  { text: "If we had to compete on a reality TV show together, which one would we win?", category: "Fun" },
  { text: "What's a weird food combination you want me to try?", category: "Fun" },
  { text: "If we were characters in a movie, what genre would our story be?", category: "Fun" },
  { text: "What's something silly you love about me that you've never mentioned?", category: "Fun" },
  { text: "If we could have dinner with any couple — real or fictional — who would it be?", category: "Fun" },
  { text: "What's a dare you'd give me right now?", category: "Fun" },
  { text: "If we could only listen to one artist for the rest of our lives, who would you pick?", category: "Fun" },
  { text: "What's the most embarrassing thing we've done together?", category: "Fun" },
  { text: "If we opened a restaurant, what would we call it and what would we serve?", category: "Fun" },
  { text: "What's a guilty pleasure show or movie we should binge together?", category: "Fun" },
  { text: "If you could give me a supranormal power, what would it be?", category: "Fun" },
  { text: "What's a new date night idea you've been wanting to try?", category: "Fun" },
  { text: "If we had to pick new names for each other, what would you choose?", category: "Fun" },
  { text: "What's something you think we'd be hilariously bad at doing together?", category: "Fun" },
  { text: "If we time-traveled back to our first date, what would you do differently?", category: "Fun" },

  // ── Future (16) ──────────────────────────────────────────────
  { text: "Where do you see us in 5 years?", category: "Future" },
  { text: "What tradition should we start?", category: "Future" },
  { text: "What's one thing you want us to do differently next year?", category: "Future" },
  { text: "How do you want us to handle disagreements better going forward?", category: "Future" },
  { text: "What's a relationship goal you'd like us to set for this month?", category: "Future" },
  { text: "If we could redesign our daily routine, what would you change?", category: "Future" },
  { text: "What's something new you'd like us to try in the next 30 days?", category: "Future" },
  { text: "How do you want to celebrate our next anniversary?", category: "Future" },
  { text: "What's a conversation you think we need to have soon?", category: "Future" },
  { text: "What does growing old together look like to you?", category: "Future" },
  { text: "What's one habit you'd love for us to build together?", category: "Future" },
  { text: "If we could volunteer for a cause together, what would it be?", category: "Future" },
  { text: "What's something you want to make sure we never stop doing?", category: "Future" },
  { text: "How do you want us to support each other's individual growth?", category: "Future" },
  { text: "What does your ideal holiday season look like for us?", category: "Future" },
  { text: "What's one promise you'd like us to make to each other right now?", category: "Future" },

  // ── Gratitude (16) ───────────────────────────────────────────
  { text: "What's something I do that you're proud of?", category: "Gratitude" },
  { text: "What's something small I do that makes your day better?", category: "Gratitude" },
  { text: "What's a quality of mine that you admire most?", category: "Gratitude" },
  { text: "When did I last make you feel really loved?", category: "Gratitude" },
  { text: "What's something I've taught you — even without realizing it?", category: "Gratitude" },
  { text: "What's a way I've helped you grow as a person?", category: "Gratitude" },
  { text: "What do you appreciate most about how I show up for you?", category: "Gratitude" },
  { text: "What's something about our relationship that you never want to take for granted?", category: "Gratitude" },
  { text: "What's a time I supported you that really meant a lot?", category: "Gratitude" },
  { text: "What's your favorite thing about the way we communicate?", category: "Gratitude" },
  { text: "What's something about our life together that makes you feel grateful?", category: "Gratitude" },
  { text: "How have I surprised you in a good way recently?", category: "Gratitude" },
  { text: "What's something I do for others that makes you proud to be with me?", category: "Gratitude" },
  { text: "What's a strength of our relationship that other people might not see?", category: "Gratitude" },
  { text: "What's one thing about me that you'd never want to change?", category: "Gratitude" },
  { text: "What are you most thankful for about us right now, in this moment?", category: "Gratitude" },
];

async function main() {
  // Delete all existing questions for idempotency
  await prisma.question.deleteMany();

  // Insert all questions
  const result = await prisma.question.createMany({
    data: questions,
  });

  console.log(`Seeded ${result.count} Table Topics questions.`);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
