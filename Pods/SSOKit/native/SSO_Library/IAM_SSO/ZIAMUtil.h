//
//  ZIAMUtil.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 21/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "SSOConstants.h"
#include "SSOEnums.h"
#include "ZSSOProtocols.h"
#include "SSORequestBlocks.h"
#include "ZSSOProfileData.h"
#include "SSORequestBlocks+Internal.h"
#include "ZIAMToken.h"

#if !TARGET_OS_UIKITFORMAC && !TARGET_OS_WATCH
#import <SafariServices/SafariServices.h>
#endif

#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY
#import "ZSSOKitPresentationContextProviding.h"
#endif

static const long wmsTimeCheckMargin = 420000 ;
static const long timecheckbuffer = 60000;


@interface ZIAMUtil : NSObject
{
@public
    NSString* ClientID;
    NSString* Scopes;
    NSString* UrlScheme;
    NSString* AppName;
#if (!SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH)
    UIWindow *MainWindow;
#endif
    NSInteger MODE;
    NSString* BaseUrl;
    NSString* ContactsUrl;
    NSString* profileBaseUrl;
    NSString* Service;
    NSString* AccessGroup;
    NSString* IAMURLScheme;
    
    NSString* UrlParams;
    BOOL showGoogleSignIn;
    NSString *SignUpUrl;
    NSString *CNSignUpURL;
    NSString *ScopeEnhancementUrl;
    NSString *UnconfirmedUserURL;
    NSString *OneAuthTokenActivationURL;
    NSString *TokenActivationURL;
    NSString *deviceVerificationURL;

    NSString *NativeSignInTok;
    NSString *AddSecondaryEmailURL;
    NSString *CloseAccountURL;
    NSString *reloginURL;
    NSString *webSessionURL;
    NSString *verifyEmailURL;

    NSString *inc_token;
    NSString* MicsBaseUrl;
    
    BOOL ButtonClick;
    BOOL showSignUp;
    
    BOOL wmsCallBack;
    long long expiresinMillis;
    
    BOOL isMultiAccountSignIn;
    
    BOOL isSSOLogin;
    
    requestSuccessBlock setSuccessBlock;
    requestFailureBlock setFailureBlock;
    requestSuccessBlock finalMultiAccountSuccessBlock;
    requestFailureBlock finalMultiAccountFailureBlock;
    
    
    ZSSOKitManageAccountsSuccessHandler finalAcountSwitchSuccessBlock;
    ZSSOKitManageAccountsFailureHandler finalAcountSwitchFailureBlock;
    
    ZSSOKitScopeEnhancementSuccessHandler finalScopeEnhancementSuccessBlock;
    ZSSOKitScopeEnhancementFailureHandler finalScopeEnhancementFailureBlock;

    ZSSOKitErrorResponse finalDeviceVerificationBlock;

    ZSSOKitAddEmailIDHandler finalAddEmailIDBlock;

    NSString *User_ZUID;
    
    NSData *setProfileImageData;
    NSDictionary *setProfileInfoDict;
    NSString *setClientSecret;
    NSString *setAccessToken;
    NSString *setExpiresIn;
    NSString *setRefreshToken;
    NSString *setAccountsServerURL;
    NSString *setLocation;
    NSData *setBas64DCL_Meta_Data;
    NSString *setMultiAccountZUID;
    
    NSMutableDictionary *stackBlocksDictionary;
    dispatch_queue_t serialDispatchQueue;
    
    void (^showProgressBlock)(void);
    void (^endProgressBlock)(void);
    
     NSDictionary *setjsonDictTeamParams;
    
    NSString *weChatAppID;
    NSString *weChatAppSecret;
    NSString *weChatUniversalLink;
    
    NSString *fsProvider;
    NSLock *lock;
}

/**
 *  ZIAMUtil Shared instance.
 *
 *  @return ZIAMUtil
 */
+ (ZIAMUtil *)sharedUtil;

#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
- (void) initWithClientID: (NSString*)clientID
                    Scope:(NSArray*)scopearray
                URLScheme:(NSString*)URLScheme
               MainWindow:(UIWindow*)mainWindow
                BuildType:(SSOBuildType)buildType;

-(UIWindow *)getActiveWindow;
@property (nonatomic, weak) id <ZSSOKitPresentationContextProviding> presentationContextProviderSSOKit;

#endif
@property (nonatomic, weak) id <ZSSOSSLChallengeDelegate> SSLPinningDelegate;

