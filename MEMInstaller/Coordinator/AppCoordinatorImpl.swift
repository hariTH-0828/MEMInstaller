//
//  AppCoordinatorImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation
import SwiftUI

enum Screen: Screens {
    case settings
}


final class AppCoordinatorImpl: NavigationProtocol {
    @Published var navigationPath: NavigationPath = NavigationPath()
    
    func push(_ screen: any Screens) {
        navigationPath.append(screen)
    }
    
    @ViewBuilder
    func build(screen: Screen) -> some View {
        switch screen {
        case .settings:
            AnyView(Text("Settings"))
        }
    }
}
