//
//  AboutView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            GeometryReader(content: { geometry in
                VStack {
                    Image(uiImage: UIImage.getCurrentAppIcon())
                        .resizable()
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(.buttonBorder)
                    
                    Text("com.learn.meminstaller.loginview.appName")
                        .font(.system(size: 20).bold())
                        .padding(.vertical, 8)
                    
                    Text("Version \(Bundle.appVersion ?? "1.0")")
                        .font(.system(size: 14.0))
                        .foregroundStyle(Color(uiColor: .lightGray))
                    
                    Text("com.learn.meminstaller.setting.about.description")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14.0))
                        .frame(width: geometry.size.width * 0.8)
                        .padding(.vertical)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.vertical)
            })
        }
    }
}

#Preview {
    AboutView()
}
