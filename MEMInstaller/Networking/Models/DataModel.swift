//
//  DataModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation

struct DataModel<T: Codable>: Codable {
    var status: String
    var data: T
    
    init(status: String, data: T) {
        self.status = status
        self.data = data
    }
    
    enum CodingKeys: String, CodingKey {
        case status = "status"
        case data = "data"
    }
}
