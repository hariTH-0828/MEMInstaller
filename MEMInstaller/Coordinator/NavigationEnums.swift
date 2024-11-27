//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation

enum Screen: Hashable {
    case tabView
    case login
    case home
    case settings
    
//    static func == (lhs: Screen, rhs: Screen) -> Bool {
//        switch (lhs, rhs) {
//        case (.tabView, .tabView),
//             (.login, .login),
//             (.home, .home):
//            return true
//        case (.settings(let lhsViewModel), .settings(let rhsViewModel)):
//            return ObjectIdentifier(lhsViewModel) == ObjectIdentifier(rhsViewModel)
//        default:
//            return false
//        }
//    }
//    
//    func hash(into hasher: inout Hasher) {
//        switch self {
//        case .tabView:
//            hasher.combine("tabView")
//        case .login:
//            hasher.combine("login")
//        case .home:
//            hasher.combine("home")
//        case .settings(let viewModel):
//            hasher.combine(ObjectIdentifier(viewModel))
//        }
//    }
}

enum Sheet: Identifiable, Hashable {
    case logout
    case activityRepresentable(URL)
    case attachmentDetailView(HomeViewModel)
    
    var id: Self { self }
}

extension Sheet {
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        switch (lhs, rhs) {
        case(.logout, .logout):
            return true
        case(.activityRepresentable(let lhsURL), .activityRepresentable(let rhsURL)):
            return lhsURL == rhsURL
        case(.attachmentDetailView(let lhsHomeViewModel), .attachmentDetailView(let rhsHomeViewModel)):
            return ObjectIdentifier(lhsHomeViewModel) == ObjectIdentifier(rhsHomeViewModel)
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .logout:
            hasher.combine(id)
        case .activityRepresentable(let uRL):
            hasher.combine(id)
        case .attachmentDetailView(let homeViewModel):
            hasher.combine(ObjectIdentifier(homeViewModel))
        }
    }
}
