//
//  PackageExtractionModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 10/12/24.
//

import Foundation

struct PackageExtractionModel: Hashable {
    let appIcon: Data?
    let app: Data?
    let mobileProvision: Data?
    let infoPropertyList: Data?
    var installationPList: Data?
    
    var id: Self { return self }
}
