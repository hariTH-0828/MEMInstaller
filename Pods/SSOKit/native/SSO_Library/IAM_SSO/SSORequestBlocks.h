//
//  SSORequestBlocks.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 24/03/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#ifndef SSORequestBlocks_h
#define SSORequestBlocks_h
#include "ZSSOUser.h"

typedef void (^ZSSOKitOTPCodeResponse)(NSString* mobileID, NSError *error );
typedef void (^ZSSOKitErrorResponse)(NSError *error);

/**
 The callback handler gives an access token or an error, if attempt to refresh was unsuccessful.

 @param accessToken This accessToken should be sent in the Authorization Header.(Header Value should be @"Zoho-oauthtoken TOKEN"  forHTTPHeaderField:@"Authorization" where TOKEN is the NSString accessToken obtained in this block)
 @param error Any error if the attempt to refresh was unsuccessful.
 */
typedef void (^ZSSOKitAccessTokenHandler)(NSString *accessToken,NSError *error);

/**
 The callback handler gives an access token, millis value of the respective access token's expiry time or an error, if attempt to refresh was unsuccessful.
 
 @param accessToken This accessToken should be sent in the Authorization Header.(Header Value should be @"Zoho-oauthtoken TOKEN"  forHTTPHeaderField:@"Authorization" where TOKEN is the NSString accessToken obtained in this block)
 @param expiresMillis This value gives you the millis value for which the respective accesstoken would be alive and valid.
 @param error Any error if the attempt to refresh was unsuccessful.
 */
typedef void (^ZSSOKitWMSAccessTokenHandler)(NSString *accessToken,long long expiresMillis,NSError *error);

/**
 The callblack handler during Sign-in that gives the accessToken if there is no error. Inside this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil.
 
 @param accessToken OAuth Access Token of the Signed-in User.
 @param error Respective error object.
 */
typedef void (^ZSSOKitSigninHandler)(NSString *accessToken,NSError *error);

/**
 The callblack handler during Sign-up that gives the accessToken if there is no error. Inside this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil and continue to hit the sign up process apo using the team params dict value.
 
 @param accessToken OAuth Access Token of the Signed-in User.
 @param jsonDictTeamParams Corresponding params passed by your respective server side team which is required to continue the sign up process from native app
 @param error Respective error object.
 */
typedef void (^ZSSOKitSignupHandler)(NSString *accessToken,NSDictionary *jsonDictTeamParams,NSError *error);

/**
 The callblack handler during Sign-in that gives the accessToken if there is no error. Inside this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil.
 
 @param accessToken OAuth Access Token of the Signed-in User.
 @param zuid ZUID of the current signed in user.
 @param error Respective error object.
 */
typedef void (^ZSSOKitMultiAccountSigninHandler)(NSString *accessToken,NSString *zuid,NSError *error);

/**
 The callback handler for revoking the access token during logout. Nil error means that the access token was revoked successfully. You can handle your apps logout logic in this handler if there is no error.

 @param error Respective error object of revoke network call.
 */
typedef void (^ZSSOKitRevokeAccessTokenHandler)(NSError *error);


/**
 The callback for handling managing and switching between multi accounts. If there is any SSO Account, then it will be shown on top. Managing SSO Account can be done only in OneAuth. (Whitelist URLScheme ("ZOA") of OneAuth. If all accounts are signed out/revoked, an error with error code k_SSONoUsersFound 500 will be thrown and thereby you should be taking to your initial onboarding/tour screen of your app handling this error.

 @param accessToken OAuth Access Token of the Selected User.
 @param changed Yes if current account is switched.
 @param zUser Zoho User object.
 @param error respective error object of managing multi account and revoking network call.
 */
typedef void (^ZSSOKitManageAccountsHandler)(ZSSOUser *zUser, NSError *error);

/**
 The callblack handler during Sign-in that gives the accessToken if there is no error. Inside this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil.
 
 @param accessToken OAuth Access Token of the Signed-in User.
 @param error Respective error object.
 */
typedef void (^ZSSOKitScopeEnhancementHandler)(NSString *accessToken,NSError *error);

/**
 The callblack handler during Sign-in that gives the accessToken if there is no error. Inside this handler, you can redirect to your app's signed-in state and present your respective screens if the error is nil.
 
 @param accessToken OAuth Access Token of the Signed-in User.
 @param error Respective error object.
 */
typedef void (^ZSSOKitAuthToOAuthHandler)(NSString *accessToken,NSError *error);

/**
 The callblack handler during the intermitent time when the accesstoken in the device would be valid where as the refresh_token would be revoked by the user in web. In such cases, getOAuth2Token would return you the access_token since it is alive, but on your server side you may get the invalid_oauthtoken error. If you get that error, call this method and if the shouldLogoutUser returnd in ZSSOKitInvalidOAuthLogoutHandler is true, take the user to the initial root onboarding/tour screen of your respective app.
 
 @param shouldLogoutUser If it is Yes/True take the user to the initial root viewcontroller. If it is No/False handle the error accordingly.
 */
typedef void (^ZSSOKitInvalidOAuthLogoutHandler)(BOOL shouldLogoutUser);


typedef void (^ZSSOKitPhotoFetchHandler)(NSData *imgdata,NSError *error);

typedef void (^ZSSOKitHandShakeIDHandler)(NSString *handShakeId,NSError *error);

typedef void (^ZSSOKitTokenActivationHandler)(BOOL isTokenActivated, NSError *error);

/**
 The callback handler to notiffy regarding the Authorization status change invloved with Sign In with Apple

 @param error Respective error object returned from Apple for AuthState change, nil if Authorization is granted.
 */
typedef void (^ZSSOKitSignInWithAppleAuthStateChangeHandler)(NSError *error);

/**
 For Multi-Account
 The callback handler to notiffy regarding the Authorization status change invloved with Sign In with Apple
 
 @param zuid Respective ZUID string of the SIWA User.
 @param error Respective error object returned from Apple for AuthState change, nil if Authorization is granted.
 */
typedef void (^ZSSOKitSignInWithAppleAuthStateChangeWithZUIDHandler)(NSString *zuid, NSError *error);

typedef void (^ZSSOKitAddEmailIDHandler)(NSError *error);
typedef void (^ZSSOKitErrorResponse)(NSError *error);
#if !TARGET_OS_WATCH
typedef void (^ZSSOKitContentViewHandler)(UIView *viewForWebContent, NSError *error);
#endif
#endif /* SSORequestBlocks_h */
