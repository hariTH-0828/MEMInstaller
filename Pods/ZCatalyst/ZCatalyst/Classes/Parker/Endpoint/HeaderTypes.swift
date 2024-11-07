//
//  HeaderTypes.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

enum HeaderValueTypes : String {
    case applicationForm            = "application/x-www-form-urlencoded;"
    case utf8Charset                = "charset=utf-8;"
    case applicationJSON            = "application/json;"
    
}

enum HeaderKeyTypes : String{
    case contentType        = "Content-Type"
    case authorization      = "Authorization"
    case userAgent          = "User-Agent"

}
