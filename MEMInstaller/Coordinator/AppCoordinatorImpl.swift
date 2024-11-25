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
    var shouldShowFileImporter: Bool = false
    var fileImportCompletion: ((Result<URL, Error>) -> Void)?
    var fileExportCompletion: ((Bool, Error?) -> Void)?
    
    // MARK: - Navigation Management
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func pop() {
        guard !path.isEmpty else { return } // Prevent crash if the path is already empty
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - Sheet Management
    func presentSheet(_ sheet: Sheet, onDismiss: (() -> Void)? = nil) {
        self.sheet = sheet
        self.onDismiss = onDismiss
    }
    
    func dismissSheet() {
        let onDismissHandler = onDismiss // Capture the closure to avoid race condition
        self.sheet = nil
        onDismissHandler?()  // Safely execute the captured closure
        self.onDismiss = nil // Reset for future use
    }
    
    func openFileImporter(completion: @escaping (Result<URL, Error>) -> Void) {
        self.fileImportCompletion = completion
        self.shouldShowFileImporter = true
    }
    
    func presentActivityRepresentable(logFileURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        fileExportCompletion = completion
        presentSheet(.activityRepresentable(logFileURL))
        ZLogs.shared.info("Activity representable presented for URL: \(logFileURL)")
    }
    
    // MARK: View Builders
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .home: HomeView()
        case .login: LoginView()
        case .about: AboutView()
        case .attachedDetail(viewModel: let viewModel, mode: let attachmentMode):
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: attachmentMode)
        }
    }
    
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        switch sheet {
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
