//
//  AppCoordinatorImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import SwiftUI

class AppCoordinatorImpl: CoordinatorProtocol, FileImporterProtocol {
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var shouldShowFileImporter: Bool = false
    
    var fileImportCompletion: ((Result<URL, Error>) -> Void)?
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void) {
        self.fileImportCompletion = completion
        self.shouldShowFileImporter = true
    }
    
    // MARK: Presentation Style Providers
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .home:
            HomeView()
        case .login:
            LoginView()
        }
    }
    
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .settings(viewModel: let viewModel):
            SettingView(viewModel: viewModel)
        case .attachedDetail(viewModel: let viewModel, property: let property):
            AttachedFileDetailView(viewModel: viewModel, bundleProperty: property)
        }
    }
}
