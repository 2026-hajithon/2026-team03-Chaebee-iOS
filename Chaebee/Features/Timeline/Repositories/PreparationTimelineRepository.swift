protocol PreparationTimelineRepository: Sendable {
    func fetchTimeline(tripID: Int) async throws -> PreparationTimeline
    func updateChecklistItem(id: Int, isChecked: Bool) async throws
}
