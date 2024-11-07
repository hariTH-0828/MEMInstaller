//
//  UIImage+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 06/11/24.
//

import UIKit

extension UIImage {
    static func getCurrentAppIcon() -> UIImage {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last,
              let icon = UIImage(named: lastIcon) else {
            return UIImage()
        }
        return icon
    }
}
