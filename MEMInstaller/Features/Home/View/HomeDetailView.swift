//
//  HomeDetailView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 02/12/24.
//

import SwiftUI

struct HomeDetailView: View {
    @EnvironmentObject private var viewModel: HomeViewModel
    
    var body: some View {
        switch viewModel.detailViewLoadingState {
        case .idle(let idleState):
            handleIdleState(idleState)
        case .error(let errorState):
            handleErrorState(errorState)
        case .loading:
            HorizontalLoadingWrapper()
        case .uploading(let loadingMessage):
            HorizontalLoadingWrapper(title: loadingMessage, value: viewModel.uploadProgress)
        }
    }
    
    @ViewBuilder
    private func handleIdleState(_ idleState: IdleViewState) -> some View {
        switch idleState {
        case .available:
            textViewForIdleState("select a app to view details")
        case .empty:
            EmptyBucketView()
        case .detail(let attachmentMode):
//            AttachedFileDetailView(bucketObjectModel: <#T##BucketObjectModel#>, attachmentMode: <#T##AttachmentMode#>)
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func handleErrorState(_ errorState: ErrorViewState) -> some View {
        switch errorState {
        case .empty:
            EmptyBucketView()
        case .detailError:
            Text("Detail Error")
        }
    }
    
    private func shouldShowNoAppsAvailableView() -> Bool {
        viewModel.detailViewLoadingState != .loading && viewModel.bucketObjectModels.isEmpty
    }
}

#Preview {
    HomeDetailView()
}
