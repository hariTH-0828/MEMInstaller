//
//  AttachedFileDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import MEMToast

struct AttachedFileDetailView: View {
    @ObservedObject var viewModel: AttachedFileDetailViewModel
    @StateObject private var packageExtractionHandler: PackageExtractionHandler = PackageExtractionHandler.shared
    
    private let bucketObjectModel: BucketObjectModel
    private let attachmentMode: AttachmentMode
    
    init(viewModel: AttachedFileDetailViewModel,
         bucketObjectModel: BucketObjectModel,
         attachmentMode: AttachmentMode)
    {
        self.viewModel = viewModel
        self.bucketObjectModel = bucketObjectModel
        self.attachmentMode = attachmentMode
    }
    
    var body: some View {
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
        .navigationTitle(packageExtractionHandler.bundleProperties?.bundleName ?? "Loading")
        .navigationBarTitleDisplayMode(.inline)
        .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isShowingToast)
    }
   
    @ViewBuilder
    private func bundleNameWithIdentifierView(bundleName: String?, bundleId: String?) -> some View {
        if viewModel.detailViewState == .loading {
            VStack(alignment: .leading, spacing: 5) {
                rectangleShimmerView(width: 100, corner: 4)
                rectangleShimmerView(width: 200, corner: 4)
            }
            .task {
                guard let infoPlistURL = bucketObjectModel.getInfoPropertyListURL() else { return }
                await viewModel.downloadFile(url: infoPlistURL, type: .infoFile)
                viewModel.detailViewState = .loaded
            }
        }else if viewModel.detailViewState == .loaded {
            VStack(alignment: .leading, spacing: 5) {
                Text(bundleName ?? "No Bundle name available")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                
                Text(bundleId ?? "Bundle Id not available")
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }
        }
    }
    
    @ViewBuilder
    private func iPhoneLayoutBundlePropertyView() -> some View {
        if viewModel.detailViewState == .loading {
            ForEach(0..<2) { _ in
                RoundedRectangleOutlineView {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
            }
            .task {
                guard let provisionURL = bucketObjectModel.getMobileProvisionURL() else { return }
                await viewModel.downloadFile(url: provisionURL, type: .provision)
                viewModel.detailViewState = .loaded
            }
        }else if viewModel.detailViewState == .loaded {
            if let bundleProperties = packageExtractionHandler.bundleProperties {
                RoundedRectangleOutlineView {
                    ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                        HorizontalKeyValueContainer(key: identifier.rawValue, value: bundleProperties.value(for: identifier))
                    }
                }
            }
            
            if let mobileProvision = packageExtractionHandler.mobileProvision {
                RoundedRectangleOutlineView {
                    ForEach(ProvisionCellIdentifiers.allCases, id: \.self) { identifier in
                        mobileProvisionCellView(provision: mobileProvision, identifier)
                    }
                }
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
    
    @ViewBuilder
    private func rectangleShimmerView(width: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner)
            .fill(StyleManager.colorStyle.systemGray)
            .frame(width: width, height: 15)
            .shimmer(enable: .constant(true))
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
    
    private func isMobileProvisionValid(_ date: String?) -> Bool {
        guard let expireDate = date?.dateFormat(by: "d MMM yyyy 'at' h:mm a") else { return false }
        return expireDate < Date()
    }
}

// MARK: PREVIEW
struct AttachedFileDatailView_preview: PreviewProvider {
    static var previews: some View {
        AttachedFileDetailView(viewModel: .preview, bucketObjectModel: BucketObjectModel(), attachmentMode: .install)
    }
}