- (void) initExtensionWithClientID:(NSString*)clientID
                             Scope:(NSArray*)scopearray
                         URLScheme:(NSString*)URLScheme
                         BuildType:(SSOBuildType)buildType;

-(BOOL)isUserSignedIn;
-(BOOL) isUserSignedInUsingSIWAForZUID:(NSString *)ZUID;
-(void)appFirstLaunchClearData;

- (void) getTokenWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) getTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) getTokenForWMSWithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure;
-(void) getTokenForWMSHavingZUID:(NSString *)zuid WithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure;
-(ZIAMToken *)getSyncOAuthToken;

- (NSDictionary *)giveOAuthDetailsForWatchApp;
- (NSDictionary *)giveOAuthDetailsForWatchAppForZUID:(NSString *)zuid;

-(void)setOAuthDetailsInKeychainForWatchApp:(NSDictionary *)OAuthDetails;
-(void)setOAuthDetailsInKeychainForWatchAppHavingZUID:(NSString *)zuid details:(NSDictionary *)OAuthDetails;

- (void) presentInitialViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentInitialViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentGoogleSigninSFSafariViewControllerWithSuccess:(requestSuccessBlock)success
                                                   andFailure:(requestFailureBlock)failure;
- (void) presentGoogleSigninSFSafariViewControllerWithoutOneAuthSuccess:(requestSuccessBlock)success
                                                             andFailure:(requestFailureBlock)failure;
- (void) presentNativeSignInWithAppleWithSuccess:(requestSuccessBlock)success
                                      andFailure:(requestFailureBlock)failure;
-(void) presentWeChatSignInHavingWeChatID:(NSString *)appID weChatAppSecret:(NSString *)appSecret universalLink:(NSString *)universalLink WithSuccess:(requestSuccessBlock)success
andFailure:(requestFailureBlock)failure;
- (void) presentSignUpViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentSignUpViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentMultiAccountSigninWithSuccess:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentMultiAccountSigninWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentSignInUsingAnotherAccountWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure;
- (void) presentManageAccountsViewControllerWithSuccess:(ZSSOKitManageAccountsSuccessHandler)success
                                             andFailure:(ZSSOKitManageAccountsFailureHandler)failure;

-(BOOL)handleURL:url sourceApplication:sourceApplication annotation:annotation;
-(ZSSOUser *)getCurrentUser;
-(void)revokeAccessTokenWithSuccess:(requestLogoutSuccessBlock)success
                         andFailure:(requestLogoutFailureBlock)failure;
-(void)removeAllScopesForZUID:(NSString *)zuid success:(requestLogoutSuccessBlock)successBlock failure:(requestLogoutFailureBlock)failureBlock;


- (NSArray<ZSSOUser*> *)getUsersForApp;
-(ZSSOUser *)getZSSOUserHavingZUID:(NSString *)zuid;
-(void)addSecondaryEmailIDForZUID:(NSString *)zuid WithCallback:(ZSSOKitAddEmailIDHandler)failure;
-(void)enhanceScopeWithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                    andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure;
-(void)enhanceScopeForZuid:(NSString *)zuid WithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure;
-(void)getOAuth2TokenUsingAuthToken:(NSString *)authtoken forApp:(NSString *)appName havingAccountsURL:(NSString *)accountsBaseURL havingSuccess:(requestSuccessBlock)success
                         andFailure:(requestFailureBlock)failure;
-(void)getClientPortalUserTokenWithSuccess:(requestSuccessBlock)success
                                andFailure:(requestFailureBlock)failure;
-(void)getClientPortalUserTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success
                            andFailure:(requestFailureBlock)failure;
