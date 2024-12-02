//
//  AttachedFileDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

enum PListCellIdentifiers: String, CaseIterable {
    case bundleName = "Bundle name"
    case bundleIdentifiers = "Bundle identifiers"
    case bundleVersionShort = "Bundle version (short)"
    case bundleVersion = "Bundle version"
    case minOSVersion = "Minimum OS version"
    case requiredDevice = "Required device compability"
    case supportedPlatform = "Suppported platform"
}

enum ProvisionCellIdentifiers: String, CaseIterable {
    case name = "Name"
    case teamIdentifier = "Team identifier"
    case creationDate = "Creation date"
    case expiredDate = "Expired date"
    case teamName = "Team name"
    case version = "Version"
}

enum AttachmentMode: Hashable {
    case install
    case upload
}

struct AttachedFileDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    let attachmentMode: AttachmentMode
    
    var body: some View {
        LoaderView(loadingState: $viewModel.detailViewLoadingState) {
            ProgressView()
                .progressViewStyle(.horizontalCircular)
        } loadedContent: {
            VStack(alignment: .leading) {
                HStack {
                    appIconView(viewModel.packageHandler.fileTypeDataMap[.icon])
                    bundleNameWithIdentifierView(bundleName: viewModel.packageHandler.bundleProperties?.bundleName,
                                                 bundleId: viewModel.packageHandler.bundleProperties?.bundleIdentifier)
                }
                .padding(.horizontal)
                
                RoundedRectangleOutlineView {
                    ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                        HorizontalKeyValueContainer(key: identifier.rawValue, value: viewModel.valueFor(identifier))
                    }
                }
                
                RoundedRectangleOutlineView {
                    ForEach(ProvisionCellIdentifiers.allCases, id: \.self) { identifier in
                        mobileProvisionCellView(identifier)
                    }
                }
                Spacer()
                actionButtonView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationTitle(viewModel.packageHandler.bundleProperties?.bundleName ?? "Loading")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func bundleNameWithIdentifierView(bundleName: String?, bundleId: String?) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            /// App Name
            Text(bundleName ?? "")
                .font(.title2)
                .bold()
                .lineLimit(1)
            
            /// App Bundle Identifier
            Text(bundleId ?? "")
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func appIconView(_ data: Data?) -> some View {
        var uiImage: UIImage {
            if let appIcon = data, let uiImage = UIImage(data: appIcon) {
                return uiImage
            }else {
                return imageWith(name: "unknown")!
            }
        }
        
        Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: 50, height: 50)
            .clipShape(.circle)
    }
    
    @ViewBuilder
    private func mobileProvisionCellView(_ identifier: ProvisionCellIdentifiers) -> some View {
        if identifier != .expiredDate {
            HorizontalKeyValueContainer(key: identifier.rawValue, value: viewModel.valueFor(provision: identifier))
        }else {
            HorizontalKeyValueContainer(key: identifier.rawValue) {
                let isExpired: Bool = isMobileProvisionValid(viewModel.valueFor(provision: identifier))
                
                Text(viewModel.valueFor(provision: identifier) ?? "No Expiration Date")
                    .font(.system(.footnote))
                    .foregroundStyle(isExpired ? Color.red : Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    @ViewBuilder
    private func actionButtonView() -> some View {
        HStack(spacing: 50) {
            Button(attachmentMode == .install ? "Install" : "Upload") {
                attachmentMode == .install ? installApplication() : uploadApplication()
            }
            .defaultButtonStyle(width: 180)
            .padding(.bottom, 30)
            
            Button("Cancel") {
                viewModel.detailViewLoadingState = .idle()
            }
            .defaultButtonStyle(width: 180)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - HELPER METHODS
    /// Handles the action when a folder is selected, such as downloading necessary files and updating the UI state.
    /// - Parameter fileURLs: A tuple containing the URLs for the app icon, Info.plist, and object plist.
    private func handleAppSelection(with fileURLs: (iconURL: String?, infoPlistURL: String?, provisionURL: String?, objectURL: String?)) {
        guard let iconURL = fileURLs.iconURL, let infoPlistURL = fileURLs.infoPlistURL, let provisionURL = fileURLs.provisionURL  else { return }
        
//        isPresentDetailView.toggle()
        viewModel.updateLoadingState(for: .detail, to: .loading)
        
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
            viewModel.packageHandler.objectURL = fileURLs.objectURL
            viewModel.detailViewLoadingState = .idle(.detail(.install))
        }
    }
    
    private func installApplication() {
        guard let objectURL = viewModel.packageHandler.objectURL else {
            ZLogs.shared.error("Error: Installation - objectURL not found")
            viewModel.showToast("Installation failed: URL not found")
            return
        }
        
        let itmsServicesURLString = "itms-services://?action=download-manifest&url="+objectURL

        if let itmsServiceURL = URL(string: itmsServicesURLString) {
            UIApplication.shared.open(itmsServiceURL)
        }
    }
    
    private func uploadApplication() {
        guard let endpoint = generateUploadBodyParams() else { return }
        
        Task {
            await viewModel.uploadPackage(endpoint: endpoint) {
                viewModel.updateLoadingState(for: .detail, to: .loading)
                await viewModel.fetchFoldersFromBucket()
                viewModel.updateLoadingState(for: .detail, to: .idle())
            }
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userprofile?.email else { return nil }
        guard let bundleName = viewModel.valueFor(.bundleName) else { return nil }
        
        return "\(userEmail)/\(bundleName)"
    }
    
    private func isMobileProvisionValid(_ date: String?) -> Bool {
        guard let expireDate = date?.dateFormat(by: "d MMM yyyy 'at' h:mm a") else { return false }
        return expireDate < Date()
    }
}

#Preview {
    AttachedFileDetailView(viewModel: .preview, attachmentMode: .install)
        .environmentObject(HomeViewModel.preview)
}
