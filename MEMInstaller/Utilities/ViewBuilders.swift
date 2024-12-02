//
//  ViewBuilders.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

@ViewBuilder
func textViewForIdleState(_ message: String) -> Text {
    Text(message)
        .font(.footnote)
        .foregroundStyle(StyleManager.colorStyle.systemGray)
}
