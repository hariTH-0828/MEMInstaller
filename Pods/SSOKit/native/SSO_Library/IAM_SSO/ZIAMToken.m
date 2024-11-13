//
//  ZIAMToken.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 15/12/17.
//

#import "ZIAMToken.h"
#import "ZIAMToken+Internal.h"

@implementation ZIAMToken
@synthesize accessToken,expiryMillis,error;
-(void)initWithToken:(NSString*)token expiry:(int)millis error:(NSError *)err{
    accessToken = token;
    expiryMillis = millis;
    error = err;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.accessToken forKey:@"token"];
    [coder encodeInt:self.expiryMillis forKey:@"millis"];
    [coder encodeObject:self.error   forKey:@"error"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.accessToken = [coder decodeObjectForKey:@"token"];
        self.expiryMillis = [coder decodeIntForKey:@"millis"];
        self.error = [coder decodeObjectForKey:@"error"];
    }
    
    return self;
}
@end
