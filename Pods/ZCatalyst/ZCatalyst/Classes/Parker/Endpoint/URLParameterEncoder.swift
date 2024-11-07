//
//  URLParameterEncoding.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

struct URLParameterEncoder : ParameterEncoder{

    static func encode(urlRequest: inout URLRequest, jsonBody body: Data?, withParameters parameters: Parameters) throws {
        
        do{
            guard let url = urlRequest.url else{
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.internalError ) : URL is not specified, Details : -" )
                throw ZCatalystError.processingError( code : ErrorCode.internalError, message : "URL is not specified", details : nil )
            }
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty{
                
                urlComponents.queryItems = [URLQueryItem]()
                
                for (key,value) in parameters {
                    let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                    urlComponents.queryItems?.append(queryItem)
                }
                urlRequest.url = urlComponents.url

            }
            
            
            //TODO: Fix this
            if (urlRequest.value(forHTTPHeaderField: "\(HeaderKeyTypes.contentType.rawValue)") == nil){
                urlRequest.setValue("\(HeaderValueTypes.applicationJSON.rawValue)\(HeaderValueTypes.utf8Charset.rawValue)", forHTTPHeaderField: "\(HeaderKeyTypes.contentType.rawValue)")
            }
        }catch{
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.internalError ) : Parameters encoding failed, Details : -" )
            throw ZCatalystError.processingError( code : ErrorCode.internalError, message : "Parameters encoding failed", details : nil )
        }
    }
}
