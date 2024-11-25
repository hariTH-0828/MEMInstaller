//
//  EnvironmentKey+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 21/11/24.
//

import SwiftUI

struct UserInterfaceIdiomKey: EnvironmentKey {
    static let defaultValue: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom
}

extension EnvironmentValues {
    var userInterfaceIdiom: UIUserInterfaceIdiom {
        get { self[UserInterfaceIdiomKey.self] }
        set { self[UserInterfaceIdiomKey.self] = newValue }
    }
}
