//
//  PackageURL.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 04/12/24.
//

import Foundation

struct PackageURL {
    let infoPropertyListURL: String?
    let appIconURL: String?
    let installerPropertListURL: String?
    let mobileProvisionURL: String?
    
    init(infoPropertyListURL: String?, appIconURL: String?, installerURL: String?, mobileProvisionURL: String?) {
        self.infoPropertyListURL = infoPropertyListURL
        self.appIconURL = appIconURL
        self.installerPropertListURL = installerURL
        self.mobileProvisionURL = mobileProvisionURL
    }
}
