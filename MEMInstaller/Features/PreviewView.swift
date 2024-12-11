//
//  PreviewView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 10/12/24.
//

import SwiftUI

struct PreviewView: View {
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                ContentUnavailableView(label: {
                    Label(
                        title: {
                            Text("com.learn.meminstaller.home.no-file-title")
                        },
                        icon: {
                           Image("no-file-found")
                                .resizable()
                                .scaledToFit()
                                .frame(width: min(geometry.size.width * 0.7, 500), height: 500)
                        }
                    )
                }, description: {
                    Text("com.learn.meminstaller.home.no-file-description")
                })
                
                HStack(spacing: 20) {
                    Button {
                        
                    } label: {
                        Text("com.learn.meminstaller.home.btn_upload")
                            .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                    }
                    
                    Button {
                        
                    } label: {
                        Text("com.learn.meminstaller.home.refresh")
                            .defaultButtonStyle(width: min(geometry.size.width * 0.4, 300))
                    }
                }
                .padding(.bottom, 30)
            }
        })
    }
}

#Preview {
    PreviewView()
}
