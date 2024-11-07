//
//  UTType+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import UniformTypeIdentifiers

extension UTType {
    static var ipa: UTType {
        let bundleIdentifier = Bundle.main.bundleIdentifier
        return UTType(bundleIdentifier!) ?? UTType(filenameExtension: "ipa")!
    }
}
