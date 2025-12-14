import SwiftUI

@main
struct YouRyseApp: App {
    @StateObject private var goalStore = GoalStore()
    
    var body: some Scene {
        MenuBarExtra("YouRyse", systemImage: "arrow.up.circle.fill") {
            MainView()
                .environmentObject(goalStore)
        }
        .menuBarExtraStyle(.window) // Allows complex SwiftUI view
    }
}
