// SettingsManager.swift
// Handles persistent game settings using UserDefaults

import Foundation
import Combine

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    private let defaults = UserDefaults.standard
    
    @Published var settings: GameSettings {
        didSet {
            save()
        }
    }
    private init() {
        if let data = defaults.data(forKey: "GameSettings"),
           let loaded = try? JSONDecoder().decode(GameSettings.self, from: data) {
            settings = loaded
        } else {
            settings = GameSettings()
        }
    }
    func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: "GameSettings")
        }
    }
    func reset() {
        settings = GameSettings()
    }
}
