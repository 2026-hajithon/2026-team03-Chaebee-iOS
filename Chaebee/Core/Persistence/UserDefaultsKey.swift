/// A type-safe identifier for a UserDefaults entry.
/// Actual keys are defined after the hackathon starts.
struct UserDefaultsKey<Value> {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
