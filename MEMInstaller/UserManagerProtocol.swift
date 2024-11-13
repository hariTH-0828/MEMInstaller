//
//  UserManagerProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 13/11/24.
//

import Foundation

protocol UserManagerProtocol {
    func saveLoggedUserIntoKeychain() -> Bool
    func retriveLoggedUserFromKeychain() -> ZUserProfile?
}
