//
//  UserProfileButtonView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 29/11/24.
//

import SwiftUI

struct UserProfileButtonView: View {
    @EnvironmentObject private var coordinator: AppCoordinatorImpl
    
    private var uiImage: Data {
        if let profileImageData = UserDataManager().userProfile {
            return profileImageData.profileImageData
        }
        
        return UserDataManager().retrieveLoggedUserFromKeychain()!.profileImageData
    }
    
    var body: some View {
        ZStack {
            Button(action: {
                coordinator.presentSheet(.settings)
            }, label: {
                Image(uiImage: UIImage(data: uiImage)!)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            })
        }
    }
}

#Preview {
    UserProfileButtonView()
}
