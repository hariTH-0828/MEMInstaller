//
//  FileAPIManager.swift
//  Catalyst
//
//  Created by Umashri R on 07/10/20.
//

import Foundation

public protocol ZCatalystFileDownloadDelegate
{
    func progress( fileRefId : String, session: URLSession, downloadTask: URLSessionDownloadTask, progressPercentage : Double, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 )
    
    func didFinish( fileRefId : String, fileResult : ( Data, URL ) )
    
    func didFail( fileRefId : String, with error : ZCatalystError? )
}

public protocol ZCatalystFileUploadDelegate
{
    func progress( fileRefId : String, session : URLSession, sessionTask : URLSessionTask, progressPercentage : Double, totalBytesSent : Int64, totalBytesExpectedToSend : Int64 )
    
    func didFinish( fileRefId : String, fileDetails : ZCatalystFile )
    
    func didFail( fileRefId : String, with error : ZCatalystError? )

}


/**
    To cancel a specific upload task which is in progress.
 
    - Parameters:
        - id : Reference ID (fileRefId) of the upload task which has to be cancelled.
        - completion : Returns an APIResponse with success message if the task has been cancelled or, an error message if the cancellation failed.
 */

public func cancelUploadTask(withRefId id : String, completion : @escaping ( ZCatalystError? ) -> () )
{
    uploadTasksQueue.async
    {
        guard let fileUploadTasks = FileTasks.liveUploadTasks, !fileUploadTasks.isEmpty else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.processingError ) : There are no upload tasks in progress, Details : -" )
            completion( .processingError(code: ErrorCode.processingError, message: "There are no upload tasks in progress", details: nil))
            return
        }
        guard let task = fileUploadTasks[ id ] else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.processingError ) : There are no upload tasks in progress with refId - \( id ), Details : -" )
            completion( .processingError(code: ErrorCode.processingError, message: "There is no upload task in progress with refId - \( id ).", details: nil))
            return
        }
        if task.state != URLSessionTask.State.completed {
            task.cancel()
        }
        completion( nil )
        FileTasks.liveUploadTasks?.removeValue(forKey: id)
    }
}

/**
    To cancel a specific download task which is in progress
 
    - Parameters:
        - id : ID of the particular download task which has to be cancelled.
        - completion : Returns the APIResponse with success message if the upload has been cancelled or, an error message if the cancellation failed

         ID of the download task differs according to the type of action performed. The different types of ID are,

         * Attachment ID - Entity download attachments
         * Attachment ID - Entity notes attachment download
         * Note ID - Voice note
         * User ID - User photo download
         * Record ID - Record photo download
         * Image ID - Email inline image attachment
         * Attachment ID ( or ) File Name ( or ) Message ID ( For cancelling all the attachments download in mail ) - Email attachment
         * Component ID - DashboardComponent
 */

public func cancelDownloadTask(withId id : String, completion : @escaping ( ZCatalystError? ) -> () )
{
    downloadTasksQueue.async {
        guard let fileDownloadTasks = FileTasks.liveDownloadTasks, !fileDownloadTasks.isEmpty else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.processingError ) : There are no download tasks in progress, Details : -" )
            completion( .processingError(code: ErrorCode.processingError, message: "There are no download tasks in progress.", details: nil))
            return
        }
        
        guard let task = fileDownloadTasks[ id ] else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.processingError ) : There are no download tasks in progress with refId - \( id ), Details : -" )
            completion( .processingError(code: ErrorCode.processingError, message: "There is no download task in progress with refId - \( id ).", details: nil))
            return
        }
        if task.state != URLSessionDownloadTask.State.completed
        {
            task.cancel()
        }
        completion( nil )
        FileTasks.liveDownloadTasks?.removeValue(forKey: id)
    }
}

