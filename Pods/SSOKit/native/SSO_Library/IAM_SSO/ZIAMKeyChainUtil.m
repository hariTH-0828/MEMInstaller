//
//  ZIAMKeyChainUtil.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZIAMKeyChainUtil.h"
#include "SSOKeyChainWrapper.h"
#include "ZSSODCLUtil.h"
#include "ZIAMUtilConstants.h"

@implementation ZIAMUtil(ZIAMKeyChainUtil)

//ClearAll Data From Keychain
-(void)appFirstLaunchClearDataFromKeychain{
    NSArray *items = [SSOKeyChainWrapper itemsForService:kServiceKeychainItem accessGroup:self.ExtensionAppGroup];
    for (NSDictionary *item in items) {
        NSString *key = [item valueForKey:(NSString *)kSecAttrAccount];
        if(![key isEqualToString:kSSODeviceID_KEY] ){
            NSMutableDictionary *itemToDelete = [[NSMutableDictionary alloc] initWithDictionary:item];
            [itemToDelete setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];

            OSStatus status = SecItemDelete((__bridge CFDictionaryRef)itemToDelete);
            if (status != errSecSuccess) {
                DLog(@"Error while deleting from Keychain");
            }
        }

    }
}

-(BOOL)migrateDetailsToAppGroup {
    NSArray *storedItems = [SSOKeyChainWrapper itemsForService:[SSOKeyChainWrapper defaultService] accessGroup:nil];
    DLog(@"%@",storedItems);
    
    if (self.ExtensionAppGroup) {
        BOOL isMoved = YES;
        for (NSDictionary* item in storedItems) {
            NSString *groupKey = (NSString *)kSecAttrAccessGroup;
            NSString *valueKey = (NSString *)kSecValueData;
            NSString *acctKey = (NSString *)kSecAttrAccount;

            NSString *group = [item valueForKey:groupKey];
            NSString *key = [item valueForKey:acctKey];

            NSData *data = [item valueForKey:valueKey];

            BOOL isAppGroup = [group isEqualToString:self.ExtensionAppGroup];
            if (!isAppGroup) {
                BOOL moved = [SSOKeyChainWrapper setData:data
                                                   forKey:key
                                                  service:[SSOKeyChainWrapper defaultService]
                                              accessGroup:self.ExtensionAppGroup];
                if (!moved)
                    //SOME INFORMATION NOT MOVED
                    isMoved = NO;
                }
            }
        return isMoved;

    } else {
        return NO;
    }
    
    
}

//CurrentUser ZUID
-(NSString *)getCurrentUserZUIDFromKeychain{
    NSString* current_user_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOCurrentUser_KEY];
    return [SSOKeyChainWrapper stringForKey:current_user_key];
}
-(void)setCurrentUserZUIDInKeychain:(NSString *)zuid{
     NSString* current_user_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOCurrentUser_KEY];
    [SSOKeyChainWrapper setString:zuid forKey:current_user_key];
}
-(void)removeCurrentUserZUIDFromKeychain{
    NSString* current_user_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOCurrentUser_KEY];
    [SSOKeyChainWrapper removeItemForKey:current_user_key];
}

