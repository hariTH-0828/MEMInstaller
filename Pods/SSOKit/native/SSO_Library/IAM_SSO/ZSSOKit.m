//
//  ZSSOKit.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/03/17.
//
//

#import "ZSSOKit.h"
#include "ZIAMUtil.h"
#import "ZIAMKeyChainUtil.h"
#import "ZIAMUtilConstants.h"
#import "ZIAMHelpers.h"

@implementation ZSSOKit


#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
+ (void) initWithClientID: (NSString*)clientID
                         Scope:(NSArray*)scopeArray
                     URLScheme:(NSString*)urlScheme
                    MainWindow:(UIWindow*)mainWindow
                     BuildType:(SSOBuildType)buildType{
    [[ZIAMUtil sharedUtil] initWithClientID:clientID Scope:scopeArray URLScheme:urlScheme MainWindow:mainWindow BuildType:buildType];
}
+ (void)setMultiWindowInstance:(UIWindow*)mainWindow{
    [ZIAMUtil sharedUtil]->MainWindow = mainWindow;
}
#endif

+ (void) initWithClientID: (NSString*)clientID
                                  Scope:(NSArray*)scopeArray
                              URLScheme:(NSString*)urlScheme
                              BuildType:(SSOBuildType)buildType{
    [[ZIAMUtil sharedUtil] initExtensionWithClientID:clientID Scope:scopeArray URLScheme:urlScheme BuildType:buildType];
}

+ (BOOL)migrateDetailsToAppGroup {
    return [[ZIAMUtil sharedUtil] migrateDetailsToAppGroup];
}
+ (void)setHavingAppExtensionWithAppGroup:(NSString *)appGroup{
    [ZIAMUtil sharedUtil].ExtensionAppGroup = appGroup;
}
+ (void) getOAuth2Token:(ZSSOKitAccessTokenHandler)tokenBlock{
    [[ZIAMUtil sharedUtil]getTokenWithSuccess:^(NSString *token) {
        tokenBlock(token,nil);
    } andFailure:^(NSError *error) {
        tokenBlock(nil,error);
    }];
}
+ (void) getOAuth2TokenForZUID:(NSString *)zuid tokenHandler:(ZSSOKitAccessTokenHandler)tokenBlock{
    [[ZIAMUtil sharedUtil] getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        tokenBlock(token,nil);
    } andFailure:^(NSError *error) {
        tokenBlock(nil,error);
    }];
}
+ (void) getOAuth2TokenForWMS:(ZSSOKitWMSAccessTokenHandler)tokenBlock{
    [[ZIAMUtil sharedUtil]getTokenForWMSWithSuccess:^(NSString *token, long long expiresMillis) {
        tokenBlock(token,expiresMillis,nil);
    } andFailure:^(NSError *error) {
        tokenBlock(nil,0,error);
    }];
}
+ (void) getOAuth2TokenForWMSHavingZUID:(NSString *)zuid tokenHandler:(ZSSOKitWMSAccessTokenHandler)tokenBlock{
    [[ZIAMUtil sharedUtil] getTokenForWMSHavingZUID:zuid WithSuccess:^(NSString *token, long long expiresMillis) {
         tokenBlock(token,expiresMillis,nil);
    } andFailure:^(NSError *error) {
        tokenBlock(nil,0,error);
    }];
}
+(ZIAMToken *)getSyncOAuth2TokenForWMS{
    return [[ZIAMUtil sharedUtil] getSyncOAuthToken];
}
+ (NSDictionary *)getOAuthDetailsForWatchApp{
    return [[ZIAMUtil sharedUtil] giveOAuthDetailsForWatchApp];
}
+ (NSDictionary *)getOAuthDetailsForWatchAppHavingZUID:(NSString *)zuid{
    return [[ZIAMUtil sharedUtil] giveOAuthDetailsForWatchAppForZUID:zuid];
}
+(void)setOAuthDetailsInKeychainForWatchApp:(NSDictionary *)oauthDetails{
    [[ZIAMUtil sharedUtil] setOAuthDetailsInKeychainForWatchApp:oauthDetails];
}
+(void)setOAuthDetailsInKeychainForWatchAppHavingZUID:(NSString *)zuid details:(NSDictionary *)oauthDetails{
    [[ZIAMUtil sharedUtil] setOAuthDetailsInKeychainForWatchAppHavingZUID:zuid details:oauthDetails];
}
+ (void) presentInitialViewController:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentInitialViewControllerWithSuccess:^(NSString *token) {
        signinBlock(token, nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);

    }];
}

