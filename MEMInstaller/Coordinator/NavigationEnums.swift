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
    case about
    
    var id: Self { self }
}

enum Sheet: Identifiable, Hashable {
    case attachedDetail(viewModel: HomeViewModel, mode: AttachmentMode)
    case logout
    case activityRepresentable(URL)
    
    var id: Self { self }
}

extension Sheet {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .attachedDetail(let viewModel, let mode):
            hasher.combine(ObjectIdentifier(viewModel))
            hasher.combine(mode)
        case .logout:
            hasher.combine(self)
        case .activityRepresentable(let url):
            hasher.combine(url)
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
