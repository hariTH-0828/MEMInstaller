//
//  FileImporterView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 20/12/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileImporterView: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let startingDirectoryURL: URL?
    let onFilePicked: (URL?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFilePicked: onFilePicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        
        // Set the initial directory if available
        if let startingURL = startingDirectoryURL {
            picker.directoryURL = startingURL
        }
        
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onFilePicked: (URL?) -> Void

        init(onFilePicked: @escaping (URL?) -> Void) {
            self.onFilePicked = onFilePicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onFilePicked(urls.first)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onFilePicked(nil)
        }
    }
}
