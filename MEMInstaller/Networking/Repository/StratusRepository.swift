//
//  StratusRepository.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation
import Alamofire

@frozen
enum ViewState {
    case loading
    case response(_ T: Codable)
}

protocol StratusRepository {
    func getFoldersFromBucket(_ params: Parameters?) async throws -> BucketObjectModel?
    func uploadObjects(endpoint: ZAPIStrings.Endpoint, headers: HTTPHeaders, data: Data) async throws -> Result<String, Error>
}
