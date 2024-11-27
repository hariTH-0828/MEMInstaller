//
//  ListAvailableApplications.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct ListAvailableApplications: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @ObservedObject var viewModel: HomeViewModel
    
    @State private var isPresentDetailView: Bool = false
    @State private var isPresentFileUploadView: Bool = false
    
    var body: some View {
        NavigationStack {
            GeometryReader(content: { geometry in
                // Creates a list of folders, sorted alphabetically, and generates buttons for each folder
                List(sortedFolderNames(), id: \.self) { folderName in
                    
                    if let contents = viewModel.allObjects[folderName] {
                        // Extract relevant file URLs (icon, Info.plist, object plist) for each folder
                        let fileURLs = extractFileURLs(from: contents, folderName: folderName)
                        
                        // Calculate package size
                        let packageSizeAsBytes = contents.filter({ $0.actualKeyType == .file && $0.key.contains(".ipa") }).first?.size
                        let packageSizeAsMB = calculatePackageSize(packageSizeAsBytes)
                        
                        Button(action: {
                            handleAppSelection(with: fileURLs)
                        }, label: {
                            appLabel(folderName: folderName, iconURL: fileURLs.iconURL, size: packageSizeAsMB)
                        })
                    }
                }
                .refreshable { await viewModel.fetchFoldersFromBucket() }
                .toolbar { addPackageButtonView() }
            })
        }
    }
    
    @ViewBuilder
    private func loadingOverlay() -> some View {
       if case .loading = viewModel.sideBarLoadingState {
           overlayLoaderView()
       }
    }
    
    @ViewBuilder
    private func appLabel(folderName: String, iconURL: String?, size: String) -> some View {
        HStack {
            Label(
                title: {
                    Text(folderName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StyleManager.colorStyle.invertBackground)
                },
                icon: {
                    appIconView(iconURL, folderName: folderName)
                }
            )
            
            Spacer()
            
            Text(size)
                .font(.footnote)
                .foregroundStyle(StyleManager.colorStyle.systemGray)
        }
    }
    
    @ViewBuilder
    private func appIconView(_ iconURL: String?, folderName: String) -> some View {
        if let iconURL {
            AsyncImage(url: URL(string: iconURL)!) { image in
                image
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundStyle(StyleManager.colorStyle.systemGray)
            }
        }else {
            Image(uiImage: imageWith(name: folderName)!)
        }
    }
    
    private func addPackageButtonView() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
                appCoordinator.openFileImporter { result in
                    switch result {
                    case .success(let filePath):
                        viewModel.packageHandler?.initiateAppExtraction(from: filePath)
                        appCoordinator.presentSheet(.attachmentDetailView(viewModel))
                    case .failure(let failure):
                        ZLogs.shared.error(failure.localizedDescription)
                        viewModel.showToast(failure.localizedDescription)
                    }
                }
            }, label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(StyleManager.colorStyle.invertBackground)
            })
        }
    }
    
    // MARK: - HELPER METHODS
    /// Returns a sorted list of folder names from the `allObject` dictionary keys.
    /// Sorting ensures a consistent display order.
    private func sortedFolderNames() -> [String] {
        return Array(viewModel.allObjects.keys).sorted()
    }
    
    /// Extracts the URLs for the app icon, Info.plist, and object plist file from a folder's content list.
    /// - Parameters:
    ///   - contents: The list of contents in the folder.
    ///   - folderName: The name of the folder being processed.
    /// - Returns: A tuple containing the app icon URL, Info.plist URL, and object plist URL (all optional).
    private func extractFileURLs(from contents: [ContentModel], folderName: String) -> (iconURL: String?, infoPlistURL: String?, provisionURL: String?, objectURL: String?) {
        let iconURL = contents.first(where: { $0.actualContentType == .png && $0.key.contains("AppIcon60x60@") })?.url
        let infoPlistURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("Info.plist") })?.url
        let provisionURL = contents.first(where: { $0.actualContentType == .mobileProvision && $0.key.contains("embedded.mobileprovision") })?.url
        let objectURL = contents.first(where: { $0.actualContentType == .document && $0.key.contains("\(folderName).plist") })?.url
        return (iconURL, infoPlistURL, provisionURL, objectURL)
    }
    
    /// Calculates the size of a package in megabytes (MB) and returns a formatted string.
    /// - Parameter size: The size in bytes (Decimal?). If the value is nil, it returns "0 MB".
    /// - Returns: A string representing the size in MB, formatted with two decimal places (default behavior).
    private func calculatePackageSize(_ size: Decimal?) -> String {
        guard let size else { return "0 MB" }
        let sizeInMB = size / 1048576
        return sizeInMB.formattedString() + " MB"
    }

    /// Handles the action when a folder is selected, such as downloading necessary files and updating the UI state.
    /// - Parameter fileURLs: A tuple containing the URLs for the app icon, Info.plist, and object plist.
    private func handleAppSelection(with fileURLs: (iconURL: String?, infoPlistURL: String?, provisionURL: String?, objectURL: String?)) {
        guard let iconURL = fileURLs.iconURL, let infoPlistURL = fileURLs.infoPlistURL, let provisionURL = fileURLs.provisionURL  else { return }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        viewModel.downloadInfoFile(url: infoPlistURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        viewModel.downloadProvisionFile(url: provisionURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        viewModel.downloadAppIconFile(url: iconURL) {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            viewModel.packageHandler?.objectURL = fileURLs.objectURL
            viewModel.shouldShowDetailView = true
        }
    }
}

#Preview {
    ListAvailableApplications(viewModel: .preview)
        .environmentObject(AppCoordinatorImpl())
}
