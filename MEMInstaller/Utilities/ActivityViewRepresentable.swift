//
//  ActivityViewRepresentable.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 04/11/24.
//

import SwiftUI

struct ActivityViewRepresentable: UIViewControllerRepresentable {
    // Items to be shared
    var activityItems: [URL]
    // Custom app-specific activities
    var applicationActivities: [UIActivity]? = nil
    // Optional: Exclude specific activity types
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    // Completion handler to pass results to the root view
    var completion: (Bool, Error?) -> Void
    
    // Coordinator class to handle any delegates or custom logic
    class Coordinator: NSObject {
        var parent: ActivityViewRepresentable
        
        init(parent: ActivityViewRepresentable) {
            self.parent = parent
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, didFinishWith activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) {
            
            parent.completion(completed, activityError)
        }
    }
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        // Set the excluded activity types if provided
        if let excluded = excludedActivityTypes {
            activityVC.excludedActivityTypes = excluded
        }
        
        activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            context.coordinator.activityViewController(activityVC,
                                                       didFinishWith: activityType,
                                                       completed: completed,
                                                       returnedItems: returnedItems,
                                                       activityError: error)
        }
        
        return activityVC
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update logic needed here as UIActivityViewController is usually a one-time action
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
}

