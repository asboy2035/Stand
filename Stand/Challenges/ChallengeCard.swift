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
        .overlay(
            RoundedRectangle(cornerRadius: 13)
                .stroke(.tertiary.opacity(0.5), lineWidth: 1)
        )
    }
}

#Preview {
    ChallengeCard()
}
