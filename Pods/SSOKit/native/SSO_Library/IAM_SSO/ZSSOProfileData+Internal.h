//
//  ZSSOProfileData+Internal.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#ifndef ZSSOProfileData_Internal_h
#define ZSSOProfileData_Internal_h

@interface ZSSOProfileData(){
    
}
// The Zoho user's email.
@property(nonatomic, readwrite) NSString *email;

// The Zoho user's full name.
@property(nonatomic, readwrite) NSString *name;

// The Zoho user's display name.
@property(nonatomic, readwrite) NSString *displayName;

// Whether or not the user has profile image.
@property(nonatomic, readwrite) BOOL hasImage;

// The Zoho user's profile image data.
@property(nonatomic, readwrite) NSData * profileImageData;

-(void)initWithEmailid:(NSString *)emailid name:(NSString *)username displayName:(NSString *)userDisplayName hasImage:(BOOL)isHavingPhoto profileImageData:(NSData *)photoData;
-(ZSSOProfileData *)initWithProfileObject:(ZSSOProfileData *)profileObject;

@end
#endif /* ZSSOProfileData_Internal_h */
