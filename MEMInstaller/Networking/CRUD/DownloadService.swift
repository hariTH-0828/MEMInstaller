//
//  Downloadservice.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 18/11/24.
//

import Foundation
import Alamofire

class DownloadService {
    private let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func downloadFile() async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            ZIAMManager.getIAMAccessToken { token in
                AF.download(self.url, headers: HTTPHeaders([.authorization(bearerToken: token)]))
                    .responseData { response in
                        switch response.result {
                        case .success(let data):
                            continuation.resume(returning: data)
                        case .failure(let error):
                            ZLogs.shared.error("Download Error: " + error.localizedDescription)
                            continuation.resume(throwing: error)
                        }
                    }
            } failure: { error in
                guard let error else { return }
                ZLogs.shared.error("Error in download: " + error.localizedDescription)
                continuation.resume(throwing: error)
            }
        }
    }
}
