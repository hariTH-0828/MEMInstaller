//
//  AppCoordinatorImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

final class AppCoordinatorImpl: NavigationProtocol, FileImporterProtocol, ModelPresentationProtocol {
    @Published var navigationPath: NavigationPath = NavigationPath()
    
    // ModelPresentation
    @Published var sheet: Sheet?
    @Published var popView: Pop?
    var onDismiss: (() -> Void)?
    var isPopover: Bool { Device.isIpad }
    
    // FileImporterProtocol
    var fileImportCompletion: ((URL) -> Void)?
    var fileExportCompletion: ((Bool, Error?) -> Void)?

    func push(_ screen: Screen) {
        navigationPath.append(screen)
    }
    
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    // MARK: - Sheet Management
    func presentSheet(_ sheet: Sheet, onDismiss: (() -> Void)? = nil) {
        self.sheet = sheet
        self.onDismiss = onDismiss
    }
    
    func pop(_ pop: Pop) {
        self.popView = pop
    }
    
    func dismissSheet() {
        let onDismissHandler = onDismiss // Capture the closure to avoid race condition
        self.sheet = nil
        self.popView = nil
        onDismissHandler?()  // Safely execute the captured closure
        self.onDismiss = nil // Reset for future use
    }
    
    @ViewBuilder
    func build(forScreen screen: Screen) -> some View {
        switch screen {
        case .settings:
            SettingsView()
        case .about:
            AboutView()
        case .privacy:
            SettingPrivacyView()
        }
    }
    
    @ViewBuilder
    func build(forSheet sheet: Sheet) -> some View {
        switch sheet {
        case .logout:
            PresentLogoutView()
        case .activityRepresentable(let logFileURL):
            ActivityViewRepresentable(activityItems: [logFileURL]) { completion, error in
                self.fileExportCompletion?(completion, error)
                self.fileExportCompletion = nil // Reset to prevent reuse
            }
            .ignoresSafeArea()
            .presentationDetents([.medium, .large])
        case .AttachedFileDetail(let viewModel, let packageExtractionModel, let attachedMode):
            AttachedFileDetailView(viewModel: viewModel,
                                   packageModel: packageExtractionModel,
                                   attachmentMode: attachedMode).interactiveDismissDisabled(true)
        case .QRCodeProvider(let qrprovider):
            if #available(iOS 17.0, *) {
                QRCodeProviderView(qrProvider: qrprovider)
                    .presentationDetents([.medium])
                    .presentationBackground(StyleManager.colorStyle.qrcodeBackgroundStyle)
                    .presentationDragIndicator(.visible)
            }else {
                QRCodeProviderView(qrProvider: qrprovider)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        case .fileImporter(let lastDirectory, let filePicked):
            FileImporterView(allowedContentTypes: [.ipa],
                             startingDirectoryURL: lastDirectory,
                             onFilePicked: filePicked)
        }
    }
    
    @ViewBuilder
    func build(forPop pop: Pop) -> some View {
        switch pop {
        case .logout:
            PresentLogoutView()
                .padding()
        case .QRCodeProvider(let qrprovider):
            QRCodeProviderView(qrProvider: qrprovider)
        }
    }
}
