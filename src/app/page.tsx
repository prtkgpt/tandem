import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen gradient-bg-soft">
      {/* Navigation */}
      <nav className="flex items-center justify-between px-6 py-4 max-w-6xl mx-auto">
        <div className="flex items-center gap-2">
          <span className="text-2xl">💕</span>
          <span className="text-xl font-bold gradient-text">Tandem</span>
        </div>
        <div className="flex items-center gap-3">
          <Link href="/login" className="btn-ghost">
            Sign in
          </Link>
          <Link href="/register" className="btn-primary">
            Get Started
          </Link>
        </div>
      </nav>

      {/* Hero */}
      <main className="max-w-6xl mx-auto px-6">
        <div className="pt-20 pb-16 text-center">
          <div className="inline-flex items-center gap-2 rounded-full bg-rose-100 px-4 py-1.5 text-sm font-medium text-rose-700 mb-6 animate-fade-in">
            <span>✨</span>
            <span>Your relationship, supercharged</span>
          </div>

          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold tracking-tight text-gray-900 mb-6 animate-slide-up">
            The OS for
            <br />
            <span className="gradient-text">Modern Couples</span>
          </h1>

          <p className="text-lg sm:text-xl text-gray-600 max-w-2xl mx-auto mb-10 animate-slide-up">
            Stay in sync with your partner. Share notes, track moods, manage
            lists, and celebrate milestones — all in one beautiful space.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 animate-slide-up">
            <Link href="/register" className="btn-primary text-base px-8 py-4">
              Start Your Journey Together
            </Link>
            <Link href="/login" className="btn-secondary text-base px-8 py-4">
              I have an account
            </Link>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 py-16">
          <FeatureCard
            emoji="💌"
            title="Love Notes"
            description="Send sweet notes to your partner anytime. A digital love letter box just for you two."
          />
          <FeatureCard
            emoji="📋"
            title="Shared Lists"
            description="Groceries, bucket lists, movie nights — create and manage lists together in real-time."
          />
          <FeatureCard
            emoji="😊"
            title="Mood Check-ins"
            description="Share how you're feeling. Stay emotionally connected even on busy days."
          />
          <FeatureCard
            emoji="📅"
            title="Events & Dates"
            description="Plan date nights, track anniversaries, and never forget an important moment."
          />
          <FeatureCard
            emoji="🔗"
            title="Partner Pairing"
            description="Connect with your partner using a simple invite code. Your private space, instantly."
          />
          <FeatureCard
            emoji="💝"
            title="Relationship Dashboard"
            description="See your love story at a glance — days together, recent activity, and more."
          />
        </div>

        {/* CTA */}
        <div className="text-center py-16 border-t border-gray-200">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Ready to ride in tandem?
          </h2>
          <p className="text-gray-600 mb-8 max-w-md mx-auto">
            Join couples who are building stronger relationships, one shared
            moment at a time.
          </p>
          <Link href="/register" className="btn-primary text-base px-8 py-4">
            Create Your Account
          </Link>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-gray-200 py-8 text-center text-sm text-gray-500">
        <div className="flex items-center justify-center gap-2">
          <span>💕</span>
          <span>
            Tandem — Built with love for couples who want to stay in sync.
          </span>
        </div>
      </footer>
    </div>
  );
}

function FeatureCard({
  emoji,
  title,
  description,
}: {
  emoji: string;
  title: string;
  description: string;
}) {
  return (
    <div className="card group">
      <div className="text-3xl mb-3 transition-transform duration-300 group-hover:scale-110 inline-block">
        {emoji}
      </div>
      <h3 className="text-lg font-semibold text-gray-900 mb-2">{title}</h3>
      <p className="text-sm text-gray-600 leading-relaxed">{description}</p>
    </div>
  );
}
