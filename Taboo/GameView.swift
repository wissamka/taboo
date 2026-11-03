// GameView.swift
// Main game UI view with card display and actions

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var settingsManager: SettingsManager
    @Binding var selection: AppFlow
    @State private var isPaused: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardOpacity: Double = 1
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with team name and timer
                gameHeader
                
                // Card Area
                ScrollView {
                    VStack(spacing: 20) {
                        if let card = viewModel.currentCard {
                            GameCardView(card: card)
                                .offset(y: cardOffset)
                                .opacity(cardOpacity)
                                .padding(.horizontal)
                                .padding(.top, 16)
                        } else {
                            noCardsView
                        }
                        
                        // Action Buttons
                        actionButtons
                            .padding(.horizontal)
                        
                        // Taboo Foul Button
                        tabooFoulButton
                            .padding(.horizontal)
                        
                        // Stats Bar
                        statsBar
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
            }
            
            // Pause Overlay
            if isPaused {
                pauseOverlay
            }
            
            // Buzzer Overlay
            if viewModel.showBuzzer {
                buzzerOverlay
            }
        }
        .onAppear {
            Task {
                await viewModel.loadCards()
                // Start timer automatically on view appear if not running
                if !viewModel.timerRunning {
                    viewModel.startTimer()
                }
            }
        }
        // Restart timer automatically when team changes
        .onChange(of: viewModel.currentTeamIndex) { _ in
            viewModel.startTimer()
        }
        // Restart timer automatically when new card appears (failsafe)
        .onChange(of: viewModel.currentCard) { _ in
            viewModel.startTimer()
        }
        .onChange(of: settingsManager.settings) { new in
            viewModel.settings = new
        }
        .fullScreenCover(isPresented: $viewModel.showEndGame) {
            ScoreboardView(viewModel: viewModel, selection: $selection)
        }
    }
    
    // MARK: - Game Header
    private var gameHeader: some View {
        HStack(spacing: 12) {
            // Team Badge
            HStack(spacing: 6) {
                Image(systemName: currentTeamRole == .kid ? "face.smiling.inverse" : "person.fill")
                    .font(.system(size: 14))
                Text(currentTeamName)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(red: 0.2, green: 0.5, blue: 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Spacer()
            
            // Timer Display - Now just shows timer value, no button to start
            HStack(spacing: 4) {
                TimerDigit(value: timerMinutes)
                Text("MIN")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
                
                TimerDigit(value: timerSeconds)
                Text("SEC")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            // Pause Button
            Button {
                togglePause()
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color(red: 0.2, green: 0.5, blue: 0.9))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Skip Button
            Button {
                animateCardTransition {
                    viewModel.markSkip()
                    SoundManager.shared.playTick()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                    Text("Skip")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.55, green: 0.6, blue: 0.7))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            
            // Correct Button
            Button {
                animateCardTransition {
                    viewModel.markCorrect()
                    SoundManager.shared.playCorrect()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                    Text("Correct")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.2, green: 0.5, blue: 0.9), lineWidth: 2)
                )
            }
        }
    }
    
    // MARK: - Taboo Foul Button
    private var tabooFoulButton: some View {
        Button {
            viewModel.markTaboo()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18))
                Text("TABOO! FOUL!")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.9, green: 0.3, blue: 0.3), Color(red: 0.85, green: 0.25, blue: 0.25)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.red.opacity(0.3), radius: 6, y: 3)
        }
    }
    
    // MARK: - Stats Bar
    private var statsBar: some View {
        HStack {
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("\(viewModel.teams[viewModel.currentTeamIndex].score) Done")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                Text("\(foulsCount) Foul")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Card \(viewModel.usedCards.count) of \(totalCards)")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - No Cards View
    private var noCardsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.xmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No more cards!")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Pause Overlay
    private var pauseOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Game Paused")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    Button {
                        togglePause()
                    } label: {
                        Text("Resume")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 200)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.2, green: 0.5, blue: 0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        selection = .welcome
                    } label: {
                        Text("Quit Game")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    // MARK: - Buzzer Overlay
    private var buzzerOverlay: some View {
        ZStack {
            Color.red.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                Text("TABOO!")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .transition(.opacity)
    }
    
    // MARK: - Helper Properties
    private var currentTeamName: String {
        viewModel.teams.isEmpty ? "Team" : viewModel.teams[viewModel.currentTeamIndex].name
    }
    
    private var currentTeamRole: GameViewModel.Team.Role {
        viewModel.teams.isEmpty ? .kid : viewModel.teams[viewModel.currentTeamIndex].role
    }
    
    private var timerMinutes: Int {
        viewModel.timerValue / 60
    }
    
    private var timerSeconds: Int {
        viewModel.timerValue % 60
    }
    
    private var foulsCount: Int {
        // Track fouls separately if needed, for now show 0
        0
    }
    
    private var totalCards: Int {
        max(viewModel.cards.count, 30)
    }
    
    // MARK: - Actions
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            viewModel.stopTimer()
        } else {
            viewModel.startTimer()
        }
    }
    
    private func animateCardTransition(action: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.2)) {
            cardOffset = -20
            cardOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            action()
            cardOffset = 20
            
            withAnimation(.easeOut(duration: 0.2)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
    }
}

// MARK: - Game Card View
struct GameCardView: View {
    let card: TabooCard
    
    var body: some View {
        VStack(spacing: 0) {
            // Image Placeholder Area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.98, green: 0.95, blue: 0.92), Color(red: 0.96, green: 0.9, blue: 0.86)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                
                // Icon based on word category
                Image(systemName: cardIcon)
                    .font(.system(size: 70))
                    .foregroundColor(.brown.opacity(0.4))
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Target Word Section
            VStack(spacing: 8) {
                Text("TARGET WORD")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                    .tracking(1)
                
                Text(card.word)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            // Forbidden Words Section
            VStack(spacing: 12) {
                Text("FORBIDDEN WORDS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(1)
                    .padding(.top, 16)
                
                VStack(spacing: 8) {
                    ForEach(card.tabooWords, id: \.self) { word in
                        Text(word)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 24)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
    }
    
    private var cardIcon: String {
        // Return different icons based on some criteria
        let word = card.word.lowercased()
        if word.contains("cake") || word.contains("food") || word.contains("pizza") {
            return "birthday.cake.fill"
        } else if word.contains("animal") || word.contains("cat") || word.contains("dog") {
            return "pawprint.fill"
        } else if word.contains("school") || word.contains("book") {
            return "book.fill"
        } else if word.contains("game") || word.contains("play") {
            return "gamecontroller.fill"
        } else {
            return "sparkles"
        }
    }
}

// MARK: - Timer Digit
struct TimerDigit: View {
    let value: Int
    
    var body: some View {
        Text(String(format: "%02d", value))
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.96, green: 0.97, blue: 0.98))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    GameView(
        viewModel: GameViewModel(),
        settingsManager: SettingsManager.shared,
        selection: .constant(.game)
    )
}
