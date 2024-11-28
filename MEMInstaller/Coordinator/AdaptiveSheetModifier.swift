//
//  AdaptiveSheetModifier.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 28/11/24.
//

import SwiftUI

struct AdaptiveSheetModifier: ViewModifier {
    @ObservedObject var coordinator: AppCoordinatorImpl
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(
                get: { coordinator.sheet != nil && !(coordinator.isPopover)},
                set: { if !$0 { coordinator.dismissSheet() } }
            )) {
                if let sheet = coordinator.sheet {
                    coordinator.build(forSheet: sheet)
                }
            }
            .popover(isPresented: Binding(
               get: { coordinator.sheet != nil && coordinator.isPopover },
               set: { if !$0 { coordinator.dismissSheet() } }
           )) {
               if let sheet = coordinator.sheet {
                   coordinator.build(forSheet: sheet)
               }
           }
    }
}

extension View {
    
    func adaptiveSheet(coordinator: AppCoordinatorImpl) -> some View {
        modifier(AdaptiveSheetModifier(coordinator: coordinator))
    }
}
