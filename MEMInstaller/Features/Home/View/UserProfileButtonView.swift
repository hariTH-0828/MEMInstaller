//
//  UserProfileButtonView.swift
//  MEMInstaller
//
//  Created by Hariharan R S on 29/11/24.
//

import SwiftUI

struct UserProfileButtonView: View {
    @EnvironmentObject var coordinator: AppCoordinatorImpl
    
    private var uiImage: Data {
        if let profileImageData = UserDataManager().retrieveLoggedUserFromKeychain() {
            return profileImageData.profileImageData
        }
        
        return UserDataManager().retrieveLoggedUserFromKeychain()?.profileImageData ?? imageWith(name: "unknown")!.pngData()!
    }
    
    var body: some View {
        ZStack {
            Button {
                coordinator.push(.settings)
            } label: {
                Image(uiImage: UIImage(data: uiImage)!)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    UserProfileButtonView()
}
