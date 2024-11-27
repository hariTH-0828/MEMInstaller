//
//  AppCoordinatorImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation
import SwiftUI

final class AppCoordinatorImpl: NavigationProtocol, FileImporterProtocol, ModelPresentationProtocol {
    @Published var navigationPath: NavigationPath = NavigationPath()
    
    // ModelPresentation
    var sheet: Sheet?
    var onDismiss: (() -> Void)?
    
    // FileImporterProtocol
    @Published var shouldShowFileImporter: Bool = false
    var fileImportCompletion: ((Result<URL, any Error>) -> Void)?
    var fileExportCompletion: ((Bool, Error?) -> Void)?
    
    @inlinable
    @inline(__always)
    func push(_ screen: Screen) {
        navigationPath.append(screen)
    }
    
    @inlinable
    @inline(__always)
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    @inlinable
    @inline(__always)
    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
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
    
    func openFileImporter(completion: @escaping (Result<URL, any Error>) -> Void) {
        self.fileImportCompletion = completion
        self.shouldShowFileImporter = true
    }
    
    
    @ViewBuilder
    func build(forScreen screen: Screen) -> some View {
        switch screen {
        case .tabView:
            TabViewController()
        case .settings:
            SideMenuView()
        case .login:
            LoginView()
        case .home:
            HomeView()
        }
    }
    
    @ViewBuilder
    func build(forSheet sheet: Sheet) -> some View {
        switch sheet {
        case .logout:
            PresentLogoutView(isPresentLogOut: .constant(false))
        case .activityRepresentable(let logFileURL):
            ActivityViewRepresentable(activityItems: [logFileURL]) { completion, error in
                self.fileExportCompletion?(completion, error)
                self.fileExportCompletion = nil // Reset to prevent reuse
            }
            .presentationDetents([.medium, .large])
        case .attachmentDetailView(let viewModel):
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: .upload)
        }
    }
}