//Accounts URL
-(NSString *)getAccountsURLFromKeychain{
    return [self getAccountsURLFromKeychainForZUID:[self getCurrentUserZUIDFromKeychain]];
}
-(NSString *)getAccountsURLFromKeychainForZUID:(NSString *)zuid{
    NSString* accounts_server_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccountsServer_KEY];
    NSString* accountsURLStr = [SSOKeyChainWrapper stringForKey:accounts_server_key];
    if ((accountsURLStr == NULL) && [[ZIAMUtil sharedUtil] checkifSSOAccountsMatchForZUID:zuid]) {
        accountsURLStr =  [self getSSOAccountsURLFromKeychainForZUID:zuid];
        [self setAccountsURL:accountsURLStr inKeychainForZUID:zuid];
    }
    return accountsURLStr;
}
-(void)setAccountsURLInKeychain:(NSString *)accountsURL{
    [self setAccountsURL:accountsURL inKeychainForZUID:[self getCurrentUserZUIDFromKeychain]];
}
-(void)setAccountsURL:(NSString *)accountsURL inKeychainForZUID:(NSString *)zuid{
    NSString* accounts_server_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccountsServer_KEY];
    [SSOKeyChainWrapper setString:accountsURL forKey:accounts_server_key];
}
-(NSString *)getSSOAccountsURLFromKeychainForZUID:(NSString *)zuid{
    NSString* accounts_server_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSOAccountsServer_KEY];
    NSString * accountsURLFromSharedKeychain = [SSOKeyChainWrapper stringForKey:accounts_server_key service:Service accessGroup:AccessGroup];
    if (accountsURLFromSharedKeychain) {
        return accountsURLFromSharedKeychain;
    } else {
        NSString *accountsUrl = [SSOKeyChainWrapper stringForKey:accounts_server_key];
        if(!accountsUrl){
            //Set in app's keychain. We are not storing in shared keychain as it might bring any issues. Shared keychain is fed by OneAuth app only. SSOKit can  only get values from the shared keychain.
            accountsUrl = [self transformURL:BaseUrl AppName:Service forZuid:zuid];
            [SSOKeyChainWrapper setString:accountsUrl forKey:accounts_server_key];
        }
        return accountsUrl;
    }
}

//SSO ZUID
-(NSString *)getSSOZUIDFromSharedKeychain{
    return [SSOKeyChainWrapper stringForKey:kSSOZUIDU0_KEY service:Service accessGroup:AccessGroup];
}
-(NSString *)getSSOZUIDFromSharedKeychainForService:(NSString *)service{
    return [SSOKeyChainWrapper stringForKey:kSSOZUIDU0_KEY service:service accessGroup:AccessGroup];
}
-(void)setSSOZUIDInSharedKeychain:(NSString *)ZUID{
    [SSOKeyChainWrapper setString:ZUID forKey:kSSOZUIDU0_KEY service:Service accessGroup:AccessGroup];
}
-(NSData *)getSSOZUIDListFromSharedKeychain{
    return [SSOKeyChainWrapper dataForKey:kSSOZUIDList_KEY service:Service accessGroup:AccessGroup];
}


-(NSString *)getDeviceIDFromKeychain{
    return [SSOKeyChainWrapper stringForKey:kSSODeviceID_KEY service:kServiceKeychainItem accessGroup:AccessGroup];
}

-(void)setDeviceIDtoKeychain:(NSString *)deviceID{
    [SSOKeyChainWrapper setString:deviceID forKey:kSSODeviceID_KEY service:kServiceKeychainItem accessGroup:AccessGroup];
}



//Client Secret

-(NSString *)getClientSecretFromKeychainForZUID:(NSString *)zuid{
    NSString* old_client_secret_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOClientSecret_OLD_KEY];
    NSString* new_client_secret_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOClientSecret_KEY];
    NSString *old_client_secret = [SSOKeyChainWrapper stringForKey:old_client_secret_key];
    if(old_client_secret){
        [SSOKeyChainWrapper setString:old_client_secret forKey:new_client_secret_key];
        [SSOKeyChainWrapper removeItemForKey:old_client_secret_key];
        return old_client_secret;
    }else{
        return [SSOKeyChainWrapper stringForKey:new_client_secret_key];
    }
}
-(void)setClientSecret:(NSString *)clientSecret inKeychainForZUID:(NSString *)zuid{
    NSString* new_client_secret_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOClientSecret_KEY];
    [SSOKeyChainWrapper setString:clientSecret forKey:new_client_secret_key];
}
-(NSString *)getSSOClientSecretFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* new_client_secret_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSOClientSecret_KEY];
    NSString *old_client_secret = [SSOKeyChainWrapper stringForKey:kSSOClientSecret_KEY service:Service accessGroup:AccessGroup];
    NSString *new_client_secret = [SSOKeyChainWrapper stringForKey:new_client_secret_key service:Service accessGroup:AccessGroup];
    if(new_client_secret){
        return new_client_secret;
    }else{
        if(old_client_secret)
            [SSOKeyChainWrapper setString:old_client_secret forKey:new_client_secret_key service:Service accessGroup:AccessGroup];
        ///[SSOKeyChainWrapper removeItemForKey:old_client_secret_key];
        return old_client_secret;
    }
}
-(void)setSSOClientSecretInSharedKeychain:(NSString *)clientSecret ForZUID:(NSString *)zuid{
    NSString* new_client_secret_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSOClientSecret_KEY];
    [SSOKeyChainWrapper setString:clientSecret forKey:new_client_secret_key service:Service accessGroup:AccessGroup];
}

