//
//  ZIAMKeyChainUtil.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZIAMUtil.h"

#define kSSOAccountsServer_KEY @"accounts_server"
#define kSSOCurrentUser_KEY @"current_user"
#define kSSOZUIDU0_KEY @"ZOneAuth_U0"
#define kSSOZUIDList_KEY @"ZOneAuth_ZUIDS"
#define kSSOClientSecret_KEY @"client_secret"
#define kSSOClientSecret_OLD_KEY @"Client_Secret"
#define kSSORefreshToken_KEY @"refresh_token"
#define kSSOAccessToken_KEY @"access_token_dictionary"
#define kSSOisAppUsingSSOAccount_KEY @"is_using_ssoaccount"
#define kSSOisAppUsingMyZohoSSOAccount_KEY @"is_using_myzohossoaccount"
#define kSSODCLLocation_KEY @"dcl_location"
#define kSSODCLMeta_KEY @"dcl_meta"
#define kSSOOneAuthSSO_KEY @"OneAuthSSO"
#define kSSOOneAuthUserDetails_KEY @"ZOneAuth_USERDETAILS"
#define kSSOUserDetails_KEY @"USERDETAILS"
#define kSSOZuidUIndex @"U"
#define kSSOClientID_KEY @"client_id"
#define kSSOSIWAUID @"siwa_uid"
#define kSSOSIWAUserName @"siwa_user_name"
#define kSSOSIWAUserFirstName @"siwa_user_first_name"
#define kSSOSIWAUserLastName @"siwa_user_last_name"
#define kSSODeviceID_KEY @"sso_device_id"
#define kSSODeviceDetails_KEY @"sso_device_details"
#define kSSORevokeFailedDueToNetworkError @"revoke_access_token_failed"
#define kSSOCloseAccountTempToken_KEY @"close_account_temp_token"

#define kSSOOneAuthApplock_KEY @"isPassCodeEnabled"
#define kSSOOneAuthSetupCompleted @"mfa_setup_completed"
#define kSSOOneAuthMFAWithBiometric @"mfa_with_biometric_configured"

@interface ZIAMUtil(ZIAMKeyChainUtil)

-(void)appFirstLaunchClearDataFromKeychain;
-(BOOL)migrateDetailsToAppGroup;

-(NSString *)getCurrentUserZUIDFromKeychain;
-(void)setCurrentUserZUIDInKeychain:(NSString *)zuid;
-(void)removeCurrentUserZUIDFromKeychain;

-(NSString *)getAccountsURLFromKeychain;
-(void)setAccountsURLInKeychain:(NSString *)accountsURL;

-(NSString *)getAccountsURLFromKeychainForZUID:(NSString *)zuid;
-(void)setAccountsURL:(NSString *)accountsURL inKeychainForZUID:(NSString *)zuid;

-(NSString *)getSSOZUIDFromSharedKeychain;
-(NSString *)getSSOZUIDFromSharedKeychainForService:(NSString *)service;
-(NSString *)getSSOAccountsURLFromKeychainForZUID:(NSString *)zuid;
-(void)setSSOZUIDInSharedKeychain:(NSString *)ZUID;
-(NSData *)getSSOZUIDListFromSharedKeychain;

-(NSString *)getClientSecretFromKeychainForZUID:(NSString *)zuid;
-(void)setClientSecret:(NSString *)clientSecret inKeychainForZUID:(NSString *)zuid;
-(NSString *)getSSOClientSecretFromSharedKeychainForZUID:(NSString *)zuid;
-(void)setSSOClientSecretInSharedKeychain:(NSString *)clientSecret ForZUID:(NSString *)zuid;

-(NSString *)getRefreshTokenFromKeychainForZUID:(NSString *)zuid;
-(void)setRefreshToken:(NSString *)refreshToken inKeychainForZUID:(NSString *)zuid;
-(NSString *)getSSORefreshTokenFromSharedKeychainForZUID:(NSString *)zuid;
-(void)setSSORefreshTokenInSharedKeychain:(NSString *)refreshToken ForZUID:(NSString *)zuid;
-(void)removeRefreshTokenFromKeychainForZUID:(NSString *)zuid;

