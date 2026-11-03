// SettingsView.swift
// Settings for timer, points, sound, penalties

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @Binding var selection: AppFlow
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.largeTitle.bold())
            Form {
                Section("Timer (seconds)") {
                    Picker("Seconds", selection: $settingsManager.settings.timerSeconds) {
                        Text("30").tag(30)
                        Text("60").tag(60)
                        Text("90").tag(90)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Points to Win") {
                    Stepper(value: $settingsManager.settings.pointsToWin, in: 5...50) {
                        Text("\(settingsManager.settings.pointsToWin) points")
                    }
                }
                Section("Penalties") {
                    Stepper(value: $settingsManager.settings.skipPenalty, in: 0...5) {
                        Text("Skip: -\(settingsManager.settings.skipPenalty)")
                    }
                    Stepper(value: $settingsManager.settings.tabooPenalty, in: 1...10) {
                        Text("Taboo: -\(settingsManager.settings.tabooPenalty)")
                    }
                }
                Section("Sound") {
                    Toggle("Sound On", isOn: $settingsManager.settings.soundOn)
                }
            }
            Button {
                selection = .game
            } label: {
                Text("Start Game")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .accessibilityHint("Start the game")
        }
        .padding(.horizontal, 40)
    }
}
