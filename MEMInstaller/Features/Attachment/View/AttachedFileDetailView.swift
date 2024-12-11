//
//  AttachedFileDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI
import MEMToast

struct AttachedFileDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appCoordinator: AppCoordinatorImpl
    
    // Initializer properties
    @ObservedObject var viewModel: AttachedFileDetailViewModel
    private var bucketObjectModel: BucketObjectModel? {
        didSet { resetViewModel() }
    }
    private var packageModel: PackageExtractionModel? {
        didSet { resetViewModel() }
    }
    let attachmentMode: AttachmentMode
    
    @State private var showExpiredAlert = false

    // MARK: Initialize view with BucketObjectModel
    init(viewModel: AttachedFileDetailViewModel,
         bucketObjectModel: BucketObjectModel? = nil,
         packageModel: PackageExtractionModel? = nil,
         attachmentMode: AttachmentMode)
    {
        self.viewModel = viewModel
        self.bucketObjectModel = bucketObjectModel
        self.packageModel = packageModel
        self.attachmentMode = attachmentMode
        
        mainQueue {
            viewModel.readFileDataToProperites(infoProperties: packageModel?.infoPropertyList, mobileProvision: packageModel?.mobileProvision)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if let bucketObjectModel {
                        AppIconView(iconURL: bucketObjectModel.getAppIcon())
                    }else if let packageModel {
                        AppIconView(icon: packageModel.appIcon)
                    }
                    
                    bundleNameWithIdentifierView()
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
            .navigationTitle(viewModel.bundleProperties?.bundleName ?? "Loading")
            .navigationBarTitleDisplayMode(.inline)
            .alert("com.learn.meminstaller.upload.provision.error.title", isPresented: $showExpiredAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("com.learn.meminstaller.upload.provision.error.message")
            })
            .showToast(message: viewModel.toastMessage, isShowing: $viewModel.isShowingToast)
            .overlay {
                switch viewModel.detailLoadingState {
                case .uploading(let uploadingMessage):
                    HorizontalLoadingWrapper(title: uploadingMessage, value: viewModel.uploadProgress)
                        .allowsHitTesting(true)
                default:
                    Color.clear
                }
            }
        }
    }
    
    private func uploadApplication() {
        // Validate the mobile provision before uploading the application
        viewModel.mobileProvision?.isExpired == true ? showExpiredAlert.toggle() : uploadApplicationToServer()
    }
    
    private func uploadApplicationToServer() {
        guard let endpoint = generateUploadBodyParams() else { return }
        Task {
            await viewModel.uploadPackage(endpoint: endpoint, packageExtractionModel: packageModel) {
                dismiss()
                NotificationCenter.default.post(name: .refreshData, object: nil)
            }
        }
    }
    
    private func generateUploadBodyParams() -> String? {
        guard let userEmail = viewModel.userProfile?.email else { return nil }
        guard let bundleName = viewModel.bundleProperties?.value(for: .bundleName) else { return nil }

        return "\(userEmail)/\(bundleName)"
    }
    
    private func resetViewModel() {
        viewModel.bundleProperties = nil
        viewModel.mobileProvision = nil
    }
}

// MARK: - Private Extension
private extension AttachedFileDetailView {
    @ViewBuilder
    func bundleNameWithIdentifierView() -> some View {
        if let bundleProperties = viewModel.bundleProperties {
            VStack(alignment: .leading) {
                Text(bundleProperties.bundleName ?? "No Bundle name available")
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                
                Text(bundleProperties.bundleIdentifier ?? "Bundle Id not available")
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(1)
            }
        }else {
            VStack(alignment: .leading, spacing: 5) {
                rectangleShimmerView(width: 100, corner: 4)
                rectangleShimmerView(width: 200, corner: 4)
            }
        }
    }
    
    @ViewBuilder
    func iPhoneLayoutBundlePropertyView() -> some View {
        bundlePropertyView()
        mobileProvisionView()
    }
    
    @ViewBuilder
    func iPadLayoutBundlePropertyView() -> some View {
        HStack(spacing: 0) {
            iPhoneLayoutBundlePropertyView()
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    func bundlePropertyView() -> some View {
        if let bundleProperties = viewModel.bundleProperties {
            RoundedRectangleOutlineView {
                ForEach(PListCellIdentifiers.allCases, id: \.self) { identifier in
                    HorizontalKeyValueContainer(key: identifier.rawValue, value: bundleProperties.value(for: identifier))
                }
            }
        }else {
            loadingRoundedRectangleView(taskType: .infoFile) {
                self.bucketObjectModel?.getInfoPropertyListURL()
            }
        }
    }
    
    @ViewBuilder
    func mobileProvisionView() -> some View {
        if let mobileProvision = viewModel.mobileProvision {
            RoundedRectangleOutlineView {
                ForEach(ProvisionCellIdentifiers.allCases, id: \.self) { identifier in
                    mobileProvisionCellView(provision: mobileProvision, identifier)
                }
            }
        }else {
            loadingRoundedRectangleView(taskType: .provision) {
                self.bucketObjectModel?.getMobileProvisionURL()
            }
        }
    }
    
    @ViewBuilder
    func mobileProvisionCellView(provision: MobileProvision, _ identifier: ProvisionCellIdentifiers) -> some View {
        if identifier != .expiredDate {
            HorizontalKeyValueContainer(key: identifier.rawValue, value: provision.value(for: identifier))
        }else {
            HorizontalKeyValueContainer(key: identifier.rawValue) {
                Text(provision.value(for: identifier) ?? "No Expiration Date")
                    .font(.system(.footnote))
                    .foregroundStyle(provision.isExpired ? Color.red : Color(uiColor: .secondaryLabel))
            }
        }
    }
    
    @ViewBuilder
    func loadingRoundedRectangleView(taskType: DownloadType, urlProvider: @escaping () -> String?) -> some View {
        RoundedRectangleOutlineView {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .task {
            guard let url = urlProvider() else { return }
            await viewModel.downloadFile(url: url, type: taskType)
        }
    }
    
    @ViewBuilder
    func actionButtonView() -> some View {
        HStack(spacing: 30) {
            Button {
                attachmentMode == .install ? viewModel.installApplication(bucketObjectModel?.getObjectURL()) : uploadApplication()
            } label: {
                Text(attachmentMode == .install ? "Install" : "Upload")
                    .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.3, 180))
            }
            .padding(.bottom, 30)
            
            if attachmentMode == .upload {
                dismissButtonView()
            }
            
            if attachmentMode == .install {
                showQRCodeView()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    func dismissButtonView() -> some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
                .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.3, 180))
        }
        .padding(.bottom, 30)
    }
    
    @ViewBuilder
    func showQRCodeView() -> some View {
        Button(action: {
            guard let appIcon = bucketObjectModel?.getAppIcon(), let appName = bucketObjectModel?.folderName, let url = bucketObjectModel?.getObjectURL() else { return }
            let qrProvider = QRProvider(appIconURL: appIcon, appName: appName, url: url)
            appCoordinator.pop(.QRCodeProvider(qrProvider))
        }, label: {
            Text("QR Code")
                .defaultButtonStyle(width: min(UIScreen.screenWidth * 0.3, 180))
        })
        .padding(.bottom, 30)
        .popover(item: $appCoordinator.popView) { pop in
            appCoordinator.build(forPop: pop)
        }
    }
    
    @ViewBuilder
    func rectangleShimmerView(width: CGFloat, corner: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: corner)
            .fill(StyleManager.colorStyle.systemGray)
            .frame(width: width, height: 15)
            .shimmer(enable: .constant(true))
    }
}
