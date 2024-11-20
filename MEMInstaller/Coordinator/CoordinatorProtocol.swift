//
//  CoordinatorProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import SwiftUI

protocol CoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheet: Sheet? { get set }
    
    // Navigation destination
    func push(_ screen: Screen)
    func pop()
    func popToRoot()
    
    // Presentation
    func presentSheet(_ sheet: Sheet)
}

protocol FileImporterProtocol: ObservableObject {
    var shouldShowFileImporter: Bool { get set }
    var fileImportCompletion: ((Result<URL, Error>) -> Void)? { get set }

    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void)
}
