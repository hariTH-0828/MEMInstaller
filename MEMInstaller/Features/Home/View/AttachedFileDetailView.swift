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

struct AttachedFileDetailView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    @ObservedObject var viewModel: HomeViewModel
    let attachmentMode: AttachmentMode
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    appIconView(viewModel.packageHandler.appIcon)
                    bundleNameWithIdentifierView()
                }
                .padding(.horizontal)
                
                VStack {
                    ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                        AppDataCellView(key: identifier, value: valueFor(identifier))
                    }
                }
                .padding(.vertical)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                )
                .padding()
                
                Spacer()
                
                uploadBtnView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(viewModel.packageHandler.bundleProperties?.bundleName ?? "Loading")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func bundleNameWithIdentifierView() -> some View {
        VStack(alignment: .leading, spacing: 5) {
            /// App Name
            if let bundleName = viewModel.packageHandler.bundleProperties?.bundleName {
                Text(bundleName)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
            }else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.placeholder)
                    .frame(width: 180, height: 20)
                    .shimmer(enable: .constant(true))
            }
            
            /// App Bundle Identifier
            if let bundleIdentifier = viewModel.packageHandler.bundleProperties?.bundleIdentifier {
                Text(bundleIdentifier)
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.placeholder)
                    .frame(width: 100, height: 15)
                    .shimmer(enable: .constant(true))
            }
        }
    }
    
    @ViewBuilder
    private func appIconView(_ data: Data?) -> some View {
        if let appIcon = data, let uiImage = UIImage(data: appIcon) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(.circle)
        }else {
            Circle()
                .fill(.placeholder)
                .frame(width: 50, height: 50, alignment: .center)
                .shimmer(enable: .constant(true))
        }
    }
    
    @ViewBuilder
    private func AppDataCellView(key: PListCellIdentifiers, value: String?) -> some View {
        HStack {
            Text(key.rawValue)
                .font(.system(.footnote))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Spacer()
            
            if let value {
                Text(value)
                    .font(.system(.footnote))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }else {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.placeholder)
                    .frame(width: 100, height: 15)
                    .shimmer(enable: .constant(true))
            }
        }
        .frame(height: 22)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func uploadBtnView() -> some View {
        Button(action: {
            attachmentMode == .install ? installApplication() : uploadApplication()
        }, label: {
            Text(attachmentMode == .install ? "Install" : "Upload")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 180, height: 50)
                .background(RoundedRectangle(cornerRadius: 14))
        })
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 30)
    }
    
    private func valueFor(_ identifier: PListCellIdentifiers) -> String? {
        switch identifier {
        case .bundleName:
            return viewModel.packageHandler.bundleProperties?.bundleName
        case .bundleIdentifiers:
            return viewModel.packageHandler.bundleProperties?.bundleIdentifier
        case .bundleVersionShort:
            return viewModel.packageHandler.bundleProperties?.bundleVersionShort
        case .bundleVersion:
            return viewModel.packageHandler.bundleProperties?.bundleVersion
        case .minOSVersion:
            return viewModel.packageHandler.bundleProperties?.minimumOSVersion
        case .requiredDevice:
            return viewModel.packageHandler.bundleProperties?.requiredDeviceCompability?.joined(separator: ", ")
        case .supportedPlatform:
            return viewModel.packageHandler.bundleProperties?.supportedPlatform?.joined(separator: ", ")
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
            appCoordinator.sheet = nil
            await viewModel.uploadPackage(endpoint: endpoint)
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userprofile?.email else { return nil }
        guard let bundleName = valueFor(.bundleName) else { return nil }
        
        return "\(userEmail)/\(bundleName)"
    }
}
