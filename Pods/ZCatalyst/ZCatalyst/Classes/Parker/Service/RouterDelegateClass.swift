//
//  APICallLayer.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A on 20/07/18.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

internal class RouterDelegate : NSObject, URLSessionDataDelegate, URLSessionTaskDelegate, URLSessionDownloadDelegate
{
    
    var uploadTaskWithFileRefIdDict : [ URLSessionTask : FileUploadTaskReference ] = [ URLSessionTask : FileUploadTaskReference ]()
    var downloadTaskWithFileRefIdDict : [ URLSessionTask : FileDownloadTaskReference ] = [ URLSessionTask : FileDownloadTaskReference ]()
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didCompleteWithError error : Error? )
    {
         if let err = error
         {
             if let _ = task as? URLSessionDownloadTask
             {
                 if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ task ]
                 {
                    fileDownloadTaskReference.downloadClosure( nil, nil, typeCastToZCatalystError( err ) )
                 }
             }
             else if let _ = task as? URLSessionUploadTask
             {
                 if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ task ]
                 {
                    fileUploadTaskReference.uploadClosure( nil, nil, typeCastToZCatalystError( err ) )
                 }
             }
         }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ downloadTask ]
        {
            fileDownloadTaskReference.downloadClosure( nil, FileDownloadTaskFinished(downloadTask: downloadTask, location: location), nil)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        let progress : Double = Double ( ( totalBytesWritten / totalBytesExpectedToWrite ) * 100 )
        if let fileDownloadTaskReference = downloadTaskWithFileRefIdDict[ downloadTask ]
        {
            fileDownloadTaskReference.downloadClosure( FileDownloadTaskDetails(progress: progress, session: session, task: downloadTask, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite), nil, nil)
        }
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive response : URLResponse, completionHandler : @escaping ( URLSession.ResponseDisposition ) -> Void )
    {
        completionHandler( .allow )
    }
    
    func urlSession( _ session : URLSession, task : URLSessionTask, didSendBodyData bytesSent : Int64, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    {
        let progress : Double = Double ( ( Double( totalBytesSent ) / Double( totalBytesExpectedToSend ) ) * 100 )
        if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ task ]
        {
            fileUploadTaskReference.uploadClosure( FileUploadTaskDetails(progress: progress, session: session, task: task, bytesSent: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend), nil, nil )
        }
    }
    
    func urlSession( _ session : URLSession, dataTask : URLSessionDataTask, didReceive data : Data )
    {
        if let fileUploadTaskReference = uploadTaskWithFileRefIdDict[ dataTask ]
        {
            fileUploadTaskReference.uploadClosure( nil, FileUploadTaskFinished( dataTask: dataTask, data: data ), nil )
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        if let identifier = session.configuration.identifier, let completionHandler = ZCatalystApp.sessionCompletionHandlers[ identifier ]
        {
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
}

/**
   To hold the file reference id and a closure for passing the upload task details to the delegate

    The closure has three parameters which helps to specify the status of the upload. The three parameters are,
 
    1. FileUploadTaskDetails : Contains the progress details of the upload task
    2. FileUploadTaskFinished : Contains the data of the uploaded file
    3. Error : Error details
*/
internal struct FileUploadTaskReference
{
    var fileRefId : String
    var uploadClosure : ( FileUploadTaskDetails?, FileUploadTaskFinished?, Error? ) -> Void
}

internal struct FileUploadTaskDetails
{
    var progress : Double
    var session : URLSession
    var task : URLSessionTask
    var bytesSent : Int64
    var totalBytesSent : Int64
    var totalBytesExpectedToSend : Int64
}

internal struct FileUploadTaskFinished
{
    var dataTask : URLSessionDataTask?
    var data : Data?
}

/**
   To hold the file reference id and a closure for passing the download task details to the delegate

    The closure has three parameters which helps to specify the status of the download. The three parameters are,
 
    1. FileDownloadTaskDetails : Contains the progress details of the download task
    2. FileDownloadTaskFinished : Contains the location of the downloaded file
    3. Error : Error details
*/
internal struct FileDownloadTaskReference
{
    var fileRefId : String
    var downloadClosure : ( FileDownloadTaskDetails?, FileDownloadTaskFinished?, Error? ) -> Void
}

internal struct FileDownloadTaskDetails
{
    var progress : Double
    var session : URLSession
    var task : URLSessionDownloadTask
    var totalBytesWritten : Int64
    var totalBytesExpectedToWrite : Int64
}

internal struct FileDownloadTaskFinished
{
    var downloadTask : URLSessionDownloadTask?
    var location : URL?
}

internal struct FileTasks
{
    static var liveUploadTasks : [ String : URLSessionTask]?
    static var liveDownloadTasks : [ String : URLSessionDownloadTask ]?
}

internal var uploadTasksQueue = DispatchQueue(label: "com.zoho.cl.sdk.fileuploadtasks.queue" )
internal var downloadTasksQueue = DispatchQueue(label: "com.zoho.cl.sdk.filedownloadtasks.queue" )
