//
//  Router.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

enum URLSessionConfigurationType {
    case upload
    case download
}



internal var RouterErrorDictionary: [RouterError: Int]  = [.general: 1000,
                                                           .Bad_Request: 400,
                                                           .Auth_Error: 401,
                                                           .Forbidden:403,
                                                           .Not_Found: 404,
                                                           .Method_Not_Allowed:405,
                                                           .Internal_Server_Error:500]



public enum RouterError: Error
{
    case general
    case noData
    case noResponse
    case Bad_Request
    case Auth_Error
    case Forbidden
    case Not_Found
    case Method_Not_Allowed
    case Unsupported_Media_Type
    case Internal_Server_Error
    case Other_Http_Error
    case URLSessionError(jsonData: Data, statusCode: Int, error: Error?) // Data and status code
    // FIXME: case URLSessionError (Error) // Enums with Raw values cannot have associated values. Rewrite this error protocol.
    

    var rawValue: String
    {
        switch  self {
        case .general:
            return "Genenral Error"
        case .noData:
            return "No Data"
        case .noResponse:
            return "No Response"
        case .Bad_Request:
            return "Bad Request"
        case .Auth_Error:
            return "Authentication Error"
        case .Forbidden:
            return "Forbidden Connection"
        case .Not_Found:
            return "URL Not found"
        case .Method_Not_Allowed:
            return "Method Not Allowed"
        case .Unsupported_Media_Type:
            return "Unsupported Media Type"
        case .Internal_Server_Error:
            return "Internal Server Error"
        case .Other_Http_Error:
            return "Other HTTP Error"
        case .URLSessionError(_, let statusCode, let error):
            return "Network Error http code: \(statusCode) \n Error: \(String(describing: error))"
        }
    }

    func errorForCode(code: Int) -> RouterError
    {
        switch code
        {
        case 400:
            return RouterError.Bad_Request
        case 401:
            return RouterError.Auth_Error
        case 403:
            return RouterError.Forbidden
        case 404:
            return RouterError.Not_Found
        case 405:
            return RouterError.Method_Not_Allowed
        case 500:
            return RouterError.Internal_Server_Error
        default:
            return RouterError.Other_Http_Error
        }
    }
    
    var errorCode: Int {
        guard let code = RouterErrorDictionary[self] else
        {
            return 999
        }
        return code
    }
    
}

extension RouterError:Hashable
{
    public static func == (lhs: RouterError, rhs: RouterError) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public var hashValue: Int {
        switch self {
        case .general:
            return 999
        case .Auth_Error:
            return 401
        case .Bad_Request:
            return 400
        case .Forbidden:
            return 403
        case .Internal_Server_Error:
            return 500
        case .Method_Not_Allowed:
            return 405
        case .noData:
            return 998
        case .noResponse:
            return 997
        case .Not_Found:
            return 404
        case .Other_Http_Error:
            return 996
        case .Unsupported_Media_Type:
            return 995
        case .URLSessionError(_, _, _):
            return 994
        }
    }
}

internal class Router  {
    var tasks: [String:URLSessionTask] = [:]
    fileprivate var fileDownloadDelegate : ZCatalystFileDownloadDelegate?
    fileprivate var fileUploadDelegate : ZCatalystFileUploadDelegate?
    private static var fileAPIRequestDelegate : RouterDelegate = RouterDelegate()
    
    internal static var fileUploadURLSessionWithDelegates : URLSession = URLSession(configuration: ZCatalystApp.fileUploadURLSessionConfiguration, delegate: Router.fileAPIRequestDelegate, delegateQueue: OperationQueue())
    internal static var fileDownloadURLSessionWithDelegates : URLSession = URLSession(configuration: ZCatalystApp.fileDownloadURLSessionConfiguration, delegate: Router.fileAPIRequestDelegate, delegateQueue: OperationQueue())
    
}

extension Router {
    
