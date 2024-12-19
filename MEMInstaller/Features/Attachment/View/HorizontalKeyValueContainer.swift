//
//  HorizontalKeyValueContainer.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 26/11/24.
//

import SwiftUI

struct HorizontalKeyValueContainer<T>: View where T: View {
    let key: String
    let value: String?
    var customValueView: T
    
    init(key: String, value: String? = "No value exist") where T == EmptyView {
        self.key = key
        self.value = value
        self.customValueView = EmptyView()
    }
    
    init(key: String, @ViewBuilder content: () -> T) {
        self.key = key
        self.value = nil
        self.customValueView = content()
    }
    
    var body: some View {
        HStack {
            Text(key)
                .font(.system(.callout))
                .foregroundStyle(Color(uiColor: .secondaryLabel))
            
            Spacer()
            
            if let value {
                Text(value)
                    .font(.system(.callout))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }else {
                customValueView
            }
        }
        .frame(height: 22)
        .padding(.horizontal)
    }
}
