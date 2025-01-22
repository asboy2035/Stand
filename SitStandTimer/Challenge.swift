//
//  Challenge.swift
//  SitStandTimer
//
//  Created by ash on 1/21/25.
//


import Foundation

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
