import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [WorkoutSet] = []
    @Published var isPro: Bool = false

    static let freeLimit = 40

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("repline_items.json")
        load()
    }

    var canAddMore: Bool { isPro || items.count < Store.freeLimit }

    func add(_ item: WorkoutSet) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: WorkoutSet) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: WorkoutSet) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([WorkoutSet].self, from: data) {
            items = decoded
        } else {
            items = [
        WorkoutSet(exercise: "Bench Press", weight: 135, reps: 5, rpe: 7.5),
        WorkoutSet(exercise: "Squat", weight: 185, reps: 5, rpe: 8),
        WorkoutSet(exercise: "Deadlift", weight: 225, reps: 3, rpe: 8.5)
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
