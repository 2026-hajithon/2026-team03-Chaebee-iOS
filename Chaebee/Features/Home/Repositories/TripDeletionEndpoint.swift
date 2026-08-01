import Foundation

struct TripDeletionEndpoint: Endpoint {
    let path: String
    let method = HTTPMethod.delete

    init(tripID: Int) {
        path = "/trips/\(tripID)"
    }
}
