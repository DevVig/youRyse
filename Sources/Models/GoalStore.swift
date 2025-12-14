import Foundation
import Combine

class GoalStore: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var completedGoals: [Goal] = []
    @Published var currentStreak: Int = 0
    @Published var lastCompletionDate: Date?
    
    // Timer state
    @Published var activeGoalId: UUID?
    private var timer: Timer?
    
    private let goalsFileName = "goals.json"
    private let completedFileName = "completed_goals.json"
    private let settingsFileName = "settings.json"
    
    init() {
        loadData()
        updateStreak()
    }
    
    // MARK: - Goal Management
    
    func addGoal(title: String, priority: Priority) {
        let newGoal = Goal(title: title, priority: priority)
        goals.append(newGoal)
        saveData()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveData()
        }
    }
    
    func deleteGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
        if let activeId = activeGoalId, !goals.contains(where: { $0.id == activeId }) {
            stopTimer()
        }
        saveData()
    }
    
    func toggleComplete(goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            var updatedGoal = goals[index]
            updatedGoal.isCompleted.toggle()
            
            if updatedGoal.isCompleted {
                // Goal Completed!
                updatedGoal.dateCompleted = Date()
                stopTimer() // Stop timer if it was running on this goal
                
                // Move to completed list
                goals.remove(at: index)
                completedGoals.insert(updatedGoal, at: 0) // Newest first
                
                // Update Streak
                incrementStreakIfNeeded()
            } else {
                goals[index] = updatedGoal
            }
            saveData()
        }
    }
    
    func restoreGoal(_ goal: Goal) {
         if let index = completedGoals.firstIndex(where: { $0.id == goal.id }) {
             var restored = completedGoals[index]
             restored.isCompleted = false
             restored.dateCompleted = nil
             
             completedGoals.remove(at: index)
             goals.append(restored)
             saveData()
         }
    }

    // MARK: - Timer Logic
    
    func toggleTimer(for goalId: UUID) {
        if activeGoalId == goalId {
            stopTimer()
        } else {
            startTimer(for: goalId)
        }
    }
    
    func startTimer(for goalId: UUID) {
        stopTimer() // Stop any existing timer
        activeGoalId = goalId
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.incrementTime()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        activeGoalId = nil
    }
    
    private func incrementTime() {
        guard let goalId = activeGoalId,
              let index = goals.firstIndex(where: { $0.id == goalId }) else {
            stopTimer()
            return
        }
        
        goals[index].timeSpent += 1
        // We could optimize saving here to not save every second, maybe on stop or app background
        // For MVP, simple saving occasionally or relying on memory is okay, but let's debounce if possible. 
        // For simplicity in MVP, we just update the published property. Persistence happens on other actions or app exit (if we hooked that up, but file write every second is bad).
        // Let's NOT save to disk every second. We will save when timer stops.
    }
    
    // MARK: - Streak Logic
    
    private func incrementStreakIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        // If last completion was today, do nothing
        if let lastDate = lastCompletionDate, calendar.isDateInToday(lastDate) {
            return
        }
        
        // If last completion was yesterday, increment
        // If last completion was within 3 days (Forgiving Streak), increment?
        // Actually, usually streak increments by 1 per day.
        // If you miss a day, normally it resets. But we want "Forgiving".
        // Logic: 
        // If lastCompletionDate is nil, streak = 1.
        // If lastCompletionDate was yesterday (or today - 1 day), streak += 1.
        // If lastCompletionDate was > 3 days ago, streak = 1 (reset).
        // If within 3 days window but not yesterday, we maintain streak? Or just don't reset it?
        // Let's say: Streak increases by 1 for the *current day* if not already incremented.
        
        if let lastDate = lastCompletionDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
            
            if daysBetween > 3 {
                 currentStreak = 1 // Reset
            } else {
                currentStreak += 1
            }
        } else {
            currentStreak = 1
        }
        
        lastCompletionDate = today
        saveSettings()
    }
    
    private func updateStreak() {
        // Run on load to check if streak should be reset due to time passage
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDate = lastCompletionDate {
            let daysBetween = calendar.dateComponents([.day], from: lastDate, to: today).day ?? 0
             if daysBetween > 3 {
                 currentStreak = 0 
                 saveSettings()
            }
        }
    }

    // MARK: - Persistence
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("YouRyse")
    }
    
    private func loadData() {
        let folder = getDocumentsDirectory()
        // Ensure folder exists
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let decoder = JSONDecoder()
        
        if let data = try? Data(contentsOf: folder.appendingPathComponent(goalsFileName)),
           let decoded = try? decoder.decode([Goal].self, from: data) {
            goals = decoded
        }
        
        if let data = try? Data(contentsOf: folder.appendingPathComponent(completedFileName)),
           let decoded = try? decoder.decode([Goal].self, from: data) {
            completedGoals = decoded
        }
        
        if let data = try? Data(contentsOf: folder.appendingPathComponent(settingsFileName)),
           let settings = try? decoder.decode(SettingsData.self, from: data) {
            currentStreak = settings.streak
            lastCompletionDate = settings.lastCompletionDate
        }
    }
    
    func saveData() {
        let folder = getDocumentsDirectory()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(goals) {
            try? data.write(to: folder.appendingPathComponent(goalsFileName))
        }
        
        if let data = try? encoder.encode(completedGoals) {
            try? data.write(to: folder.appendingPathComponent(completedFileName))
        }
        
        saveSettings()
    }
    
    private func saveSettings() {
        let folder = getDocumentsDirectory()
        let encoder = JSONEncoder()
        let settings = SettingsData(streak: currentStreak, lastCompletionDate: lastCompletionDate)
        if let data = try? encoder.encode(settings) {
            try? data.write(to: folder.appendingPathComponent(settingsFileName))
        }
    }
}

struct SettingsData: Codable {
    var streak: Int
    var lastCompletionDate: Date?
}
