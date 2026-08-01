import Foundation

struct AppEnvironment {
    let apiClient: any APIClient
    let authTokenStore: KeychainAuthTokenStore
    let authenticationRepository: any AuthenticationRepository
    let tripRegistrationRepository: any TripRegistrationRepository

    static func live(
        configuration: APIConfiguration = .current
    ) -> AppEnvironment {
        let tokenStore = KeychainAuthTokenStore()
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 15
        sessionConfiguration.timeoutIntervalForResource = 30

        let client = DefaultAPIClient(
            baseURL: configuration.baseURL,
            session: URLSession(configuration: sessionConfiguration),
            accessTokenProvider: { await tokenStore.accessToken() }
        )
        let authenticationRepository = RemoteAuthenticationRepository(
            apiClient: client,
            tokenStore: tokenStore
        )
        let tripRegistrationRepository = RemoteTripRegistrationRepository(
            apiClient: client
        )
        return AppEnvironment(
            apiClient: client,
            authTokenStore: tokenStore,
            authenticationRepository: authenticationRepository,
            tripRegistrationRepository: tripRegistrationRepository
        )
    }
}
