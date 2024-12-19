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
    
    func uploadObjects(_ uploader: PUT) async throws -> Result<String, Error> {
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
    
    func deletePathObject(endpoint: ZAPIStrings.Endpoint, parameters: Alamofire.Parameters?) async throws -> BucketDeletionModel {
        let networkRequest = NetworkRequest(endpoint: endpoint, parameters: parameters)
        let deleteRequest = DELETE<DataModel<BucketDeletionModel>>(request: networkRequest)
        
        do {
            return try await deleteRequest.execute().data
        }catch {
            ZLogs.shared.error(error.localizedDescription)
            throw error
        }
    }
}
