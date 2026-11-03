//
//  ContentView.swift
//  Taboo
//
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var settingsManager = SettingsManager.shared
    @State private var flow: AppFlow = .welcome
    
    var body: some View {
        Group {
            switch flow {
            case .welcome:
                WelcomeView(selection: $flow, gameMode: $viewModel.gameMode, ageGroup: $viewModel.ageGroup)
            case .gameSetup:
                GameSetupView(viewModel: viewModel, settingsManager: settingsManager, selection: $flow)
            case .game:
                GameView(viewModel: viewModel, settingsManager: settingsManager, selection: $flow)
            case .scoreboard:
                ScoreboardView(viewModel: viewModel, selection: $flow)
            case .howToPlay:
                HowToPlayView(selection: $flow)
            case .decks:
                DecksView(selection: $flow)
            case .stats:
                StatsView(selection: $flow)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: flow)
    }
}

// MARK: - How To Play View
struct HowToPlayView: View {
    @Binding var selection: AppFlow
    
    private let rules = [
        ("person.wave.2.fill", "One player describes the word on the card to their teammates"),
        ("xmark.circle.fill", "Don't say any of the forbidden 'taboo' words listed on the card"),
        ("timer", "Score as many words as possible before the timer runs out"),
        ("exclamationmark.triangle.fill", "If you say a taboo word, the other team buzzes and you lose a point"),
        ("trophy.fill", "First team to reach the target score wins!")
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        selection = .welcome
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("How to Play")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Title
                        VStack(spacing: 8) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                            
                            Text("Game Rules")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.top, 32)
                        
                        // Rules
                        VStack(spacing: 12) {
                            ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                                RuleCard(number: index + 1, icon: rule.0, text: rule.1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Got It Button
                        Button {
                            selection = .welcome
                        } label: {
                            Text("Got It!")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.5, blue: 0.9), Color(red: 0.25, green: 0.55, blue: 0.95)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}

struct RuleCard: View {
    let number: Int
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(number)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
                
                Text(text)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

// MARK: - Decks View (Placeholder)
struct DecksView: View {
    @Binding var selection: AppFlow
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        selection = .welcome
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Card Decks")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.3))
                    
                    Text("Card Decks")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("More card decks coming soon!\nNew decks are added weekly.")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

// MARK: - Stats View (Placeholder)
struct StatsView: View {
    @Binding var selection: AppFlow
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        selection = .welcome
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Text("Statistics")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20))
                        .foregroundColor(.clear)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 70))
                        .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.3))
                    
                    Text("Game Statistics")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Track your game history and stats.\nComing soon!")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
