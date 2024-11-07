//
//  NetworkErrors.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

enum NetworkErrors : String, Error {
    case noParameters = "Parameters not found"
    case encodingFailed = "Parameters encoding failed"
    case missingURL = "URL is not specified"
}
