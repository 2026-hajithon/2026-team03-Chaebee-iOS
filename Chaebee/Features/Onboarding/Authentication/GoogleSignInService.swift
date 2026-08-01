import Foundation
import GoogleSignIn
import UIKit

enum GoogleSignInServiceError: LocalizedError {
    case missingConfiguration
    case missingPresentingViewController
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingConfiguration:
            String(localized: "onboarding.login.error.configuration")
        case .missingPresentingViewController:
            String(localized: "onboarding.login.error.presentation")
        case .missingIDToken:
            String(localized: "onboarding.login.error.token")
        }
    }
}

@MainActor
protocol GoogleSignInServicing {
    func signIn() async throws -> GoogleSignInCredential
}

struct GoogleSignInCredential: Equatable, Sendable {
    let idToken: String
    let name: String?
    let email: String?
}

@MainActor
final class GoogleSignInService: GoogleSignInServicing {
    private let signIn = GIDSignIn.sharedInstance

    func signIn() async throws -> GoogleSignInCredential {
        guard let clientID = GoogleSignInConfiguration.clientID else {
            throw GoogleSignInServiceError.missingConfiguration
        }
        guard let presentingViewController = UIApplication.shared.topViewController else {
            throw GoogleSignInServiceError.missingPresentingViewController
        }

        signIn.configuration = GIDConfiguration(
            clientID: clientID,
            serverClientID: GoogleSignInConfiguration.serverClientID
        )

        // GIDSignIn persists its own session independently of our app token.
        // Clear it before an interactive login so an account switch cannot
        // silently reuse the previously authenticated Google user.
        signIn.signOut()
        let result = try await signIn.signIn(withPresenting: presentingViewController)

        guard let idToken = result.user.idToken?.tokenString,
              !idToken.isEmpty else {
            throw GoogleSignInServiceError.missingIDToken
        }

        return GoogleSignInCredential(
            idToken: idToken,
            name: result.user.profile?.name,
            email: result.user.profile?.email
        )
    }
}

private enum GoogleSignInConfiguration {
    static var clientID: String? {
        configuration["CLIENT_ID"] as? String
    }

    static var serverClientID: String? {
        configuration["SERVER_CLIENT_ID"] as? String
    }

    private static var configuration: [String: Any] {
        guard let url = Bundle.main.url(
            forResource: "GoogleService-Info",
            withExtension: "plist"
        ), let data = try? Data(contentsOf: url),
           let propertyList = try? PropertyListSerialization.propertyList(
               from: data,
               options: [],
               format: nil
           ), let dictionary = propertyList as? [String: Any] else {
            return [:]
        }
        return dictionary
    }
}

private extension UIApplication {
    var topViewController: UIViewController? {
        let rootViewController = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        return rootViewController?.topPresentedViewController
    }
}

private extension UIViewController {
    var topPresentedViewController: UIViewController {
        if let presentedViewController {
            return presentedViewController.topPresentedViewController
        }
        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topPresentedViewController
        }
        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topPresentedViewController
        }
        return self
    }
}