-(NSData *)getAccessTokenDataFromKeychainForZUID:(NSString *)zuid;
-(void)setAccessTokenData:(NSData *)accessTokenData inKeychainForZUID:(NSString *)zuid;
-(NSData *)getSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid;
-(NSData *)getSSOAccessTokenDataFromSharedKeychainForService:(NSString *)service;
-(NSData *)getAppSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid;
-(void)setAppSSOAccessTokenDataInSharedKeychain:(NSData *)accessTokenData ForZUID:(NSString *)zuid;
-(void)removeAppSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid;
-(void)removeAccessTokenDataFromKeychainForZUID:(NSString *)zuid;
-(void)removeAppSSORefreshTokenDataFromSharedKeychainForZUID:(NSString *)zuid;

-(BOOL)isAppUsingSSOAccount;
-(void)setisAppUsingSSOAccount;
-(void)removeisAppUsingSSOAccount;
-(BOOL)isAppUsingMyZohoSSOAccount;
-(void)setisAppUsingMyZohoSSOAccount;
-(void)removeisAppUsingMyZohoSSOAccount;

-(NSString *)getDCLLocationFromKeychainForZUID:(NSString *)zuid;
-(void)setDCLLocation:(NSString *)location inKeychainForZUID:(NSString *)zuid;
-(NSString *)getSSODCLLocationFromSharedKeychainForZUID:(NSString *)zuid;

-(NSData *)getDCLMetaFromKeychainForZUID:(NSString *)zuid;
-(void)setDCLMeta:(NSData *)dclmeta inKeychainForZUID:(NSString *)zuid;
-(NSData *)getSSODCLMetaFromSharedKeychainForZUID:(NSString *)zuid;

-(NSData *)getSSOUserDetailsDataFromSharedKeychain;
-(void)setSSOUserDetailsDataInSharedKeychain:(NSData *)userDetailsData;
-(NSData *)getUserDetailsDataFromKeychain;
-(void)setUserDetailsDataInKeychain:(NSData *)userdetails;
-(void)removeUserDetailsDataFromKeychain;

-(NSString *)getZUIDFromKeyChainForIndex:(int)i;
-(void)setZUIDInKeyChain:(NSString *)zuid atIndex:(int)i;
-(void)removeZUIDFromKeyChainatIndex:(int)i;

-(NSString *)getClientIDFromKeychainForZUID:(NSString *)zuid;
-(void)setClientID:(NSString *)clientid inKeychainForZUID:(NSString *)zuid;
-(NSString *)getClientIDFromSharedKeychain;
-(void)setSSOClientIDFromSharedKeychain:(NSString *)clientID;
-(NSString *)getSIWAUserIDFromKeychain;
-(NSString *)getSIWAUserNameFromKeychain;
-(NSString *)getSIWAUserFirstNameFromKeychain;
-(NSString *)getSIWAUserLastNameFromKeychain;
-(NSString *)getZUIDFromKeychainForSIWAUID:(NSString *)siwa_uid;
-(void)setZUID:(NSString *)zuid forSIWAUserIDInKeychain:(NSString *)siwa_uid;
-(void)setSIWAUserIDInKeychain:(NSString *)siwa_uid;
-(void)setSIWAUserFirstNameInKeychain:(NSString *)siwa_userfirstname;
-(void)setSIWAUserLastNameInKeychain:(NSString *)siwa_userlastname;
-(void)setSIWAUserNameInKeychain:(NSString *)siwa_username;
-(void)removeSIWAUserIDFromKeychain;
-(void)removeSIWAUserNameFromKeychain;
-(void)removeSIWAUserFirstNameFromKeychain;
-(void)removeSIWAUserLastNameFromKeychain;
-(void)removeZUIDFromKeychainForSIWAUID:(NSString *)siwa_uid;


-(NSString *)getDeviceIDFromKeychain;
-(void)setDeviceIDtoKeychain:(NSString *)deviceID;



//Offline revoke token methods
-(void)setRevokeFailedDueToNetworkErrorInKeychain;
-(void)resetRevokeFailedinKeychain;
-(BOOL)checkShouldCallRevokeTokenInKeychain;

// close account temp token storage
- (NSDictionary*)getTempTokenForCloseAccountWebSessionForZUID:(NSString*)ZUID ;
- (void)setTempTokenForCloseAccountWebSession:(NSString*)tempToken
                                    expiresIn:(NSString*)expiresInSeconds
                                      forZUID:(NSString*)ZUID;
-(void)removeCloseAccountTempTokenFromKeychainForZUID:(NSString *)zuid;

-(BOOL)getOneAuthApplockStatus;
-(BOOL)getIsBiometricEnabledForUser:(NSString *)zuid;
-(BOOL)getIsMFASetupCompletedForUser:(NSString *)zuid;

@end
