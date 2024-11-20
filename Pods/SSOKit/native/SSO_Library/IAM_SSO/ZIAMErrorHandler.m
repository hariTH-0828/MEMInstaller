//
//  ZIAMErrorHandler.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZIAMErrorHandler.h"
#import "SSOConstants.h"
#import "ZIAMUtilConstants.h"
#import "ZIAMHelpers.h"

@implementation ZIAMUtil(ZIAMErrorHandler)
//Error Handling
-(NSError *)handleAccessTokenFetchError:(SSOInternalError)type error:(NSError*)error{
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        DLog(@"AccessToken fetch JSON nil");
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"AccessToken Fetch Nil" forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        DLog(@"AccessToken fetch JSON parse failed: %@", [error localizedDescription]);
        return error;
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        
        DLog(@"AccessToken fetch Error: %@", error.userInfo);
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenFetchError userInfo:error.userInfo];

    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        DLog(@"AccessTokenFetch Connection failed with Error: %@", [error localizedDescription]);
        return error;
        
    }else{
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"General Error" forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenFetchGeneralError userInfo:userInfo];
    }
}

-(NSError *)handleOneAuthFetchError:(SSOInternalError)type error:(NSError*)error{
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        DLog(@"One Auth fetch JSON nil");
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"OneAuth fetch nil" forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthTokenFetchNil userInfo:userInfo];
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        DLog(@"One Auth fetch JSON parse failed: %@", [error localizedDescription]);
        return error;
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"One Auth fetch Error: %@", error.userInfo);
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthTokenFetchError userInfo:error.userInfo];

    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        DLog(@"One Auth fetch Connection failed with Error: %@", [error localizedDescription]);
        return error;
    }else{
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"General Error" forKey:NSLocalizedDescriptionKey];
        return [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthTokenFetchGeneralError userInfo:userInfo];
    }
}

-(void)handleRevokeError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestLogoutFailureBlock)failed {
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        DLog(@"revoke JSON nil");
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setValue:@"RevokeToken fetch nil " forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORevokeTokenResultNil userInfo:userInfo];
        failed(error);
    }else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        DLog(@"revoke JSON parse failed: %@", [error localizedDescription]);
        failed(error);
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        
        DLog(@"revoke Error: %@", error.userInfo);
        NSError *revokeError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORevokeTokenError userInfo:error.userInfo];
        failed(revokeError);

        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        [[ZIAMUtil sharedUtil]setRevokeFailedDueToNetworkError];
        failed(error);
        
    }
}

-(void)handleScopeEnhancementError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure{
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Get Extra Scope Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Get Extra Scope fetch Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementFetchError userInfo:error.userInfo];

        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}

-(void)handleSecondaryEmailError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure{
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Add secondary email Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAddSecondaryEmailResponseNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Add secondary email Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAddSecondaryEmailServerError userInfo:error.userInfo];
   
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}

-(void)handleCloseAccountError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure {
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Close account - Response Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountResponseNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Close account - Server Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountServerError userInfo:error.userInfo];
        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}

-(void)handleUpdatePhotoError:(SSOInternalError)type info:(NSError*)error failureBlock:(requestFailureBlock)failed {
    if (type == SSO_ERR_JSON_NIL || type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        DLog(@"UpdatePhoto JSON parse failed: %@", [jsonError localizedDescription]);
        failed(error);
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        
        DLog(@"UpdatePhoto Error: %@", errorMessage);
       
        NSError *serverError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUpdatePhotoError userInfo:error.userInfo];
        failed(serverError);

        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        failed(error);
        
    }
}
-(void)handleNativeSigninError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure{
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Native Sign in Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Native Sign in fetch Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInFetchError userInfo:error.userInfo];
        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}

-(void)handleAuthToOAuthError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure{
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Auth to OAuth Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthToOAuthFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Auth to OAuth fetch Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthToOAuthFetchError userInfo:error.userInfo];
 
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}

-(void)handleRemoteLoginError:(SSOInternalError)type error:(NSError*)error failureBlock:(requestFailureBlock)failure  {
    NSError *returnError;
    if (type == SSO_ERR_JSON_NIL) {
        // JSON is Nil
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Get RemoteLogin Key Fetch Nil" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORemoteLoginFetchNil userInfo:userInfo];
        
    } else if (type == SSO_ERR_JSONPARSE_FAILED) {
        // JSON parse failed with error
        
        returnError = error;
        
        
    } else if (type == SSO_ERR_SERVER_ERROR) {
        //Server returned an error
        DLog(@"Get RemoteLogin Key fetch Error: %@", error.userInfo);
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORemoteLoginFetchError userInfo:error.userInfo];   
        
    } else if (type == SSO_ERR_CONNECTION_FAILED) {
        //Connection failed!
        
        returnError = error;
        
    }
    failure(returnError);
}
@end
