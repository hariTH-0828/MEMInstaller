//
//  ZIAMToken.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 15/12/17.
//

#import <Foundation/Foundation.h>

@interface ZIAMToken : NSObject
/**
 Access Token
 */
@property(nonatomic, readonly) NSString *accessToken;


/**
 Expiry Millis
 */
@property(nonatomic, readonly) int expiryMillis;

/**
 Error Object
 */
@property(nonatomic, readonly) NSError *error;
@end
