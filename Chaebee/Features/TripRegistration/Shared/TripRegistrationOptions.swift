struct TripRegistrationOptions: Hashable {
    let plansToBuyESIM: Bool
    let plansToUseCash: Bool

    var includesESIMPreparation: Bool { plansToBuyESIM }
    var includesCurrencyExchange: Bool { plansToUseCash }
}
