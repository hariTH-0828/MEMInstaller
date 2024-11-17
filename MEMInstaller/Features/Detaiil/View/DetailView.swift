//
//  DetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 18/11/24.
//

import SwiftUI

struct DetailView: View {
    let content: [ContentModel]
    
    var body: some View {
        Text(content.first?.key ?? "No key found")
    }
}
//
//#Preview {
//    DetailView()
//}
