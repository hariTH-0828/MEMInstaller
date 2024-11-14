//
//  PATCH.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Alamofire

class PATCH<T: Codable> {
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
            
            ZLogs.shared.info(accessToken)
            
            let url = request.baseURL.appending(path: request.endpoint.rawValue)
            ZLogs.shared.info(url.absoluteString)
            
            self.request.headers.add(.authorization(bearerToken: accessToken))
            print("*** Headers ***\n\(request.headers)")
            
            let afRequest = await AF.request(url, method: .patch,
                                           parameters: request.parameters,
                                           encoding: JSONEncoding.default, headers: request.headers)
                .serializingDecodable(T.self, automaticallyCancelling: true)
                .response
            
            guard let data = afRequest.data, let httpResponse = afRequest.response else {
                throw ZError.NetworkError.badServerResponse
            }
            ZLogs.shared.info("HTTP Status Code: \(httpResponse.statusCode)")
            
            try request.validateHTTPResponse(httpResponse)
            return try JSONDecoder().decode(T.self, from: data)
        }catch {
            throw error
        }
    }
}
