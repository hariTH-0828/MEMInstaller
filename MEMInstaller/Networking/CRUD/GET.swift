//
//  GET.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation
import Alamofire

class GET<T: Codable> {
    private var request: NetworkRequest
    private let tokenProvider: TokenProvider
    
    init(request: NetworkRequest, tokenProvider: TokenProvider = ZIAMTokenProvider()) {
        self.request = request
        self.tokenProvider = tokenProvider
    }
    
    func execute() async throws -> T {
        do {
            guard request.checkNetworkIsAvailable() else { throw ZError.NetworkError.noNetworkAvailable }
            
            guard let accessToken = try await tokenProvider.getAccessToken() else {
                throw ZError.NetworkError.tokenRetrievalFailed
            }
            
            let url = constructURL()
            logRequestDetails(url: url)
            
            // Adding authorization header
            self.request.headers.add(.authorization(bearerToken: accessToken))
            
            return try await sendRequest(to: url)
        }catch {
            throw error
        }
    }
    
    // MARK: Helper methods
    private func constructURL() -> URL {
        request.baseURL.appending(path: request.endpoint.path)
    }
    
    private func logRequestDetails(url: URL) {
        ZLogs.shared.info("URL: "+url.absoluteString)
        
        request.parameters?.forEach({ key, value in
            print("\(key) : \(value)")
        })
    }
    
    private func sendRequest(to url: URL) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get,
                       parameters: request.parameters,
                       encoding: URLEncoding.default,
                       headers: request.headers)
            .responseDecodable(of: T.self) { [weak self] response in
                do {
                    try self?.handleResponse(response, continuation: continuation)
                }catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func handleResponse(_ response: DataResponse<T, AFError>, continuation: CheckedContinuation<T, Error>) throws {
        guard let httpResponse = response.response else {
            continuation.resume(throwing: ZError.NetworkError.invalidResponse)
            return
        }
        
        ZLogs.shared.info("HTTP Status Code: \(httpResponse.statusCode)")
        
        try request.validateHTTPResponse(httpResponse)
        
        switch response.result {
        case .success(let serializedData):
            continuation.resume(returning: serializedData)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}