//Refresh Token
-(NSString *)getRefreshTokenFromKeychainForZUID:(NSString *)zuid{
    NSString* refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSORefreshToken_KEY];
    return [SSOKeyChainWrapper stringForKey:refresh_token_key];
}
-(void)setRefreshToken:(NSString *)refreshToken inKeychainForZUID:(NSString *)zuid{
    NSString* refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSORefreshToken_KEY];
    [SSOKeyChainWrapper setString:refreshToken forKey:refresh_token_key];
}
-(NSString *)getSSORefreshTokenFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* sso_refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSORefreshToken_KEY];
    return [SSOKeyChainWrapper stringForKey:sso_refresh_token_key service:Service accessGroup:AccessGroup];
}
-(void)setSSORefreshTokenInSharedKeychain:(NSString *)refreshToken ForZUID:(NSString *)zuid{
    NSString* sso_refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSORefreshToken_KEY];
    [SSOKeyChainWrapper setString:refreshToken forKey:sso_refresh_token_key service:Service accessGroup:AccessGroup];
}
-(void)removeRefreshTokenFromKeychainForZUID:(NSString *)zuid{
    NSString* refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSORefreshToken_KEY];
    [SSOKeyChainWrapper removeItemForKey:refresh_token_key];
}

//Access Token
-(NSData *)getAccessTokenDataFromKeychainForZUID:(NSString *)zuid{
    NSString* access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    return [SSOKeyChainWrapper dataForKey:access_token_key];
}
-(void)setAccessTokenData:(NSData *)accessTokenData inKeychainForZUID:(NSString *)zuid{
    NSString* access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    [SSOKeyChainWrapper setData:accessTokenData forKey:access_token_key];
}
-(NSData *)getSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* sso_access_token_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSOAccessToken_KEY];
    return [SSOKeyChainWrapper dataForKey:sso_access_token_key service:Service accessGroup:AccessGroup];
}
-(NSData *)getSSOAccessTokenDataFromSharedKeychainForService:(NSString *)service{
    NSString* sso_access_token_key = [NSString stringWithFormat:@"%@_%@_%@",service,[self getSSOZUIDFromSharedKeychainForService:service],kSSOAccessToken_KEY];
    return [SSOKeyChainWrapper dataForKey:sso_access_token_key service:service accessGroup:AccessGroup];
}
-(NSData *)getAppSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* app_access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    return [SSOKeyChainWrapper dataForKey:app_access_token_key service:Service accessGroup:AccessGroup];
}
-(void)setAppSSOAccessTokenDataInSharedKeychain:(NSData *)accessTokenData ForZUID:(NSString *)zuid{
    NSString* app_access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    [SSOKeyChainWrapper setData:accessTokenData forKey:app_access_token_key service:Service accessGroup:AccessGroup];
}
-(void)removeAppSSOAccessTokenDataFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* app_access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    [SSOKeyChainWrapper removeItemForKey:app_access_token_key service:Service accessGroup:AccessGroup];
}
-(void)removeAccessTokenDataFromKeychainForZUID:(NSString *)zuid{
    NSString* access_token_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOAccessToken_KEY];
    [SSOKeyChainWrapper removeItemForKey:access_token_key];
}
-(void)removeAppSSORefreshTokenDataFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* sso_refresh_token_key = [NSString stringWithFormat:@"%@_%@_%@",Service,zuid,kSSORefreshToken_KEY];
    [SSOKeyChainWrapper removeItemForKey:sso_refresh_token_key service:Service accessGroup:AccessGroup];
}
//isApp using SSO Account
-(BOOL)isAppUsingSSOAccount{
    NSString *isAppUsingSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingSSOAccount_KEY,AppName];
    return [SSOKeyChainWrapper boolForKey:isAppUsingSSOAccount];
}
-(void)setisAppUsingSSOAccount{
    NSString *isAppUsingSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingSSOAccount_KEY,AppName];
    [SSOKeyChainWrapper setBool:YES forKey:isAppUsingSSOAccount];
}
-(void)removeisAppUsingSSOAccount{
    NSString *isAppUsingSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingSSOAccount_KEY,AppName];
    [SSOKeyChainWrapper removeItemForKey:isAppUsingSSOAccount];
}
-(BOOL)isAppUsingMyZohoSSOAccount{
    NSString *isAppUsingMyZohoSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingMyZohoSSOAccount_KEY,AppName];
    return [SSOKeyChainWrapper boolForKey:isAppUsingMyZohoSSOAccount];
}
-(void)setisAppUsingMyZohoSSOAccount{
    NSString *isAppUsingMyZohoSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingMyZohoSSOAccount_KEY,AppName];
    [SSOKeyChainWrapper setBool:YES forKey:isAppUsingMyZohoSSOAccount];
}
-(void)removeisAppUsingMyZohoSSOAccount{
    NSString *isAppUsingMyZohoSSOAccount = [NSString stringWithFormat:@"%@_%@",kSSOisAppUsingMyZohoSSOAccount_KEY,AppName];
    [SSOKeyChainWrapper removeItemForKey:isAppUsingMyZohoSSOAccount];
}

