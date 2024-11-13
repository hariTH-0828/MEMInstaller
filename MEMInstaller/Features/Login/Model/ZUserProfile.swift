//
//  ZCUserProfile.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import SSOKit

struct ZUserProfile: Codable {
    let name: String
    let displayName: String
    let email: String
    let profileImageData: Data
}

