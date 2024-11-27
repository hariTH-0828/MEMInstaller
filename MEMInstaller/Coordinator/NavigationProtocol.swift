//
//  NavigationProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation
import SwiftUI

protocol NavigationProtocol: ObservableObject {
    var navigationPath: NavigationPath { get set }
    
    // Navigation destination
    func push(_ screen: Screen)
    func pop()
    func popToRoot()
}

protocol ModelPresentationProtocol: ObservableObject {
    var sheet: Sheet? { get set }
    var onDismiss: (() -> Void)? { get set }
    
    // Presentation
    func presentSheet(_ sheet: Sheet, onDismiss: (() -> Void)?)
    func dismissSheet()
}

protocol FileImporterProtocol: ObservableObject {
    var shouldShowFileImporter: Bool { get set }
    var fileImportCompletion: ((Result<URL, Error>) -> Void)? { get set }

    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void)
}
