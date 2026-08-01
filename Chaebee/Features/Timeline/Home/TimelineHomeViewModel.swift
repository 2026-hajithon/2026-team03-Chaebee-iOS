import Combine
import Foundation

@MainActor
final class TimelineHomeViewModel: ObservableObject {
    @Published private(set) var timeline: PreparationTimeline?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let tripID: Int
    private let repository: any PreparationTimelineRepository
    private var updatingItemIDs: Set<Int> = []

    init(
        tripID: Int,
        repository: any PreparationTimelineRepository
    ) {
        self.tripID = tripID
        self.repository = repository
    }

    func load() async {
        guard timeline == nil, !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            timeline = try await repository.fetchTimeline(tripID: tripID)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func retry() async {
        timeline = nil
        await load()
    }

    func toggleChecklistItem(id: Int) {
        guard
            !updatingItemIDs.contains(id),
            var updatedTimeline = timeline,
            let phaseIndex = updatedTimeline.phases.firstIndex(where: { phase in
                phase.checklistItems.contains(where: { $0.id == id })
            }),
            let itemIndex = updatedTimeline.phases[phaseIndex].checklistItems.firstIndex(
                where: { $0.id == id }
            )
        else { return }

        updatingItemIDs.insert(id)
        let previousValue = updatedTimeline.phases[phaseIndex].checklistItems[itemIndex].isChecked
        let newValue = !previousValue
        updatedTimeline.phases[phaseIndex].checklistItems[itemIndex].isChecked = newValue
        updatedTimeline.progress.done += newValue ? 1 : -1
        timeline = updatedTimeline

        Task {
            defer { updatingItemIDs.remove(id) }
            do {
                try await repository.updateChecklistItem(id: id, isChecked: newValue)
            } catch {
                restoreChecklistItem(id: id, isChecked: previousValue)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func restoreChecklistItem(id: Int, isChecked: Bool) {
        guard
            var updatedTimeline = timeline,
            let phaseIndex = updatedTimeline.phases.firstIndex(where: { phase in
                phase.checklistItems.contains(where: { $0.id == id })
            }),
            let itemIndex = updatedTimeline.phases[phaseIndex].checklistItems.firstIndex(
                where: { $0.id == id }
            )
        else { return }

        let currentValue = updatedTimeline.phases[phaseIndex].checklistItems[itemIndex].isChecked
        guard currentValue != isChecked else { return }

        updatedTimeline.phases[phaseIndex].checklistItems[itemIndex].isChecked = isChecked
        updatedTimeline.progress.done += isChecked ? 1 : -1
        timeline = updatedTimeline
    }
}
