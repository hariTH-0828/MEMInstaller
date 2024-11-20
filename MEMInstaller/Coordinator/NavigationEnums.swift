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

enum Screen: Identifiable, Hashable {
    case home
    case login
    
    var id: Self { self }
}

enum Sheet: Identifiable, Hashable {
    case attachedDetail(viewModel: HomeViewModel, mode: AttachmentMode)
    case logout
    
    var id: Self { self }
}

extension Screen {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(self)
        case .login:
            hasher.combine(self)
        }
    }
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Sheet {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .attachedDetail(let viewModel, let mode):
            hasher.combine(ObjectIdentifier(viewModel))
            hasher.combine(mode)
        case .logout:
            hasher.combine(true)
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
