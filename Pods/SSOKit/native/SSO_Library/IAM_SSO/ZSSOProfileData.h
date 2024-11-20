//
//  ZSSOProfileData.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 26/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 This class represents the basic profile information of a ZSSOUser.
 */
@interface ZSSOProfileData : NSObject <NSCoding>


/**
 The Zoho user's email.
 */
@property(nonatomic, readonly) NSString *email;


/**
 The Zoho user's full name.
 */
@property(nonatomic, readonly) NSString *name;


/**
 The Zoho user's display name.
 */
@property(nonatomic, readonly) NSString *displayName;


/**
 Whether the user has a profile image or not.
 */
@property(nonatomic, readonly) BOOL hasImage;


/**
 The Zoho user's profile image data.
 */
@property(nonatomic, readonly) NSData * profileImageData;

//To-do Add other profile information required here.

@end
