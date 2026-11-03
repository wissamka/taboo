// GameViewModel.swift
// Taboo
// Handles game logic, deck management, timer, and scoring.

import Foundation
import Combine
import AVFoundation
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    enum GameMode: String, CaseIterable, Identifiable {
        case kidsVsParents = "Kids vs Parents"
        case soloOrTeam = "Solo/Team"
        var id: String { rawValue }
    }

    struct Team: Identifiable, Equatable {
        enum Role: String, CaseIterable, Codable, Equatable, Identifiable {
            case kid = "Kid"
            case parent = "Parent"
            var id: String { rawValue }
        }
        let id = UUID()
        var name: String
        var score: Int = 0
        var role: Role = .kid // default role
    }

    @Published var cards: [TabooCard] = []
    @Published var currentCard: TabooCard?
    @Published var usedCards: Set<UUID> = []
    @Published var timerValue: Int = 60
    @Published var timerRunning: Bool = false
    @Published var showBuzzer: Bool = false
    @Published var currentTeamIndex: Int = 0
    @Published var teams: [Team] = []
    @Published var gameMode: GameMode = .kidsVsParents
    @Published var ageGroup: TabooCard.AgeGroup = .kids
    @Published var showEndGame: Bool = false
    @Published var settings = GameSettings()
    
    var timer: Timer?
    private(set) var cardPile: [TabooCard] = []
    private var kidCardPile: [TabooCard] = []
    private var parentCardPile: [TabooCard] = []
    
    // MARK: - Init & Data Loading
    func loadCards() async {
        do {
            guard let url = Bundle.main.url(forResource: "CardData", withExtension: "json") else { return }
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([TabooCard].self, from: data)
            self.cards = decoded
            buildDeck()
        } catch {
            print("Card data load error", error)
        }
    }
    
    func buildDeck() {
        // Build deck based on game mode and team roles
        switch gameMode {
        case .kidsVsParents:
            // Separate card piles for kids and parents according to specified rules
            // Kids: cards where isParentsCard == false and ageGroup == .kids
            kidCardPile = cards.filter { !$0.isParentsCard && $0.ageGroup == .kids }
            // Parents: cards where isParentsCard == true OR (ageGroup == .adults && isParentsCard == false)
            parentCardPile = cards.filter { $0.isParentsCard || ($0.ageGroup == .adults && !$0.isParentsCard) }
            kidCardPile.shuffle()
            parentCardPile.shuffle()
            usedCards.removeAll()
            // Initialize cardPile according to current team's role
            updateCardPileForCurrentTeam()
        case .soloOrTeam:
            // In solo/team mode, just filter by age group
            cardPile = cards.filter { $0.ageGroup == ageGroup }
            cardPile.shuffle()
            usedCards.removeAll()
        }
        drawNextCard()
    }
    
    /// Update the active cardPile based on the current team's role in kidsVsParents mode
    private func updateCardPileForCurrentTeam() {
        guard gameMode == .kidsVsParents, !teams.isEmpty else {
            // fallback to normal deck in other modes or no teams set
            cardPile = []
            return
        }
        
        let currentTeam = teams[currentTeamIndex]
        switch currentTeam.role {
        case .kid:
            // Use kidCardPile for kid role
            cardPile = kidCardPile.filter { !usedCards.contains($0.id) }
            if cardPile.isEmpty {
                // reset used cards for kid pile
                // Fix closure parameter shadowing by naming UUID parameter explicitly
                usedCards = usedCards.filter { uuid in !kidCardPile.contains(where: { $0.id == uuid }) }
                cardPile = kidCardPile
            }
            cardPile.shuffle()
        case .parent:
            // Use parentCardPile for parent role
            cardPile = parentCardPile.filter { !usedCards.contains($0.id) }
            if cardPile.isEmpty {
                // reset used cards for parent pile
                // Fix closure parameter shadowing by naming UUID parameter explicitly
                usedCards = usedCards.filter { uuid in !parentCardPile.contains(where: { $0.id == uuid }) }
                cardPile = parentCardPile
            }
            cardPile.shuffle()
        }
    }
    
    func drawNextCard() {
        // In Kids vs Parents mode, update cardPile based on current team's role before drawing
        if gameMode == .kidsVsParents {
            updateCardPileForCurrentTeam()
        } else if gameMode == .soloOrTeam {
            if cardPile.isEmpty {
                cardPile = cards.filter { $0.ageGroup == ageGroup }
                cardPile.shuffle()
                usedCards.removeAll()
            }
        }
        
        // Draw from the current cardPile
        if cardPile.isEmpty {
            // If no cards available, reset usedCards for current pile and reshuffle
            if gameMode == .kidsVsParents {
                switch teams[currentTeamIndex].role {
                case .kid:
                    // Fix closure parameter shadowing by naming UUID parameter explicitly
                    usedCards = usedCards.filter { uuid in !kidCardPile.contains(where: { $0.id == uuid }) }
                    cardPile = kidCardPile
                case .parent:
                    // Fix closure parameter shadowing by naming UUID parameter explicitly
                    usedCards = usedCards.filter { uuid in !parentCardPile.contains(where: { $0.id == uuid }) }
                    cardPile = parentCardPile
                }
            } else {
                usedCards.removeAll()
                cardPile = cards.filter { $0.ageGroup == ageGroup }
            }
            cardPile.shuffle()
        }
        currentCard = cardPile.popLast()
        if let card = currentCard { usedCards.insert(card.id) }
    }
    
    // MARK: - Timer
    func startTimer() {
        timer?.invalidate()
        timerValue = settings.timerSeconds
        timerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            if self.timerValue > 0 {
                self.timerValue -= 1
                if self.settings.soundOn {
                    SoundManager.shared.playTick()
                }
            } else {
                t.invalidate()
                self.endTurn()
            }
        }
    }
    func stopTimer() {
        timer?.invalidate()
        timerRunning = false
    }
    func endTurn() {
        stopTimer()
        // Advance to next team
        if currentTeamIndex + 1 < teams.count {
            currentTeamIndex += 1
        } else {
            currentTeamIndex = 0
        }
        // Check if there is a winner
        if winningTeam != nil {
            showEndGame = true
        } else {
            drawNextCard()
        }
    }
    // MARK: - Actions
    func markCorrect() {
        teams[currentTeamIndex].score += settings.pointsPerCorrect
        SoundManager.shared.playCorrect()
        drawNextCard()
    }
    func markSkip() {
        teams[currentTeamIndex].score -= settings.skipPenalty
        drawNextCard()
    }
    func markTaboo() {
        teams[currentTeamIndex].score -= settings.tabooPenalty
        showBuzzer = true
        SoundManager.shared.playBuzzer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showBuzzer = false
        }
    }
    // MARK: - Scoring
    var winningTeam: Team? {
        teams.first(where: { $0.score >= settings.pointsToWin })
    }
    func resetGame() {
        for i in teams.indices { teams[i].score = 0 }
        showEndGame = false
        currentTeamIndex = 0
        buildDeck()
        drawNextCard()
    }
}

struct GameSettings: Codable, Equatable {
    var timerSeconds: Int = 60
    var pointsToWin: Int = 10
    var skipPenalty: Int = 1
    var tabooPenalty: Int = 2
    var pointsPerCorrect: Int = 1
    var soundOn: Bool = true
}

