//
//  AttachedFileDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SwiftUI

private enum PListCellIdentifiers: String, CaseIterable {
    case bundleName = "Bundle name"
    case bundleIdentifiers = "Bundle identifiers"
    case bundleVersionShort = "Bundle version (short)"
    case bundleVersion = "Bundle version"
    case minOSVersion = "Minimum OS version"
    case requiredDevice = "Required device compability"
    case supportedPlatform = "Suppported platform"
}

struct AttachedFileDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isPresentExport: Bool = false
    let bundleProperty: BundleProperties
    
    private let propertyListCellData: [PListCellIdentifiers: String] = [:]
    
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
                
                installBtnView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle(bundleProperty.bundleName ?? "Unknown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Export", systemImage: "square.and.arrow.down") {
                        viewModel.packageHandler.generatePrivacyList {
                            isPresentExport.toggle()
                        }
                    }
                }
            }
            .sheet(isPresented: $isPresentExport, content: {
                ActivityViewRepresentable(activityItems: viewModel.packageHandler.shareItem) { completion, error in
                    if let error = error {
                        viewModel.presentToast(message: error.localizedDescription)
                    }else if completion {
                        viewModel.presentToast(message:"File successfully saved")
                    }else {
                        viewModel.presentToast(message:"Activity Dismissed")
                    }
                }
                .presentationDetents([.medium, .large])
            })
        }
    }
    
    @ViewBuilder
    private func bundleNameWithIdentifierView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            /// App Name
            Text(bundleProperty.bundleName ?? "Unknown")
                .font(.title2)
                .bold()
                .lineLimit(1)
            /// App Bundle Identifier
            Text(bundleProperty.bundleIdentifier ?? "nil")
                .font(.footnote)
                .foregroundStyle(Color(.secondaryLabel))
                .lineLimit(1)
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
            Image(uiImage: UIImage.getCurrentAppIcon())
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(.circle)
        }
    }
    
    @ViewBuilder
    private func AppDataCellView(key: PListCellIdentifiers, value: String?) -> some View {
        HStack {
            Text(key.rawValue)
                .font(.system(.footnote))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Spacer()
            
            Text(value ?? " - No value -")
                .font(.system(.footnote))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
        .frame(height: 22)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func installBtnView() -> some View {
        Button(action: {
            viewModel.packageHandler.executeInstall("https://packages-development.zohostratus.com/plist/ZohoFaciMap.plist")
        }, label: {
            Text("Install")
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
            return bundleProperty.bundleName
        case .bundleIdentifiers:
            return bundleProperty.bundleIdentifier
        case .bundleVersionShort:
            return bundleProperty.bundleVersionShort
        case .bundleVersion:
            return bundleProperty.bundleVersion
        case .minOSVersion:
            return bundleProperty.minimumOSVersion
        case .requiredDevice:
            return bundleProperty.requiredDeviceCompability?.joined(separator: ", ")
        case .supportedPlatform:
            return bundleProperty.supportedPlatform?.joined(separator: ", ")
        }
    }
}
