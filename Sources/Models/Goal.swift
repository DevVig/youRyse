import Foundation

enum Priority: String, Codable, CaseIterable, Identifiable {
    case high
    case medium
    case low
    
    var id: String { rawValue }
    
    var colorName: String {
        switch self {
        case .high: return "red"
        case .medium: return "yellow"
        case .low: return "green"
        }
    }
    
    var label: String {
        switch self {
        case .high: return "High Priority"
        case .medium: return "Medium Priority"
        case .low: return "Low Priority"
        }
    }
}

struct Goal: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var priority: Priority
    var timeSpent: TimeInterval = 0
    var isCompleted: Bool = false
    var dateCreated: Date = Date()
    var dateCompleted: Date?
    
    // ADHD Strategy: Micro-goals
    // Simple list of steps to help break down the task
    var steps: [GoalStep] = []
}

struct GoalStep: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
}
