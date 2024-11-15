//
//  BucketListView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 15/11/24.
//

import SwiftUI

struct BucketListView: View {
    @EnvironmentObject var appCoordinator: AppCoordinatorImpl
    
    let bucket: BucketModel
    
    init(bucket: BucketModel) {
        self.bucket = bucket
    }
    
    var body: some View {
        HStack {
            Label(
                title: {
                    Text(bucket.bucketName.capitalized)
                        .font(.system(size: 16, weight: .regular))
                },
                icon: {
                    Image("bucket")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            )
            
            Spacer()
            
            Button(action: {
                // Handle bucket info
            }, label: {
                Image(systemName: "i.circle")
                    .foregroundStyle(StyleManager.colorStyle.contentBackground)
                    .font(.system(size: 14))
            })
        }
    }
}
