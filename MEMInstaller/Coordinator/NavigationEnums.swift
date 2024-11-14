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
    
    var id: Self { self }
}

extension Sheet {
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings(let viewModel):
            hasher.combine("Settings")
            hasher.combine(ObjectIdentifier(viewModel))
        }
    }
    
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        switch (lhs, rhs) {
        case(.settings, .settings):
            return true
        }
    }
    
}
