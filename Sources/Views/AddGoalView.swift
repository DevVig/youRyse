import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: GoalStore
    
    @State private var title: String = ""
    @State private var priority: Priority = .medium
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Goal")
                .font(.headline)
            
            TextField("What will you rise to today?", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($isTitleFocused)
                .onSubmit {
                    saveGoal()
                }
            
            Picker("Priority", selection: $priority) {
                ForEach(Priority.allCases) { p in
                    Text(p.label).tag(p)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add Goal") {
                    saveGoal()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            isTitleFocused = true
        }
    }
    
    private func saveGoal() {
        if !title.trimmingCharacters(in: .whitespaces).isEmpty {
            store.addGoal(title: title, priority: priority)
            title = ""
            dismiss()
        }
    }
}
