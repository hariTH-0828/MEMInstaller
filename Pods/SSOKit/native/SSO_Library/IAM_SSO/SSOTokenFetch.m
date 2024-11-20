//
//  SSOTokenFetch.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 11/06/18.
//

#import "SSOTokenFetch.h"
#include "SSORequestBlocks+Internal.h"
#include "ZIAMErrorHandler.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"
#include "SSONetworkManager.h"
#include "ZIAMUtilConstants.h"

#if TARGET_OS_WATCH && !TARGET_OS_UIKITFORMAC
@import WatchKit;
#endif

@implementation ZIAMUtil(SSOTokenFetch)
- (void)initTokenFetch {
    serialDispatchQueue = dispatch_queue_create("com.zoho.ssokit.tokenfetch", DISPATCH_QUEUE_SERIAL);
}

-(void)processTokenFetchForZUID:(NSString *)zuid isSSOAccount:(BOOL)isSSO WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    
    dispatch_async(serialDispatchQueue, ^{
        NSString *successKey;
        NSString *failureKey;
        NSString *isLoadingKey;
        
        if(isSSO){
            successKey = @"successblocks_sso";
            failureKey = @"failureblocks_sso";
            isLoadingKey = @"isLoading_sso";
        }else{
            successKey = [NSString stringWithFormat:@"successblocks_%@",zuid];
            failureKey = [NSString stringWithFormat:@"failureblocks_%@",zuid];
            isLoadingKey = [NSString stringWithFormat:@"isloading_%@",zuid];
        }
        
        [self addSuccessInStackBlockDict:success forKey:successKey];
        [self addFailureInStackBlockDict:failure forKey:failureKey];
        
        
        if(self->stackBlocksDictionary && [self->stackBlocksDictionary objectForKey:isLoadingKey]) {
            [self->lock unlock];
            return;
        }
        
        [self->stackBlocksDictionary setObject:@"yes" forKey:isLoadingKey];
        if(isSSO){
            [self oneAuthFetchAccessTokenFromServerForZUID:zuid WithSuccess:^(NSString *token) {
                [self->lock unlock];
                [self processSuccessWithAccessToken:token havingSuccessKey:successKey andFailureKey:failureKey];
                [self->stackBlocksDictionary removeObjectForKey:isLoadingKey];
            } andFailure:^(NSError *error) {
                [self->lock unlock];
                [self processFailureWithError:error havingSuccessKey:successKey andFailureKey:failureKey];
                [self->stackBlocksDictionary removeObjectForKey:isLoadingKey];
            }];
        }else{
            [self fetchAccessTokenFromServerForZUID:zuid WithSuccess:^(NSString *token) {
                [self->lock unlock];
                [self processSuccessWithAccessToken:token havingSuccessKey:successKey andFailureKey:failureKey];
                [self->stackBlocksDictionary removeObjectForKey:isLoadingKey];
            } andFailure:^(NSError *error) {
                [self->lock unlock];
                [self processFailureWithError:error havingSuccessKey:successKey andFailureKey:failureKey];
                [self->stackBlocksDictionary removeObjectForKey:isLoadingKey];
            }];
        }
    });
    
}

-(void)addSuccessInStackBlockDict:(requestSuccessBlock)success forKey:(NSString *)key{
    dispatch_async(self->serialDispatchQueue, ^{
        if(!self->stackBlocksDictionary){
            self->stackBlocksDictionary = [[NSMutableDictionary alloc] init];
        }
        NSMutableArray *successBlocks = [self->stackBlocksDictionary objectForKey:key];
        if(successBlocks){
            if(success)
                [successBlocks addObject:success];
            [self->stackBlocksDictionary setObject:successBlocks forKey:key];
        }else{
            NSMutableArray *successBlocks = [[NSMutableArray alloc]init];
            if(success)
                [successBlocks addObject:success];
            [self->stackBlocksDictionary setObject:successBlocks forKey:key];
        }
    });
}

-(void)addFailureInStackBlockDict:(requestFailureBlock)failure forKey:(NSString *)key{
    dispatch_async(self->serialDispatchQueue, ^{
        if(!self->stackBlocksDictionary){
            self->stackBlocksDictionary = [[NSMutableDictionary alloc] init];
        }
        NSMutableArray *failureBlocks = [self->stackBlocksDictionary objectForKey:key];
        if(failureBlocks){
            if(failure)
                [failureBlocks addObject:failure];
            [self->stackBlocksDictionary setObject:failureBlocks forKey:key];
        }else{
            NSMutableArray *failureBlocks = [[NSMutableArray alloc]init];
            if(failure)
                [failureBlocks addObject:failure];
            [self->stackBlocksDictionary setObject:failureBlocks forKey:key];
        }
    });
}

