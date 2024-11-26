//
//  ZSMultiThreading.swift
//  ZohoSignSDK
//
//  Created by somesh-8758 on 09/10/19.
//  Copyright © 2019 Zoho Corporation. All rights reserved.
//

import Foundation

public typealias DispathQueueCompletionBlock = () -> Void

public func mainQueue(_ completion: @escaping DispathQueueCompletionBlock) {
    DispatchQueue.main.async {
        completion()
    }
}

public func globalQueue(_ completion: @escaping DispathQueueCompletionBlock) {
    DispatchQueue.global().async {
        completion()
    }
}

public func globalUserInitiatedQueue(_ completion: @escaping DispathQueueCompletionBlock) {
    DispatchQueue.global(qos: .userInitiated).async {
        mainQueue{
            completion()
        }
    }
}

public func globalBackgroundQueue(_ completion: @escaping DispathQueueCompletionBlock) {
    DispatchQueue.global(qos: .background).async {
        mainQueue{
            completion()
        }
    }
}
