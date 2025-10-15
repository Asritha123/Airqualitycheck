import Combine

@MainActor
final class AuthenticationManager: ObservableObject {
    @Published var username: String = "Asritha"
    @Published var passwordAttempts: Int = 0
}