-(void)processSuccessWithAccessToken:(NSString *)access_token havingSuccessKey:(NSString *)successKey andFailureKey:(NSString *)failureKey{
    dispatch_async(self->serialDispatchQueue, ^{
        
        NSMutableArray *successBlocks = [self->stackBlocksDictionary objectForKey:successKey];
        for (requestSuccessBlock successBlock in successBlocks) {
            successBlock(access_token);
        }
        [self->stackBlocksDictionary removeObjectForKey:successKey];
        [self->stackBlocksDictionary removeObjectForKey:failureKey];
    });
}

-(void)processFailureWithError:(NSError *)error havingSuccessKey:(NSString *)successKey andFailureKey:(NSString *)failureKey{
    dispatch_async(self->serialDispatchQueue, ^{
        
        NSMutableArray *failureBlocks = [self->stackBlocksDictionary objectForKey:failureKey];
        for (requestFailureBlock failureBlock in failureBlocks) {
            failureBlock(error);
        }
        [self->stackBlocksDictionary removeObjectForKey:successKey];
        [self->stackBlocksDictionary removeObjectForKey:failureKey];
    });
}

-(void)fetchAccessTokenFromServerForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    
        NSString* client_secret = [[ZIAMUtil sharedUtil] getClientSecretFromKeychainForZUID:zuid];
        
        NSString *encoded_gt_sec=[[ZIAMUtil sharedUtil] getEncodedStringForString:client_secret];
        
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSOFetchToken_URL];
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:@"refresh_token" forKey:@"grant_type"];
        [paramsAndHeaders setValue:[ZIAMUtil sharedUtil]->ClientID forKey:@"client_id"];
        [paramsAndHeaders setValue:encoded_gt_sec forKey:@"client_secret"];
        if(![ZIAMUtil sharedUtil].donotSendScopesParam){
            [paramsAndHeaders setValue:[ZIAMUtil sharedUtil]->Scopes forKey:@"scope"];
        }
        [paramsAndHeaders setValue:zuid forKey:@"mzuid"];
        [paramsAndHeaders setValue:@"YES" forKey:@"x_mobileapp_migrated"];
        [paramsAndHeaders setValue:[[ZIAMUtil sharedUtil] getRefreshTokenFromKeychainForZUID:zuid] forKey:@"refresh_token"];

        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forKey:@"User-Agent"];
        if([ZIAMUtil sharedUtil].shouldSendUnconfirmedUserParam){
            [headers setValue:@"true" forKey:@"X-MOBILE-UNCONFIRMED-TOKEN"];
            [ZIAMUtil sharedUtil].shouldSendUnconfirmedUserParam = NO;
        }
       
    if ([[ZIAMUtil sharedUtil]getDeviceIDFromKeychain]){
        [headers setValue:[[ZIAMUtil sharedUtil]getDeviceIDFromKeychain] forKey:@"X-Device-Id"];
    }else{
        [headers setValue:@"NOT_CONFIGURED" forKey:@"X-Device-Id"];
    }
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];



        
        // Request....
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        //Give the Access token when asked!
                                                        NSString* access_token = [jsonDict objectForKey:@"access_token"];
                                                        NSString* expires_in = [jsonDict objectForKey:@"expires_in"];
                                                        
                                                        DLog(@"AccessToken: %@ Expires in : %@",access_token,expires_in);
            if([jsonDict objectForKey:@"deviceId"]){
                [[ZIAMUtil sharedUtil]setDeviceIDtoKeychain:[jsonDict objectForKey:@"deviceId"]];
            }
                                                        if(access_token!=nil && ![[ZIAMUtil sharedUtil] checkIfUnauthorisedManagedMDMAccount]){
                                                            
                                                            long long millis = [[ZIAMUtil sharedUtil] getCurrentTimeMillis];
                                                            long long expiresIn = [expires_in longLongValue];
                                                            if([ZIAMUtil sharedUtil]->wmsCallBack){
                                                                [ZIAMUtil sharedUtil]->expiresinMillis = expiresIn;
                                                            }
                                                            long long timeStampMillis = millis+expiresIn;
                                                            NSString* timeStamp = [NSString stringWithFormat:@"%lld",timeStampMillis];
                                                            DLog(@"TIME Stamp : %@",timeStamp);
                                                            
                                                            NSData* access_token_data = [[ZIAMUtil sharedUtil] getAccessTokenDataFromKeychainForZUID:zuid];
                                                            NSMutableDictionary* accessTokenDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:access_token_data];
                                                            
                                                            NSArray *accessTokenArray = @[access_token, timeStamp];
                                                            [accessTokenDictionary setObject:accessTokenArray forKey:[ZIAMUtil sharedUtil]->Scopes];
                                                            DLog(@"AccessToken Refreshed for Scope: %@",Scopes);
                                                            
                                                            NSData *dictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:accessTokenDictionary];
                                                            [[ZIAMUtil sharedUtil] setAccessTokenData:dictionaryRep inKeychainForZUID:zuid];
                                                            //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
                                                            [[ZIAMUtil sharedUtil] removeisAppUsingSSOAccount];
                                                            success(access_token);
                                                            return ;
                                                        }else{
                                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                            NSError *returnError;
                                                            if([[ZIAMUtil sharedUtil] checkIfUnauthorisedManagedMDMAccount]){
                                                                [userInfo setValue:@"UnAuthorised Managed MDM Account" forKey:NSLocalizedDescriptionKey];
                                                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUnAuthorisedManagedMDMAccount userInfo:userInfo];
                                                            }else{
                                                                [userInfo setValue:@"Oops AccessToken Fetch Nil" forKey:NSLocalizedDescriptionKey];
                                                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenFetchNil userInfo:userInfo];
                                                            }
                                                            failure(returnError);
                                                            return ;
                                                        }
                                                        
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        //Request failed
                                                        NSDictionary *responseDict = error.userInfo;
                                                        NSString* errorMessage = [responseDict valueForKey:@"error"];
                                                        if (errorType == SSO_ERR_SERVER_ERROR && [errorMessage isEqualToString:@"invalid_mobile_code"]) {
                                                            [self clearDataForLogoutHavingZUID:zuid];
                                                        }else if(errorType == SSO_ERR_SERVER_ERROR && [errorMessage isEqualToString:@"unconfirmed_user"]){
                                                            NSString *unc_token = [responseDict valueForKey:@"unc_token"];
                                                            self->UnconfirmedUserURL = [NSString stringWithFormat:@"%@%@?redirect_uri=%@&unc_token=%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSOUnconfirmedUser_URL,self->UrlScheme,unc_token];
                                                            
                                                            self->User_ZUID = zuid;
                                                            //present SFSafari to show scope enhancement
                                                            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                                                            return;
                                                        }
                                                        //Server returned an error
                                                        NSError *err = [self handleAccessTokenFetchError:errorType error:error];
                                                        failure(err);
                                                        return;
                                                    }];
}

