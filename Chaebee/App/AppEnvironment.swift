import Foundation

struct AppEnvironment {
    let apiClient: any APIClient
    let authTokenStore: KeychainAuthTokenStore
    let authenticationRepository: any AuthenticationRepository
    let tripRegistrationRepository: any TripRegistrationRepository
    let homeDashboardRepository: any HomeDashboardRepository
    let preparationTimelineRepository: any PreparationTimelineRepository
    let writeExperienceRepository: any WriteExperienceHomeRepository
    let experienceLocationRepository: any ExperienceLocationRepository

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
        let homeDashboardRepository = RemoteHomeDashboardRepository(
            apiClient: client
        )
        let preparationTimelineRepository = RemotePreparationTimelineRepository(
            client: client
        )
        let writeExperienceRepository = RemoteWriteExperienceHomeRepository(
            apiClient: client
        )
        let experienceLocationRepository = RemoteExperienceLocationRepository(
            apiClient: client
        )
        return AppEnvironment(
            apiClient: client,
            authTokenStore: tokenStore,
            authenticationRepository: authenticationRepository,
            tripRegistrationRepository: tripRegistrationRepository,
            homeDashboardRepository: homeDashboardRepository,
            preparationTimelineRepository: preparationTimelineRepository,
            writeExperienceRepository: writeExperienceRepository,
            experienceLocationRepository: experienceLocationRepository
        )
    }
}
