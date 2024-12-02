//
//  StateManagementEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import Foundation

// MARK: - State Management
enum LoadingState: Hashable {
    case idle(IdleViewState = .empty)
    case loading
    case uploading(String)
    case error(ErrorViewState = .empty)
}

enum IdleViewState: Hashable {
    case empty
    case detail(AttachmentMode = .install)
}

enum ErrorViewState: Hashable {
    case empty
    case detailError
}

// MARK: - View Type
enum ViewType {
    case sidebar
    case detail
}
