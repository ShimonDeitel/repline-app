import Foundation

struct WorkoutSet: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var exercise: String
    var weight: Double
    var reps: Double
    var rpe: Double

    init(id: UUID = UUID(), createdAt: Date = Date(), exercise: String = "", weight: Double = 0, reps: Double = 0, rpe: Double = 0) {
        self.id = id
        self.createdAt = createdAt
        self.exercise = exercise
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
    }
}
