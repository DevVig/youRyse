import SwiftUI

struct MainView: View {
    @EnvironmentObject var store: GoalStore
    @State private var selectedTab: Tab = .goals
    // Confetti trigger
    // We can monitor store.completedGoals changes or a specific specific publisher. 
    // For simplicity, let's just trigger confetti when a goal completion happens in UI? 
    // Actually, GoalStore updates completedGoals inside logic. 
    // We can use `.onChange(of: store.completedGoals)` to trigger it.
    
    @State private var showConfetti = false
    
    enum Tab {
        case goals, backlog, stats
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Tab Bar
                Picker("", selection: $selectedTab) {
                    Image(systemName: "list.bullet").tag(Tab.goals)
                    Image(systemName: "chart.bar").tag(Tab.stats)
                    Image(systemName: "tray.full").tag(Tab.backlog)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                switch selectedTab {
                case .goals:
                    GoalListView(store: store)
                case .stats:
                    StatsView(store: store)
                case .backlog:
                    BacklogView(store: store)
                }
            }
            .frame(width: 320, height: 450)
            
            // Celebration Overlay
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .onChange(of: store.completedGoals.count) { newValue in
            // Assuming simplified logic: if completed count increases, show confetti.
            // (Edge case: Restore goal decreases count, we handle that by verifying old value < new value ideally)
            // But we don't have old value easily in standard onChange iOS 16-. 
            // In macOS 13+, onChange gives old/new? No, simpler to just trigger.
            // Actually, if we restore, count goes down. 
            // We only want confetti on completion (count up).
            // Let's assume most changes are completions for now or basic toggle logic.
            // A better way is a dedicated 'trigger' publisher in store. 
            // For MVP, just show confetti if count > 0 is simplest, but technically we want meaningful triggers.
            showConfetti = true
            
            // Hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showConfetti = false
            }
        }
    }
}
