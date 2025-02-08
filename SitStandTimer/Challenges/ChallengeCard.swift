//
//  ChallengeCard.swift
//  SitStandTimer
//
//  Created by ash on 1/22/25.
//

import SwiftUI
import Luminare

struct ChallengeCard: View {
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        HStack {
            Image(systemName: currentChallenge.symbol)
                .imageScale(.large)
                .padding(.horizontal, 6)
            
            VStack(alignment: .leading) {
                Text(currentChallenge.title)
                    .font(.title2)
                Text(currentChallenge.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: { // Reload
                currentChallenge = challenges.randomElement()!
            }) {
                Image(systemName: "arrow.clockwise")
                    .frame(height: 25)
            }
            .buttonStyle(LuminareCompactButtonStyle())
            .frame(width: 35, height: 40)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.tertiary.opacity(0.2))
        .mask(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(.tertiary.opacity(0.5), lineWidth: 1))
    }
}

struct Challenge: Identifiable {
    let id = UUID()
    let titleKey: String
    let descriptionKey: String // Optional full description
    let amount: String // If no description, simple value instead
    let symbol: String
    
    var title: String {
        NSLocalizedString(titleKey, tableName: "ChallengeTitles", comment: "")
    }

    var description: String {
        if !descriptionKey.isEmpty {
            NSLocalizedString(descriptionKey, tableName: "ChallengeDescriptions", comment: "")
        } else {
            amount
        }
    }
}

let challenges: [Challenge] = [
    Challenge(titleKey: "stretchTitle", descriptionKey: "stretchDescription", amount: "", symbol: "figure.cooldown"),
    Challenge(titleKey: "balanceTitle", descriptionKey: "balanceDescription", amount: "", symbol: "figure"),
    Challenge(titleKey: "squatsTitle", descriptionKey: "", amount: "10", symbol: "figure.cross.training"),
    Challenge(titleKey: "jjTitle", descriptionKey: "", amount: "25", symbol: "figure.arms.open"),
    Challenge(titleKey: "pushupsTitle", descriptionKey: "", amount: "10", symbol: "hands.sparkles"),
    Challenge(titleKey: "plankTitle", descriptionKey: "plankDescription", amount: "", symbol: "hands.sparkles"),
    Challenge(titleKey: "lungesTitle", descriptionKey: "", amount: "10", symbol: "figure.strengthtraining.functional"),
    Challenge(titleKey: "highKneesTitle", descriptionKey: "", amount: "20", symbol: "figure.run"),
    Challenge(titleKey: "mountainClimbersTitle", descriptionKey: "", amount: "20", symbol: "figure.run"),
    Challenge(titleKey: "situpsTitle", descriptionKey: "", amount: "10", symbol: "figure.core.training"),
    Challenge(titleKey: "jumpRopeTitle", descriptionKey: "jumpRopeDescription", amount: "", symbol: "figure.jumprope")
]

#Preview {
    ChallengeCard()
}
