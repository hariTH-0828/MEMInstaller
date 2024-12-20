//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation
import SwiftUI

typealias getFileImporterURL = ((URL?) -> Void)

enum Screen: Hashable, Identifiable {
    case settings
    case about
    case privacy
    
    var id: Screen { self }
}

enum Sheet: Identifiable, Hashable {
    case logout
    case activityRepresentable(URL)
    case AttachedFileDetail(AttachedFileDetailViewModel, PackageExtractionModel, AttachmentMode)
    case QRCodeProvider(QRProvider)
    case fileImporter(URL?, getFileImporterURL)
    
    var id: Self { self }
}

enum Pop: Identifiable, Hashable {
    case logout
    case QRCodeProvider(QRProvider)
    
    var id: Self { self }
}

extension Sheet {
    static func == (lhs: Sheet, rhs: Sheet) -> Bool {
        switch (lhs, rhs) {
        case (.logout, .logout): return true
        case(.activityRepresentable(let lhsURL), .activityRepresentable(let rhsURL)): return lhsURL == rhsURL
        case (.AttachedFileDetail(let lhsAFD, let lhsPackage, let lhsMode),
                      .AttachedFileDetail(let rhsAFD, let rhsPackage, let rhsMode)):
            return ObjectIdentifier(lhsAFD) == ObjectIdentifier(rhsAFD) && lhsPackage == rhsPackage && lhsMode == rhsMode
        case (.QRCodeProvider(let lhsQRProvider), .QRCodeProvider(let rhsQRProvider)):
            return lhsQRProvider == rhsQRProvider
        case (.fileImporter, .fileImporter): return true
        default: return false
        }
    }
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .logout:
            hasher.combine("logout")
        case .activityRepresentable(let url):
            hasher.combine("activityRepresentable")
            hasher.combine(url)
        case .AttachedFileDetail(let afd, let package, let mode):
            hasher.combine("AttachedFileDetail")
            hasher.combine(ObjectIdentifier(afd))
            hasher.combine(package)
            hasher.combine(mode)
        case .QRCodeProvider(let qrprovider):
            hasher.combine(qrprovider)
        case .fileImporter:
            hasher.combine("FileImporter")
        }
    }
}
