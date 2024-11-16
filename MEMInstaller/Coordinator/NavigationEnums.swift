//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation

enum Screen: Identifiable, Hashable {
    case home
    case login
    
    var id: Self { self }
}

enum Sheet: Identifiable, Hashable {
    case settings(viewModel: HomeViewModel)
    case attachedDetail(viewModel: HomeViewModel, property: BundleProperties)
    
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
        case .settings(let viewModel):
            hasher.combine(ObjectIdentifier(viewModel))
        case .attachedDetail(let viewModel, _):
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
