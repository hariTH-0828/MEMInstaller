//
//  ZCUserProfile.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import Foundation
import ZCatalyst

struct ZCUserProfile: Codable {
    let id: Int64
    let zuId: Int64
    let firstName: String
    let lastName: String?
    let email: String
    let status: String
    let role: ZCUserRole
    
    static func fromZCatalystUser(_ user: ZCatalystUser) -> Self {
        return ZCUserProfile(id: user.id,
                             zuId: user.zuId,
                             firstName: user.firstName,
                             lastName: user.lastName,
                             email: user.email,
                             status: user.status,
                             role: ZCUserRole(id: user.role.id, name: user.role.name))
    }
}

struct ZCUserRole: Codable {
    let id: Int64
    let name: String
}
