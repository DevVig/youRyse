import SwiftUI
import Charts

struct StatsView: View {
    @ObservedObject var store: GoalStore
    
    // Derived data for charts
    var weeklyData: [DailyCount] {
        let calendar = Calendar.current
        let today = Date()
        // Last 7 days
        var data: [DailyCount] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let count = store.completedGoals.filter { goal in
                    guard let completedDate = goal.dateCompleted else { return false }
                    return calendar.isDate(completedDate, inSameDayAs: date)
                }.count
                
                // Formatter for day name
                let dayName = date.formatted(.dateTime.weekday(.abbreviated))
                data.append(DailyCount(day: dayName, count: count, date: date))
            }
        }
        return data.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.headline)
            
            Chart {
                ForEach(weeklyData) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Goals", item.count)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .annotation(position: .top) {
                        if item.count > 0 {
                            Text("\(item.count)")
                                .font(.caption2)
                        }
                    }
                }
            }
            .frame(height: 150)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Total Goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(store.completedGoals.count)")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("🔥 \(store.currentStreak)")
                        .font(.title2)
                        .bold()
                }
            }
            .padding(.top)
        }
        .padding()
    }
}

struct DailyCount: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
    let date: Date
}
