//
//  DOWNLOAD.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 18/11/24.
//

import Foundation
import Alamofire

class Download {
    private let url: String
    
    init(url: String) {
        self.url = url
    }
    
    func downloadFile(completion: @escaping (Result<Data, Error>) -> Void) {
        ZIAMManager.getIAMAccessToken { token in
            AF.download(self.url, headers: HTTPHeaders([.authorization(bearerToken: token)]))
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        ZLogs.shared.error("Download Error: " + error.localizedDescription)
                        completion(.failure(error))
                    }
                }
        } failure: { error in
            guard let error else { return }
            ZLogs.shared.error("Error in download: " + error.localizedDescription)
            completion(.failure(error))
        }

    }
}