//DCL
-(NSString *)getDCLLocationFromKeychainForZUID:(NSString *)zuid{
    NSString* dcl_location_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSODCLLocation_KEY];
    return [SSOKeyChainWrapper stringForKey:dcl_location_key];
}
-(void)setDCLLocation:(NSString *)location inKeychainForZUID:(NSString *)zuid{
    NSString* dcl_location_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSODCLLocation_KEY];
    [SSOKeyChainWrapper setString:location forKey:dcl_location_key];
}
-(NSString *)getSSODCLLocationFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* dcl_location_key = [NSString stringWithFormat:@"%@_%@_%@",kSSOOneAuthSSO_KEY,zuid,kSSODCLLocation_KEY];
    return [SSOKeyChainWrapper stringForKey:dcl_location_key service:Service accessGroup:AccessGroup];
}
-(NSData *)getDCLMetaFromKeychainForZUID:(NSString *)zuid{
    NSString* dcl_meta_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSODCLMeta_KEY];
    return [SSOKeyChainWrapper dataForKey:dcl_meta_key];
}
-(void)setDCLMeta:(NSData *)dclmeta inKeychainForZUID:(NSString *)zuid{
    NSString* dcl_meta_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSODCLMeta_KEY];
    [SSOKeyChainWrapper setData:dclmeta forKey:dcl_meta_key];
}
-(NSData *)getSSODCLMetaFromSharedKeychainForZUID:(NSString *)zuid{
    NSString* dcl_meta_key = [NSString stringWithFormat:@"%@_%@_%@",kSSOOneAuthSSO_KEY,zuid,kSSODCLMeta_KEY];
    return [SSOKeyChainWrapper dataForKey:dcl_meta_key service:Service accessGroup:AccessGroup];
}

//User Details
-(NSData *)getSSOUserDetailsDataFromSharedKeychain{
    return [SSOKeyChainWrapper dataForKey:kSSOOneAuthUserDetails_KEY service:Service accessGroup:AccessGroup];
}
-(void)setSSOUserDetailsDataInSharedKeychain:(NSData *)userDetailsData{
    [SSOKeyChainWrapper setData:userDetailsData forKey:kSSOOneAuthUserDetails_KEY service:Service accessGroup:AccessGroup];
}
-(NSData *)getUserDetailsDataFromKeychain{
    NSString* user_details_key= [NSString stringWithFormat:@"%@_%@",AppName,kSSOUserDetails_KEY];
    return [SSOKeyChainWrapper dataForKey:user_details_key];
}
-(void)setUserDetailsDataInKeychain:(NSData *)userdetails{
    NSString* user_details_key= [NSString stringWithFormat:@"%@_%@",AppName,kSSOUserDetails_KEY];
    [SSOKeyChainWrapper setData:userdetails forKey:user_details_key];
}
-(void)removeUserDetailsDataFromKeychain{
    NSString* user_details_key= [NSString stringWithFormat:@"%@_%@",AppName,kSSOUserDetails_KEY];
    [SSOKeyChainWrapper removeItemForKey:user_details_key];
}

