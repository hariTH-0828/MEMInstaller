//
//  Notification+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 25/11/24.
//

import Foundation

public extension Notification.Name {
    static let loginSuccess = Notification.Name("kNotificationLogin")
    static let performLogout = Notification.Name("kNotificationLogout")
    static let profileButtonTapped = Notification.Name("kNotificationProfileButtonTapped")
}
