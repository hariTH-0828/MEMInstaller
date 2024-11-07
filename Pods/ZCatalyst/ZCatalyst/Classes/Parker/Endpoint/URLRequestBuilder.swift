//
//  URLRequestBuilder.swift
//  NetworkLayer
//
//  Created by Giridhar on 10/05/19.
//  Copyright © 2019 Rizwan Ahmed A. All rights reserved.
//

import Foundation
import MobileCoreServices

enum RequestBuildError: String, Error
{
    
    // Add more errors here.
    case generic = "General Error"
    case parameter = "Error in parameter"
    case OAuth = "Error in OAuth token"
    
}


//Change this to Swift5 result type
public enum Result<T, E: Error>
{
    case success(T)
    case error(E)
}

public struct CatalystResult
{
    public enum DataURLResponse< Data : Any, Response : Any >
    {
        case success( Data, Response )
        case failure( Error )
    }
}

typealias RequestSuccessCompletion = (_ urlRequest:URLRequest?) -> ()
typealias RequestFailureCompletion = (_ error:Error?) -> ()

typealias ConfigureParametersSuccessBlock  = (_ urlRequest:URLRequest) -> ()
typealias ConfigureParametersErrorBlock    = (_ error:Error) -> ()


struct URLRequestBuilder
{
    
    
    //TODO: Request Building must not be here. Move it to a seperate class and make it Result type and not throwable. Anything other than throwable.
    
    

