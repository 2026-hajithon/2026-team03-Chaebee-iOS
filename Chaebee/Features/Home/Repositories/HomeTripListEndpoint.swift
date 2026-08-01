import Foundation

struct HomeTripListEndpoint: Endpoint {
    let path = "/trips/me"
    let method = HTTPMethod.get
}
