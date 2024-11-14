//
//  StratusRepository.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation

protocol StratusRepository {
    func getAllBuckets() async throws -> [BucketModel]
}
