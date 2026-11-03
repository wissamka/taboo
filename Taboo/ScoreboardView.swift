// ScoreboardView.swift
// Game Over screen with winner celebration

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var selection: AppFlow
    @State private var showConfetti = false
    @State private var trophyScale: CGFloat = 0.5
    @State private var trophyOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            // Confetti particles
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Trophy Icon
                        trophySection
                            .padding(.top, 32)
                        
                        // Winner Announcement
                        if let winner = viewModel.winningTeam {
                            VStack(spacing: 12) {
                                Text("The \(winner.name) Win!")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                
                                // Deck Badge
                                Text(deckName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color(red: 0.2, green: 0.5, blue: 0.9), lineWidth: 1.5)
                                    )
                            }
                        }
                        
                        // Scores Card
                        scoresCard
                            .padding(.horizontal)
                        
                        // Decorative Element
                        Image(systemName: "flag.pattern.checkered")
                            .font(.system(size: 40))
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.3))
                            .rotationEffect(.degrees(-15))
                            .padding(.vertical, 16)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            // Play Again Button
                            Button {
                                viewModel.resetGame()
                                selection = .game
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.system(size: 18))
                                    Text("Play Again")
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.5, blue: 0.9), Color(red: 0.25, green: 0.55, blue: 0.95)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.4), radius: 6, y: 3)
                            }
                            
                            // Back to Home Button
                            Button {
                                selection = .welcome
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 16))
                                    Text("Back to Home")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear {
            SoundManager.shared.playEndFanfare()
            animateEntrance()
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                selection = .welcome
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Game Over")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Invisible spacer
            Image(systemName: "xmark")
                .font(.system(size: 18))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Trophy Section
    private var trophySection: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color(red: 0.92, green: 0.95, blue: 1.0))
                .frame(width: 140, height: 140)
            
            // Trophy
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                .scaleEffect(trophyScale)
                .opacity(trophyOpacity)
        }
    }
    
    // MARK: - Scores Card
    private var scoresCard: some View {
        VStack(spacing: 0) {
            // Winner (Champion)
            if let winner = viewModel.winningTeam {
                let lead = calculateLead(winner: winner)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CHAMPIONS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                            .tracking(1)
                        
                        Text(winner.name)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(winner.score)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("pts")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                        
                        if lead > 0 {
                            Text("+\(lead) Lead")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(20)
                .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            
            // Other teams
            ForEach(sortedTeams.dropFirst()) { team in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(team.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(team.score)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text("pts")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "face.smiling")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .background(Color.white)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
    
    // MARK: - Helper Properties
    private var sortedTeams: [GameViewModel.Team] {
        viewModel.teams.sorted { $0.score > $1.score }
    }
    
    private var deckName: String {
        switch viewModel.ageGroup {
        case .kids: return "Kids Deck"
        case .teens: return "Family Deck"
        case .adults: return "Adult Deck"
        }
    }
    
    private func calculateLead(winner: GameViewModel.Team) -> Int {
        let otherScores = viewModel.teams.filter { $0.id != winner.id }.map { $0.score }
        let highestOther = otherScores.max() ?? 0
        return winner.score - highestOther
    }
    
    // MARK: - Animation
    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            trophyScale = 1.0
            trophyOpacity = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showConfetti = true
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink,
            Color(red: 0.2, green: 0.5, blue: 0.9)
        ]
        
        particles = (0..<50).map { _ in
            ConfettiParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0,
                targetY: size.height + 50
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    particles[i].position.y = particles[i].targetY
                    particles[i].position.x += CGFloat.random(in: -50...50)
                    particles[i].opacity = 0
                }
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
    let targetY: CGFloat
}

#Preview {
    ScoreboardView(
        viewModel: GameViewModel(),
        selection: .constant(.scoreboard)
    )
}
