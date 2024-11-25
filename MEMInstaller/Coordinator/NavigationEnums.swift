//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation
import SwiftUI

enum AttachmentMode {
    case install
    case upload
}

enum Screen: Hashable {
    case home
    case login
    case about
    case attachedDetail(viewModel: HomeViewModel, mode: AttachmentMode)
}

enum Sheet: Identifiable, Hashable {
    case logout
    case activityRepresentable(URL)
    
    var id: String {
        switch self {
        case .logout:
            return "logout"
        case .activityRepresentable(let url):
            return "activityRepresentable-\(url.absoluteString)"
        }
    }
}

extension Screen {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine("home")
        case .login:
            hasher.combine("login")
        case .attachedDetail(let viewModel, let mode):
            hasher.combine(ObjectIdentifier(viewModel))
            hasher.combine(mode)
        case .about:
            hasher.combine("about")
        }
    }
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case (.about, _):
            return true
        default:
            return false
        }
    }
}

extension Sheet {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .logout:
            hasher.combine(self)
        case .activityRepresentable(let url):
            hasher.combine(url)
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        switch (lhs, rhs) {
        case (.logout, .logout):
            return true
        case (.activityRepresentable(let lurl), .activityRepresentable(let rurl)):
            return lurl == rurl
        default:
            return false
        }
    }
}
