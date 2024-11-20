//
//  UIViewController+.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI
import UIKit

extension UIViewController {
    /// A SwiftUI view that wraps a `UIViewController` for previewing purposes.
    struct Preview: UIViewControllerRepresentable {
        let viewController: UIViewController
        
        /// Initializes the preview with a builder function that creates the `UIViewController` instance.
        ///  ```swift
        ///     struct MakeViewController_Preview: PreviewProvider {
        ///         static var previews: some View {
        ///             MakeViewController()
        ///                 .toPreview()
        ///                 .background(ignoresSafeAreaEdges: .all)
        ///         }
        ///     }
        ///  ```
        /// - Parameter builder: A closure that returns a `UIViewController` instance.
        init(_ builder: @escaping () -> UIViewController) {
            self.viewController = builder()
        }
        
        // Creates the `UIViewController` instance for the SwiftUI preview.
        func makeUIViewController(context: Context) -> some UIViewController {
            viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    }
    
    /// Converts the current `UIViewController` instance to a SwiftUI preview.
    ///
    /// - Returns: A SwiftUI `View` that wraps the current `UIViewController` instance for previewing.
    func toPreview() -> some View {
        Preview { self }
    }
}


class MakeViewController: UIViewController {
    
}
