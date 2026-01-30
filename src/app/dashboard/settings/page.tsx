import { getCurrentUser, getPartner, daysSince } from "@/lib/helpers";

export default async function SettingsPage() {
  const user = await getCurrentUser();
  if (!user) return null;

  const partner = getPartner(user);
  const isPaired = !!user.coupleId;

  return (
    <div>
      <div className="mb-8">
        <h1 className="page-header flex items-center gap-2">
          <span>⚙️</span> Settings
        </h1>
        <p className="text-gray-600 mt-1">Manage your account and couple</p>
      </div>

      {/* Profile */}
      <div className="card mb-6">
        <h2 className="section-header mb-4">Your Profile</h2>
        <div className="space-y-4">
          <div className="flex items-center gap-4">
            <div className="flex h-16 w-16 items-center justify-center rounded-full gradient-bg text-white text-2xl font-bold">
              {user.name[0].toUpperCase()}
            </div>
            <div>
              <p className="text-lg font-semibold text-gray-900">{user.name}</p>
              <p className="text-sm text-gray-500">{user.email}</p>
            </div>
          </div>
        </div>
      </div>

      {/* Couple Info */}
      <div className="card mb-6">
        <h2 className="section-header mb-4">Couple Status</h2>
        {isPaired ? (
          <div className="space-y-4">
            <div className="flex items-center gap-4 p-4 bg-green-50 rounded-xl border border-green-200">
              <span className="text-2xl">💕</span>
              <div>
                <p className="font-semibold text-green-800">
                  Paired with {partner?.name}
                </p>
                <p className="text-sm text-green-600">
                  {daysSince(user.couple!.createdAt)} days on Tandem together
                </p>
              </div>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-4 p-4 bg-amber-50 rounded-xl border border-amber-200">
            <span className="text-2xl">🔗</span>
            <div>
              <p className="font-semibold text-amber-800">Not yet paired</p>
              <p className="text-sm text-amber-600">
                Your invite code:{" "}
                <span className="font-mono font-bold">{user.inviteCode}</span>
              </p>
            </div>
          </div>
        )}
      </div>

      {/* About */}
      <div className="card">
        <h2 className="section-header mb-4">About Tandem</h2>
        <div className="space-y-2 text-sm text-gray-600">
          <p>
            <span className="font-medium text-gray-900">Version:</span> 0.1.0
            (MVP)
          </p>
          <p>
            <span className="font-medium text-gray-900">Built with:</span>{" "}
            Next.js, TypeScript, Tailwind CSS, Prisma
          </p>
          <p className="pt-2 text-gray-500">
            Made with 💕 for couples who want to stay in sync.
          </p>
        </div>
      </div>
    </div>
  );
}
