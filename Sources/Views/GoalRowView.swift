import SwiftUI

struct GoalRowView: View {
    @ObservedObject var store: GoalStore
    var goal: Goal
    
    var isTimerRunning: Bool {
        store.activeGoalId == goal.id
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var body: some View {
        HStack {
            // Checkbox
            Button(action: {
                withAnimation {
                    store.toggleComplete(goal: goal)
                }
            }) {
                Image(systemName: goal.isCompleted ? "checkmark.square.fill" : "square")
                    .foregroundColor(goal.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // Priority Indicator
            Circle()
                .fill(Color(goal.priority.colorName))
                .frame(width: 8, height: 8)
            
            // Content
            VStack(alignment: .leading) {
                Text(goal.title)
                    .strikethrough(goal.isCompleted)
                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
            }
            
            Spacer()
            
            // Time Display
            Text(formatTime(goal.timeSpent))
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.secondary)
            
            // Timer Button
            if !goal.isCompleted {
                Button(action: {
                    store.toggleTimer(for: goal.id)
                }) {
                    Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundColor(isTimerRunning ? .orange : .blue)
                        .font(.title2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}
