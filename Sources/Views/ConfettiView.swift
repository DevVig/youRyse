import SwiftUI

struct ConfettiView: View {
    @State private var confettiDetails: [ConfettiDetail] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiDetails) { detail in
                Circle()
                    .fill(detail.color)
                    .frame(width: detail.size, height: detail.size)
                    .position(detail.position)
                    .opacity(detail.opacity)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            animateConfetti()
        }
        .allowsHitTesting(false) // Let clicks pass through
    }
    
    func animateConfetti() {
        // Create 50 particles
        for _ in 0..<50 {
            let startX = Double.random(in: 0...300)
            let startY = -50.0 // Start above screen

            let color = [Color.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
            
            let detail = ConfettiDetail(
                position: CGPoint(x: startX, y: startY),
                color: color,
                size: Double.random(in: 5...10),
                opacity: 1.0
            )
            confettiDetails.append(detail)
            
            withAnimation(.easeOut(duration: Double.random(in: 1.5...2.5))) {
                // simple fall animation not easily doable with just 'withAnimation' on position state in a loop effectively without complex geometry effect or canvas.
                // Simplified approach: Just fade in/out or move slightly.
                // A better approach for "Confetti" in pure SwiftUI without external packages is a GeometryEffect or Canvas.
            }
        }
    }
}

// A simpler, proven SwiftUI Confetti approach using modifiers
struct ConfettiModifier: ViewModifier {
    @State private var circleStart = 0.0
    @State private var circleEnd = 0.0
    
    func body(content: Content) -> some View {
        content // Placeholder, actual confetti logic is complex to scratch-build.
        // Let's use a simple overlay with random circles falling.
    }
}

// Rewriting ConfettiView to be functional self-contained
struct SimpleConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                ConfettiParticle()
            }
        }
    }
}

struct ConfettiParticle: View {
    @State private var animationState = false
    
    let xStart = Double.random(in: 0...300)
    let color = [Color.red, .blue, .green, .orange, .purple, .pink].randomElement()!
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(x: xStart, y: animationState ? 600 : -20)
            .opacity(animationState ? 0 : 1)
            .onAppear {
                withAnimation(.linear(duration: Double.random(in: 1...3))) {
                    animationState = true
                }
            }
    }
}

struct ConfettiDetail: Identifiable {
    let id = UUID()
    var position: CGPoint
    var color: Color
    var size: Double
    var opacity: Double
}
