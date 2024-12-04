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
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: HomeViewModel
    let attachmentMode: AttachmentMode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                appIconView(viewModel.packageHandler.fileTypeDataMap[.icon])
                bundleNameWithIdentifierView(bundleName: viewModel.packageHandler.bundleProperties?.bundleName,
                                             bundleId: viewModel.packageHandler.bundleProperties?.bundleIdentifier!)
            }
            .padding(.horizontal)
            
            if Device.isIpad {
                iPadLayoutBundlePropertyView()
            }else {
                iPhoneLayoutBundlePropertyView()
            }
            
            Spacer()
            
            actionButtonView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(viewModel.packageHandler.bundleProperties?.bundleName ?? "Loading")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func iPhoneLayoutBundlePropertyView() -> some View {
        RoundedRectangleOutlineView {
            ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                HorizontalKeyValueContainer(key: identifier.rawValue, value: viewModel.packageHandler.bundleProperties?.value(for: identifier))
            }
        }
        
        RoundedRectangleOutlineView {
            ForEach(ProvisionCellIdentifiers.allCases, id: \.self) { identifier in
                mobileProvisionCellView(identifier)
            }
        }
    }
    
    @ViewBuilder
    private func iPadLayoutBundlePropertyView() -> some View {
        HStack(spacing: 0) {
            iPhoneLayoutBundlePropertyView()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    private func bundleNameWithIdentifierView(bundleName: String?, bundleId: String?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
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
            HorizontalKeyValueContainer(key: identifier.rawValue, value: viewModel.packageHandler.mobileProvision?.value(for: identifier))
        }else {
            HorizontalKeyValueContainer(key: identifier.rawValue) {
                let isExpired: Bool = isMobileProvisionValid(viewModel.packageHandler.mobileProvision?.value(for: identifier))
                
                Text(viewModel.packageHandler.mobileProvision?.value(for: identifier) ?? "No Expiration Date")
                    .font(.system(.footnote))
                    .foregroundStyle(isExpired ? Color.red : Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    @ViewBuilder
    private func actionButtonView() -> some View {
        HStack(spacing: 50) {
            Button {
                attachmentMode == .install ? installApplication() : uploadApplication()
            } label: {
                Text(attachmentMode == .install ? "Install" : "Upload")
                    .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.25, 180))
            }
            .padding(.bottom, 30)
            
            Button {
                viewModel.updateLoadingState(for: .detail, to: .idle(.available))
            } label: {
                Text("Cancel")
                    .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.25, 180))
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func installApplication() {
        guard let objectURL = PackageExtractionHandler.shared.packageURLs?.infoPropertyListURL else {
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
                viewModel.fetchFolders()
                viewModel.updateLoadingState(for: .detail, to: .idle())
            }
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userProfile?.email else { return nil }
        guard let bundleName = viewModel.packageHandler.bundleProperties?.value(for: .bundleName) else { return nil }
        
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