-(void)checkAndLogout:(requestFailureBlock)logoutBlock;
-(void)checkAndLogoutForZUID:(NSString *)zuid handler:(requestFailureBlock)logoutBlock;
-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url;
-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url havingZUID:(NSString *)zuid;
-(NSDictionary *)ziamgetDCLInfoForCurrentUser;
-(NSDictionary *)ziamgetDCLInfoForZuid:(NSString *)zuid;
-(BOOL)getIsSignedInUsingSSOAccount;
-(BOOL)getIsSignedInUsingSSOAccountForZUID:(NSString *)zuid;
-(void)forceFetchProfilePhotoForCurrentUserhavingAccessToken:(NSString *)accessToken withSuccessBlock:(photoSuccessBlock)successBlock withErrorBlock:(requestFailureBlock)errorBlock;
-(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID
                               havingZUID:(NSString *)zuid
                            forService:(NSString*)serviceName WithSuccess:(requestSuccessBlock)success
                               andFailure:(requestFailureBlock)failure ;
- (void)observeSIWAAuthticationStateHavingCallback:(requestMultiAccountFailureBlock)failure;

-(void)activateRefreshTokenUsing:(NSString*)handshakeID
                      havingZUID:(NSString *)zuid
             ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                     WithSuccess:(requestSuccessBlock)success
                      andFailure:(requestFailureBlock)failure;

@property BOOL donotfetchphoto;
@property NSString *ExtensionAppGroup;
@property BOOL isAppSupportingChinaSetup;
@property BOOL shouldShowFeedbackOption;
@property BOOL shouldLog;
@property BOOL donotSendScopesParam;
#if !TARGET_OS_WATCH && !TARGET_OS_UIKITFORMAC
@property SFSafariViewControllerDismissButtonStyle dismissButtonStyle API_AVAILABLE(ios(11.0));
#endif
@property UIColor *preferredBarTintColor;
@property UIColor *preferredControlTintColor;
@property BOOL shoulduseSFAuthenticationSession;
@property BOOL shoulduseASWebAuthenticationSession;
@property BOOL shouldPresentInFormSheet;
@property BOOL shouldSendUnconfirmedUserParam;
@property BOOL shouldUseWKWebview;
@property NSString *siwaBaseURL;
#if (!SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH)
    @property UIView *dcChooserActionSheetSourceView;
#endif



//Internal
-(void)fetchUserInfoHavingProfileURL:(NSString *)contactsURL WithBlock:(requestFailureBlock)errorBlock;
-(void)getForceFetchOAuthToken:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
-(void)getForceFetchOAuthTokenForZUID:(NSString *)zuid success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;

-(void)getSSOForceFetchOAuthTokenForSSOZUID:(NSString*)ZUID WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
-(void)checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure switchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess;
-(void)presentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
-(void)handleOpenUniversalLink:(NSUserActivity *)userActivity;
-(void)proceedSignInUsingGrantToken:(NSString *)grantToken forProvider:(NSString *)provider;

-(void)setRevokeFailedDueToNetworkError;

- (void)sendOTPTo:(NSString*)mobileNumber
 countryCode:(NSString*)code
    forZUID:(NSString*)userZUID
    WithResponse:(ZSSOKitOTPCodeResponse)response;

-(void)resendOTPForMobilID:(NSString*)mobileID
         forZUID:(NSString*)userZUID
              WithResponse:(ZSSOKitErrorResponse)response;

- (void)verifyMobileD:(NSString*)mobileID
         WithOTPCode:(NSString *)otp
             forZUID:(NSString*)userZUID
            response:(ZSSOKitErrorResponse)response;
-(void)verifySSOPasswordForZUID:(NSString*)zuid
                        success:(requestSuccessBlock)successBlock
                        failure:(requestFailureBlock)failureBlock;
-(void)closeAccountFor:(NSString*)ZUID havingCompletionHandler:(requestFailureBlock)response;

-(void)updatePhotoOfUserHavingZUID:(NSString*)zuid
                             image:(UIImage*)image WithSuccess:(responseSuccessBlock)success failure:(requestFailureBlock)failure;
-(void)openWebkitViewForZUID:(NSString*)ZUID
                      url:(NSURL*)url
                      headers:(NSDictionary<NSString*, NSString*>*)headers
                       WithFailure:(requestFailureBlock)failure;

- (void) showReloginForUser:(NSString*)ZUID
             WithCompletion:(requestFailureBlock)completion;

- (NSString*)getMDMHeaderFromMDMToken:(NSString*)mdmToken;

-(BOOL)checkifSSOAccountsMatchForZUID:(NSString *)zuid;

- (void) showEmailVerificationPage:(NSString*)ZUID
                    WithCompletion:(requestFailureBlock)completion;

#if !TARGET_OS_WATCH
-(void)getWebsessionView:(NSString*)ZUID
                      url:(NSURL*)url
                  headers:(NSDictionary<NSString*, NSString*> *)headers
          WithCompletion:(requestWebviewBlock)completion ;
#endif

- (void)getJWTForUser:(NSString *)zuid portalID:(NSString*)portalID success:(requestSuccessBlock)success failure:(requestFailureBlock)failure;
-(NSString*) getEncryptedMDMQueryParam;
@end