//ZUID
-(NSString *)getZUIDFromKeyChainForIndex:(int)i{
    NSString *zuid_key = [NSString stringWithFormat:@"%@_%@%d",AppName,kSSOZuidUIndex,i];
    return [SSOKeyChainWrapper stringForKey:zuid_key];
}
-(void)setZUIDInKeyChain:(NSString *)zuid atIndex:(int)i{
    NSString *zuid_key = [NSString stringWithFormat:@"%@_%@%d",AppName,kSSOZuidUIndex,i];
    [SSOKeyChainWrapper setString:zuid forKey:zuid_key];
}
-(void)removeZUIDFromKeyChainatIndex:(int)i{
    NSString *zuid_key = [NSString stringWithFormat:@"%@_%@%d",AppName,kSSOZuidUIndex,i];
    [SSOKeyChainWrapper removeItemForKey:zuid_key];
}

//ClientID
-(NSString *)getClientIDFromKeychainForZUID:(NSString *)zuid{
    NSString* client_id_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOClientID_KEY];
    return [SSOKeyChainWrapper stringForKey:client_id_key];
}
-(void)setClientID:(NSString *)clientid inKeychainForZUID:(NSString *)zuid{
    NSString* client_id_key = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOClientID_KEY];
    [SSOKeyChainWrapper setString:clientid forKey:client_id_key];
}
-(NSString *)getClientIDFromSharedKeychain{
    return [SSOKeyChainWrapper stringForKey:kSSOClientID_KEY service:Service accessGroup:AccessGroup];
}
-(void)setSSOClientIDFromSharedKeychain:(NSString *)clientID{
    [SSOKeyChainWrapper setString:clientID forKey:kSSOClientID_KEY service:Service accessGroup:AccessGroup];
}

//SIWA
-(NSString *)getSIWAUserIDFromKeychain{
    NSString *siwa_uid_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUID];
    return [SSOKeyChainWrapper stringForKey:siwa_uid_key];
}
-(NSString *)getSIWAUserNameFromKeychain{
    NSString *siwa_uname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserName];
    return [SSOKeyChainWrapper stringForKey:siwa_uname_key];
}
-(NSString *)getSIWAUserFirstNameFromKeychain{
    NSString *siwa_ufirstname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserFirstName];
    return [SSOKeyChainWrapper stringForKey:siwa_ufirstname_key];
}
-(NSString *)getSIWAUserLastNameFromKeychain{
    NSString *siwa_ulastname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserLastName];
    return [SSOKeyChainWrapper stringForKey:siwa_ulastname_key];
}
-(NSString *)getZUIDFromKeychainForSIWAUID:(NSString *)siwa_uid{
    NSString *siwa_zuid_key = [NSString stringWithFormat:@"%@_%@_ZUID",AppName,siwa_uid];
    return [SSOKeyChainWrapper stringForKey:siwa_zuid_key];
}
-(void)setZUID:(NSString *)zuid forSIWAUserIDInKeychain:(NSString *)siwa_uid{
     NSString *siwa_zuid_key = [NSString stringWithFormat:@"%@_%@_ZUID",AppName,siwa_uid];
    [SSOKeyChainWrapper setString:zuid forKey:siwa_zuid_key];
}
-(void)setSIWAUserNameInKeychain:(NSString *)siwa_username{
    NSString *siwa_uname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserName];
    [SSOKeyChainWrapper setString:siwa_username forKey:siwa_uname_key];
}
-(void)setSIWAUserFirstNameInKeychain:(NSString *)siwa_userfirstname{
    NSString *siwa_ufirstname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserFirstName];
    [SSOKeyChainWrapper setString:siwa_userfirstname forKey:siwa_ufirstname_key];
}
-(void)setSIWAUserLastNameInKeychain:(NSString *)siwa_userlastname{
    NSString *siwa_ulastname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserLastName];
    [SSOKeyChainWrapper setString:siwa_userlastname forKey:siwa_ulastname_key];
}
-(void)setSIWAUserIDInKeychain:(NSString *)siwa_uid{
    NSString *siwa_uid_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUID];
    [SSOKeyChainWrapper setString:siwa_uid forKey:siwa_uid_key];
}
-(void)removeSIWAUserFirstNameFromKeychain{
    NSString *siwa_uname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserFirstName];
    [SSOKeyChainWrapper removeItemForKey:siwa_uname_key];
}
-(void)removeSIWAUserLastNameFromKeychain{
    NSString *siwa_uname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserLastName];
    [SSOKeyChainWrapper removeItemForKey:siwa_uname_key];
}
-(void)removeSIWAUserNameFromKeychain{
    NSString *siwa_uname_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUserName];
    [SSOKeyChainWrapper removeItemForKey:siwa_uname_key];
}
-(void)removeSIWAUserIDFromKeychain{
    NSString *siwa_uid_key = [NSString stringWithFormat:@"%@_%@",AppName,kSSOSIWAUID];
    [SSOKeyChainWrapper removeItemForKey:siwa_uid_key];
}
-(void)removeZUIDFromKeychainForSIWAUID:(NSString *)siwa_uid{
    NSString *siwa_zuid_key = [NSString stringWithFormat:@"%@_%@_ZUID",AppName,siwa_uid];
    [SSOKeyChainWrapper removeItemForKey:siwa_zuid_key];
}