    func request(_ route: APIEndPointConvertable, session:URLSession = URLSession.shared, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> String
    {
        let requestBuilder = URLRequestBuilder()
        var task : URLSessionTask?
        let id = UUID.init().uuidString
        requestBuilder.buildRequest(from: route, success: { [weak self] (urlRequest) in
            guard let request = urlRequest else{
                ZCatalystLogger.logDebug( message : "Error Occurred : Unable to construct URL request" )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
            
            task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                completion(Router.handleResponse(data, response: response, error: error))
                
            })
            task?.resume()
            
            self?.tasks[id] = task!
        }, failure: { (error) in
            if let error = error
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                completion(Result.error(typeCastToZCatalystError( error )))
            }
            else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) ) )
            }
        })
        
        return id
    }
    
    static func request(_ route: APIEndPointConvertable, session:URLSession = URLSession.shared, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> URLSessionTask?
    {
        let requestBuilder = URLRequestBuilder()
        var task : URLSessionTask?
        requestBuilder.buildRequest(from: route, success: { (urlRequest) in
            guard let request = urlRequest else{
                ZCatalystLogger.logDebug( message : "Error Occurred : Unable to construct URL request" )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
    
            task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
                completion(handleResponse(data, response: response, error: error))
                
            })
            task?.resume()
            
            
        }, failure: { (error) in
            if let error = error
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                completion(Result.error(typeCastToZCatalystError( error )))
            }
            else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) ) )
            }
        })
        
        return task
    }
    
   internal static func handleResponse(_ data: Data?, response: URLResponse?, error: Error?) -> Result<Data, ZCatalystError>
    {
        guard let data = data else {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
            return .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
        }
           
        guard let response = response else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
            return .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
        }
        
        if let error = error {
            //
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
        
        
        return Result.success(data)
    }
    
    func upload( _ route : APIEndPointConvertable, fileRefId : String, filePath : URL?, fileName : String?, fileData : Data?, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        self.fileUploadDelegate = fileUploadDelegate
        let requestBuilder = URLRequestBuilder()
        requestBuilder.buildRequest( from : route, success : { ( urlRequest ) in
            guard var request = urlRequest else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.unableToConstructURL ) : Request could not be constructed for \( fileRefId ), Details : -" )
                self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.sdkError( code : ErrorCode.unableToConstructURL, message : "Request could not be constructed", details : nil ) )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
            
            requestBuilder.createMultipartRequest( fileURL : filePath, fileName : fileName, fileData : fileData, request : &request )
            
            let fileName = fileName ?? filePath?.lastPathComponent ?? ""
            let tempFileUrl = self.getTempFileURL( fileData : request.httpBody!, fileName : fileName )
            
            
            let fileUploadReference = FileUploadTaskReference( fileRefId : fileRefId) { ( taskDetails, taskFinished, error ) in
                if let error = error
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( error ) for \( fileRefId )" )
                    self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : typeCastToZCatalystError( error ) )
                    self.removeTempFile(atURL: tempFileUrl)
                    return
                }
                else if let taskFinished = taskFinished
                {
                    if let data = taskFinished.data
                    {
                        uploadTasksQueue.async {
                            FileTasks.liveUploadTasks?.removeValue(forKey: fileRefId)
                        }
                        let jsonResult : Result< ZCatalystFile, ZCatalystError > = APIHandler().parse( data : data )
                        switch jsonResult
                        {
                        case .success( let fileDetails ) :
                            self.fileUploadDelegate?.didFinish( fileRefId : fileRefId, fileDetails : fileDetails )
                        case .error( let error ) :
                            ZCatalystLogger.logError( message : "Error Occurred : \( error ) for \( fileRefId )" )
                            self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : typeCastToZCatalystError( error ) )
                        }
                        self.removeTempFile( atURL : tempFileUrl )
                    }
                    else
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil for \( fileRefId ), Details : -" )
                        self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
                        self.removeTempFile(atURL: tempFileUrl)
                        return
                    }
                }
                else if let taskDetails = taskDetails
                {
                    self.fileUploadDelegate?.progress( fileRefId : fileRefId, session : taskDetails.session, sessionTask : taskDetails.task, progressPercentage : taskDetails.progress, totalBytesSent : taskDetails.totalBytesSent, totalBytesExpectedToSend : taskDetails.totalBytesExpectedToSend )
                }
            }
            
            let uploadTask = Router.fileUploadURLSessionWithDelegates.uploadTask( with : request, fromFile : tempFileUrl )
            Router.fileAPIRequestDelegate.uploadTaskWithFileRefIdDict.updateValue( fileUploadReference, forKey : uploadTask )
            uploadTasksQueue.async {
                if FileTasks.liveUploadTasks == nil
                {
                    FileTasks.liveUploadTasks = [ String : URLSessionUploadTask ]()
                }
                if let tasks = FileTasks.liveUploadTasks, tasks[ fileRefId ] == nil
                {
                    FileTasks.liveUploadTasks?.updateValue( uploadTask, forKey: fileRefId)
                    uploadTask.resume()
                }
                else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.invalidData ) : A task with file reference Id - \( fileRefId ) is already present. Please provide a unique reference id, Details : -" )
                    self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.inValidError(code: ErrorCode.invalidData, message: "A task with file reference Id - \( fileRefId ) is already present. Please provide a unique reference id", details: nil ) )
                }
            }
        }) { (error) in
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil for \( fileRefId ), Details : -" )
            self.fileUploadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
        }
    }
    
    func upload( _ route : APIEndPointConvertable, filePath : URL?, fileName : String?, fileData : Data?, completion : @escaping ( Result< Data, ZCatalystError > ) -> Void )
    {
        let requestBuilder = URLRequestBuilder()
        requestBuilder.buildRequest( from : route, success : { ( urlRequest ) in
            guard var request = urlRequest else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to construct URL request, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.unableToConstructURL, message : "Unable to construct URL request", details : nil ) ) )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
            
            requestBuilder.createMultipartRequest( fileURL : filePath, fileName : fileName, fileData : fileData, request : &request )
            
            let fileName = fileName ?? filePath?.lastPathComponent ?? ""
            let tempFileUrl = self.getTempFileURL( fileData : request.httpBody!, fileName : fileName )
            
            let urlsession = URLSession( configuration : .default )
            urlsession.uploadTask( with : request, fromFile : tempFileUrl ) { ( data, response, error ) in
                completion( Router.handleResponse( data, response : response, error : error ) )
            }.resume()
            
        }) { (error) in
            if let error = error
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                completion(Result.error(typeCastToZCatalystError( error )))
            }
            else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) ) )
            }
        }
    }
    
    func download( _ route : APIEndPointConvertable, fileRefId : String, fileDownloadDelegate : ZCatalystFileDownloadDelegate )
    {
        self.fileDownloadDelegate = fileDownloadDelegate
        let requestBuilder = URLRequestBuilder()
        requestBuilder.buildRequest( from : route, success : { ( urlRequest ) in
            guard let request = urlRequest else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.unableToConstructURL ) : Request could not be constructed, Details : -" )
                self.fileDownloadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.sdkError( code : ErrorCode.unableToConstructURL, message : "Request could not be constructed", details : nil ) )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
            
            let fileDownloadTaskReference = FileDownloadTaskReference( fileRefId : fileRefId) { ( taskDetails, taskFinished, error ) in
                if let error = error
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( error ) for \( fileRefId )" )
                    self.fileDownloadDelegate?.didFail( fileRefId : fileRefId, with : typeCastToZCatalystError( error ) )
                    return
                }
                else if let taskFinished = taskFinished
                {
                    downloadTasksQueue.async {
                        FileTasks.liveDownloadTasks?.removeValue(forKey: fileRefId)
                    }
                    if let url = taskFinished.location
                    {
                        do
                        {
                            let data = try Data( contentsOf : url )
                            self.fileDownloadDelegate?.didFinish( fileRefId : fileRefId, fileResult : ( data, url ) )
                        }
                        catch
                        {
                            ZCatalystLogger.logError( message : "Error Occurred : \( error ) for \( fileRefId )" )
                            self.fileDownloadDelegate?.didFail( fileRefId : fileRefId, with : typeCastToZCatalystError( error ) )
                        }
                    }
                    else
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil for \( fileRefId ), Details : -" )
                        self.fileDownloadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
                        return
                    }
                }
                else if let taskDetails = taskDetails
                {
                    self.fileDownloadDelegate?.progress( fileRefId : fileRefId, session: taskDetails.session, downloadTask: taskDetails.task, progressPercentage: taskDetails.progress, totalBytesWritten: taskDetails.totalBytesWritten, totalBytesExpectedToWrite: taskDetails.totalBytesExpectedToWrite )
                }
            }
            
            let downloadTask = Router.fileDownloadURLSessionWithDelegates.downloadTask( with : request )
            Router.fileAPIRequestDelegate.downloadTaskWithFileRefIdDict.updateValue( fileDownloadTaskReference, forKey: downloadTask)
            downloadTasksQueue.async {
                if FileTasks.liveDownloadTasks == nil
                {
                    FileTasks.liveDownloadTasks = [ String : URLSessionDownloadTask ]()
                }
                FileTasks.liveDownloadTasks?.updateValue(downloadTask, forKey: fileRefId)
            }
            downloadTask.resume()
        }) { (error) in
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil for \( fileRefId ), Details : -" )
            self.fileDownloadDelegate?.didFail( fileRefId : fileRefId, with : ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) )
        }
    }
    
    func download( _ route : APIEndPointConvertable, completion : @escaping ( Result< URL, ZCatalystError > ) -> Void )
    {
        let requestBuilder = URLRequestBuilder()
        requestBuilder.buildRequest( from : route, success : { ( urlRequest ) in
            guard let request = urlRequest else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.unableToConstructURL ) : Unable to construct URL request, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.unableToConstructURL, message : "Unable to construct URL request", details : nil ) ) )
                return
            }
            ZCatalystLogger.logDebug( message : "Request : \( request.toString() )" )
            
            let urlsession = URLSession( configuration : .default )
            urlsession.downloadTask( with : request) { ( url, response, error ) in
                if let url = url
                {
                    completion( .success( url ) )
                }
                else
                {
                    if let error = error
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                        completion(Result.error(typeCastToZCatalystError( error )))
                    }
                    else
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
                        completion( .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) ) )
                    }
                }
            }.resume()
        }) { (error) in
            if let error = error
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                completion(Result.error(typeCastToZCatalystError( error )))
            }
            else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.responseNil ) : Response nil, Details : -" )
                completion( .error( ZCatalystError.processingError( code : ErrorCode.responseNil, message : "Response nil", details : nil ) ) )
            }
        }
    }
    
    private func getTempFileURL( fileData : Data, fileName : String ) -> URL
    {
        let tempFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\( fileName )")
        try? fileData.write(to: tempFileURL)
        return tempFileURL
    }
    
    private func removeTempFile( atURL tempFileURL : URL)
    {
        try? FileManager.default.removeItem(at: tempFileURL)
    }

    static private func sessionConfiguration(for type: URLSessionConfigurationType) -> URLSessionConfiguration {
        let configuration: URLSessionConfiguration
        switch type {
        case .download:
            configuration = URLSessionConfiguration.background(withIdentifier: "Download")
            configuration.allowsCellularAccess = true
            configuration.isDiscretionary = true
            configuration.sessionSendsLaunchEvents = true
            if #available(iOS 11.0, *) {
                configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
        case .upload:
            configuration = URLSessionConfiguration.default
            configuration.allowsCellularAccess = true
            if #available(iOS 11.0, *) {
                configuration.waitsForConnectivity = true
            } else {
                // Fallback on earlier versions
            }
        }
        return configuration
    }
    
    static private func session(for type: URLSessionConfigurationType, delegate: URLSessionTaskDelegate?) -> URLSession {
        let session: URLSession
        switch type {
        case .download:
            let configuration = self.sessionConfiguration(for: .download)
            session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        case .upload:
            let configuration = self.sessionConfiguration(for: .upload)
            session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        }
        return session
    }
}
