//
//  Parker.swift
//  NetworkLayer
//
//  Created by Giridhar on 10/05/19.
//  Copyright © 2019 Rizwan Ahmed A. All rights reserved.
//

import Foundation

internal protocol NetworkRequestable
{
    @discardableResult
    func request(_ route: APIEndPointConvertable, session:URLSession, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> URLSessionTask?
    
    func requestWithID(_ route: APIEndPointConvertable, session:URLSession, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> String
    
    func cancelRequest(id: String)
    
    func upload( fileRefId : String, filePath : URL?, fileName : String?, fileData : Data?, url : APIEndPointConvertable, fileUploadDelegate : ZCatalystFileUploadDelegate )
    
    func upload( filePath : URL?, fileName : String?, fileData : Data?, url : APIEndPointConvertable, completion: @escaping (Result<Data,ZCatalystError>) -> Void )
    
    func download( url : APIEndPointConvertable, completion : @escaping ( Result< URL, ZCatalystError > ) -> Void )
    
    func download( url : APIEndPointConvertable, fileRefId : String, fileDownloadDelegate : ZCatalystFileDownloadDelegate )
}

struct Parker: NetworkRequestable
{
 
    
    let router: Router
    init()
    {
        router = Router()
    }
    
    @discardableResult
    func requestWithID(_ route: APIEndPointConvertable, session:URLSession, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> String
    {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = ZCatalystApp.shared.appConfig.requestTimeOut
        let session = URLSession( configuration : configuration )
        return router.request(route, session: session, completion: completion)
    }
    
    func cancelRequest(id: String)
    {
        let task:URLSessionTask? = router.tasks[id]
        guard let aTask = task else
        {
            print("No task found")
            return
        }
        aTask.cancel()
        print("Cancelled")
    }
    
    
    @discardableResult
    func request(_ route: APIEndPointConvertable, session: URLSession = URLSession.shared, completion: @escaping (Result<Data, ZCatalystError>) -> Void) -> URLSessionTask? {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = ZCatalystApp.shared.appConfig.requestTimeOut
        let session = URLSession( configuration : configuration )
        return Router.request(route, session: session, completion: completion)
    }
    
    func upload( fileRefId : String, filePath : URL?, fileName : String?, fileData : Data?, url : APIEndPointConvertable, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        router.upload(url, fileRefId : fileRefId, filePath : filePath, fileName : fileName, fileData : fileData, fileUploadDelegate : fileUploadDelegate)
    }
    
    func upload( filePath : URL?, fileName : String?, fileData : Data?, url : APIEndPointConvertable, completion : @escaping ( Result< Data, ZCatalystError > ) -> Void )
    {
        router.upload( url, filePath : filePath, fileName : fileName, fileData : fileData) { ( result ) in
            completion( result )
        }
    }
    
    func download( url : APIEndPointConvertable, completion : @escaping ( Result< URL, ZCatalystError > ) -> Void )
    {
        router.download( url) { ( result ) in
            completion( result )
        }
    }
    
    func download( url : APIEndPointConvertable, fileRefId : String, fileDownloadDelegate : ZCatalystFileDownloadDelegate )
    {
        router.download( url, fileRefId : fileRefId, fileDownloadDelegate : fileDownloadDelegate )
    }
}
