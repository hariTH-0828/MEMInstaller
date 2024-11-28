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

enum AttachmentMode {
    case install
    case upload
}

struct AttachedFileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: HomeViewModel
    let attachmentMode: AttachmentMode
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    appIconView(viewModel.packageHandler.packageDataManager.appIcon)
                    bundleNameWithIdentifierView(bundleName: viewModel.packageHandler.packageDataManager.bundleProperties?.bundleName,
                                                 bundleId: viewModel.packageHandler.packageDataManager.bundleProperties?.bundleIdentifier)
                }
                .padding(.horizontal)
                
                RoundedRectangleOutlineView {
                    ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                        HorizontalKeyValueContainer(key: identifier.rawValue, value: valueFor(identifier))
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
            .navigationTitle(viewModel.packageHandler.packageDataManager.bundleProperties?.bundleName ?? "Loading")
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                loadingOverlay()
            }
        }
    }
    
    @ViewBuilder
    private func loadingOverlay() -> some View {
       if case .uploading(let title) = viewModel.detailViewLoadingState {
           overlayLoaderView(with: title)
       }else if case .loading = viewModel.detailViewLoadingState {
           overlayLoaderView()
       }
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
            HorizontalKeyValueContainer(key: identifier.rawValue, value: valueFor(provision: identifier))
        }else {
            HorizontalKeyValueContainer(key: identifier.rawValue) {
                let isExpired: Bool = validateMobileProvisionExpiration(valueFor(provision: identifier) ?? Date().formatted())
                
                Text(valueFor(provision: identifier) ?? "No Expiration Date")
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
                viewModel.shouldShowUploadView = false
                viewModel.shouldShowDetailView = false
                viewModel.packageHandler.packageDataManager.reset()
            }
            .defaultButtonStyle(width: 180)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func valueFor(_ identifier: PListCellIdentifiers) -> String? {
        let bundleProperties = viewModel.packageHandler.packageDataManager.bundleProperties
        
        switch identifier {
        case .bundleName:
            return bundleProperties?.bundleName
        case .bundleIdentifiers:
            return bundleProperties?.bundleIdentifier
        case .bundleVersionShort:
            return bundleProperties?.bundleVersionShort
        case .bundleVersion:
            return bundleProperties?.bundleVersion
        case .minOSVersion:
            return bundleProperties?.minimumOSVersion
        case .requiredDevice:
            return bundleProperties?.requiredDeviceCompability?.joined(separator: ", ")
        case .supportedPlatform:
            return bundleProperties?.supportedPlatform?.joined(separator: ", ")
        }
    }
    
    private func valueFor(provision identifier: ProvisionCellIdentifiers) -> String? {
        guard let mobileProvision = viewModel.packageHandler.packageDataManager.mobileProvision else { return nil }
        switch identifier {
        case .name:
            return mobileProvision.name
        case .teamIdentifier:
            return mobileProvision.teamIdentifier.joined(separator: ", ")
        case .creationDate:
            return mobileProvision.creationDate.formatted(date: .abbreviated, time: .shortened)
        case .expiredDate:
            return mobileProvision.expirationDate.formatted(date: .abbreviated, time: .shortened)
        case .teamName:
            return mobileProvision.teamName
        case .version:
            return String(mobileProvision.version)
        }
    }
    
    private func installApplication() {
        guard let objectURL = viewModel.packageHandler.packageDataManager.objectURL else {
            ZLogs.shared.error("Error: Installation - objectURL not found")
            viewModel.showToast("Installation failed: URL not found")
            return
        }
        
        let itmsServicesURLString = "itms-services://?action=download-manifest&url="+objectURL

        if let itmsServiceURL = URL(string: itmsServicesURLString) {
            UIApplication.shared.open(itmsServiceURL)
            dismiss()
        }
    }
    
    private func uploadApplication() {
        guard let endpoint = generateUploadBodyParams() else { return }
        
        Task {
            await viewModel.uploadPackage(endpoint: endpoint) {
                dismiss()
                
                viewModel.updateLoadingState(for: .detail, to: .loading)
                await viewModel.fetchFoldersFromBucket()
                viewModel.updateLoadingState(for: .detail, to: .idle)
            }
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userprofile?.email else { return nil }
        guard let bundleName = valueFor(.bundleName) else { return nil }
        
        return "\(userEmail)/\(bundleName)"
    }
    
    private func validateMobileProvisionExpiration(_ date: String) -> Bool {
        let expireDate = date.dateFormat(by: "d MMM yyyy 'at' h:mm a")
        return expireDate < Date()
    }
}

#Preview {
    AttachedFileDetailView(viewModel: .preview, attachmentMode: .install)
}
