//
//  PUT.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 19/11/24.
//

import Foundation
import Alamofire

class PUT {
    private var request: NetworkRequest
    private let tokenProvider: TokenProvider
    
    init(request: NetworkRequest, tokenProvider: TokenProvider = ZIAMTokenProvider()) {
        self.request = request
        self.tokenProvider = tokenProvider
    }
    
    func execute() async throws -> Result<String, Error> {
        guard request.checkNetworkIsAvailable() else { throw ZError.NetworkError.noNetworkAvailable }
        
        guard let accessToken = try await tokenProvider.getAccessToken() else {
            throw ZError.NetworkError.tokenRetrievalFailed
        }
        
        let url = request.uploadBaseURL.appending(path: request.endpoint.path)
        ZLogs.shared.info(url.absoluteString)
        
        self.request.headers.add(.authorization(bearerToken: accessToken))
        
        guard let fileData = request.data else { throw ZError.LocalError.noFileFound }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(fileData, to: url, method: .put, headers: request.headers)
                .validate()
                .response { response in
                    switch response.result {
                    case .success(_):
                        continuation.resume(returning: .success("Upload success"))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}
