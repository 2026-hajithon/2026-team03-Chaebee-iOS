import Foundation

struct TripRegistrationEndpoint: Endpoint {
    let path = "/trips"
    let method = HTTPMethod.post
    let body: Data?

    init(request: TripRegistrationRequest) throws {
        body = try JSONEncoder().encode(
            TripRegistrationRequestDTO(
                countryCode: request.countryCode,
                cityCode: request.cityCode,
                departureAt: TripRegistrationDateCodec.string(from: request.departureAt),
                arrivalAt: TripRegistrationDateCodec.string(from: request.arrivalAt),
                esimPlan: request.esimPlan,
                cashPlan: request.cashPlan
            )
        )
    }
}

private struct TripRegistrationRequestDTO: Encodable {
    let countryCode: String
    let cityCode: String
    let departureAt: String
    let arrivalAt: String
    let esimPlan: Bool
    let cashPlan: Bool
}

struct TripRegistrationResponseDTO: Decodable {
    let tripID: Int
    let countryCode: String
    let cityCode: String
    let departureAt: String
    let arrivalAt: String
    let esimPlan: Bool
    let cashPlan: Bool
    let dDay: Int

    private enum CodingKeys: String, CodingKey {
        case tripID = "tripId"
        case countryCode
        case cityCode
        case departureAt
        case arrivalAt
        case esimPlan
        case cashPlan
        case dDay
    }
}

enum TripRegistrationDateCodec {
    static func string(from date: Date) -> String {
        formatter().string(from: date)
    }

    static func date(from value: String) -> Date? {
        formatter().date(from: value)
    }

    private static func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }
}
