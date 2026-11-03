// CardModel.swift
// Taboo
// Defines the data structure for a Taboo game card, with age group categorization.

import Foundation

/// Represents a single Taboo card.
struct TabooCard: Codable, Identifiable, Equatable {
    enum AgeGroup: String, Codable, CaseIterable, Hashable {
        case kids = "Kids"      // 8-12
        case teens = "Teens"    // 12-18
        case adults = "Adults"  // 18+
    }
    
    var id: UUID = UUID()
    let word: String
    let tabooWords: [String] // Always 5 words
    let ageGroup: AgeGroup
    let isParentsCard: Bool // true if for parents in Kids vs Parents mode
    
    /// Convenience for JSON decoding without id.
    enum CodingKeys: String, CodingKey {
        case word, tabooWords, ageGroup, isParentsCard
    }
    
    init(word: String, tabooWords: [String], ageGroup: AgeGroup, isParentsCard: Bool = false) {
        self.word = word
        self.tabooWords = tabooWords
        self.ageGroup = ageGroup
        self.isParentsCard = isParentsCard
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decode(String.self, forKey: .word)
        tabooWords = try container.decode([String].self, forKey: .tabooWords)
        ageGroup = try container.decode(AgeGroup.self, forKey: .ageGroup)
        isParentsCard = try container.decode(Bool.self, forKey: .isParentsCard)
        // id is auto-generated
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(word, forKey: .word)
        try container.encode(tabooWords, forKey: .tabooWords)
        try container.encode(ageGroup, forKey: .ageGroup)
        try container.encode(isParentsCard, forKey: .isParentsCard)
    }
}

