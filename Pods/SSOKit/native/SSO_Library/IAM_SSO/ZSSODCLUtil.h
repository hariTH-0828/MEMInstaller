//
//  ZSSODCLUtil.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZIAMUtil.h"

@interface ZIAMUtil(ZSSODCLUtil)
-(NSString *)getTransformedURLStringForURL:(NSString *)url;
-(NSString *)getTransformedURLStringForURL:(NSString *)url forZuid:(NSString *)zuid;
-(NSString *)transformURL:(NSString *)url AppName:(NSString *)appName forZuid:(NSString *)zuid;
-(NSDictionary *)getDCLInfoForCurrentUser;
-(NSDictionary *)getDCLInfoForZuid:(NSString *)zuid;
-(NSString *)transformURL:(NSString *)url ZUID:(NSString *)zuid Location:(NSString *)dclLocation;
@end
