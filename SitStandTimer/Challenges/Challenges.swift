//
//  Challenges.swift
//  SitStandTimer
//
//  Created by ash on 2/17/25.
//

import Foundation

struct Challenge: Identifiable {
    let id = UUID()
    let titleKey: String // Localized title key (ChallengeTitles.xcstrings)
    let descriptionKey: String // Optional full description (CHallengeDescriptions.xcstrings)
    let amount: String // If no description, simple value instead
    let symbol: String // SF symbol
    
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
    Challenge(
        titleKey: "stretchTitle",
        descriptionKey: "stretchDescription",
        amount: "",
        symbol: "figure.cooldown"
    ),
    Challenge(
        titleKey: "balanceTitle",
        descriptionKey: "balanceDescription",
        amount: "",
        symbol: "figure"
    ),
    Challenge(
        titleKey: "squatsTitle",
        descriptionKey: "",
        amount: "10",
        symbol: "figure.cross.training"
    ),
    Challenge(
        titleKey: "jjTitle",
        descriptionKey: "",
        amount: "25",
        symbol: "figure.arms.open"
    ),
    Challenge(
        titleKey: "pushupsTitle",
        descriptionKey: "",
        amount: "10",
        symbol: "hands.sparkles"
    ),
    Challenge(
        titleKey: "plankTitle",
        descriptionKey: "plankDescription",
        amount: "",
        symbol: "hands.sparkles"
    ),
    Challenge(
        titleKey: "lungesTitle",
        descriptionKey: "",
        amount: "10",
        symbol: "figure.strengthtraining.functional"
    ),
    Challenge(
        titleKey: "highKneesTitle",
        descriptionKey: "",
        amount: "20",
        symbol: "figure.run"
    ),
    Challenge(
        titleKey: "mountainClimbersTitle",
        descriptionKey: "",
        amount: "20",
        symbol: "figure.run"
    ),
    Challenge(
        titleKey: "situpsTitle",
        descriptionKey: "",
        amount: "10",
        symbol: "figure.core.training"
    ),
    Challenge(
        titleKey: "jumpRopeTitle",
        descriptionKey: "jumpRopeDescription",
        amount: "",
        symbol: "figure.jumprope"
    )
]
