import Combine
import Foundation

@MainActor
final class TripRegistrationViewModel: ObservableObject {
    @Published private(set) var draft = TripRegistrationDraft()

    var canSubmit: Bool { draft.isComplete }

    func selectCountry(code: String) {
        guard draft.countryCode != code else { return }
        draft.countryCode = code
        draft.cityID = nil
    }

    func selectCity(id: String) {
        draft.cityID = id
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

    func submit(using repository: any TripRegistrationRepository) async throws {
        try await repository.createTrip(makeRequest())
    }
}
