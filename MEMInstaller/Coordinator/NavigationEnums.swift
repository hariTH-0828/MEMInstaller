//
//  NavigationEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import Foundation
import SwiftUI

enum Screen: Hashable, Identifiable {
    case settings
    case about
    case privacy
    
    var id: Screen { self }
}

enum Sheet: Identifiable, Hashable {
    case settings
    case logout
    case activityRepresentable(URL)
    case AttachedFileDetail(AttachedFileDetailViewModel, PackageExtractionModel, AttachmentMode)
    case QRCodeProvider(QRProvider)
    
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
        case (.settings, .settings), (.logout, .logout): return true
        case(.activityRepresentable(let lhsURL), .activityRepresentable(let rhsURL)): return lhsURL == rhsURL
        case (.AttachedFileDetail(let lhsAFD, let lhsPackage, let lhsMode),
                      .AttachedFileDetail(let rhsAFD, let rhsPackage, let rhsMode)):
            return ObjectIdentifier(lhsAFD) == ObjectIdentifier(rhsAFD) && lhsPackage == rhsPackage && lhsMode == rhsMode
        case (.QRCodeProvider(let lhsQRProvider), .QRCodeProvider(let rhsQRProvider)):
            return lhsQRProvider == rhsQRProvider
        default: return false
        }
    }
    
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .settings:
            hasher.combine("settings")
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
        }
    }
}
