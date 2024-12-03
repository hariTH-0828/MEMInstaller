//
//  StratusRepositoryImpl.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Alamofire

final class StratusRepositoryImpl: StratusRepository, ObservableObject {
    @Published var uploadProgress: Double = 0.0 // Observable progress
    
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
        let networkRequest = NetworkRequest(endpoint: endpoint, headers: headers, data: data)
        let uploader = PUT(request: networkRequest)
        
        // Observe progress from PUT and assign to repository's uploadProgress
        uploader.$uploadProgress
            .receive(on: DispatchQueue.main)
            .assign(to: &$uploadProgress)
        do {
            return try await uploader.execute()
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
}
