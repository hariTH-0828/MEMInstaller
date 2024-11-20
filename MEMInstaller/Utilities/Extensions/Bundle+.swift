//
//  Bundle+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 20/11/24.
//

import Foundation

extension Bundle {
    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