-(void)oneAuthFetchAccessTokenFromServerForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
        DLog(@"One Auth Fetch Access token : %@",Scopes);
        
        NSString* client_secret = [ [ZIAMUtil sharedUtil] getSSOClientSecretFromSharedKeychainForZUID:zuid];
        NSString* client_id = [ [ZIAMUtil sharedUtil] getClientIDFromSharedKeychain];
        
        NSString *encoded_gt_sec=[ [ZIAMUtil sharedUtil] getEncodedStringForString:client_secret];
        
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[ [ZIAMUtil sharedUtil] getSSOAccountsURLFromKeychainForZUID:zuid],kSSOFetchToken_URL];
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:@"refresh_token" forKey:@"grant_type"];
        [paramsAndHeaders setValue:client_id forKey:@"client_id"];
        [paramsAndHeaders setValue:encoded_gt_sec forKey:@"client_secret"];
        [paramsAndHeaders setValue: [ZIAMUtil sharedUtil]->Scopes forKey:@"scope"];
        [paramsAndHeaders setValue:zuid forKey:@"mzuid"];
        [paramsAndHeaders setValue:@"YES" forKey:@"x_mobileapp_migrated"];
        [paramsAndHeaders setValue:[ [ZIAMUtil sharedUtil] getSSORefreshTokenFromSharedKeychainForZUID:zuid] forKey:@"refresh_token"];
        if([ZIAMUtil sharedUtil]->isSSOLogin){
            [paramsAndHeaders setValue:@"true" forKey:@"sso_app_register"];
            [ZIAMUtil sharedUtil]->isSSOLogin = NO;
        }
        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue: [ZIAMUtil sharedUtil]->ClientID forKey:@"X-Client-Id"];
        [headers setValue:@"true" forKey:@"x_mobileapp_migrated_s2"];
        
    if ([[ZIAMUtil sharedUtil]getDeviceIDFromKeychain]){
        [headers setValue:[[ZIAMUtil sharedUtil]getDeviceIDFromKeychain] forKey:@"X-Device-Id"];
    }else{
        [headers setValue:@"NOT_CONFIGURED" forKey:@"X-Device-Id"];
    }

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        // Request....
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        //Give the Access token when asked!
            if([jsonDict objectForKey:@"deviceId"]){
                [[ZIAMUtil sharedUtil]setDeviceIDtoKeychain:[jsonDict objectForKey:@"deviceId"]];
            }
                                                        NSString* access_token = [jsonDict objectForKey:@"access_token"];
                                                        NSString* expires_in = [jsonDict objectForKey:@"expires_in"];
                                                        
                                                        DLog(@"One Auth AccessToken: %@ Expires in : %@",access_token,expires_in);
                                                        
                                                        long long millis = [ [ZIAMUtil sharedUtil] getCurrentTimeMillis];
                                                        long long expiresIn = [expires_in longLongValue];
                                                        if( [ZIAMUtil sharedUtil]->wmsCallBack){
                                                             [ZIAMUtil sharedUtil]->expiresinMillis = expiresIn;
                                                        }
                                                        long long timeStampMillis = millis+expiresIn;
                                                        NSString* timeStamp = [NSString stringWithFormat:@"%lld",timeStampMillis];
                                                        DLog(@"TIME Stamp : %@",timeStamp);
                                                        
                                                        NSData* access_token_data = [ [ZIAMUtil sharedUtil] getAppSSOAccessTokenDataFromSharedKeychainForZUID:zuid];
                                                        NSMutableDictionary* accessTokenDictionary;
                                                        if(access_token_data){
                                                            accessTokenDictionary = (NSMutableDictionary *) [[NSKeyedUnarchiver unarchiveObjectWithData:access_token_data] mutableCopy];
                                                        }else{
                                                            accessTokenDictionary = [[NSMutableDictionary alloc]init];
                                                        }
                                                        
                                                        NSArray *accessTokenArray = @[access_token, timeStamp];
                                                        [accessTokenDictionary setObject:accessTokenArray forKey: [ZIAMUtil sharedUtil]->Scopes];
                                                        
                                                        DLog(@"One Auth Dictionary check:%@",[accessTokenDictionary objectForKey:Scopes]);
                                                        NSData *dictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:accessTokenDictionary];
                                                        [ [ZIAMUtil sharedUtil] setAppSSOAccessTokenDataInSharedKeychain:dictionaryRep ForZUID:zuid];
                                                        //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
                                                        if(![ [ZIAMUtil sharedUtil] isAppUsingSSOAccount] && ([ [ZIAMUtil sharedUtil] isOneAuthApp])){
                                                            [ [ZIAMUtil sharedUtil] setisAppUsingSSOAccount];
                                                        }
                                                        success(access_token);
                                                        return ;
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        //Request failed
                                                        NSDictionary *responseDict = error.userInfo;
                                                        NSString* errorMessage = [responseDict valueForKey:@"error"];
                                                        if (errorType == SSO_ERR_SERVER_ERROR && ([errorMessage isEqualToString:@"invalid_mobile_code"]) ) {


                                                            [self clearDataForLogoutHavingZUID:zuid];
                                                            if([self isAppUsingSSOAccount]){
                                                                [self removeisAppUsingSSOAccount];
                                                            }
                                                            if([self isAppUsingMyZohoSSOAccount]){
                                                                [self removeisAppUsingMyZohoSSOAccount];
                                                            }
                                                            [self removeAppSSOAccessTokenDataFromSharedKeychainForZUID:zuid];
                                                            [self removeAppSSORefreshTokenDataFromSharedKeychainForZUID:zuid];
                                                        }else if(errorType == SSO_ERR_SERVER_ERROR && [errorMessage isEqualToString:@"unconfirmed_user"]){
                                                            NSString *unc_token = [responseDict valueForKey:@"unc_token"];
                                                            self->UnconfirmedUserURL = [NSString stringWithFormat:@"%@%@?redirect_uri=%@&unc_token=%@",[self getSSOAccountsURLFromKeychainForZUID:zuid],kSSOUnconfirmedUser_URL,self->UrlScheme,unc_token];
                                                            
                                                            self->User_ZUID = zuid;
                                                            //present SFSafari to show scope enhancement
                                                            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                                                            return;
                                                        }else if(errorType == SSO_ERR_SERVER_ERROR && [errorMessage isEqualToString:@"inactive_refreshtoken"]){

                                                            NSString *inc_token = [responseDict valueForKey:@"inc_token"];
                                                            self->inc_token = inc_token;
                                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                            [userInfo setValue:@"SSO Account Blocked State" forKey:NSLocalizedDescriptionKey];
                                                            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthAccountBlockedState userInfo:userInfo];
                                                            failure(returnError);
                                                            
                                                            return;
                                                        }
                                                        //Server returned an error
                                                        NSError *err = [self handleOneAuthFetchError:errorType error:error];
                                                        failure(err);
                                                        return;
                                                    }];
}
@end
