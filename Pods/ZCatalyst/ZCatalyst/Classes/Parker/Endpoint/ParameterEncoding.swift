//
//  ParameterEncoding.swift
//  NetworkLayer
//
//  Created by Rizwan Ahmed A.
//  Copyright © 2018 Rizwan Ahmed A. All rights reserved.
//

import Foundation

typealias Parameters  = [String : Any]

protocol ParameterEncoder {
    
    static func encode(urlRequest : inout URLRequest, jsonBody body : Data?,withParameters parameters : Parameters) throws
    

}


