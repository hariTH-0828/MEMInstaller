//
//  StratusRepositoryImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Alamofire

final class StratusRepositoryImpl: StratusRepository {
    
    func getAllBuckets() async throws -> [BucketModel] {
        do {
            let networkRequest = NetworkRequest(endpoint: .bucket)
            return try await GET<DataModel<[BucketModel]>>(request: networkRequest).execute().data
        }catch {
            throw error
        }
    }
}
