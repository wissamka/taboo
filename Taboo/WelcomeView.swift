// WelcomeView.swift
// Taboo - Welcome screen with mode selection

import SwiftUI

enum AppFlow {
    case welcome, gameSetup, game, scoreboard, howToPlay, decks, stats
}

struct WelcomeView: View {
    @Binding var selection: AppFlow
    @Binding var gameMode: GameViewModel.GameMode
    @Binding var ageGroup: TabooCard.AgeGroup
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Main Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Title Section
                        VStack(spacing: 8) {
                            Text("Ready to Play?")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Pick a mode to start the fun!")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)
                        
                        // Mode Cards
                        VStack(spacing: 16) {
                            // Kids vs Parents Mode Card
                            ModeCard(
                                title: "Kids vs Parents",
                                icon: "figure.2.and.child.holdinghands",
                                gradient: LinearGradient(
                                    colors: [Color(red: 0.98, green: 0.94, blue: 0.9), Color(red: 0.96, green: 0.88, blue: 0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                isSelected: gameMode == .kidsVsParents
                            ) {
                                gameMode = .kidsVsParents
                                selection = .gameSetup
                            }
                            
                            // Age-Based Mode Card
                            ModeCard(
                                title: "Age-Based Mode",
                                icon: "rectangle.stack.fill",
                                gradient: LinearGradient(
                                    colors: [Color(red: 0.93, green: 0.95, blue: 0.98), Color(red: 0.88, green: 0.92, blue: 0.97)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                isSelected: gameMode == .soloOrTeam
                            ) {
                                gameMode = .soloOrTeam
                                selection = .gameSetup
                            }
                        }
                        .padding(.horizontal)
                        
                        // How to Play Button
                        Button {
                            selection = .howToPlay
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 18))
                                Text("How to Play")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        }
                        .padding(.top, 8)
                        
                        // Subtitle
                        Text("New card decks added weekly!")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                        
                        Spacer(minLength: 100)
                    }
                }
                
                // Bottom Navigation
                bottomNavigation
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text("TABOO")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
            
            Spacer()
            
            Button {
                // Settings action
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.2, green: 0.5, blue: 0.9))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    // MARK: - Bottom Navigation
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            TabButton(icon: "house.fill", label: "Home", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(icon: "square.stack.3d.up.fill", label: "Decks", isSelected: selectedTab == 1) {
                selectedTab = 1
                selection = .decks
            }
            TabButton(icon: "chart.bar.fill", label: "Stats", isSelected: selectedTab == 2) {
                selectedTab = 2
                selection = .stats
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 8, y: -2)
    }
}

// MARK: - Mode Card
struct ModeCard: View {
    let title: String
    let icon: String
    let gradient: LinearGradient
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon Area
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(gradient)
                        .frame(height: 140)
                    
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(.primary.opacity(0.6))
                }
                
                // Title
                HStack {
                    Image(systemName: title.contains("Kids") ? "figure.2.and.child.holdinghands" : "person.crop.rectangle.stack")
                        .font(.system(size: 16))
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.bottom, 12)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundColor(isSelected ? Color(red: 0.2, green: 0.5, blue: 0.9) : .secondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    WelcomeView(
        selection: .constant(.welcome),
        gameMode: .constant(.kidsVsParents),
        ageGroup: .constant(.kids)
    )
}
