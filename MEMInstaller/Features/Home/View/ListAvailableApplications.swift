//
//  ListAvailableApplications.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct ListAvailableApplications: View {
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    @EnvironmentObject private var viewModel: HomeViewModel
    
    @State var selectedBucketObject: BucketObjectModel? = nil
    
    var body: some View {
        // Creates a list of folders, sorted alphabetically, and generates buttons for each folder
        
        List(viewModel.bucketObjectModels, id: \.self, selection: $selectedBucketObject) { bucketObject in
            // fileURLs
            let fileURLs = viewModel.extractFileURLs(from: bucketObject.contents, folderName: bucketObject.folderName)
            // Package size
            let packageFileSize = getPackageFileSize(bucketObject.contents)
            
            NavigationLink {
                AttachedFileDetailView(attachmentMode: .install)
            } label: {
                appLabel(folderName: bucketObject.folderName, iconURL: fileURLs.iconURL, size: packageFileSize)
            }
        }
        .refreshable { await viewModel.fetchFoldersFromBucket() }
        .toolbar { addPackageButtonView() }
        
//        List(sortedFolderNames(), id: \.self) { folderName in
//            let contents = viewModel.allObjects[folderName]!
//            let fileURLs = viewModel.extractFileURLs(from: contents, folderName: folderName)
//            let packageFileSize = getPackageFileSize(contents)
//            
//            NavigationLink {
//                AttachedFileDetailView(attachmentMode: .install)
//            } label: {
//                appLabel(folderName: folderName, iconURL: fileURLs.iconURL, size: packageFileSize)
//            }
//        }
//        .refreshable { await viewModel.fetchFoldersFromBucket() }
//        .toolbar { addPackageButtonView() }
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
        .frame(height: 35)
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
                        viewModel.packageHandler.initiateAppExtraction(from: filePath)
                        viewModel.shouldShowDetailView = .upload
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
//    /// Returns a sorted list of folder names from the `allObject` dictionary keys.
//    /// Sorting ensures a consistent display order.
//    private func sortedFolderNames() -> [String] {
//        return Array(viewModel.allObjects.keys).sorted()
//    }
    
    /// Calculates the size of a package based on its contents.
    ///
    /// This method filters the provided content list to find the first item with a `.file` key type
    /// and a key containing `.ipa`, then calculates its size.
    ///
    /// - Parameter contents: An array of `ContentModel` objects representing the contents of the package.
    /// - Returns: A `String` representing the calculated size of the package, formatted by `calculatePackageSize`.
    ///
    /// - Note: If no `.ipa` file is found in the contents, the size will be determined as `nil` and handled by `calculatePackageSize`.
    ///
    /// - SeeAlso: `calculatePackageSize(_:)`
    private func getPackageFileSize(_ contents: [ContentModel]) -> String {
        let packageSizeAsBytes = contents.filter({ $0.actualKeyType == .file && $0.key.contains(".ipa") }).first?.size
        return calculatePackageSize(packageSizeAsBytes)
    }
    
    /// Calculates the size of a package in megabytes (MB) and returns a formatted string.
    /// - Parameter size: The size in bytes (Decimal?). If the value is nil, it returns "0 MB".
    /// - Returns: A string representing the size in MB, formatted with two decimal places (default behavior).
    private func calculatePackageSize(_ size: Decimal?) -> String {
        guard let size else { return "0 MB" }
        let sizeInMB = size / 1048576
        return sizeInMB.formattedString() + " MB"
    }
}

#Preview {
    ListAvailableApplications()
        .environmentObject(AppCoordinatorImpl())
}
