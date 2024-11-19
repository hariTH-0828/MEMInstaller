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
    
    func uploadObjects(endpoint: ZAPIStrings.Endpoint, headers: HTTPHeaders, data: Data) async throws -> Result<String, Error> {
        let networkRequest = NetworkRequest(endpoint: endpoint,
                                            headers: headers,
                                            data: data)
        do {
            return try await PUT(request: networkRequest).execute()
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
}
