import SwiftUI

struct BacklogView: View {
    @ObservedObject var store: GoalStore
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Completed Goals")
                .font(.headline)
                .padding(.horizontal)
            
            if store.completedGoals.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No completed goals yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(store.completedGoals) { goal in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(goal.title)
                                    .strikethrough()
                                    .foregroundColor(.secondary)
                                if let date = goal.dateCompleted {
                                    Text(date.formatted())
                                        .font(.caption2)
                                        .foregroundColor(.secondary.opacity(0.7))
                                }
                            }
                            Spacer()
                            // Restore button
                            Button(action: {
                                store.restoreGoal(goal)
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}
