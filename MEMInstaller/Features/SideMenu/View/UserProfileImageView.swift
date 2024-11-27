//
//  UserProfileImageView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 20/11/24.
//

import SwiftUI

struct UserProfileImageView: View {
    var manager: UserDataManager
    let geometry: GeometryProxy
    
    var body: some View {
        VStack {
            if let userprofile = manager.userProfile {
                let uiImage = UIImage(data: userprofile.profileImageData)
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                
                Text(userprofile.displayName)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .bold))
                
                Text(userprofile.email)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: geometry.size.height * 0.2)
        .padding(.top, 60)
        .background(
            Rectangle()
                .fill(StyleManager.colorStyle.tintColor)
        )
    }
}
