//
//  AppCoordinatorImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import SwiftUI

class AppCoordinatorImpl: NavigationProtocol, FileImporterProtocol, ModelPresentationProtocol {
    // NavigationProtocol
    @Published var path: NavigationPath = NavigationPath()
    
    // ModelPresentation
    @Published var sheet: Sheet?
    @Published var onDismiss: (() -> Void)?
    
    // FileImporterProtocol
    @Published var shouldShowFileImporter: Bool = false
    var fileImportCompletion: ((Result<URL, Error>) -> Void)?
    
    var fileExportCompletion: ((Bool, Error?) -> Void)?
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet, onDismiss: (() -> Void)? = nil) {
        self.sheet = sheet
        self.onDismiss = onDismiss
    }
    
    func dismissSheet() {
        self.sheet = nil
        self.onDismiss?() // Execute the onDismiss action
        self.onDismiss = nil // Reset to avoid unintended reuse
    }
    
    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void) {
        self.fileImportCompletion = completion
        self.shouldShowFileImporter = true
    }
    
    func presentActivityRepresentable(logFileURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        fileExportCompletion = completion
        presentSheet(.activityRepresentable(logFileURL))
    }
    
    // MARK: Presentation Style Providers
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .home:
            HomeView()
        case .login:
            LoginView()
        case .about:
            AboutView()
        }
    }
    
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        switch sheet {
        case .attachedDetail(viewModel: let viewModel, mode: let attachmentMode):
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: attachmentMode)
                .presentationDragIndicator(.visible)
        case .logout:
            PresentLogoutView()
                .presentationCompactAdaptation(.none)
                .padding(.all, 15)
                .interactiveDismissDisabled()
        case .activityRepresentable(let logFileURL):
            ActivityViewRepresentable(activityItems: [logFileURL]) { completion, error in
                self.fileExportCompletion?(completion, error)
                self.fileExportCompletion = nil // Reset to prevent reuse
            }
            .presentationDetents([.medium, .large])
        }
    }
}
