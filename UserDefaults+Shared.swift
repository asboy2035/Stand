//
//  UserDefaults.swift
//  SitStandTimer
//
//  Created by ash on 1/20/25.
//

import Foundation

extension UserDefaults {
    static let appGroup = "group.ash.Stand" // Update this to match your app group ID
    
    static var shared: UserDefaults {
        // Try to get shared defaults
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            // Fall back to standard defaults if shared fails
            print("⚠️ Could not access shared UserDefaults, falling back to standard defaults")
            return UserDefaults.standard
        }
        return defaults
    }
}
