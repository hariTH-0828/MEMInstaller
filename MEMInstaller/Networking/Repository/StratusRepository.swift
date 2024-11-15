//
//  StratusRepository.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation
import Alamofire

protocol StratusRepository {
    func getAllObjects(_ params: Parameters?) async throws -> BucketObjectModel
    func uploadObjects() async throws
}
