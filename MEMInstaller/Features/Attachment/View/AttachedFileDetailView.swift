//
//  AttachedFileDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import MEMToast

struct AttachedFileDetailView: View {
    @StateObject var viewModel: AttachedFileDetailViewModel = AttachedFileDetailViewModel()
    @StateObject private var packageExtractionHandler: PackageExtractionHandler = PackageExtractionHandler.shared
    
    let bucketObjectModel: BucketObjectModel
    let attachmentMode: AttachmentMode
    
    init(bucketObjectModel: BucketObjectModel, attachmentMode: AttachmentMode) {
        self.bucketObjectModel = bucketObjectModel
        self.attachmentMode = attachmentMode
    }
    
    var body: some View {
        LoaderView(loadingState: $viewModel.detailViewState) {
            HorizontalLoadingWrapper()
        } loadedContent: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    AppIconView(iconURL: bucketObjectModel.getAppIcon())
                    
                    bundleNameWithIdentifierView(bundleName: packageExtractionHandler.bundleProperties?.bundleName,
                                                 bundleId: packageExtractionHandler.bundleProperties?.bundleIdentifier)
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
        }
        .navigationTitle(PackageExtractionHandler.shared.bundleProperties?.bundleName ?? "Loading")
        .navigationBarTitleDisplayMode(.inline)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isShowingToast)
        .onAppear {
            downloadRequiredFiles()
        }
    }
    
    @ViewBuilder
    private func bundleNameWithIdentifierView(bundleName: String?, bundleId: String?) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            /// App Name
            if let bundleName {
                Text(bundleName)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
            }else {
                rectangleShimmerView(width: 100, corner: 4)
            }
            
            /// App Bundle Identifier
            if let bundleId {
                Text(bundleId)
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }else {
                rectangleShimmerView(width: 200, corner: 4)
            }
        }
    }
    
    @ViewBuilder
    private func iPhoneLayoutBundlePropertyView() -> some View {
        if let bundleProperties = packageExtractionHandler.bundleProperties {
            RoundedRectangleOutlineView {
                ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                    HorizontalKeyValueContainer(key: identifier.rawValue, value: bundleProperties.value(for: identifier))
                }
            }
        }else {
            RoundedRectangleOutlineView {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
        }

        if let mobileProvision = packageExtractionHandler.mobileProvision {
            RoundedRectangleOutlineView {
                ForEach(ProvisionCellIdentifiers.allCases, id: \.self) { identifier in
                    mobileProvisionCellView(provision: mobileProvision, identifier)
                }
            }
        }else {
            RoundedRectangleOutlineView {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
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
    private func mobileProvisionCellView(provision: MobileProvision, _ identifier: ProvisionCellIdentifiers) -> some View {
        if identifier != .expiredDate {
            HorizontalKeyValueContainer(key: identifier.rawValue, value: provision.value(for: identifier))
        }else {
            HorizontalKeyValueContainer(key: identifier.rawValue) {
                let isExpired: Bool = isMobileProvisionValid(provision.value(for: identifier))

                Text(provision.value(for: identifier) ?? "No Expiration Date")
                    .font(.system(.footnote))
                    .foregroundStyle(isExpired ? Color.red : Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    @ViewBuilder
    private func actionButtonView() -> some View {
        HStack(spacing: 30) {
            Button {
                attachmentMode == .install ? viewModel.installApplication(bucketObjectModel.getObjectURL()) : uploadApplication()
            } label: {
                Text(attachmentMode == .install ? "Install" : "Upload")
                    .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.3, 180))
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    private func uploadApplication() {
        guard let endpoint = generateUploadBodyParams() else { return }
        
        Task {
            await viewModel.uploadPackage(endpoint: endpoint) {
                // Change Loading state and refresh the app list
            }
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userProfile?.email else { return nil }
        guard let bundleName = packageExtractionHandler.bundleProperties?.value(for: .bundleName) else { return nil }

        return "\(userEmail)/\(bundleName)"
    }

    @ViewBuilder
    private func rectangleShimmerView(width: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner)
            .fill(StyleManager.colorStyle.systemGray)
            .frame(width: width, height: 15)
            .shimmer(enable: .constant(true))
    }
    
    private func isMobileProvisionValid(_ date: String?) -> Bool {
        guard let expireDate = date?.dateFormat(by: "d MMM yyyy 'at' h:mm a") else { return false }
        return expireDate < Date()
    }
    
    // MARK: - HELPER METHODS
    /// Handles the action when a folder is selected, such as downloading necessary files and updating the UI state.
    /// - Parameter fileURLs: A tuple containing the URLs for the app icon, Info.plist, and object plist.
    private func downloadRequiredFiles() {
        guard let infoPlistURL = bucketObjectModel.getInfoPropertyListURL(), let provisionURL = bucketObjectModel.getMobileProvisionURL()  else { return }
        
        Task {
            async let infoPlistData: Void = viewModel.downloadFile(url: infoPlistURL, type: .infoFile)
            async let provisionData: Void = viewModel.downloadFile(url: provisionURL, type: .provision)
            
            _ = await (infoPlistData, provisionData)
            
            // Handle the UI state change
            viewModel.detailViewState = .idle(.detail(.install))
        }
    }
}

// MARK: PREVIEW
struct AttachedFileDatailView_preview: PreviewProvider {
    static var previews: some View {
        AttachedFileDetailView(bucketObjectModel: BucketObjectModel(), attachmentMode: .install)
    }
}
