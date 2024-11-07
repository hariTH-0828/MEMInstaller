//
//  NetworkRouter.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

typealias NetworkRouterCompletionBlock = (_ data:Data?, _ response : URLResponse?, _ error : Error?) -> ()

typealias DownloadTaskFilePath    = (_ data : URLSession?, _ response : URLSessionDownloadTask?,_ urlPath : URL)->()
typealias DownloadCompletionBlock    = (_ error : Error?)->()
typealias DownloadProgressBlock          = (_ bytesWritten : Int64?,_ bytesToBeWritten : Int64?) -> ()

typealias UploadCompletionBlock = (_ session: URLSession?, _ uploadTask : URLSessionTask?, _ error : Error?)->()
typealias UploadProgressBlock       = (_ bytesWritten:Int?, _ bytesToBeWritten :Int?)->()
