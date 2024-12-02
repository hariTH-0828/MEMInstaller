//
//  HomeSideBarAppLabel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeSideBarAppLabel: View {
    let bucketObject: BucketObjectModel
    let iconURL: String?
    
    var body: some View {
        HStack {
            // Package size
            let packageFileSize = getPackageFileSize(bucketObject.contents)
            
            Label(
                title: {
                    Text(bucketObject.folderName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StyleManager.colorStyle.invertBackground)
                },
                icon: {
                    appIconView(iconURL)
                }
            )
            
            Spacer()
            
            Text(packageFileSize)
                .font(.footnote)
                .foregroundStyle(StyleManager.colorStyle.systemGray)
        }
        .frame(height: 35)
    }
    
    @ViewBuilder
    private func appIconView(_ iconURL: String?) -> some View {
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
        }
    }
    
    // MARK: - HELPER METHODS
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
    HomeSideBarAppLabel(bucketObject: BucketObjectModel(), iconURL: "")
}