+ (void) presentInitialViewControllerWithCustomParams:(NSString *)urlParams
                                        signinHandler:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil]presentInitialViewControllerWithCustomParams:urlParams success:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentGoogleSigninSFSafariViewController:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentGoogleSigninSFSafariViewControllerWithSuccess:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentGoogleSigninSFSafariViewControllerWithOutOneAuth:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentGoogleSigninSFSafariViewControllerWithoutOneAuthSuccess:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentNativeSignInWithApple:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentNativeSignInWithAppleWithSuccess:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentWeChatSignInHavingWeChatID:(NSString *)weChatAppID weChatAppSecret:(NSString *)weChatAppSecret universalLink:(NSString *)universalLink signinHandler:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentWeChatSignInHavingWeChatID:weChatAppID weChatAppSecret:weChatAppSecret universalLink:universalLink WithSuccess:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentSignUpViewController:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentSignUpViewControllerWithSuccess:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentignUpViewControllerWithCustomParams:(NSString *)urlParams
                                      signinHandler:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentSignUpViewControllerWithCustomParams:urlParams success:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}

+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl
                                signinHandler:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil]presentSignUpViewControllerHavingURL:signupUrl success:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL
                                signinHandler:(ZSSOKitSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentSignUpViewControllerHavingURL:signupUrl andCNSignUpURL:cnSignUpURL success:^(NSString *token) {
        signinBlock(token,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil, error);
    }];
}
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl
                                signupHandler:(ZSSOKitSignupHandler)signupBlock{
    [[ZIAMUtil sharedUtil]presentSignUpViewControllerHavingURL:signupUrl success:^(NSString *token) {
        signupBlock(token,[ZIAMUtil sharedUtil]->setjsonDictTeamParams, nil);
    } andFailure:^(NSError *error) {
        signupBlock(nil, nil, error);
    }];
}
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL
                                signupHandler:(ZSSOKitSignupHandler)signupBlock{
    [[ZIAMUtil sharedUtil] presentSignUpViewControllerHavingURL:signupUrl andCNSignUpURL:cnSignUpURL success:^(NSString *token) {
        signupBlock(token,[ZIAMUtil sharedUtil]->setjsonDictTeamParams, nil);
    } andFailure:^(NSError *error) {
        signupBlock(nil, nil, error);
    }];
}
+ (void) presentMultiAccountSignin:(ZSSOKitMultiAccountSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentMultiAccountSigninWithSuccess:^(NSString *token, NSString *zuid) {
        signinBlock(token,zuid,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil,nil,error);
    }];
}

+ (void) presentMultiAccountSigninWithCustomParams:(NSString *)urlParams
                                     signinHandler:(ZSSOKitMultiAccountSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentMultiAccountSigninWithCustomParams:urlParams success:^(NSString *token, NSString *zuid) {
        signinBlock(token,zuid,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil,nil,error);
    }];
}

+ (void) presentSignInUsingAnotherAccountWithCustomParams:(NSString *)urlParams
                                            signinHandler:(ZSSOKitMultiAccountSigninHandler)signinBlock{
    [[ZIAMUtil sharedUtil] presentSignInUsingAnotherAccountWithCustomParams:urlParams success:^(NSString *token, NSString *zuid) {
        signinBlock(token,zuid,nil);
    } andFailure:^(NSError *error) {
        signinBlock(nil,nil,error);
    }];
}

+ (void) presentManageAccountsViewController:(ZSSOKitManageAccountsHandler)manageHandler{
    
    [[ZIAMUtil sharedUtil] presentManageAccountsViewControllerWithSuccess:^(NSString *accessToken, BOOL changed, ZSSOUser *zUser) {
        manageHandler(zUser,nil);
    } andFailure:^(NSError *error) {
        manageHandler(nil,error);
    }];
    
}
    
+ (void) clearSSODetailsForFirstLaunch{
    [[ZIAMUtil sharedUtil] appFirstLaunchClearData];
}

