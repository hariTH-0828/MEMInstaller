//
//  StateManagementEnums.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import Foundation

// MARK: - State Management
enum LoadingState: Hashable {
    case idle(IdleViewState = .available)
    case loading
    case loaded
    case uploading(String)
    case error(ErrorViewState = .empty)
}

enum IdleViewState: Hashable {
    case empty
    case available
    case detail
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
