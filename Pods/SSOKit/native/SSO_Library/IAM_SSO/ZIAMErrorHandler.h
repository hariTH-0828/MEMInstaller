//
//  ZIAMErrorHandler.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZIAMUtil.h"
#import "SSONetworkManager.h"

@interface ZIAMUtil(ZIAMErrorHandler)
-(NSError *)handleAccessTokenFetchError:(SSOInternalError)type error:(NSError*)error;
-(NSError *)handleOneAuthFetchError:(SSOInternalError)type error:(NSError*)error;
-(void)handleRevokeError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestLogoutFailureBlock)failed;
-(void)handleScopeEnhancementError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleAuthToOAuthError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleRemoteLoginError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleNativeSigninError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleSecondaryEmailError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleCloseAccountError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure;
-(void)handleUpdatePhotoError:(SSOInternalError)type info:(NSError*)error failureBlock:(requestFailureBlock)failed ;
@end
