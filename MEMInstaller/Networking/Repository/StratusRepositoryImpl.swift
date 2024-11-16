//
//  StratusRepositoryImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Alamofire

final class StratusRepositoryImpl: StratusRepository {
    
    func getFoldersFromBucket(_ params: Parameters?) async throws -> BucketObjectModel {
        let networkRequest = NetworkRequest(endpoint: .objects, parameters: params)
        
        do {
            return try await GET<DataModel<BucketObjectModel>>(request: networkRequest).execute().data
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
    
    func uploadObjects() async throws {
        // Implement upload functionality
    }
}
