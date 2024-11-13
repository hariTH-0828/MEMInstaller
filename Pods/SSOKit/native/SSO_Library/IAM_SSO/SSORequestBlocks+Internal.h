//
//  SSORequestBlocks+Internal.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 30/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#ifndef SSORequestBlocks_Internal_h
#define SSORequestBlocks_Internal_h
#import <UIKit/UIKit.h>

@class ZSSOUser;

typedef void (^requestSuccessBlock)(NSString *token);
typedef void (^requestMultiAccountSuccessBlock)(NSString *token, NSString *zuid);
typedef void (^boolBlock)(BOOL isValid);
typedef void (^requestWMSSuccessBlock)(NSString *token,long long expiresMillis);
typedef void (^requestFailureBlock)(NSError *error);
typedef void (^requestMultiAccountFailureBlock)(NSString *zuid, NSError *error);
#if !TARGET_OS_WATCH
typedef void (^requestViewControllerSuccessBlock)(UIViewController *returnViewController);
typedef void (^requestWebviewBlock)(UIView *viewForWebContent, NSError *error); 

#endif
typedef void (^requestViewControllerFailureBlock)(NSError *error);
typedef void (^profileSuccessBlock)(NSDictionary *profileDictionary);
typedef void (^photoSuccessBlock)(NSData *photoData);
typedef void (^requestRevokeBlock)(NSError *error);
typedef void (^requestCheckLogoutBlock)(BOOL shouldLogout);
typedef void (^requestLogoutSuccessBlock)(void);
typedef void (^requestLogoutFailureBlock)(NSError *error);
typedef void (^ZSSOKitManageAccountsSuccessHandler)(NSString *accessToken,BOOL changed,ZSSOUser *zUser);
typedef void (^ZSSOKitManageAccountsFailureHandler)(NSError *error);
typedef void (^ZSSOKitScopeEnhancementSuccessHandler)(NSString *token);
typedef void (^ZSSOKitScopeEnhancementFailureHandler)(NSError *error);

typedef void (^responseSuccessBlock)(void);
typedef void (^requestTempTokenBlock)(NSString *token,long long expiresMillis, long long lastReAuthTime);


#endif /* SSORequestBlocks_Internal_h */
