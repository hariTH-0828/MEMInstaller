//
//  ZIAMUtilConstants.h
//  ZohoSSO
//
//  Created by Kumareshwaran on 1/25/16.
//  Copyright © 2016 Kumareshwaran. All rights reserved.
//
#import "SSOLogger.h"
#ifndef ZIAMUtilConstants_h
#define ZIAMUtilConstants_h

#ifdef DEBUG
#define DLog(fmt, ...) [SSOLogger log:__LINE__ method:__PRETTY_FUNCTION__ string:fmt]
#else
#	define DLog(...)
#endif

#define kSSOKitVersion @"2.0.19"

#define kSSOSHARED_SECRET @"1234567890123456"

#define kSSOKitErrorDomain @"com.zoho.ssokit"

#define kOneAuthURLScheme @"ZohoOneAuth://"
#define kOneAuthMDMURLScheme @"ZOAMDM://"

#define kMyZohoURLScheme @"myzoho://"
#define kMyZohoMDMURLScheme @"myzohomdm://"


#define kServiceKeychainItem @"com.zoho.sso"

#if defined(SSO_LOCAL_MDM) || defined(DEBUG)
#define kCSEZ_Base_URL @"https://accounts.csez.zohocorpin.com"

#define kLocalZoho_Base_URL @"https://accounts.localzoho.com"
#define kLocalZoho_DEV_Base_URL @"https://accounts-dev.localzoho.com"

#define kProfile_LocalZoho_Base_URL @"https://profile.localzoho.com"


#define kCONTACTS_Localzoho_PROFILE_PHOTO @"https://contacts.localzoho.com/file/download"

#define kContacts_CSEZ_Base_URL @"https://contacts.csez.zohocorpin.com"

#define kCONTACTS_prezoho_PROFILE_PHOTO @"https://precontacts.zoho.com/file/download"

#define kZoho_Pre_URL @"https://preaccounts.zoho.com"
#define kZoho_iAccounts_URL @"https://iaccounts.zoho.com"

#define kAccountsSkyDeskStage_URL @"https://accounts.stage.skydesk.jp"
#define kAccountsSkyDeskPre_URL @"https://preaccounts.skydesk.jp"

#define kContactsSkyDeskStage_URL @"https://contacts.stage.skydesk.jp"
#define kContactsSkyDeskPre_URL @"https://precontacts.skydesk.jp"

#define kAccountsCharmPre_URL @"http://preaccounts.charmtracker.com"
#define kContactsCharmPre_URL @"http://precontacts.charmtracker.com"
#endif

#define kZoho_Base_URL @"https://accounts.zoho.com"
#define kZoho_IN_Base_URL @"https://accounts.zoho.in"
#define kZoho_EU_Base_URL @"https://accounts.zoho.eu"
#define kZoho_AU_Base_URL @"https://accounts.zoho.com.au"

#define kCONTACTS_Zoho_PROFILE_PHOTO @"https://contacts.zoho.com/file/download"
#define kProfile_Zoho_Base_URL @"https://profile.zoho.com"
#define kProfile_Zoho_CN_Base_URL @"https://profile.zoho.com.cn"

#define kZoho_CN_Base_URL @"https://accounts.zoho.com.cn"
#define kCONTACTS_Zoho_CN_PROFILE_PHOTO @"https://contacts.zoho.com.cn/file/download"

#define kAccountsSkyDesk_URL @"https://accounts.skydesk.jp"
#define kContactsSkyDesk_URL @"https://contacts.skydesk.jp"

#define kContactsCharm_URL @"http://contacts.charmtracker.com"
#define kAccountsCharm_URL @"http://accounts.charmtracker.com"

#define kLocalZoho_MICS_Base_URL @"https://tipengine.localzoho.com"
#define kZoho_MICS_Base_URL @"https://tipengine.zoho.com"

#define kDevelopment_BundleID @"com.zoho.iamlogin"
#define kDevelopment_AppGroup @"group.zoho.iamtest"
#define kDevelopment_MyZoho_BundleID @"com.zoho.myzoho"


#define kMDM_BundleID @"com.zoho.inhouse.oneauth"
#define kMDM_AppGroup @"group.zoho.inhouse.iam"
#define kMDM_MyZoho_BundleID @"com.zoho.inhouse.myzoho"


#define kSSO_public_key_tag @"com.zoho.sso.publicKey"
#define kSSO_private_key_tag @"com.zoho.sso.privateKey"
#define kSSO_server_public_key_tag @"com.zoho.sso.serverPublicKey"

//API End Points
#define kSSOAccountsSignUp_URL @"/register?servicename=aaaserver"
#define kSSOAccountsSignUpForCustomParams_URL @"/register"
#define kSSORevoke_URL @"/oauth/v2/token/revoke"
#define kSSODeviceVerify_Signout_URL @"/oauth/sso/userSignOut"
#define kSSOScopeEnhancement_URL @"/oauth/v2/token/internal/getextrascopes"
#define kSSOAddScope_URL @"/oauth/v2/token/addscope"
#define kSSOAuthToOAuth_URL @"/oauth/v2/token/internal/authtooauth"
#define kSSOFetchToken_URL @"/oauth/v2/token"
#define kSSOClientPortalRemoteLogin_URL @"/oauth/v2/mobile/internal/getremoteloginkey"
#define kSSOClientPortalJWTLogin_URL @"/oauth/v2/mobile/getremotejwt"


#define kSSOFetchUserInfo_URL @"/oauth/user/info"
#define kSSOMobileAuth_URL @"/oauth/v2/mobile/auth"
#define kSSOUnconfirmedUser_URL @"/oauth/v2/mobile/unconfirmed"
#define kSSOInactiveRefreshToken_URL @"/oauth/v2/mobile/inactive/token"
#define kSSOGenerateHandshakeID_URL @"/oauth/inactivetoken/handshakeId"
#define kSSOInternalTokenActivation_URL @"/oauth/v2/internal/inactive/token"
#define kSSODeviceVerify_URL @"/oauth/mobile/verify"
#define kSSODeviceVerifyWebPage_URL @"/oauth/mobile/verify/prompt"

#define kSSONativeSignInHandling_URL @"/oauth/v2/native/init"
#define kSSOUpdateDeviceDetails_URL @"/oauth/device/modify"
#define kSSOTemporarySessionToken_URL @"/api/v1/ssokit/token"
#define kSSOAddSecondaryEmail_URL @"/ssokit/addemail"
#define kSSOSendOTPMobile @"/ssokit/v1/user/self/mobile"
#define kSSOCloseAccount_URL @"/ssokit/closeaccount"
#define kSSOReAuth_URL @"/account/v1/relogin"
#define kSSOWebSession_URL @"/account/v1/websession"
#define kSSOVerifyEmail_URL @"/ssokit/addemail"

#define kProfilePhotoFetch_URL @"/api/v1/user/self/photo"
#endif /* ZIAMUtilConstants_h */
