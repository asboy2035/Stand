//
//  ChallengeCard.swift
//  SitStandTimer
//
//  Created by ash on 1/22/25.
//

import SwiftUI

struct ChallengeCard: View {
    @State private var currentChallenge: Challenge = challenges.randomElement()!
    
    var body: some View {
        HStack() {
            Image(systemName: currentChallenge.symbol)
                .imageScale(.large)
                .padding(.horizontal, 6)
            
            VStack(alignment: .leading) {
                Text(currentChallenge.title)
                    .font(.title2)
                Text(currentChallenge.description)
                    .font(.body)
            }
            
            Button(action: {
                currentChallenge = challenges.randomElement()!
            }) {
                Image(systemName: "arrow.clockwise")
                    .frame(height: 25)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.primary.opacity(0.1))
        .mask(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color.primary.opacity(0.2), lineWidth: 1))
    }
}

struct Challenge: Identifiable {
    let id = UUID()
    let titleKey: String
    let descriptionKey: String
    let symbol: String
    
    var title: String {
        NSLocalizedString(titleKey, tableName: "ChallengeTitles", comment: "")
    }

    var description: String {
        NSLocalizedString(descriptionKey, tableName: "ChallengeDescriptions", comment: "")
    }
}

let challenges: [Challenge] = [
    Challenge(titleKey: "stretchTitle", descriptionKey: "stretchDescription", symbol: "figure.walk"),
    Challenge(titleKey: "balanceTitle", descriptionKey: "balanceDescription", symbol: "person.circle"),
    Challenge(titleKey: "squatsTitle", descriptionKey: "squatsDescription", symbol: "figure.stand"),
    Challenge(titleKey: "jjTitle", descriptionKey: "jjDescription", symbol: "figure.run"),
    Challenge(titleKey: "pushupsTitle", descriptionKey: "pushupsDescription", symbol: "hands.sparkles")
]
