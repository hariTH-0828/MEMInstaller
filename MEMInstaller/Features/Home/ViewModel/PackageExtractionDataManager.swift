//
//  PackageExtractionDataManager.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 28/11/24.
//

import Foundation

class PackageExtractionDataManager {
    var appIcon: Data?
    var sourceFileData: Data?
    var infoPlistData: Data?
    var installablePropertyListData: Data?
    var provisionProfileData: Data?
    var bundleProperties: BundleProperties?
    var mobileProvision: MobileProvision?
    var objectURL: String?
    
    func reset() {
        appIcon = nil
        sourceFileData = nil
        infoPlistData = nil
        installablePropertyListData = nil
        bundleProperties = nil
        mobileProvision = nil
        objectURL = nil
    }
}
