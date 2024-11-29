//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation
import SwiftUI

enum Screen: Hashable, Identifiable, CaseIterable {
    case tabView
    case login
    case home
    case settings
    case about
    
    var id: Screen { self }
}

enum Sheet: Identifiable, Hashable {
    case settings
    case logout
    case activityRepresentable(URL)
    
    var id: Self { self }
}

enum Pop: Identifiable, Hashable {
    case logout
    
    var id: Self { self }
}
