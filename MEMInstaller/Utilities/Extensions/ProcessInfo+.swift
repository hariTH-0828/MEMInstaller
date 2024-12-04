//
//  ProcessInfo+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 04/12/24.
//

import Foundation

extension ProcessInfo {
    var isPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
