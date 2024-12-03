//
//  UserProfileImageView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 27/11/24.
//

import SwiftUI

struct UserProfileImageView: View {
    let userProfile: ZUserProfile
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                Image(uiImage: UIImage(data: userProfile.profileImageData)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(userProfile.displayName)
                        .foregroundStyle(StyleManager.colorStyle.invertBackground)
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(userProfile.email)
                        .lineLimit(1)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(StyleManager.colorStyle.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppCoordinatorImpl())
}
