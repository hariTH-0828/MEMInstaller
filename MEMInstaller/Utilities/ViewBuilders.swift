//
//  ViewBuilders.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

@ViewBuilder
func textViewForIdleState(_ message: String) -> some View {
    Text(message)
        .font(.footnote)
        .foregroundStyle(StyleManager.colorStyle.systemGray)
}
