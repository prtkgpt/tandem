import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var currentUser: TandemUser?
    @Published var couple: Couple?
    @Published var partnerName: String?
    @Published var needsOnboarding: Bool = true
    @Published var isPaired: Bool = false

    init() {
        checkAuth()
    }

    func checkAuth() {
        isAuthenticated = APIService.shared.isAuthenticated
        if isAuthenticated {
            Task {
                await loadProfile()
            }
        } else {
            isLoading = false
        }
    }

    func loadProfile() async {
        do {
            let me = try await APIService.shared.getMe()
            currentUser = me.user
            couple = me.couple
            partnerName = me.partnerName
            isPaired = me.couple != nil
            needsOnboarding = false
            isAuthenticated = true
        } catch {
            // Token invalid, clear it
            APIService.shared.clearToken()
            isAuthenticated = false
        }
        isLoading = false
    }

    func login(email: String, password: String) async throws {
        let response = try await APIService.shared.login(email: email, password: password)
        APIService.shared.setToken(response.token)
        currentUser = response.user
        isPaired = response.user.coupleId != nil
        isAuthenticated = true
        await loadProfile()
    }

    func register(name: String, email: String, password: String) async throws {
        let response = try await APIService.shared.register(name: name, email: email, password: password)
        APIService.shared.setToken(response.token)
        currentUser = response.user
        isAuthenticated = true
        isPaired = false
    }

    func logout() {
        APIService.shared.clearToken()
        isAuthenticated = false
        currentUser = nil
        couple = nil
        partnerName = nil
        isPaired = false
        needsOnboarding = true
    }

    func onPaired(coupleId: String, partnerName: String) async {
        self.partnerName = partnerName
        self.isPaired = true
        await loadProfile()
    }
}
