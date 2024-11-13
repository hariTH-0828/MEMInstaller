//
//  MicsApiHandler.swift
//  SSOKit-SSOKitBundle
//
//  Created by Sathish Kumar G on 16/01/24.
//

import Foundation
#if !os(watchOS)
enum MicsAppError: Error {
    case invalidURL
    case invalidAccessToken
    case invalidResponse
}

class MicsApiHandler {
    
    static let shared = MicsApiHandler()
        
    typealias Completion = ((_ jsonResponse: [String: Any]?, _ error: Error?) -> Void)
    func makeRequest(urlString: String, params: [String: Any], _ completion: Completion? = nil) {
        
        guard let baseURL = URL(string: urlString) else {
            completion?(nil, MicsAppError.invalidURL)
            return
        }
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        var urlQueryItems: [URLQueryItem] = []
        params.forEach {
            if let value = $0.value as? String {
                urlQueryItems.append(URLQueryItem(name: $0.key, value: value))
            }
        }
        urlComponents?.queryItems = urlQueryItems
        guard let url = urlComponents?.url else {
            completion?(nil, MicsAppError.invalidURL)
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        makeRequestWithToken(urlRequest: urlRequest, completion)
    }
    
    func makePOSTRequest(urlString: String, params: [String: Any], _ completion: Completion? = nil) {
        
        var urlStr = urlString
        guard let url = URL(string: urlStr) else {
            completion?(nil, MicsAppError.invalidURL)
            return
        }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        var urlQueryItems: [URLQueryItem] = []
        params.forEach {
//            if let value = $0.value {
                urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
//            }
        }
        urlComponents?.queryItems = urlQueryItems
        
        var urlRequest = URLRequest(url: urlComponents!.url!)
        urlRequest.httpMethod = "POST"
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
//            urlRequest.httpBody = jsonData
//        } catch let error {
//            debugPrint("MICS ERROR: \(error)")
//        }
        makeRequestWithToken(urlRequest: urlRequest, completion)
    }
    
    private func makeRequestWithToken(urlRequest: URLRequest, _ completion: Completion? = nil) {
        
        ZSSOKit.getOAuth2Token { token, error in
            guard let accesstoken = token else {
                completion?(nil, MicsAppError.invalidAccessToken)
                return
            }
            var urlReq = urlRequest
            let token = "Zoho-oauthtoken " + accesstoken
            urlReq.setValue(token, forHTTPHeaderField: "Authorization")
            let userAgent = ZIAMUtil.shared().getUserAgentString() ?? ""
            urlReq.addValue(userAgent, forHTTPHeaderField: "User-Agent")
            
            let session = URLSession.shared
            let task = session.dataTask(with: urlReq) { data, response, error in
                if let err = error {
                    completion?(nil, err)
                    debugPrint("ERROR: \(err)")
                }else if let responseData = data {
                    self.processResponseData(data: responseData, response: response, completion)
                }else {
                    completion?(nil, MicsAppError.invalidResponse)
                }
            }
            task.resume()
        }
    }
    
    func processResponseData(data responseData:Data, response: URLResponse?, _ completion: Completion? = nil) {
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options : .mutableContainers) as? Dictionary<String,Any> {
                completion?(jsonResponse, nil)
            }
        } catch let serialiseError as NSError {
            debugPrint("ERROR: \(serialiseError)")
            completion?(nil, serialiseError)
        }
    }
}
#endif
