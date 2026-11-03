// GameSetupView.swift
// Combined team setup and game settings view
// All text and icons use .black for better contrast

import SwiftUI

struct GameSetupView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var settingsManager: SettingsManager
    @Binding var selection: AppFlow
    
    @State private var teamAName: String = "Team Alpha"
    @State private var teamBName: String = "Team Bravo"
    @State private var selectedDeck: TabooCard.AgeGroup = .kids
    @State private var selectedTimer: Int = 60
    @State private var selectedPoints: Int = 15
    // Added explicit @State variables to hold roles for each team (for kidsVsParents mode)
    @State private var teamARole: GameViewModel.Team.Role = .kid
    @State private var teamBRole: GameViewModel.Team.Role = .parent
    
    private let timerOptions = [30, 60, 90]
    private let pointsOptions = [10, 15, 20, 25]
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Team Identification
                        sectionCard(title: "Team Identification", icon: "person.2.fill") {
                            VStack(spacing: 16) {
                                TeamNameField(label: "Team A Name", text: $teamAName)
                                
                                // If game mode is kidsVsParents, add Role Picker for Team A
                                if viewModel.gameMode == .kidsVsParents {
                                    Picker("Role", selection: $teamARole) {
                                        Text("Kid").tag(GameViewModel.Team.Role.kid)
                                        Text("Parent").tag(GameViewModel.Team.Role.parent)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                                
                                TeamNameField(label: "Team B Name", text: $teamBName)
                                
                                // If game mode is kidsVsParents, add Role Picker for Team B
                                if viewModel.gameMode == .kidsVsParents {
                                    Picker("Role", selection: $teamBRole) {
                                        Text("Kid").tag(GameViewModel.Team.Role.kid)
                                        Text("Parent").tag(GameViewModel.Team.Role.parent)
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                        }
                        
                        // Age-Based Decks
                        if viewModel.gameMode == .soloOrTeam {
                            sectionCard(title: "Age-Based Decks", icon: "sparkles") {
                                HStack(spacing: 12) {
                                    DeckButton(
                                        icon: "face.smiling",
                                        label: "Kids",
                                        isSelected: selectedDeck == .kids
                                    ) { selectedDeck = .kids }
                                    
                                    DeckButton(
                                        icon: "figure.2.and.child.holdinghands",
                                        label: "Family",
                                        isSelected: selectedDeck == .teens
                                    ) { selectedDeck = .teens }
                                    
                                    DeckButton(
                                        icon: "person.fill",
                                        label: "Adult",
                                        isSelected: selectedDeck == .adults
                                    ) { selectedDeck = .adults }
                                }
                            }
                        }
                        
                        // Round Timer
                        sectionCard(title: "Round Timer", icon: "timer") {
                            HStack(spacing: 12) {
                                ForEach(timerOptions, id: \.self) { seconds in
                                    TimerOptionButton(
                                        seconds: seconds,
                                        isSelected: selectedTimer == seconds
                                    ) { selectedTimer = seconds }
                                }
                            }
                        }
                        
                        // Points to Win
                        sectionCard(title: "Points to Win", icon: "trophy.fill") {
                            HStack(spacing: 12) {
                                ForEach(pointsOptions, id: \.self) { points in
                                    PointsOptionButton(
                                        points: points,
                                        isSelected: selectedPoints == points
                                    ) { selectedPoints = points }
                                }
                            }
                        }
                        
                        // Game Summary
                        gameSummaryCard
                        
                        // Start Game Button
                        Button {
                            startGame()
                        } label: {
                            HStack(spacing: 8) {
                                Text("START GAME")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                            }
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
                            .shadow(color: Color(red: 0.2, green: 0.5, blue: 0.9).opacity(0.4), radius: 8, y: 4)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .onAppear {
            selectedDeck = viewModel.ageGroup
            selectedTimer = settingsManager.settings.timerSeconds
            selectedPoints = settingsManager.settings.pointsToWin
            
            if viewModel.teams.count >= 2 {
                teamAName = viewModel.teams[0].name
                teamBName = viewModel.teams[1].name
                
                // Initialize roles from viewModel teams if available (important for kidsVsParents mode)
                teamARole = viewModel.teams[0].role
                teamBRole = viewModel.teams[1].role
            }
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button {
                selection = .welcome
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Text("Game Setup")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
            
            // Invisible spacer for centering
            Image(systemName: "arrow.left")
                .font(.system(size: 20))
                .foregroundColor(.clear)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
    }
    
    // MARK: - Section Card
    @ViewBuilder
    private func sectionCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            
            content()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding(.horizontal)
    }
    
    // MARK: - Game Summary Card
    private var gameSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GAME SUMMARY")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.black)
            
            // Split summary into several Text views to resolve type checking limits.
            VStack(alignment: .leading, spacing: 0) {
                Text("\(teamAName) vs \(teamBName)")
                    .fontWeight(.semibold)
                Text("Playing \(deckName)")
                    .fontWeight(.semibold)
                Text("with \(selectedTimer)s rounds")
                Text("until someone hits \(selectedPoints) points.")
            }
            .font(.system(size: 14))
            .foregroundColor(.black)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var deckName: String {
        switch selectedDeck {
        case .kids: return "Kids Deck"
        case .teens: return "Family Deck"
        case .adults: return "Adult Deck"
        }
    }
    
    // MARK: - Start Game
    private func startGame() {
        // Set up teams with roles from pickers if kidsVsParents mode, else default
        var teamA = GameViewModel.Team(name: teamAName)
        var teamB = GameViewModel.Team(name: teamBName)
        
        if viewModel.gameMode == .kidsVsParents {
            // Use roles from role pickers instead of hardcoded roles
            teamA.role = teamARole
            teamB.role = teamBRole
        }
        
        viewModel.teams = [teamA, teamB]
        viewModel.ageGroup = selectedDeck
        viewModel.currentTeamIndex = 0
        
        // Update settings
        settingsManager.settings.timerSeconds = selectedTimer
        settingsManager.settings.pointsToWin = selectedPoints
        viewModel.settings = settingsManager.settings
        
        selection = .game
    }
}

// MARK: - Team Name Field
struct TeamNameField: View {
    let label: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.black)
            
            TextField("Enter team name", text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(red: 0.96, green: 0.97, blue: 0.98))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .foregroundColor(.black)
        }
    }
}

// MARK: - Deck Button
struct DeckButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color(red: 0.96, green: 0.97, blue: 0.98))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Timer Option Button
struct TimerOptionButton: View {
    let seconds: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(seconds)s")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color(red: 0.96, green: 0.97, blue: 0.98))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Points Option Button
struct PointsOptionButton: View {
    let points: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(points)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color(red: 0.2, green: 0.5, blue: 0.9) : Color(red: 0.96, green: 0.97, blue: 0.98))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    GameSetupView(
        viewModel: GameViewModel(),
        settingsManager: SettingsManager.shared,
        selection: .constant(.gameSetup)
    )
}

