//
//  BucketModel.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 14/11/24.
//

import Foundation

struct BucketModel: Codable {
    let bucketName: String
    let projectDetails: ProjectDetail
    let createdBy: CreatedBy
    let createdTime: String
    let bucketURL: String
    
    enum CodingKeys: String, CodingKey {
        case bucketName = "bucket_name"
        case projectDetails = "project_details"
        case createdBy = "created_by"
        case createdTime = "created_time"
        case bucketURL = "bucket_url"
    }
}

struct ProjectDetail: Codable {
    let projectName: String
    let id: Decimal
    
    enum CodingKeys: String, CodingKey {
        case projectName = "project_name"
        case id = "id"
    }
}

struct CreatedBy: Codable {
    let firstName: String
    let lastName: String
    let emailId: String
    let userType: String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case emailId = "email_id"
        case userType = "user_type"
    }
}
