// SoundManager.swift
// Manages sound effects and haptics for Taboo Game

import AVFoundation
import SwiftUI
import CoreHaptics

class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    private var hapticEngine: CHHapticEngine?
    
    private init() {
        if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
            hapticEngine = try? CHHapticEngine()
            try? hapticEngine?.start()
        }
    }
    
    func playCorrect() {
        play(sound: "correct_chime")
        vibrate(strong: false)
    }
    func playBuzzer() {
        play(sound: "buzzer")
        vibrate(strong: true)
    }
    func playTick() {
        play(sound: "tick", volume: 0.3)
    }
    func playEndFanfare() {
        play(sound: "fanfare")
        vibrate(strong: true)
    }
    private func play(sound: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: sound, withExtension: "mp3") else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.volume = volume
        player?.play()
    }
    private func vibrate(strong: Bool) {
        #if !targetEnvironment(simulator)
        guard let hapticEngine else { return }
        let intensity = strong ? 1.0 : 0.5
        let sharpness = strong ? 1.0 : 0.5
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity)),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(sharpness))
        ], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {}
        #endif
    }
}
// Note: Add sound files named buzzer.mp3, correct_chime.mp3, tick.mp3, fanfare.mp3 to your asset catalog.
