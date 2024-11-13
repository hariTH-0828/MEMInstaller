//
//  ZSSOUser+Internal.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#ifndef ZSSOUser_Internal_h
#define ZSSOUser_Internal_h

@interface ZSSOUser() {
    
}
// Zoho user ID(ZUID).
@property(nonatomic, readwrite) NSString *userZUID;

// Representation of the Basic profile data. It is only available if |SignIn| has been completed successfully.
@property(nonatomic, readwrite) ZSSOProfileData *profile;

// The API scopes requested by the app in an array of |NSString|s.
@property(nonatomic, readwrite) NSArray *accessibleScopes;

// Zoho accounts url of the user.
@property(nonatomic, readwrite) NSString *accountsUrl;

// Zoho location of the user.
@property(nonatomic, readwrite) NSString *location;

-(void)initWithZUID:(NSString*)zuid Profile:(ZSSOProfileData *)profiledata accessibleScopes:(NSArray*)scopeArray accountsUrl:(NSString *)accountsserver location:(NSString *)dcllocation;
- (id)initWithCoder:(NSCoder *)coder;

@end

#endif /* ZSSOUser_Internal_h */
