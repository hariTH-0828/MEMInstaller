//
//  ZUser.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZSSOProfileData;


/**
 This class represents a user account.
 */
@interface ZSSOUser : NSObject <NSCoding>



/**
 The ZUID of the User.
 */
@property(nonatomic, readonly) NSString *userZUID;


/**
 Representation of the Basic profile data. It is only available if |SignIn| has been completed successfully.
 */
@property(nonatomic, readonly) ZSSOProfileData *profile;


/**
 The API scopes requested by the app in an array of |NSString|s.
 */
@property(nonatomic, readonly) NSArray *accessibleScopes;


/**
 Zoho accounts URL of the user.
 */
@property(nonatomic, readonly) NSString *accountsUrl;


/**
 DCL information of the user.
 */
@property(nonatomic, readonly) NSString *location;

//To-do Store other User Related information here...

@end
