//
//  ZSSOProfileData.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZSSOProfileData.h"
#include "ZSSOProfileData+Internal.h"

@implementation ZSSOProfileData
@synthesize email,name,displayName,profileImageData,hasImage;

-(void)initWithEmailid:(NSString *)emailid name:(NSString *)username displayName:(NSString *)userDisplayName hasImage:(BOOL)isHavingPhoto profileImageData:(NSData *)photoData{
    email = emailid;
    name = username;
    displayName = userDisplayName;
    hasImage = isHavingPhoto;
    profileImageData = photoData;
}
-(ZSSOProfileData *)initWithProfileObject:(ZSSOProfileData *)profileObject{
    self.email = profileObject.email;
    self.name = profileObject.name;
    self.displayName = profileObject.displayName;
    self.hasImage = profileObject.hasImage;
    self.profileImageData = profileObject.profileImageData;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.email forKey:@"email"];
    [coder encodeObject:self.name    forKey:@"name"];
    [coder encodeObject:self.displayName forKey:@"displayname"];
    [coder encodeBool:self.hasImage   forKey:@"hasimage"];
    [coder encodeObject:self.profileImageData   forKey:@"profileimagedata"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    self.email = [coder decodeObjectForKey:@"email"];
    self.name = [coder decodeObjectForKey:@"name"];
    self.displayName   = [coder decodeObjectForKey:@"displayname"];
    self.hasImage = [coder decodeBoolForKey:@"hasimage"];
    self.profileImageData = [coder decodeObjectForKey:@"profileimagedata"];
    
    return self;
}

@end
