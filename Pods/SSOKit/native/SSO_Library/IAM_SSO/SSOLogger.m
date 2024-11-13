//
//  SSOLogger.m
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 21/12/17.
//

#import "SSOLogger.h"
#import "ZIAMUtil.h"


@implementation SSOLogger
+(void)log:(int)line method:(const char *)method string:(NSString*)string {
    BOOL shouldLog = [[ZIAMUtil sharedUtil] shouldLog];
    if (shouldLog) {
        NSLog(@"SSOKitLogger %s,%d,%@",method,line,string);
    }
}

@end
