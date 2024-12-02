//
//  HomeDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        Group {
            switch viewModel.detailViewLoadingState {
            case .idle(let idleState):
                handleIdleState(idleState)
            case .error(let errorState):
                handleErrorState(errorState)
            case .loading:
                OverlayLoaderView()
            case .uploading(let loadingMessage):
                OverlayLoaderView(title: loadingMessage)
            }
        }
    }
    
    @ViewBuilder
    private func handleIdleState(_ idleState: IdleViewState) -> some View {
        switch idleState {
        case .empty:
            textViewForIdleState("select a app to view details")
        case .detail(let attachmentMode):
            AttachedFileDetailView(viewModel: viewModel, attachmentMode: attachmentMode)
        }
    }
    
    @ViewBuilder
    private func handleErrorState(_ errorState: ErrorViewState) -> some View {
        switch errorState {
        case .empty:
            EmptyBucketView(viewModel: viewModel)
        case .detailError:
            Text("Detail Error")
        }
    }
}

#Preview {
    HomeDetailView(viewModel: .preview)
}