//RevokeDuringLogout
-(void)setRevokeFailedDueToNetworkErrorInKeychain{
    [SSOKeyChainWrapper setBool:YES forKey:kSSORevokeFailedDueToNetworkError];
}
-(void)resetRevokeFailedinKeychain{
    [SSOKeyChainWrapper removeItemForKey:kSSORevokeFailedDueToNetworkError];
}
-(BOOL)checkShouldCallRevokeTokenInKeychain{
    if([SSOKeyChainWrapper boolForKey:kSSORevokeFailedDueToNetworkError]){
        return [SSOKeyChainWrapper boolForKey:kSSORevokeFailedDueToNetworkError];
    }
    return NO;

}
- (NSDictionary*)getTempTokenForCloseAccountWebSessionForZUID:(NSString*)ZUID {
    NSString *tempTokenKey = [NSString stringWithFormat:@"%@_%@_%@",AppName,ZUID,kSSOCloseAccountTempToken_KEY];
    NSData* storedData = [SSOKeyChainWrapper dataForKey:tempTokenKey];
    if(storedData){
        NSError* serialisationError;
        NSPropertyListFormat plistFormat;

        NSDictionary *dictionary = [NSPropertyListSerialization propertyListWithData:storedData options:NSPropertyListMutableContainersAndLeaves format:&plistFormat error:&serialisationError];
        if (serialisationError) {
            return nil;
        } else {
            return dictionary;
        }

    } else {
        return nil;
    }

}
- (void)setTempTokenForCloseAccountWebSession:(NSString*)tempToken
                                    expiresIn:(NSString*)expiresInSeconds
                                      forZUID:(NSString*)ZUID {
    NSString *tempTokenKey = [NSString stringWithFormat:@"%@_%@_%@",AppName,ZUID,kSSOCloseAccountTempToken_KEY];
    NSMutableDictionary *tempTokenDict = [NSMutableDictionary new];
    [tempTokenDict setValue:tempToken forKey:@"token"];
    [tempTokenDict setValue:expiresInSeconds forKey:@"expires_in_sec"];
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:tempTokenDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    [SSOKeyChainWrapper setData:data forKey:tempTokenKey];
}

-(void)removeCloseAccountTempTokenFromKeychainForZUID:(NSString *)zuid{
    NSString *tempTokenKey = [NSString stringWithFormat:@"%@_%@_%@",AppName,zuid,kSSOCloseAccountTempToken_KEY];
    [SSOKeyChainWrapper removeItemForKey:tempTokenKey];
}

@end
