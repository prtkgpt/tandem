import SwiftUI

struct BoardView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    @State private var items: [BoardItem] = []
    @State private var isLoading = true
    @State private var showNewItem = false

    // New item form
    @State private var newTitle = ""
    @State private var newCategory = "life"
    @State private var newEmoji = "\u{2728}"

    private let categories: [(id: String, label: String, emoji: String)] = [
        ("nest", "Nesting", "\u{1F3E0}"),
        ("wellness", "Wellness", "\u{1F33F}"),
        ("adventure", "Adventures", "\u{1F680}"),
        ("life", "Life Stuff", "\u{2728}"),
    ]

    private var activeItems: [BoardItem] {
        items.filter { !$0.isComplete }
    }

    private var completedItems: [BoardItem] {
        items.filter { $0.isComplete }
    }

    private var currentUserId: String {
        appViewModel.currentUser?.id ?? ""
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: TandemSpacing.lg) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: TandemColors.boardColor))
                            .padding(.top, 60)
                    } else if items.isEmpty {
                        emptyState
                    } else {
                        boardHeader

                        // Active items
                        if !activeItems.isEmpty {
                            VStack(spacing: TandemSpacing.sm) {
                                ForEach(activeItems) { item in
                                    boardItemRow(item)
                                }
                            }
                            .padding(.horizontal, TandemSpacing.md)
                        }

                        // Completed section
                        if !completedItems.isEmpty {
                            completedSection
                        }
                    }
                }
                .padding(.bottom, TandemSpacing.xl)
            }
            .background(TandemColors.background.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(TandemColors.boardColor)
                    }
                }
            }
            .refreshable { await loadItems() }
            .task { await loadItems() }
            .sheet(isPresented: $showNewItem) { newItemSheet }
        }
    }

    // MARK: - Header

    private var boardHeader: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    TandemColors.boardColor.opacity(0.12),
                    TandemColors.accent.opacity(0.06),
                    TandemColors.background,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)

            VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                Text("Our Board")
                    .font(TandemFonts.largeTitle)
                    .foregroundColor(TandemColors.textPrimary)

                Text("\(activeItems.count) thing\(activeItems.count == 1 ? "" : "s") to tackle together")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.boardColor)
            }
            .padding(.horizontal, TandemSpacing.md)
            .padding(.bottom, TandemSpacing.md)
        }
    }

    // MARK: - Board Item Row

    private func boardItemRow(_ item: BoardItem) -> some View {
        HStack(spacing: TandemSpacing.md) {
            // Complete button
            Button {
                Task { await updateItem(id: item.id, action: "complete") }
            } label: {
                Circle()
                    .stroke(TandemColors.boardColor.opacity(0.4), lineWidth: 2)
                    .frame(width: 26, height: 26)
            }

            // Content
            VStack(alignment: .leading, spacing: TandemSpacing.xxs) {
                HStack(spacing: TandemSpacing.xs) {
                    Text(item.emoji)
                        .font(.system(size: 16))
                    Text(item.title)
                        .font(TandemFonts.callout)
                        .foregroundColor(TandemColors.textPrimary)
                }

                HStack(spacing: TandemSpacing.sm) {
                    // Category badge
                    Text(categoryLabel(item.category))
                        .font(TandemFonts.micro)
                        .foregroundColor(TandemColors.boardColor)
                        .padding(.horizontal, TandemSpacing.sm)
                        .padding(.vertical, 2)
                        .background(
                            Capsule().fill(TandemColors.boardColor.opacity(0.10))
                        )

                    // Added by
                    Text("by \(item.createdByUserId == currentUserId ? "you" : item.createdByName)")
                        .font(TandemFonts.micro)
                        .foregroundColor(TandemColors.textSecondary)
                }
            }

            Spacer()

            // Claim / claimed state
            if let claimer = item.claimedByName {
                Text(item.claimedByUserId == currentUserId ? "You" : claimer)
                    .font(TandemFonts.micro)
                    .foregroundColor(TandemColors.secondary)
                    .padding(.horizontal, TandemSpacing.sm)
                    .padding(.vertical, TandemSpacing.xs)
                    .background(
                        Capsule().fill(TandemColors.secondary.opacity(0.10))
                    )
            } else {
                Button {
                    Task { await updateItem(id: item.id, action: "claim") }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text("I got this")
                        .font(TandemFonts.micro)
                        .foregroundColor(TandemColors.primary)
                        .padding(.horizontal, TandemSpacing.sm)
                        .padding(.vertical, TandemSpacing.xs)
                        .background(
                            Capsule()
                                .stroke(TandemColors.primary.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(TandemSpacing.md)
        .background(TandemColors.cardBackground)
        .cornerRadius(TandemCornerRadius.card)
        .shadow(
            color: TandemShadow.soft.color,
            radius: TandemShadow.soft.radius,
            x: TandemShadow.soft.x,
            y: TandemShadow.soft.y
        )
    }

    // MARK: - Completed Section

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: TandemSpacing.sm) {
            HStack(spacing: TandemSpacing.sm) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(TandemColors.secondary)
                Text("Wins (\(completedItems.count))")
                    .font(TandemFonts.headline)
                    .foregroundColor(TandemColors.textSecondary)
            }
            .padding(.horizontal, TandemSpacing.md)

            ForEach(completedItems.prefix(5)) { item in
                HStack(spacing: TandemSpacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(TandemColors.secondary.opacity(0.6))
                        .font(.system(size: 20))

                    HStack(spacing: TandemSpacing.xs) {
                        Text(item.emoji)
                            .font(.system(size: 14))
                        Text(item.title)
                            .font(TandemFonts.callout)
                            .foregroundColor(TandemColors.textSecondary)
                            .strikethrough(true, color: TandemColors.textSecondary.opacity(0.4))
                    }

                    Spacer()

                    if let claimer = item.claimedByName {
                        Text(item.claimedByUserId == currentUserId ? "You" : claimer)
                            .font(TandemFonts.micro)
                            .foregroundColor(TandemColors.secondary.opacity(0.7))
                    }
                }
                .padding(.horizontal, TandemSpacing.md)
                .padding(.vertical, TandemSpacing.sm)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: TandemSpacing.lg) {
            Spacer().frame(height: TandemSpacing.xxl)

            ZStack {
                Circle()
                    .fill(TandemColors.boardColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "list.clipboard.fill")
                    .font(.system(size: 44))
                    .foregroundColor(TandemColors.boardColor)
            }

            VStack(spacing: TandemSpacing.sm) {
                Text("Your Shared Board")
                    .font(TandemFonts.title)
                    .foregroundColor(TandemColors.textPrimary)

                Text("Add things you want to tackle together.\nClaim them with \"I got this\" to show your partner you care.")
                    .font(TandemFonts.body)
                    .foregroundColor(TandemColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, TandemSpacing.lg)
            }

            Button {
                showNewItem = true
            } label: {
                Text("Add First Item")
                    .font(TandemFonts.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TandemSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [TandemColors.boardColor, TandemColors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(TandemCornerRadius.button)
                    .shadow(
                        color: TandemColors.boardColor.opacity(0.3),
                        radius: 8, x: 0, y: 4
                    )
            }
            .padding(.horizontal, TandemSpacing.xl)
        }
    }

    // MARK: - New Item Sheet

    private var newItemSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: TandemSpacing.lg) {
                    // Category picker
                    VStack(alignment: .leading, spacing: TandemSpacing.sm) {
                        Text("Category")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: TandemSpacing.sm) {
                            ForEach(categories, id: \.id) { cat in
                                Button {
                                    newCategory = cat.id
                                    newEmoji = cat.emoji
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    HStack(spacing: TandemSpacing.sm) {
                                        Text(cat.emoji)
                                            .font(.system(size: 18))
                                        Text(cat.label)
                                            .font(TandemFonts.callout)
                                    }
                                    .foregroundColor(
                                        newCategory == cat.id ? .white : TandemColors.textPrimary
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, TandemSpacing.sm)
                                    .background(
                                        RoundedRectangle(cornerRadius: TandemCornerRadius.button)
                                            .fill(
                                                newCategory == cat.id
                                                    ? TandemColors.boardColor
                                                    : TandemColors.background
                                            )
                                    )
                                }
                            }
                        }
                    }

                    // Title
                    VStack(alignment: .leading, spacing: TandemSpacing.xs) {
                        Text("What needs doing?")
                            .font(TandemFonts.captionBold)
                            .foregroundColor(TandemColors.textSecondary)
                        TextField("e.g., Pick up groceries", text: $newTitle)
                            .font(TandemFonts.body)
                            .padding(TandemSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: TandemCornerRadius.small)
                                    .fill(TandemColors.background)
                            )
                    }
                }
                .padding(TandemSpacing.md)
            }
            .background(TandemColors.cardBackground)
            .navigationTitle("Add to Board")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showNewItem = false }
                        .foregroundColor(TandemColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        Task { await createItem() }
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(TandemColors.boardColor)
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helpers

    private func categoryLabel(_ id: String) -> String {
        categories.first { $0.id == id }?.label ?? "Life Stuff"
    }

    // MARK: - API Calls

    private func loadItems() async {
        do {
            let result = try await APIService.shared.getBoardItems()
            items = result.items
        } catch {
            print("Failed to load board: \(error)")
        }
        isLoading = false
    }

    private func createItem() async {
        let title = newTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        do {
            let result = try await APIService.shared.createBoardItem(
                title: title, category: newCategory, emoji: newEmoji
            )
            items.insert(result.item, at: 0)
            newTitle = ""
            newCategory = "life"
            newEmoji = "\u{2728}"
            showNewItem = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            print("Failed to create board item: \(error)")
        }
    }

    private func updateItem(id: String, action: String) async {
        do {
            let result = try await APIService.shared.updateBoardItem(id: id, action: action)
            if let idx = items.firstIndex(where: { $0.id == id }) {
                withAnimation(.spring(response: 0.4)) {
                    items[idx] = result.item
                }
            }
            if action == "complete" {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } catch {
            print("Failed to update board item: \(error)")
        }
    }
}
