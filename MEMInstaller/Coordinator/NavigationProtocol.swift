//
//  NavigationProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation
import SwiftUI

protocol Screens: Hashable {}

protocol NavigationProtocol: ObservableObject {
    var navigationPath: NavigationPath { get set }
    func push(_ screen: any Screens)
}