+ (BOOL) isUserSignedIn{
    return [[ZIAMUtil sharedUtil] isUserSignedIn];
}

+ (BOOL) isCurrentUserSignedInUsingSIWA{
    return [self isUserSignedInUsingSIWAForZUID:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain]];
}
+ (BOOL) isUserSignedInUsingSIWAForZUID:(NSString *)ZUID{
    return [[ZIAMUtil sharedUtil] isUserSignedInUsingSIWAForZUID:ZUID];
}

+ (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation{
    return [[ZIAMUtil sharedUtil]handleURL:url sourceApplication:sourceApplication annotation:annotation];
}

+(ZSSOUser *)getCurrentUser{
    return [[ZIAMUtil sharedUtil]getCurrentUser];
}

+(NSArray<ZSSOUser*> *) getUsersForApp{
    return [[ZIAMUtil sharedUtil] getUsersForApp];
}

+(ZSSOUser *) getZSSOUserHavingZUID:(NSString *)zuid{
    return [[ZIAMUtil sharedUtil] getZSSOUserHavingZUID:zuid];
}

+(void)revokeAccessToken:(ZSSOKitRevokeAccessTokenHandler)revoke{
    [[ZIAMUtil sharedUtil] revokeAccessTokenWithSuccess:^{
        revoke(nil);
    } andFailure:^(NSError *error) {
        revoke(error);
    }];
}

+(void)revokeAccessTokenForZUID:(NSString *)zuid revokeHandler:(ZSSOKitRevokeAccessTokenHandler)revoke{
    [[ZIAMUtil sharedUtil] removeAllScopesForZUID:zuid success:^{
        revoke(nil);
    } failure:^(NSError *error) {
        revoke(error);
    }];
    
}

+(NSString *)getTransformedURLStringForURL:(NSString *)url{
    return [[ZIAMUtil sharedUtil] ziamgetTransformedURLStringForURL:url];
}

+(NSString *)getTransformedURLStringForURL:(NSString *)url havingZUID:(NSString *)zuid{
    return [[ZIAMUtil sharedUtil] ziamgetTransformedURLStringForURL:url havingZUID:zuid];
}

+(void) donotFetchProfilePhotoDuringSignin{
    [ZIAMUtil sharedUtil].donotfetchphoto = YES;
}

+(NSDictionary *)getDCLInfoForCurrentUser{
    return [[ZIAMUtil sharedUtil] ziamgetDCLInfoForCurrentUser];
}

+(NSDictionary *)getDCLInfoForZuid:(NSString *)zuid{
    return [[ZIAMUtil sharedUtil] ziamgetDCLInfoForZuid:zuid];
}

+(void)enhanceScopesForZUID:(NSString *)zuid ignorePasswordPrompt:(BOOL)ignorePasswordVerification handler:(ZSSOKitScopeEnhancementHandler)enhanceHandler{
    [[ZIAMUtil sharedUtil] enhanceScopeForZuid:zuid ignorePasswordPrompt: ignorePasswordVerification WithSuccess:^(NSString *token) {
        enhanceHandler(token,nil);
    } andFailure:^(NSError *error) {
        enhanceHandler(nil,error);
    }];
}

+(void)getOAuth2TokenUsingAuthToken:(NSString *)authToken
                             forApp:(NSString *)appName
                  havingAccountsURL:(NSString *)accountsBaseURL
                 authToOAuthHandler:(ZSSOKitAuthToOAuthHandler)authToOAuthBlock{
    [[ZIAMUtil sharedUtil] getOAuth2TokenUsingAuthToken:authToken forApp:appName havingAccountsURL:accountsBaseURL havingSuccess:^(NSString *token) {
        authToOAuthBlock(token,nil);
    } andFailure:^(NSError *error) {
        authToOAuthBlock(nil,error);
    }];
}

+(void) pointToChinaSetup{
    [ZIAMUtil sharedUtil].isAppSupportingChinaSetup = YES;
}

+(void)checkAndLogoutUserDuringInvalidOAuth:(ZSSOKitErrorResponse)logoutHandler{
    [[ZIAMUtil sharedUtil] checkAndLogout:^(NSError *error) {
        logoutHandler(error);
    }];
}
+(void)checkAndLogoutUserDuringInvalidOAuthForZUID:(NSString *)zuid handler:(ZSSOKitErrorResponse)logoutHandler{
    [[ZIAMUtil sharedUtil] checkAndLogoutForZUID:zuid handler:^(NSError *error) {
        logoutHandler(error);
    }];
}
+(void)shouldShowSSOKitLogs:(BOOL)shouldLog{
    [ZIAMUtil sharedUtil].shouldLog =shouldLog;
}
+(void)setShouldUseWKWebview:(BOOL)shouldUseWKWebview{
    [ZIAMUtil sharedUtil].shouldUseWKWebview = shouldUseWKWebview;
}

#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_UIKITFORMAC
+(void)setPreferredBarTintColorForSFSafari:(UIColor *)preferredBarTintColor{
    [ZIAMUtil sharedUtil].preferredBarTintColor = preferredBarTintColor;
}
+(void)setPreferredControlTintColorForSFSafari:(UIColor *)preferredControlTintColor{
    [ZIAMUtil sharedUtil].preferredControlTintColor = preferredControlTintColor;
}
+(void)setSFSafariViewControllerDismissButtonStyle:(SFSafariViewControllerDismissButtonStyle)dismissButtonStyle{
    [ZIAMUtil sharedUtil].dismissButtonStyle = dismissButtonStyle;
}
+(void)setShouldUseSFAuthenticationSession:(BOOL)shouldUseSFAuth{
    [ZIAMUtil sharedUtil].shoulduseSFAuthenticationSession = shouldUseSFAuth;
}
#endif
#endif
#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY
+(void)shoulduseASWebAuthenticationSession:(BOOL)shouldUseASWebAuth{
    [ZIAMUtil sharedUtil].shoulduseASWebAuthenticationSession = shouldUseASWebAuth;
}

+(void)setDCChooserActionSheetSourceView:(UIView *)dcChooserActionSheetSourceView{
    [ZIAMUtil sharedUtil].dcChooserActionSheetSourceView = dcChooserActionSheetSourceView;
}
#endif
+(BOOL)getIsSignedInUsingSSOAccount{
    return [[ZIAMUtil sharedUtil] getIsSignedInUsingSSOAccount];
}

+(BOOL)getIsSignedInUsingSSOAccountForZUID:(NSString *)zuid{
    return [[ZIAMUtil sharedUtil] getIsSignedInUsingSSOAccountForZUID:zuid];
}

+(void)setShouldShowFeedBackOptionOnSFSafari:(BOOL)showFeedback{
    [ZIAMUtil sharedUtil].shouldShowFeedbackOption = showFeedback;
}

+(void)setAppSupportsChinaSetup:(BOOL)isAppSupportsCN{
    [ZIAMUtil sharedUtil].isAppSupportingChinaSetup = isAppSupportsCN;
}

+(void)donotSendScopesParam{
    [ZIAMUtil sharedUtil].donotSendScopesParam = YES;
}

+(void)setShouldPresentIniPadFormSheetPresentationStyle:(BOOL)shouldPresentInFormSheet{
    [ZIAMUtil sharedUtil].shouldPresentInFormSheet = shouldPresentInFormSheet;
}

+(void) startProgress:(void (^)(void)) callbackBlock {
    [ZIAMUtil sharedUtil]->showProgressBlock = callbackBlock;
}

+(void) endProgress:(void (^)(void)) callbackBlock {
    [ZIAMUtil sharedUtil]->endProgressBlock = callbackBlock;
}

+(void)confirmUnconfirmedUserAndGetOAuth2Token:(ZSSOKitAccessTokenHandler)tokenBlock{
    [ZIAMUtil sharedUtil].shouldSendUnconfirmedUserParam = YES;
    
    [[ZIAMUtil sharedUtil] getForceFetchOAuthToken:^(NSString *token) {
        tokenBlock(token,nil);
    } andFailure:^(NSError *error) {
        tokenBlock(nil,error);
    }];
}

+(void)forceFetchProfilePhotoFromServerHavingAccessToken:(NSString *)token photoHandler:(ZSSOKitPhotoFetchHandler)photoBlock{
    [[ZIAMUtil sharedUtil] forceFetchProfilePhotoForCurrentUserhavingAccessToken:token withSuccessBlock:^(NSData *photoData) {
        photoBlock(photoData,nil);
    } withErrorBlock:^(NSError *error) {
        photoBlock(nil, error);
    }];
}

+(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID
                               forService:(NSString * _Nullable)service
                                  handler:(ZSSOKitHandShakeIDHandler)handshakeIDHandler {
    
    [[ZIAMUtil sharedUtil] generateHandshakeIDHavingClientZID:clientZID havingZUID:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain] forService:service WithSuccess:^(NSString *token) {
        handshakeIDHandler(token, nil);
    } andFailure:^(NSError *error) {
        handshakeIDHandler(nil, error);
    }];
}
 
+(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID
                               havingZUID:(NSString *)zuid
                               forService:(NSString * _Nullable)service
                                  handler:(ZSSOKitHandShakeIDHandler)handshakeIDHandler {
    [[ZIAMUtil sharedUtil] generateHandshakeIDHavingClientZID:clientZID havingZUID:zuid forService:service WithSuccess:^(NSString *token) {
         handshakeIDHandler(token, nil);
    } andFailure:^(NSError *error) {
        handshakeIDHandler(nil, error);
    }];
}

+(void)activateTokenForHandshakeID:(NSString *)handshakeID
               ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                           handler:(ZSSOKitTokenActivationHandler)activationHandler{
    [self activateTokenForHandshakeID:handshakeID
                  ignorePasswordPrompt:ignorePasswordVerification
                              forZUID:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain] handler:activationHandler];
}

+(void)activateTokenForHandshakeID:(NSString *)handshakeID
               ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                           forZUID:(NSString *)zuid
                           handler:(ZSSOKitTokenActivationHandler)activationHandler {
    
    [[ZIAMUtil sharedUtil] activateRefreshTokenUsing:handshakeID
                                          havingZUID:zuid
                                ignorePasswordPrompt:ignorePasswordVerification
                                         WithSuccess:^(NSString *token) {
        activationHandler(YES, nil);
    } andFailure:^(NSError *error) {
        activationHandler(NO, error);

    }];
}

+ (void)observeSIWAAuthticationStateHavingCallback:(ZSSOKitSignInWithAppleAuthStateChangeHandler)SIWAAuthStateHandler{
    [[ZIAMUtil sharedUtil] observeSIWAAuthticationStateHavingCallback:^(NSString *zuid, NSError *error) {
        SIWAAuthStateHandler(error);
    }];
}
+ (void)observeSIWAAuthticationStateWithZUIDHavingCallback:(ZSSOKitSignInWithAppleAuthStateChangeWithZUIDHandler)SIWAAuthStateHandler{
    [[ZIAMUtil sharedUtil] observeSIWAAuthticationStateHavingCallback:^(NSString *zuid, NSError *error) {
        SIWAAuthStateHandler(zuid,error);
    }];
}

+(NSString *)getMangedMDMToken{
    return [[ZIAMUtil sharedUtil] getMDMToken];
}

+ (void)sendOTPTo:(NSString*)mobileNumber
countryCode:(NSString*)code
   forZUID:(NSString*)userZUID
    WithResponse:(ZSSOKitOTPCodeResponse)response {
    [[ZIAMUtil sharedUtil] sendOTPTo:mobileNumber
                         countryCode:code
                             forZUID:userZUID
                        WithResponse:response];
}
+ (void)resendOTPTo:(NSString*)mobileID
       forZUID:(NSString*)userZUID
       WithResponse:(ZSSOKitErrorResponse)response {
    [[ZIAMUtil sharedUtil] resendOTPForMobilID:mobileID forZUID:userZUID WithResponse:response];

}
+(void)verifyMobileD:(NSString*)mobileID
WithOTPCode:(NSString *)OTP
    forZUID:(NSString*)userZUID
   response:(ZSSOKitErrorResponse)response {
    [[ZIAMUtil sharedUtil] verifyMobileD:mobileID
                             WithOTPCode:OTP
                                 forZUID:userZUID
                                response:response];
}
+ (void) activateSSOTokenForZUID:(NSString*)zuid
                  HavingCallback:(ZSSOKitTokenActivationHandler)callback {
    [[ZIAMUtil sharedUtil] verifySSOPasswordForZUID:zuid success:^(NSString *token) {
        callback(YES,nil);
    } failure:^(NSError *error) {
        callback(NO,error);
    }];
}

+(void)presentCloseAccountViewControllerWithoutSignInPage:(ZSSOKitErrorResponse)response {
    [[ZIAMUtil sharedUtil] closeAccountFor:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain] havingCompletionHandler:^(NSError *error) {
        response(error);
    }];
}

