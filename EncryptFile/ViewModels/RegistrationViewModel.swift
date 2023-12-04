import Combine
import Foundation

class RegistrationViewModel: ObservableObject {
    /// Input
    @Published var email = ""
    @Published var password = ""
    @Published var passwordConfirm = ""

    /// Output
    @Published var isMailValid = false
    @Published var isPasswordLengthValid = false
    @Published var isPasswordCapitalLetter = false
    @Published var isPasswordConfirmValid = false

    @Published var canLogin = false
    @Published var canRegister = false

    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        $email
            .receive(on: RunLoop.main)
            .map { email in
                // Check if it's email
                let regex = try! NSRegularExpression(
                    pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                    options: .caseInsensitive
                )
                return regex.firstMatch(in: email, options: [], range: NSRange(location: 0, length: email.count)) == nil && email.count >= 4
            }
            .assign(to: \.isMailValid, on: self)
            .store(in: &cancellableSet)

        $password
            .receive(on: RunLoop.main)
            .map { password in
                password.count >= 8
            }
            .assign(to: \.isPasswordLengthValid, on: self)
            .store(in: &cancellableSet)

        $password
            .receive(on: RunLoop.main)
            .map { password in
                let pattern = "[A-Z]"
                if let _ = password.range(of: pattern, options: .regularExpression) {
                    return true
                } else {
                    return false
                }
            }
            .assign(to: \.isPasswordCapitalLetter, on: self)
            .store(in: &cancellableSet)

        Publishers.CombineLatest($password, $passwordConfirm)
            .receive(on: RunLoop.main)
            .map { password, passwordConfirm in
                !passwordConfirm.isEmpty && (passwordConfirm == password)
            }
            .assign(to: \.isPasswordConfirmValid, on: self)
            .store(in: &cancellableSet)

        Publishers.CombineLatest($isMailValid, $isPasswordLengthValid)
            .receive(on: RunLoop.main)
            .map { $0 && $1 }
            .assign(to: \.canLogin, on: self)
            .store(in: &cancellableSet)

        Publishers.CombineLatest($isMailValid, $isPasswordConfirmValid)
            .receive(on: RunLoop.main)
            .map { $0 && $1 }
            .assign(to: \.canRegister, on: self)
            .store(in: &cancellableSet)
    }
}