    func makeRequest(from route: APIEndPointConvertable) throws -> URLRequest
    {
        var request = URLRequest(url:ServerURL.url().appendingPathComponent(route.path), cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 600.0)
        request.httpMethod = route.httpMethod.rawValue
        
        self.setAdditionalHeaders(ServerURL.portalHeader(), request: &request)
        self.setUserAgent(ServerURL.getUserAgent(), request: &request)
        guard let payload = route.payload else
        {
            return request
        }
        
        do {
                var newRequest =  try self.configureParameters(body: payload.bodyParameters, jsonBody: payload.bodyData, urlParameters: payload.urlParameters, request: &request)
                self.setAdditionalHeaders(payload.headers, request: &newRequest)
                return newRequest
            }
            catch {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.invalidData ) : Invalid parameters, Details : -" )
                throw ZCatalystError.processingError( code : ErrorCode.invalidData, message : "Invalid parameters", details : nil )
            }
    
    }
    
    
    func buildRequest(from route : APIEndPointConvertable, success : @escaping RequestSuccessCompletion, failure : @escaping RequestFailureCompletion)
    {

        do {
            let request = try makeRequest(from: route)
            
            switch route.OAuthEnabled
            {
            case .disabled:
                success(request)
            case .enabled(let helper):
                self.addOAuth(request: request, helper: helper) { (result) in
                    switch result
                    {
                    case .success(let newRequest):
                        success(newRequest)
                    case .error(let error):
                        failure(error)
                    }
                }
            }
        }
        catch
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            failure( typeCastToZCatalystError( error ) )
        }
    }
    
    private func addOAuth(request: URLRequest, helper: OAuthCompatible, completion: @escaping ((Result<URLRequest,ZCatalystError>) -> Void))
    {
        var oauthrequest = request
        helper.getOAuthToken(success: { (token) in
            self.setOAuthHeaders(token, request: &oauthrequest)
            completion(.success(oauthrequest))
        }) { (error) in
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            completion( .error( typeCastToZCatalystError( error ) ) )
        }
    }
    
    fileprivate func configureParameters(body: Parameters?, jsonBody : Data? = nil ,urlParameters : Parameters?, request : inout URLRequest) throws -> URLRequest {
        
        do {
            if let bodyJSON = body {
                try JSONParameterEncoder.encode(urlRequest: &request, jsonBody: bodyJSON)
                            }
            
            if let body = jsonBody {
                JSONParameterEncoder.encode(urlRequest: &request, jsonBody:body ,withParameters: ["":""])
            }
            
            
            if let urlParameters = urlParameters{
                try URLParameterEncoder.encode(urlRequest: &request, jsonBody:jsonBody ,withParameters: urlParameters)
            }
            
            
            return request
        }catch {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            throw error
        }
        
    }
    
    
    
    fileprivate func configureParameters(body: Parameters??, jsonBody : Data? = nil ,urlParameters : Parameters?, request : inout URLRequest, success : @escaping ConfigureParametersSuccessBlock, failure : @escaping ConfigureParametersErrorBlock) {
        
        do {
            if let body = jsonBody {
                JSONParameterEncoder.encode(urlRequest: &request, jsonBody:body ,withParameters: ["":""])
            }
            
            
            if let urlParameters = urlParameters{
                try URLParameterEncoder.encode(urlRequest: &request, jsonBody:jsonBody ,withParameters: urlParameters)
            }
            

            success(request)
        }catch {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            failure(error)
        }
        
    }
    
    fileprivate func setAdditionalHeaders(_ additionalHeader : HTTPHeaders?,request : inout URLRequest){
        
        guard let headers = additionalHeader else{
            return
        }
        for (key,value) in headers{
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        guard let requestHeaders = ZCatalystApp.shared.appConfig.requestHeaders else
        {
            return
        }
        for (key,value) in requestHeaders{
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    fileprivate func setUserAgent(_ userAgent : UserAgent?,request : inout URLRequest){
        guard let userAgentHeader = userAgent else{
            return
        }
        for (key,value) in userAgentHeader {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    fileprivate func setOAuthHeaders(_ oauthToken : String?, request : inout URLRequest){
        guard let oauthTokenValue = oauthToken else{
            return
        }
        request.setValue("Zoho-oauthtoken \(oauthTokenValue)", forHTTPHeaderField: HeaderKeyTypes.authorization.rawValue)
    }
    
    private func getMimeTypeFor( fileURL : URL ) -> String
    {
        let pathExtension = fileURL.pathExtension
        if let uniformTypeIdentifier = UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, pathExtension as CFString, nil )?.takeRetainedValue()
        {
            if let mimeType = UTTypeCopyPreferredTagWithClass( uniformTypeIdentifier, kUTTagClassMIMEType )?.takeRetainedValue()
            {
                return mimeType as String
            }
        }
        return "application/octet-stream"
    }
    
    private func getFilePart( fileURL : URL?, fileName : String?, fileData : Data?, boundary : String ) -> Data
    {
        var filePartData : Data = Data()
        if let url = fileURL
        {
            filePartData.append( "--\(boundary)\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( "Content-Disposition: form-data; name=\"code\"; filename=\"\(url.lastPathComponent)\"\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( try! Data( contentsOf : url ) )
        }
        if let fileData = fileData, let name = fileName
        {
            filePartData.append( "--\(boundary)\r\n".data( using : String.Encoding.utf8 )! )
            filePartData.append( "Content-Disposition: form-data; name=\"code\"; filename=\"\( name )\"\r\n".data( using : String.Encoding.utf8 )! )
            if let url = URL(string : name.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) ?? "")
            {
                filePartData.append( "Content-Type: \(getMimeTypeFor( fileURL : url ))\r\n\r\n".data( using : String.Encoding.utf8 )! )
            }
            filePartData.append( fileData )
        }

        return filePartData
    }

    
    func createMultipartRequest( fileURL : URL?, fileName : String?, fileData : Data?, request : inout URLRequest )
    {
        let boundary = String(format : "unique-consistent-string-%@", UUID.init().uuidString)
        var httpBodyData = Data()
        if let fileURL = fileURL
        {
            httpBodyData = self.getFilePart( fileURL : fileURL, fileName : nil, fileData : nil, boundary : boundary )
        }
        else if let fileData = fileData, let fileName = fileName
        {
            httpBodyData = self.getFilePart( fileURL : nil, fileName : fileName, fileData : fileData, boundary : boundary )
        }
        
        httpBodyData.append( "\r\n--\(boundary)".data( using : String.Encoding.utf8 )! )
        
        request.setValue( "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField : "Content-Type")
        request.setValue( "\(httpBodyData.count)", forHTTPHeaderField : "Content-Length" )
        request.httpBody = httpBodyData
    }
}
