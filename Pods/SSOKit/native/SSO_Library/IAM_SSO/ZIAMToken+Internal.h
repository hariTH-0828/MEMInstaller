//
//  ZIAMToken+Internal.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 15/12/17.
//

#ifndef ZIAMToken_Internal_h
#define ZIAMToken_Internal_h
@interface ZIAMToken() {
    
}
// accesstoken.
@property(nonatomic, readwrite) NSString *accessToken;

// millis.
@property(nonatomic, readwrite) int expiryMillis;

// error.
@property(nonatomic, readwrite) NSError *error;

-(void)initWithToken:(NSString*)token expiry:(int)millis error:(NSError *)err;

- (id)initWithCoder:(NSCoder *)coder;

@end

#endif /* ZIAMToken_Internal_h */
