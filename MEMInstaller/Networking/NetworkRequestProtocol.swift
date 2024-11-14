//
//  NetworkRequestProtocol.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Alamofire

struct NetworkRequest {
    var baseURL: URL = URL(string: ZAPIStrings.BASE_URL)!
    var endpoint: ZAPIStrings.Endpoint
    var parameters: Parameters?
    var headers: HTTPHeaders = ["Content-Type": "application/json"]
}

extension NetworkRequest {
    
    func checkNetworkIsAvailable() -> Bool {
        if !ConnectionStatus.shared.isNetworkAvailable {
            return false
        }
        return true
    }
    
    func validateOAuthAndLogout() {
        ZIAMManager.checkOAuthAndForceLogout { _ in
            showAlert(message: "Invalid_mobile_code") { _ in
                DispatchQueue.main.async {
                    AppViewModel.shared.logout()
                }
            }
        }
    }
    
    func validateHTTPResponse(_ httpResponse: HTTPURLResponse) throws {
        switch httpResponse.statusCode {
        case 200:
            return
        case 401:
            validateOAuthAndLogout()
            throw ZError.NetworkError.userAuthenticationRequired
        case 403:
            throw ZError.NetworkError.accessRestricted
        case 404:
            throw ZError.NetworkError.noDataAvailable
        default:
            throw ZError.NetworkError.badServerResponse
        }
    }
}
