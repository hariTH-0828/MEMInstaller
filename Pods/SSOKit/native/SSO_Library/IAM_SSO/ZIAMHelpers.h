//
//  ZIAMHelpers.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZIAMUtil.h"

// The Managed app configuration dictionary pushed down from an MDM server are stored in this key.
static NSString * constkManagedMDMConfigurationKey = @"com.apple.configuration.managed";

static NSString * constkManagedMDMConfigurationLoginIDKey = @"login.email";
static NSString * constkManagedMDMConfigurationRestrictLoginKey = @"restrict.login";
static NSString * constkManagedMDMConfigurationRestrictLoginConditionalAccessKey = @"mdm_restrict_login";
//Default DC Vaules can be us,in,eu,au,cn
static NSString * constkManagedMDMConfigurationDefaultDCConditionalAccessKey = @"mdm_default_dc";

@interface ZIAMUtil(ZIAMHelpers)
-(void)initMode:(SSOBuildType)mode;
-(NSString *)getEncodedStringForString:(NSString *)str;
-(void)storeItemsInKeyChainOnSuccess;
-(NSString *) GetLocalizedString:(NSString*)key Comment: (NSString*) comment;
-(void)showNetworkActivityIndicator;
-(void)hideNetworkActivityIndicator;
-(int)getUsersCount;
-(NSArray*)getUserDetailsForZUID:(NSString *)ZUID forSSOAccount:(BOOL)sso;
-(BOOL)isHavingSSOAccount;
-(long long)getCurrentTimeMillis;
-(void)clearDataForLogoutHavingZUID:(NSString *)ZUID;
-(void) isOneAuthInstalled:(boolBlock)isInstalled;
-(void) isMyZohoInstalled:(boolBlock)isInstalled;
#if (!SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH)
- (UIViewController*)topViewController;
#endif
-(NSString *) getUserAgentString;
- (NSString*) deviceName;
-(NSString *)getMDMDefaultDC;
-(NSString *)getMDMToken;
-(NSString *)getManagedMDMLoginID;
-(BOOL)isMangedMDMRestrictedLogin;
-(BOOL)checkIfUnauthorisedManagedMDMAccount;
-(BOOL)checkIfUnauthorisedManagedMDMSSOAccount;
-(BOOL) isChineseLocale;
-(void) isJailbroken:(boolBlock)isJailBroken;
-(void)clearDataForDeletingSSOAccountHavingZUID:(NSString*)ZUID ;
-(void)clearDataForSSOLogoutHavingZUID:(NSString*)ZUID ;
-(void)storeUserImageDataInKeychain:(NSData*)imageData forZUID:(NSString*)ZUID ;
-(BOOL) isOneAuthApp;
-(BOOL) canOpenURL:(NSURL*)url;
-(void) openURL:(NSURL*)url;

-(NSString *) getMicsBaseURL;
@end
