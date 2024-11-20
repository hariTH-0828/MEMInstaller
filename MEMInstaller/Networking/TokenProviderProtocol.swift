//
//  TokenProviderProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation

protocol TokenProvider {
    func getAccessToken() async throws -> String?
}

class ZIAMTokenProvider: TokenProvider {
    func getAccessToken() async throws -> String? {
        return try await ZIAMManager.getIAMAccessToken()
    }
}
