//
//  CoordinatorProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import SwiftUI

protocol NavigationProtocol: ObservableObject {
    var path: NavigationPath { get set }
    
    // Navigation destination
    func push(_ screen: Screen)
    func pop()
    func popToRoot()
}

protocol FileImporterProtocol: ObservableObject {
    var shouldShowFileImporter: Bool { get set }
    var fileImportCompletion: ((Result<URL, Error>) -> Void)? { get set }

    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void)
}

protocol ModelPresentationProtocol: ObservableObject {
    var sheet: Sheet? { get set }
    var onDismiss: (() -> Void)? { get set }
    
    // Presentation
    func presentSheet(_ sheet: Sheet, onDismiss: (() -> Void)?)
    func dismissSheet()
}
