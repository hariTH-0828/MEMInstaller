//
//  SSOLogger.h
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 21/12/17.
//

#import <Foundation/Foundation.h>

@interface SSOLogger : NSObject
+(void)log:(int)line method:(const char *)method string:(NSString*)string;
@end
