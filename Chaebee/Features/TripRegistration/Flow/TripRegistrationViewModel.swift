import Combine
import Foundation

@MainActor
final class TripRegistrationViewModel: ObservableObject {
    @Published private(set) var draft = TripRegistrationDraft()
    @Published private(set) var isSubmitting = false
    @Published private(set) var registeredTrip: RegisteredTrip?
    @Published private(set) var submissionErrorMessage: String?

    var canSubmit: Bool { draft.isComplete }

    func selectCountry(code: String, defaultCityCode: String? = nil) {
        guard draft.countryCode != code else { return }
        draft.countryCode = code
        draft.cityCode = defaultCityCode
    }

    func selectCity(code: String) {
        draft.cityCode = code
    }

    func selectDepartureDate(_ date: Date) {
        draft.departureDate = date
        draft.returnDate = nil
    }

    func selectReturnDate(_ date: Date) {
        draft.returnDate = date
    }

    func resetDates() {
        draft.departureDate = nil
        draft.returnDate = nil
    }

    func setPlansToBuyESIM(_ value: Bool) {
        draft.plansToBuyESIM = value
    }

    func setPlansToUseCash(_ value: Bool) {
        draft.plansToUseCash = value
    }

    func makeRequest() throws -> TripRegistrationRequest {
        try TripRegistrationRequest(draft: draft)
    }

    func submit(using repository: any TripRegistrationRepository) async {
        guard !isSubmitting else { return }

        isSubmitting = true
        submissionErrorMessage = nil

        do {
            registeredTrip = try await repository.createTrip(makeRequest())
        } catch let error as APIError {
            submissionErrorMessage = error.errorDescription
        } catch {
            submissionErrorMessage = String(localized: "tripRegistration.registration.error")
        }

        isSubmitting = false
    }
}
