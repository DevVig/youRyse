import SwiftUI

struct GoalListView: View {
    @ObservedObject var store: GoalStore
    @State private var showingAddGoal = false
    
    // Sort goals: High -> Medium -> Low
    // Tie-break: Is Timer Active -> Date Created
    var sortedGoals: [Goal] {
        store.goals.sorted { g1, g2 in
            // Active timer always on top? Maybe too intrusive. 
            // Stick to Priority -> Created Date
            if g1.priority != g2.priority {
                // High(0) < Medium(1) ? No, Enum order is High, Medium, Low based on cases.
                // RawValue is string. We need comparable.
                // Let's rely on explicit mapping or switch.
                return priorityValue(g1.priority) > priorityValue(g2.priority)
            }
            return g1.dateCreated < g2.dateCreated
        }
    }
    
    func priorityValue(_ p: Priority) -> Int {
        switch p {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header / Streak
            HStack {
                Text("Today's Goals")
                    .font(.headline)
                Spacer()
                if store.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(store.currentStreak)")
                            .font(.headline)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            
            if store.goals.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "checklist")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No goals set for today.")
                        .foregroundColor(.secondary)
                    Button("Rise Up & Add Goal") {
                        showingAddGoal = true
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedGoals) { goal in
                        GoalRowView(store: store, goal: goal)
                    }
                    .onDelete { indexSet in
                        // Map visual index back to store index implies specific logic 
                        // simpler to delete by ID if needed, but ForEach on sorted array with onDelete is tricky.
                        // Better to delete by object.
                        // With standard List onDelete, it gives an IndexSet relative to the `sortedGoals`.
                        // We need to find the IDs of goals at those indices and delete them from store.
                         for index in indexSet {
                             let goalToDelete = sortedGoals[index]
                             if let storeIndex = store.goals.firstIndex(where: { $0.id == goalToDelete.id }) {
                                 store.deleteGoal(at: IndexSet(integer: storeIndex))
                             }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            
            // Floating Add Button or Bottom Bar
            HStack {
                Button(action: { showingAddGoal = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("New Goal")
                    }
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
                .padding()
                
                Spacer()
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView(store: store)
        }
    }
}
