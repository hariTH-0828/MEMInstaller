//
//  ZUser.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZSSOUser.h"
#include "ZSSOUser+Internal.h"
#include "ZSSOProfileData.h"
#include "ZSSOProfileData+Internal.h"

@implementation ZSSOUser
@synthesize userZUID,profile,accountsUrl,accessibleScopes,location;

-(void)initWithZUID:(NSString*)zuid Profile:(ZSSOProfileData *)profiledata accessibleScopes:(NSArray*)scopeArray accountsUrl:(NSString *)accountsserver location:(NSString *)dcllocation{
    userZUID = zuid;
    profile = profiledata;
    accessibleScopes = scopeArray;
    accountsUrl = accountsserver;
    location = dcllocation;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.userZUID forKey:@"zuid"];
    [coder encodeConditionalObject:self.profile    forKey:@"profile"];
    [coder encodeObject:self.accessibleScopes forKey:@"scopes"];
    [coder encodeObject:self.accountsUrl   forKey:@"accountsurl"];
    [coder encodeObject:self.location   forKey:@"location"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
    self.userZUID = [coder decodeObjectForKey:@"zuid"];
    self.accessibleScopes = [coder decodeObjectForKey:@"scopes"];
    ZSSOProfileData *profileData = [coder decodeObjectForKey:@"profile"];
    self.profile   = [[ZSSOProfileData alloc] initWithProfileObject:profileData];
    self.accountsUrl = [coder decodeObjectForKey:@"accountsurl"];
    self.location = [coder decodeObjectForKey:@"location"];
    }
    
    return self;
}

@end