+(void)presentCloseAccountViewControllerWithoutSignInPageForUserHavingZUID:(NSString*)ZUID completionHandler:(ZSSOKitErrorResponse)response  {
    [[ZIAMUtil sharedUtil] closeAccountFor:ZUID havingCompletionHandler:^(NSError *error) {
        response(error);
    }];
}


+(void)updatePhoto:(UIImage*)image uploadHandler:(ZSSOKitErrorResponse)uploadBlock{
    [[ZIAMUtil sharedUtil] updatePhotoOfUserHavingZUID:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain] image:image WithSuccess:^{
        uploadBlock(nil);
    } failure:^(NSError *error) {
        uploadBlock(error);
    }];
}
+ (void)setDelegateForSSLPinning:(id <ZSSOSSLChallengeDelegate>) delegate {
    [[ZIAMUtil sharedUtil] setSSLPinningDelegate:delegate];
}

+ (void)setBaseURL:(NSString *)urlString {
    [ZIAMUtil sharedUtil]->BaseUrl = urlString;
}

+ (void) presentWebkitViewForZUID:(NSString*)zuid
                      url:(NSURL*)url
                           headers:(NSDictionary<NSString*, NSString*> *)headers
                         WithFailure:(ZSSOKitErrorResponse)failure {
    [[ZIAMUtil sharedUtil] openWebkitViewForZUID:zuid url:url headers:headers WithFailure:failure];
}

