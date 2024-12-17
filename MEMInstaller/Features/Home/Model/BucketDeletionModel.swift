//
//  BucketDeletionModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 16/12/24.
//

import Foundation

struct BucketDeletionModel: Codable {
    let path: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case path = "path"
        case message = "message"
    }
}
