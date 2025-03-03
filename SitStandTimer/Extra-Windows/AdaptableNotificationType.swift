//
//  AdaptableNotificationType.swift
//  SitStandTimer
//
//  Created by ash on 3/3/25.
//

import SwiftUI
import DynamicNotchKit

enum NotificationType: String, CaseIterable {
    case banner, hud
    
    var localizedString: String {
        switch self {
        case .banner:
            return NSLocalizedString("Banner", comment: "Banner notification type")
        case .hud:
            return NSLocalizedString("HUD", comment: "HUD notification type")
        }
    }
}

// Show either a HUD or DynamicNotchInfo notification
struct AdaptableNotificationType {
    var style: NotificationType
    let title: String
    let description: String
    let image: String
    let iconColor: Color
    let textColor: Color
    let dynamicNotchIsFloating: Bool
    
    init(
        style: NotificationType,
        title: String,
        description: String,
        image: String,
        iconColor: Color,
        textColor: Color = .primary,
        dynamicNotchIsFloating: Bool = true
    ) {
        self.style = style
        self.title = title
        self.description = description
        self.image = image
        self.iconColor = iconColor
        self.textColor = textColor
        self.dynamicNotchIsFloating = dynamicNotchIsFloating
    }
    
    private var notchNoti: DynamicNotchInfo<Image>? = nil
    
    mutating func show(for duration: Int = 0) {
        switch style {
        case .banner:
            let notch = DynamicNotchInfo(
                icon: Image(systemName: image),
                title: title,
                description: description,
                iconColor: iconColor,
                textColor: textColor,
                style: dynamicNotchIsFloating ? .floating : .notch
            )
            notchNoti = notch
            if duration != 0 {
                notch.show(for: Double(duration))
            } else {
                notch.show()
            }
        case .hud:
            let hudNoti = HUD(
                title: title,
                description: description,
                systemImage: image,
                imageColor: iconColor
            )
            if duration != 0 {
                hudNoti.show(for: duration)
            } else {
                hudNoti.show()
            }
        }
    }
    
    func hide() {
        switch style {
        case .banner:
            notchNoti?.hide() // Hide the stored notification
        case .hud:
            HUDController.shared.hide()
        }
    }
}