#if !TARGET_OS_WATCH
+ (void) getViewForLoadingWebcontentForZUID:(NSString*)zuid
                                        url:(NSURL*)url
                                     headers:(NSDictionary<NSString*, NSString*> *)headers
                      withCompletionHandler:(ZSSOKitContentViewHandler)handler {
    [[ZIAMUtil sharedUtil] getWebsessionView:zuid url:url headers:headers WithCompletion:^(UIView *viewForWebContent, NSError *error) {
        handler(viewForWebContent, error);
    }];
}
#endif

+ (void) presentReauthenticationPageForUser:(NSString*)zuid
                         WithFailure:(ZSSOKitErrorResponse)failure {
    [[ZIAMUtil sharedUtil] showReloginForUser:zuid WithCompletion:failure];
}

+ (void) presentVerifyEmailForUser:(NSString*)zuid
         WithFailure:(ZSSOKitErrorResponse)failure {
    [[ZIAMUtil sharedUtil] showEmailVerificationPage:zuid WithCompletion:failure];
}

+ (void) getJWTForUser:(NSString*)ZUID portalID:(NSString*)portalID completion:(ZSSOKitAccessTokenHandler)completion {
    [[ZIAMUtil sharedUtil] getJWTForUser:ZUID portalID:portalID success:^(NSString *token) {
        completion(token, nil);
    } failure:^(NSError *error) {
        completion(nil, error);
    }];
}

+ (void)addSecondaryEmailIDForZUID:(NSString *)zuid WithCallback:(ZSSOKitAddEmailIDHandler)handler {
    [[ZIAMUtil sharedUtil] addSecondaryEmailIDForZUID:zuid WithSuccess:^(NSString *token) {
        handler(token, nil);
    } andFailure:^(NSError *error) {
        handler(nil, error);
    }];
}

+ (void)addSecondaryEmailIDWithCallback:(ZSSOKitAddEmailIDHandler)handler {
    [[ZIAMUtil sharedUtil] addSecondaryEmailIDForZUID:[[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain] WithSuccess:^(NSString *token) {
        handler(token, nil);
    } andFailure:^(NSError *error) {
        handler(nil, error);
    }];
}

-(void)clearWebSiteData:(responseSuccessBlock)completion {
    [[ZIAMUtil sharedUtil] clearWebSiteData:completion];
}
@end
