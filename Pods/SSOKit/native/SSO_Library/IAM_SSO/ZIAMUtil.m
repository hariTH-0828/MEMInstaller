//
//  ZIAMUtil.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 21/12/17.
//  Copyright © 2017 Kumareshwaran. All rights reserved.
//

#import "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#include "SSONetworkManager.h"
#include "ZSSOUser+Internal.h"
#include "ZSSOProfileData+Internal.h"
#include "SSOSFSafariViewController.h"
#include "ZIAMToken+Internal.h"
#include "ZSSODCLUtil.h"
#include "ZIAMErrorHandler.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"
#import "ZSSOUIKit.h"
#import "SSOWebkitControllerViewController.h"
#include "SSOTokenFetch.h"
#import "UIView+ZIAMView.h"
#if !TARGET_OS_WATCH
#import "DeviceCheck/DeviceCheck.h"
#endif
#if !SSOKit_DoNotUseXcode11
#import "AuthenticationServices/AuthenticationServices.h"
#endif
#if SSOKit_WECHATSDK_SUPPORTED
#import "WeChatUtil.h"
#endif

#if __has_include("SSOKit-Swift.h")
    #import "SSOKit-Swift.h"
#else
    #import "SSOKit/SSOKit-Swift.h"
#endif

SSOWebSessionHeaderKeys SSOWebSessionUserAgent = @"User-Agent";

#if TARGET_OS_WATCH || SSOKit_DoNotUseXcode11
@interface ZIAMUtil ()
#else
@interface ZIAMUtil ()<ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding>
#endif
{
    BOOL isSSOAccessToken;
    dispatch_queue_t oauthGetQueue;
    #if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY && !SSOKit_DoNotUseXcode11
        UIView *loadingviewFrame;
        UIActivityIndicatorView *loadingActivityView;
    #endif
}
@end

@implementation ZIAMUtil

+ (ZIAMUtil *)sharedUtil {
    static ZIAMUtil *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance->oauthGetQueue = dispatch_queue_create("com.zoho.ssokit.oauthqueue", 0);
        [sharedInstance initTokenFetch];
    });

    return sharedInstance;
}

//Start of ZSSOKit Helpers
//Initializer
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
- (void) initWithClientID: (NSString*)clientID
                    Scope:(NSArray*)scopearray
                URLScheme:(NSString*)URLScheme
               MainWindow:(UIWindow*)mainWindow
                BuildType:(SSOBuildType)buildType{
    [self initExtensionWithClientID:clientID Scope:scopearray URLScheme:URLScheme BuildType:buildType];
    lock = [[NSLock alloc] init];
#if !SSO_APP__EXTENSION_API_ONLY
    MainWindow = mainWindow;
#endif
}
#endif


#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH
-(UIWindow *)getActiveWindow{
    if(self.presentationContextProviderSSOKit){
        return [self.presentationContextProviderSSOKit presentationAnchorForSSOKit];
    }else{
        return [ZIAMUtil sharedUtil]->MainWindow;
    }
}
#endif

- (void) initExtensionWithClientID:(NSString*)clientID
                             Scope:(NSArray*)scopearray
                         URLScheme:(NSString*)URLScheme
                         BuildType:(SSOBuildType)buildType{

    ClientID = clientID;

    // Create a string to concatenate all scopes existing in the _scopes array.
    Scopes = @"";
    BOOL isProfileScopeGiven = NO;
    BOOL isContactsScopeGiven = NO;



    for (int i=0; i<[scopearray count]; i++) {
        if([[scopearray objectAtIndex:i] caseInsensitiveCompare:@"aaaserver.profile.READ"] == NSOrderedSame){
            isProfileScopeGiven = YES;
        }
        if([[scopearray objectAtIndex:i] caseInsensitiveCompare:@"zohocontacts.userphoto.READ"] == NSOrderedSame){
            isContactsScopeGiven = YES;
        }

        Scopes = [Scopes stringByAppendingString:[scopearray objectAtIndex:i]];

        // If the current scope is other than the last one, then add the "+" sign to the string to separate the scopes.
        if (i < [scopearray count] - 1) {
            Scopes = [Scopes stringByAppendingString:@","];
        }
    }
    if(!isProfileScopeGiven){
        if([Scopes isEqualToString:@""]){
            Scopes = [Scopes stringByAppendingString:@"aaaserver.profile.READ"];
        }else{
            Scopes = [Scopes stringByAppendingString:@",aaaserver.profile.READ"];
        }

    }
    if(!isContactsScopeGiven){
        Scopes = [Scopes stringByAppendingString:@",zohocontacts.userphoto.READ"];
    }
    if(![URLScheme hasSuffix:@"://"]){
        UrlScheme = [URLScheme stringByAppendingString:@"://"];
    }else{
        UrlScheme = URLScheme;
    }

    MODE = buildType;
    NSBundle *bundle = [NSBundle mainBundle];

    [self initMode:MODE];

    if ([[bundle infoDictionary] valueForKey:@"SSOKIT_MAIN_APP_BUNDLE_ID"]) {
        AppName = [[bundle infoDictionary] valueForKey:@"SSOKIT_MAIN_APP_BUNDLE_ID"];
        return;
    }

    AppName = [bundle bundleIdentifier];

    if([[ZIAMUtil sharedUtil]checkShouldCallRevokeTokenInKeychain]){
        [[ZIAMUtil sharedUtil]revokeAccessTokenWithSuccess:^{
            [[ZIAMUtil sharedUtil]resetRevokeFailedinKeychain];
        } andFailure:^(NSError *error) {

        }];
    }

}

//Get Token
- (void) getTokenWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{

    [self getTokenForZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
    return;
}

- (void) getTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self processgetTokenForZuid:zuid WithSuccess:success andFailure:failure];
        return;
    });
    return;
}

- (void) getTokenForWMSWithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure{
    wmsCallBack = YES;
    [self getTokenWithSuccess:^(NSString *token) {
        success(token,self->expiresinMillis-wmsTimeCheckMargin);
        self->wmsCallBack = NO;
    } andFailure:^(NSError *error) {
        failure(error);
        self->wmsCallBack = NO;
    }];
}
-(void)getTokenForWMSHavingZUID:(NSString *)zuid WithSuccess:(requestWMSSuccessBlock)success andFailure:(requestFailureBlock)failure{
    wmsCallBack = YES;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        success(token,self->expiresinMillis-wmsTimeCheckMargin);
        self->wmsCallBack = NO;
    } andFailure:^(NSError *error) {
        failure(error);
        self->wmsCallBack = NO;
    }];
}

-(ZIAMToken *)getSyncOAuthToken{
    __block ZIAMToken *tokenObj = nil;
    [self getTokenForWMSWithSuccess:^(NSString *token, long long expiresMillis) {
        tokenObj = [[ZIAMToken alloc] init];
        [tokenObj initWithToken:token expiry:(int)expiresMillis error:nil];
    } andFailure:^(NSError *error) {
        tokenObj = [[ZIAMToken alloc] init];
        [tokenObj initWithToken:nil expiry:0 error:error];
    }];
    while (!tokenObj) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return tokenObj;
}

//Watch Utils
- (NSDictionary *)giveOAuthDetailsForWatchApp{
    return [self giveOAuthDetailsForWatchAppForZUID:[self getCurrentUserZUIDFromKeychain]];
}

- (NSDictionary *)giveOAuthDetailsForWatchAppForZUID:(NSString *)zuid{
    NSMutableDictionary *OAuthDetails = [[NSMutableDictionary alloc] init];

    BOOL isSSOLogin = [self getIsSignedInUsingSSOAccountForZUID:zuid];
    if(isSSOLogin) {
        //Handle For myzoho case later
        [OAuthDetails setValue:[self getSSOClientSecretFromSharedKeychainForZUID:zuid] forKey:@"client_secret"];
        [OAuthDetails setValue:[self getSSORefreshTokenFromSharedKeychainForZUID:zuid] forKey:@"refresh_token"];
        [OAuthDetails setValue:zuid forKey:@"zuid"];
        [OAuthDetails setValue:[self getSSOAccessTokenDataFromSharedKeychainForZUID:zuid] forKey:@"access_token"];
        [OAuthDetails setValue:[self getSSOAccountsURLFromKeychainForZUID:zuid] forKey:@"accounts_server"];
        [OAuthDetails setValue:[self getClientIDFromSharedKeychain] forKey:@"client_id"];
        [OAuthDetails setValue:[self getSSODCLLocationFromSharedKeychainForZUID:zuid] forKey:@"location"];
        [OAuthDetails setValue:@"true" forKey:@"is_sso_account"];
    }else{
        [OAuthDetails setValue:[self getClientSecretFromKeychainForZUID:zuid] forKey:@"client_secret"];
        [OAuthDetails setValue:[self getRefreshTokenFromKeychainForZUID:zuid] forKey:@"refresh_token"];
        [OAuthDetails setValue:zuid forKey:@"zuid"];
        [OAuthDetails setValue:[self getAccessTokenDataFromKeychainForZUID:zuid] forKey:@"access_token"];
        [OAuthDetails setValue:[self getAccountsURLFromKeychainForZUID:zuid] forKey:@"accounts_server"];
        [OAuthDetails setValue:[self getDCLLocationFromKeychainForZUID:zuid] forKey:@"location"];

    }
    return OAuthDetails;
}

-(void)setOAuthDetailsInKeychainForWatchApp:(NSDictionary *)OAuthDetails{

    [self setOAuthDetailsInKeychainForWatchAppHavingZUID:[self getCurrentUserZUIDFromKeychain] details:OAuthDetails];
}

-(void)setOAuthDetailsInKeychainForWatchAppHavingZUID:(NSString *)zuid details:(NSDictionary *)OAuthDetails{

    NSString* client_secret = [OAuthDetails objectForKey:@"client_secret"];
    NSString* CurrentAppUser = [OAuthDetails objectForKey:@"zuid"];
    NSString* refresh_token = [OAuthDetails objectForKey:@"refresh_token"];
    NSData *accessTokenData = [OAuthDetails objectForKey:@"access_token"];
    NSString *accountsUrl = [OAuthDetails objectForKey:@"accounts_server"];
    NSString *client_id = [OAuthDetails objectForKey:@"client_id"];
    NSString *location = [OAuthDetails objectForKey:@"location"];
    NSString *is_sso_account = [OAuthDetails objectForKey:@"is_sso_account"];

    if([is_sso_account isEqualToString:@"true"]){
        if(refresh_token)
            [self setSSORefreshTokenInSharedKeychain:refresh_token ForZUID:zuid];
        if(client_secret)
            [self setSSOClientSecretInSharedKeychain:client_secret ForZUID:zuid];
        if(accountsUrl)
            [self setAccountsURL:accountsUrl inKeychainForZUID:CurrentAppUser];
        if(accessTokenData != nil)
            [self setAppSSOAccessTokenDataInSharedKeychain:accessTokenData ForZUID:zuid];
        if(CurrentAppUser)
            [self setSSOZUIDInSharedKeychain:CurrentAppUser];
        if(location){
            [self setDCLLocation:location inKeychainForZUID:CurrentAppUser];
        }
        if(client_id)
            [self setSSOClientIDFromSharedKeychain:client_id];
    }else{
        if(refresh_token)
            [self setRefreshToken:refresh_token inKeychainForZUID:CurrentAppUser];
        if(client_secret)
            [self setClientSecret:client_secret inKeychainForZUID:CurrentAppUser];
        if(accountsUrl)
            [self setAccountsURL:accountsUrl inKeychainForZUID:CurrentAppUser];
        if(accessTokenData != nil)
            [self setAccessTokenData:accessTokenData inKeychainForZUID:CurrentAppUser];
        if(CurrentAppUser)
            [self setCurrentUserZUIDInKeychain:CurrentAppUser];
        if(client_id){
            [self setClientID:client_id inKeychainForZUID:CurrentAppUser];
        }
        if(location){
            [self setDCLLocation:location inKeychainForZUID:CurrentAppUser];
        }
    }
}

//Present Methods
- (void) presentInitialViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    ButtonClick = YES;
    
//    long long currentMillis = [[ZIAMUtil sharedUtil] getCurrentTimeMillis];
//    NSString* nbf = [NSString stringWithFormat:@"%lld",currentMillis/1000-(5*60)];
//    NSString* exp = [NSString stringWithFormat:@"%lld",currentMillis/1000+(5*60)];
//
//    NSMutableDictionary *mdmDetails = [[NSMutableDictionary alloc] init];
//    [mdmDetails setValue:nbf forKey:@"nbf"];
//    [mdmDetails setValue:exp forKey:@"exp"];
//
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mdmDetails options:NSJSONWritingPrettyPrinted error:&error];
//   // NSData *jsonData = [@"Method to get MDM Token from Managed MDM Configuration to set X-MDM-Token header value required for all API calls specifically added for Managed MDM case." dataUsingEncoding:NSUTF8StringEncoding];
//    //NSData *data = [rt_cook_string dataUsingEncoding:NSUTF8StringEncoding];
//    NSData *encryptedData = [jsonData AES128CBCEncryptedDataWithKey:@"SXOQVLQ32TWKXXUN"];
//    NSString *encryptedDataString = [encryptedData base64EncodedStringWithOptions:0];
    
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentInitialViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    ButtonClick = YES;
    UrlParams = urlParams;
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentGoogleSigninSFSafariViewControllerWithSuccess:(requestSuccessBlock)success
                                                   andFailure:(requestFailureBlock)failure{

    ButtonClick = YES;
    showGoogleSignIn = YES;
    [self getTokenWithSuccess:success andFailure:failure];
}

- (void) presentGoogleSigninSFSafariViewControllerWithoutOneAuthSuccess:(requestSuccessBlock)success
                                                             andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->showGoogleSignIn = YES;
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
    });
}
#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY && !SSOKit_DoNotUseXcode11
// SIWA Works
- (void) presentNativeSignInWithAppleWithSuccess:(requestSuccessBlock)success
                                      andFailure:(requestFailureBlock)failure{
    finalMultiAccountSuccessBlock = success;
    finalMultiAccountFailureBlock = failure;
    DLog(@"Sign In With Apple Button tapped");
    if (@available(iOS 13.0, *)) {
        if([self isChineseLocale] && _isAppSupportingChinaSetup){
            [self showDCChooserActionSheet];
        }else{
            [self presentSIWA];
        }
        
    } else {
        // Return Error SIWA unavailable for this iOS version
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"SIWA unavailable for this iOS version" forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAUnavailableForOSError userInfo:userInfo];
        finalMultiAccountFailureBlock(returnError);
    }
}
-(void)showDCChooserActionSheet {
    NSString *actionSheetTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.title" Comment:@"Select your region"];
    NSString *cancelTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.Cancel" Comment:@"Cancel"];
    NSString *zohoCNTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.china" Comment:@"China"];
    NSString *zohoTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.dcchooser.other" Comment:@"Other"];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:actionSheetTitle message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    // keep safe zones
    UIAlertAction *actionZoho = [UIAlertAction actionWithTitle:zohoTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->_siwaBaseURL = self->BaseUrl;
        [self presentSIWA];
        
    }];

    
    // delete safe zones
    UIAlertAction *actionZohoCN = [UIAlertAction actionWithTitle:zohoCNTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self->_siwaBaseURL = kZoho_CN_Base_URL;
        [self presentSIWA];
        
    }];
    
    // cancel
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction* _Nonnull action) {
        NSError *returnError;
        
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Select your region cancelled" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSODCChooserCancelledError userInfo:userInfo];
        self->finalMultiAccountFailureBlock(returnError);
        return;
    }];
    [alertVC addAction:actionZohoCN];
    [alertVC addAction:actionZoho];
    [alertVC addAction:actionCancel];
    
    //[[alertVC popoverPresentationController] setSourceView:MainWindow.rootViewController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *top = [self topViewController];
        [[alertVC popoverPresentationController] setSourceView:self->_dcChooserActionSheetSourceView];
        [[alertVC popoverPresentationController] setSourceRect:self->_dcChooserActionSheetSourceView.bounds];
        if(top){
            [top presentViewController:alertVC animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:alertVC animated:YES completion:nil];
        }
    });
}
-(void)presentSIWA{
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider* appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest* request = [appleIDProvider createRequest];
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

        ASAuthorizationController* ctrl = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        ctrl.presentationContextProvider = self;
        ctrl.delegate = self;
        [ctrl performRequests];
    }
}
// SIWA Authorization success callback
- (void)authorizationController:(ASAuthorizationController *)controller
   didCompleteWithAuthorization:(ASAuthorization *)authorization API_AVAILABLE(ios(13.0)){

    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
//        NSString *user = appleIDCredential.user;
//        NSString *email = appleIDCredential.email;
        // Store UserID for checking Revoke status later...
        if(appleIDCredential.fullName.givenName){
            [self setSIWAUserFirstNameInKeychain:appleIDCredential.fullName.givenName];
        }
        if(appleIDCredential.fullName.familyName){
            [self setSIWAUserLastNameInKeychain:appleIDCredential.fullName.familyName];
        }
        [self setSIWAUserIDInKeychain:appleIDCredential.user];
        NSString* GT = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];
        [self proceedSignInUsingGrantToken:GT forProvider:@"apple"];

    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {

        //To Do: Study more on this...
/*
        // User login uses existing password credentials
        ASPasswordCredential *passwordCredential = authorization.credential;
        // User ID of the password credential object Unique ID of the user
        NSString *user = passwordCredential.user;
        // Password for the password credential object
        NSString *password = passwordCredential.password;
 */

        //Might be for native sign in using username and password...
    } else {
        //Authorization information does not match
        DLog(@"Authorization information does not match");

    }
}

//! SIWA Authorization failed callback
- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)){
        NSString *errorMsg = nil;
        NSInteger errorcode = 0;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"User canceled authorization request";
            errorcode = k_SSONativeSIWAASAuthorizationErrorCanceled;
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"Authorization request failed";
            errorcode = k_SSONativeSIWAASAuthorizationErrorFailed;
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"Authorization request response is invalid";
            errorcode = k_SSONativeSIWAASAuthorizationErrorInvalidResponse;
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"Failed to process authorization request";
            errorcode = k_SSONativeSIWAASAuthorizationErrorNotHandled;
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"Authorization request failed for unknown reason";
            errorcode = k_SSONativeSIWAASAuthorizationErrorUnknown;
            break;
    }

    if (errorMsg) {
        //return error callback...
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:errorMsg forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorcode userInfo:userInfo];
        finalMultiAccountFailureBlock(returnError);
        return;
    }

    if (error.localizedDescription) {
        finalMultiAccountFailureBlock(error);
        return;
    }

    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:@"SIWA unknown failure" forKey:NSLocalizedDescriptionKey];
    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAError userInfo:userInfo];
    finalMultiAccountFailureBlock(returnError);
}

- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller API_AVAILABLE(ios(13.0)){
    return [self getActiveWindow];
}
/*
- (void)observeAppleSignInState { if (@available(iOS 13.0, *)) {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    if (@available(iOS 13.0, *)) {
           [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
       }
    [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil]; } }
- (void)handleSignInWithAppleStateChanged:(NSNotification *)noti {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", noti);
    if([noti.name isEqualToString:@"ASAuthorizationAppleIDCredentialRevokedNotification"]){
        NSLog(@"Call SSOKit Revoke method");
    }

}
- (void)dealloc {
    if (@available(iOS 13.0, *)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
    }
}
 */
 - (void)observeSIWAAuthticationStateHavingCallback:(requestMultiAccountFailureBlock)failure {

     if (@available(iOS 13.0, *)) {
         // A mechanism for generating requests to authenticate users based on their Apple ID.
         ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];

         NSString *userIdentifier = [self getSIWAUserIDFromKeychain];
         NSError * __block returnError;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
         if (userIdentifier) {
             NSString *SIWA_ZUID = [self getZUIDFromKeychainForSIWAUID:userIdentifier];
             //Returns the credential state for the given user in a completion handler.
             [appleIDProvider getCredentialStateForUserID:userIdentifier completion:^(ASAuthorizationAppleIDProviderCredentialState credentialState, NSError * _Nullable error) {
                 switch (credentialState) {
                         // Apple certificate authorization status
                     case ASAuthorizationAppleIDProviderCredentialRevoked:
                         // Apple authorization credentials are invalid
                         [userInfo setValue:@"Apple authorization credentials Revoked" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialRevoked userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         break;
                     case ASAuthorizationAppleIDProviderCredentialAuthorized:
                         // Apple authorization credentials are in good condition
                         failure(SIWA_ZUID,nil);
                         break;
                     case ASAuthorizationAppleIDProviderCredentialNotFound:
                         // No Apple Authorization Credentials Found
                         [userInfo setValue:@"No Apple Authorization Credentials Found" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialNotFound userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         // Can guide the user to log in again
                         break;
                     case ASAuthorizationAppleIDProviderCredentialTransferred:
                         // AppleID Credential Transferred

                        [userInfo setValue:@"AppleID Credential Transferred" forKey:NSLocalizedDescriptionKey];
                                returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateCredentialTransferred userInfo:userInfo];
                         failure(SIWA_ZUID,returnError);
                         break;
                 }
             }];

         }else{
             //No SIWA User ID found...
            [userInfo setValue:@"SIWA No UserID Found in Keychain" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSIWAAuthStateNoUserID userInfo:userInfo];
             failure(nil, returnError);
         }

     }
 }
-(void)addLoadingViewInView:(UIView *)view{
#if !SSO_APP__EXTENSION_API_ONLY

    loadingviewFrame = [[UIView alloc] initWithFrame:CGRectZero];
    [view addSubview:loadingviewFrame];
    
    //LoadingView Constraints
    loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
    [loadingviewFrame pinCenterToSuperView];
    [loadingviewFrame setWidthConstraint:100];
    [loadingviewFrame setHeightConstraint:90];

    [view setNeedsLayout];
    [view layoutIfNeeded];
    
    
    //view.backgroundColor = [UIColor clearColor];
    
    loadingviewFrame.layer.cornerRadius = 10;
        loadingviewFrame.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        loadingviewFrame.hidden = YES;
        
        loadingActivityView = [[UIActivityIndicatorView alloc]
                               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loadingActivityView.frame = loadingviewFrame.bounds;
        loadingActivityView.hidden = NO;
        [loadingviewFrame addSubview:loadingActivityView];
        UILabel *loadingText= [[UILabel alloc]initWithFrame:loadingviewFrame.frame];
        loadingText.hidden = NO;
        loadingText.text =  [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.loading" Comment:@"Loading..."];
        loadingText.textColor = [UIColor whiteColor];
        loadingText.backgroundColor = [UIColor clearColor];
        loadingText.textAlignment = NSTextAlignmentCenter;
        loadingText.font = [UIFont fontWithName:@"Helvetica" size:16];
        loadingText.center = CGPointMake(loadingviewFrame.frame.size.width/2, (loadingviewFrame.frame.size.height/2)+30);
        [loadingviewFrame addSubview:loadingText];
        
        [view addSubview:loadingviewFrame];
        loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
        
    [loadingviewFrame pinCenterToSuperView];
    [loadingviewFrame setWidthConstraint:100];
    [loadingviewFrame setHeightConstraint:90];
        [view setNeedsLayout];
        [view layoutIfNeeded];
#endif

}
-(void)showLoadingIndicator{
    if ([ZIAMUtil sharedUtil]->showProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->showProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            [self->loadingActivityView startAnimating];
#endif
            self->loadingviewFrame.hidden = NO;
        });
    }
}

-(void)hideLoadingIndicator{
    if ([ZIAMUtil sharedUtil]->endProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->endProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
#if !SSO_APP__EXTENSION_API_ONLY
            [self->loadingActivityView stopAnimating];
#endif
            self->loadingviewFrame.hidden = YES;
        });
    }
    
}
-(void)proceedSignInUsingGrantToken:(NSString *)grantToken forProvider:(NSString *)provider{
//    UIView *loadingView = [[UIView alloc] initWithFrame:[self topViewController].view.bounds];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
//        UIActivityIndicatorView *loadingActivity;
//        if (@available(iOS 13.0, *)) {
//            loadingActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
//
//        } else {
//            loadingActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//        }
//        loadingActivity.center = loadingView.center;
//        [loadingView addSubview:loadingActivity];
//        [[self topViewController].view addSubview:loadingView];
//        [[self topViewController].view bringSubviewToFront:loadingView];
//        [[self topViewController].view setNeedsLayout];
//        [[self topViewController].view layoutIfNeeded];
//        [loadingActivity startAnimating];
//    });
     
     [self addLoadingViewInView:[self topViewController].view];
    NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
    if([provider isEqualToString:@"apple"]){
        //Add Parameters
        NSMutableDictionary *nameHeader = [[NSMutableDictionary alloc]init];
        NSMutableDictionary* nameParams = [[NSMutableDictionary alloc]init];
        
        if([self getSIWAUserFirstNameFromKeychain]){
            [nameParams setValue:[self getSIWAUserFirstNameFromKeychain] forKey:@"firstName"];
            [nameParams setValue:[self getSIWAUserLastNameFromKeychain] forKey:@"lastName"];
            [nameHeader setValue:nameParams forKey:@"name"];
            [paramsAndHeaders setValue:nameHeader forKey:@"custom_info"];
        }
    }
    
    [paramsAndHeaders setValue:grantToken forKey:@"id_data"];
    [paramsAndHeaders setValue:provider forKey:@"provider"];
    [paramsAndHeaders setValue:ClientID forKey:@"c_id"];
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    //URL
    NSString *urlString;
    NSString *accountsbaseURL = BaseUrl;
    NSString *managedMDMDefaultDC = [[ZIAMUtil sharedUtil]getMDMDefaultDC];
    if(managedMDMDefaultDC){
        managedMDMDefaultDC = [managedMDMDefaultDC lowercaseString];
        NSArray *zohoDCArray = @[@"us", @"in", @"eu", @"au", @"cn"];
        int defaultDCInt = (int)[zohoDCArray indexOfObject:managedMDMDefaultDC];
        switch (defaultDCInt) {
            case 0:
                accountsbaseURL = kZoho_Base_URL;
                break;
            case 1:
                accountsbaseURL = kZoho_IN_Base_URL;
                break;
            case 2:
                accountsbaseURL = kZoho_EU_Base_URL;
                break;
            case 3:
                accountsbaseURL = kZoho_AU_Base_URL;
                break;
            case 4:
                accountsbaseURL = kZoho_CN_Base_URL;
                break;
                
            default:
                break;
        }
    }
    
    urlString = [NSString stringWithFormat:@"%@%@",accountsbaseURL,kSSONativeSignInHandling_URL];
    if([provider isEqualToString:@"wechat"] || [self->_siwaBaseURL isEqualToString:kZoho_CN_Base_URL]){
        urlString = [NSString stringWithFormat:@"%@%@",kZoho_CN_Base_URL,kSSONativeSignInHandling_URL];
    }
    [self showLoadingIndicator];
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                    //Request success
                                                    [self hideLoadingIndicator];
                                                    if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                        DLog(@"Success Response ");
                                                        self->NativeSignInTok = [jsonDict objectForKey:@"tok"];
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             self->fsProvider = provider;
                                                             [self presentSSOSFSafariViewControllerWithSuccess:self->finalMultiAccountSuccessBlock andFailure:self->finalMultiAccountFailureBlock];
                                                             
                                                         });
                                                    }else{
                                                        //failure handling...
                                                        DLog(@"Status: Failure Response");
                                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                        [userInfo setValue:@"Native Sign In Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInServerError userInfo:userInfo];
                                                        self->finalMultiAccountFailureBlock(returnError);
                                                    }
                                                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                    [self hideLoadingIndicator];
                                                    DLog(@"Failure Response");
                                                    [self handleNativeSigninError:errorType error:error failureBlock:self->finalMultiAccountFailureBlock];
                                                }];
}
#endif

//WeChatLogin
-(void) presentWeChatSignInHavingWeChatID:(NSString *)appID weChatAppSecret:(NSString *)appSecret universalLink:(NSString *)universalLink WithSuccess:(requestSuccessBlock)success
andFailure:(requestFailureBlock)failure{
    #if SSOKit_WECHATSDK_SUPPORTED
        finalMultiAccountSuccessBlock = success;
        finalMultiAccountFailureBlock = failure;
        WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
        weChatAppID = appID;
        weChatAppSecret = appSecret;
        weChatUniversalLink = universalLink;
        [weChatUtil presentWeChatSignIn];
    #endif
}

- (void) presentSignUpViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    if(_isAppSupportingChinaSetup && [self isChineseLocale]){
        BaseUrl = kZoho_CN_Base_URL;
    }
    self->showSignUp = YES;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerWithCustomParams:(NSString *)urlParams success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    UrlParams = urlParams;
    if(_isAppSupportingChinaSetup && [self isChineseLocale]){
        BaseUrl = kZoho_CN_Base_URL;
    }
    self->showSignUp = YES;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    self->SignUpUrl = signupUrl;
    [self presentSignUp:success andFailure:failure];
}

- (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    self->SignUpUrl = signupUrl;
    self->CNSignUpURL = cnSignUpURL;
    [self presentSignUp:success andFailure:failure];
}

-(void)presentSignUp:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
    });
}

- (void) presentMultiAccountSigninWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    UrlParams = urlParams;
    [self presentMultiAccountSigninWithSuccess:success andFailure:failure];
}

- (void) presentMultiAccountSigninWithSuccess:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->isMultiAccountSignIn = YES;
        [self presentSSOSFSafariViewControllerWithSuccess:^(NSString *token) {
            success(token,self->setMultiAccountZUID);
        } andFailure:^(NSError *error) {
            failure(error);
        }];
    });
}

- (void) presentSignInUsingAnotherAccountWithCustomParams:(NSString *)urlParams success:(requestMultiAccountSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->UrlParams = urlParams;
        [self presentSSOSFSafariViewControllerWithSuccess:^(NSString *token) {
            success(token,self->setMultiAccountZUID);
        } andFailure:^(NSError *error) {
            failure(error);
        }];
    });
}
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

ZSSOUIKit *ssoKit;
- (void) presentManageAccountsViewControllerWithSuccess:(ZSSOKitManageAccountsSuccessHandler)success
                                             andFailure:(ZSSOKitManageAccountsFailureHandler)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ssoKit = [[ZSSOUIKit alloc] init];
        ssoKit.presentationContextProviderSSOKit = self.presentationContextProviderSSOKit;
        ssoKit.shouldPresentInFormSheet = self.shouldPresentInFormSheet;
        ssoKit.MainWindow = [self getActiveWindow];
        [ssoKit presentAccountChooserWithSuccess:nil andFailure:failure havingSwitchSuccess:success];
    });
}
#endif


-(void)appFirstLaunchClearData{
    [self appFirstLaunchClearDataFromKeychain];
}

-(BOOL)isUserSignedIn{
    if([self getCurrentUserZUIDFromKeychain]){
        return YES;
    }
    return NO;
}

-(BOOL) isUserSignedInUsingSIWAForZUID:(NSString *)ZUID{
    NSString *SIWAUID = [self getSIWAUserIDFromKeychain];
    if(SIWAUID){
        NSString *siwaUserZUID = [self getZUIDFromKeychainForSIWAUID:SIWAUID];
        if([siwaUserZUID isEqualToString:ZUID]){
            return YES;
        }
    }
    return NO;
}

- (void)getJWTForUser:(NSString *)zuid portalID:(NSString*)portalID success:(requestSuccessBlock)success failure:(requestFailureBlock)failure {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        BOOL isSignedUsingSSO = [self getIsSignedInUsingSSOAccountForZUID:zuid];
        
        //URL
        
        NSString *client_id;
        NSString* client_secret;
        NSString *accountsUrl;
        
        if(isSignedUsingSSO ){
            accountsUrl = [self getSSOAccountsURLFromKeychainForZUID:zuid];
            client_id = [self getClientIDFromSharedKeychain];
            client_secret = [self getSSOClientSecretFromSharedKeychainForZUID:zuid];
        }else{
            accountsUrl = [self getAccountsURLFromKeychain];
            client_id = self->ClientID;
            client_secret = [self getClientSecretFromKeychainForZUID:zuid];
        }
        NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsUrl,kSSOClientPortalJWTLogin_URL];
        NSString *encoded_gt_sec= [self getEncodedStringForString:client_secret];
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:@"remote_login_token" forKey:@"grant_type"];
        [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
        [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue:[self getUserAgentString] forKey:@"User-Agent"];
        
        NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
        if(mdmToken){
            NSString *mdmHeader = [[ZIAMUtil sharedUtil] getMDMHeaderFromMDMToken:mdmToken];
            [headers setValue:mdmHeader forKey:@"X-MDM-Token"];
        }
        
        if(isSignedUsingSSO) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        // Request....
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                DLog(@"Success Response ");
                NSString *loginAccessToken = [jsonDict objectForKey:@"jwt_token"];
                success(loginAccessToken);
            }else{
                //failure handling...
                DLog(@"Status: Failure Response");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Get Remote LoginKey Server Error Occured" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORemoteLoginJWTServerError userInfo:userInfo];
                failure(returnError);
            }
            
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            //Request failed
            failure(error);
            DLog(@"Failure Response");
            
            
            
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

- (void)setSSLPinningDelegate:(id<ZSSOSSLChallengeDelegate>)SSLPinningDelegate {
    _SSLPinningDelegate = SSLPinningDelegate;
    [[SSONetworkManager sharedManager] setSSLPinningDelegate:SSLPinningDelegate];
}

//URLScheme Redirection
-(BOOL)handleURL:url sourceApplication:sourceApplication annotation:annotation{
    // just making sure we send the notification when the URL is opened in SFSafariViewController
    if ([sourceApplication isEqualToString:@"com.apple.SafariViewService"] || [sourceApplication isEqualToString:@"com.apple.mobilesafari"]) {


        NSString* queryString = [url query];

        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([queryStringDictionary objectForKey:@"gt_hash"] || [queryStringDictionary objectForKey:@"error"] || [queryStringDictionary objectForKey:@"scope_enhanced"] || [queryStringDictionary objectForKey:@"user_confirmed"] || [queryStringDictionary objectForKey:@"activate_token"] || [queryStringDictionary objectForKey:@"device_verified"] || [queryStringDictionary objectForKey:@"usecase"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sfsafariredirection" object:queryStringDictionary];
            return YES;
        }
    }else if([sourceApplication isEqualToString:@"com.tencent.xin"]){
        #if SSOKit_WECHATSDK_SUPPORTED
            WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
            return [weChatUtil handleWeChatOpenURL:url];
        #endif
    }else if([sourceApplication isEqualToString:Service]){
        if([[url query] isEqualToString:@"cancel"]){
            //dimissed in OneAuth...
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"OneAuth Sign in Dismissed" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthSignInDismiss userInfo:userInfo];
            setFailureBlock(returnError);
            return YES;
        }


        NSString* queryString = [url query];

        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([[queryStringDictionary objectForKey:@"status"] isEqualToString:@"success"]){
            //Sign In Success from OneAuth...
            [self setCurrentUserZUIDInKeychain:[queryStringDictionary objectForKey:@"zuid"]];
            ButtonClick = NO;
#if !SSO_APP__EXTENSION_API_ONLY
            [self processgetTokenForZuid:[queryStringDictionary objectForKey:@"zuid"] WithSuccess:setSuccessBlock andFailure:setFailureBlock];
#endif
            return YES;
        }else if([[queryStringDictionary objectForKey:@"oasignout"] isEqualToString:@"YES"]){
            //dimissed in OneAuth...
            ButtonClick = NO;
            NSError *returnError;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"OneAuth Sign out done" forKey:NSLocalizedDescriptionKey];
            returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthSignOut userInfo:userInfo];
            setFailureBlock(returnError);
            return YES;
        }
    }else{
        if (@available(iOS 13.0, *)) {
            // SourceApplication is not available in iOS 13.
            // https://forums.developer.apple.com/thread/119118
            // https://forums.developer.apple.com/message/381679
        } else {
            if (!([sourceApplication isEqualToString:@"com.apple.SafariViewService"] || [sourceApplication isEqualToString:@"com.apple.mobilesafari"])){
                return NO;
            }
        }
        NSString* queryString = [url query];
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
        NSArray *urlComponents = [queryString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            DLog(@"Key : %@------- Value:%@",key,value);
            [queryStringDictionary setObject:value forKey:key];
        }
        if([queryStringDictionary objectForKey:@"gt_hash"] || [queryStringDictionary objectForKey:@"error"] || [queryStringDictionary objectForKey:@"scope_enhanced"] || [queryStringDictionary objectForKey:@"user_confirmed"] || [queryStringDictionary objectForKey:@"activate_token"] || [queryStringDictionary objectForKey:@"usecase"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sfsafariredirection" object:queryStringDictionary];
            return YES;
        }
    }
    return NO;
}
-(void)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    #if SSOKit_WECHATSDK_SUPPORTED
        WeChatUtil *weChatUtil= [[WeChatUtil alloc]init];
        return [weChatUtil handleOpenUniversalLink:userActivity];
    #endif
}


-(ZSSOUser *)getCurrentUser{
    NSString* zuid = [self getCurrentUserZUIDFromKeychain];
    return [self getZSSOUserHavingZUID:zuid];
}

//Logout Handling
-(void)revokeAccessTokenWithSuccess:(requestLogoutSuccessBlock)success
                         andFailure:(requestLogoutFailureBlock)failure{
    [self postDeviceIDtoServer:success andFailure:failure];

}

#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY

-(void)closeAccountFor:(NSString*)ZUID havingCompletionHandler:(requestFailureBlock)response {
    
    NSDictionary* tempTokenDict = [self getTempTokenForCloseAccountWebSessionForZUID:ZUID];
    
    if (tempTokenDict) {
        //Get the CurrentTime!
        long long currentMillis = [self getCurrentTimeMillis];
        
        NSString* timeStampString = [tempTokenDict objectForKey:@"expires_in_sec"];

        long long storedTime = [timeStampString longLongValue];
        
        long long time = currentMillis + timecheckbuffer;

        DLog(@"Close Account token :Current Time:%ld TimeStamp:%ld",currentMillis,timeStamp);

        if(time < storedTime){
            DLog(@"Close Account token :Time Check Success!!!");

            NSString* tempToken = [tempTokenDict objectForKey:@"token"];
            [self showAuthenticatedCloseAccountPageForZUID:ZUID havingTempToken:tempToken failureCallback:response];
        } else {
            DLog(@"Close Account token :Time Check failed!!!");
            [self deleteAccountFor:ZUID WithCallback:response];
        }
    } else {
        [self deleteAccountFor:ZUID WithCallback:response];
    }
}

-(void)openWebkitViewForZUID:(NSString*)ZUID
                      url:(NSURL*)url
                      headers:(NSDictionary<NSString*, NSString*> *)headers
              WithFailure:(requestFailureBlock)failure {
    [self getSessionTempTokenForUser:ZUID
                              action:@"websession"
                         redirectURI:url.absoluteString
                          includeLRT:NO
                         WithSuccess:^(NSString *token, long long expiresMillis, long long lastReAuthTime) {
        [self showAuthenticatedWebPageForZUID:ZUID havingTempToken:token headers:headers failureCallback:failure];
    } WithFailure:^(NSError *error) {
        failure(error);
    }];
}

#if !TARGET_OS_WATCH
-(void)getWebsessionView:(NSString*)ZUID
                      url:(NSURL*)url
                  headers:(NSDictionary<NSString*, NSString*> *)headers
              WithCompletion:(requestWebviewBlock)completion {
    [self getSessionTempTokenForUser:ZUID
                              action:@"websession"
                         redirectURI:url.absoluteString
                          includeLRT:NO
                         WithSuccess:^(NSString *token, long long expiresMillis, long long lastReAuthTime) {
        
        [self checkRootedDevice:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *webSessionURLString = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOWebSession_URL,token];
                UIView* viewContainer = [[UIView alloc] init];
                WKWebView *webview = [[WKWebView alloc] init];
                webview.translatesAutoresizingMaskIntoConstraints = false;
                [viewContainer addSubview:webview];
                [webview pinToSuperView:0];
                NSURL *urlForWebview = [NSURL URLWithString:webSessionURLString];
                NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:urlForWebview];
                
                for (NSString* key in headers) {
                    NSString* value = headers[key];
                    if ([key isEqualToString:SSOWebSessionUserAgent]) {
                        webview.customUserAgent = value;
                        continue;
                    }
                    [request setValue:value forHTTPHeaderField:key];
                }
                [webview loadRequest: request];
                completion(viewContainer, nil);
            });
        }];
    } WithFailure:^(NSError *error) {
        completion(nil, error);
    }];
}
#endif

- (void) showEmailVerificationPage:(NSString*)ZUID
                WithCompletion:(requestFailureBlock)completion {
    [self getSessionTempTokenForUser:ZUID
                              action:@"verify_email"
                         redirectURI:self->UrlScheme
                          includeLRT:NO
                         WithSuccess:^(NSString *token, long long expiresMillis, long long lastReAuthTime) {
        [self showAuthenticatedVerifyEmailPageForZUID:ZUID havingTempToken:token failureCallback:completion];
    } WithFailure:^(NSError *error) {
        completion(error);
    }];
}
- (void) showReloginForUser:(NSString*)ZUID
                WithCompletion:(requestFailureBlock)completion {
    [self getSessionTempTokenForUser:ZUID
                              action:@"reauth"
                         redirectURI:self->UrlScheme
                          includeLRT:YES
                         WithSuccess:^(NSString *token, long long expiresMillis, long long lastReAuthTime) {
        [self showAuthenticatedReLoginPageForZUID:ZUID havingTempToken:token failureCallback:completion];
    } WithFailure:^(NSError *error) {
        completion(error);
    }];
}

-(void)getSessionTempTokenForUser:(NSString*)ZUID
                           action:(NSString*)action
                      redirectURI:(NSString* _Nullable)redirectURI
                       includeLRT:(BOOL)lastReAuthTime
                      WithSuccess:(requestTempTokenBlock)success
                      WithFailure:(requestFailureBlock)failure {
    
    [self getTokenForZUID:ZUID WithSuccess:^(NSString *token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLoadingViewInView:[self topViewController].view];
        });
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* redirectURLDict = [[NSMutableDictionary alloc] init];
        [redirectURLDict setValue:redirectURI forKey:@"redirect_uri"];
        [redirectURLDict setValue:action forKey:@"action"];

//        if (lastReAuthTime) {
//            [redirectURLDict setValue:@"lrt" forKey:@"inc"];
//        }

        [paramsAndHeaders setValue:redirectURLDict forKey:@"token"];

        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue: ClientID forKey:@"X-Client-Id"];
        

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOTemporarySessionToken_URL];
        [self showLoadingIndicator];
        // Request....
        [[SSONetworkManager sharedManager]
         sendJSONPOSTRequestForURL: urlString
         parameters: paramsAndHeaders
         successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            [self hideLoadingIndicator];
            int status_code = [[jsonDict objectForKey:@"status_code"]intValue];
            NSString* tempToken = [jsonDict objectForKey:@"message"];
            if(status_code == 201 && tempToken){
                DLog(@"Success Response ");
                long long lastReauthTime;
                NSString* tempToken = [jsonDict objectForKey:@"message"];
                long long generatedTime = [self getCurrentTimeMillis] + 300000;
                NSString* lastReAuthTimeString = [jsonDict valueForKeyPath:@"token.lrt"];
                if (lastReAuthTimeString) {
                    lastReauthTime = [lastReAuthTimeString longLongValue];
                }
                success(tempToken, generatedTime, lastReauthTime);

                
            }else{
                //failure handling...
                DLog(@"Status: Failure Response");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Session token - Server Error Occured" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOTokenFetchError userInfo:userInfo];
                failure(returnError);
            }
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            [self hideLoadingIndicator];
            DLog(@"Failure Response");
            failure(error);

        }];
    } andFailure:^(NSError *oauthTokenerror) {
        failure(oauthTokenerror);
    }];
}

//close account
-(void)deleteAccountFor:(NSString*)ZUID
           WithCallback:(ZSSOKitErrorResponse)failure {
    [self getSessionTempTokenForUser:ZUID
                              action:@"close_account"
                         redirectURI:self->UrlScheme
                          includeLRT:NO
                         WithSuccess:^(NSString *tempToken, long long generatedTime, long long lastReAuthTime) {
        [self setTempTokenForCloseAccountWebSession:tempToken expiresIn:[NSString stringWithFormat:@"%lld", generatedTime] forZUID:ZUID];

        [self showAuthenticatedCloseAccountPageForZUID:ZUID havingTempToken:tempToken failureCallback:failure];
    } WithFailure:^(NSError *error) {
        
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOCloseAccountServerError userInfo:error.userInfo];
        failure(returnError);

    }];
    
}

-(void)showAuthenticatedCloseAccountPageForZUID:(NSString*)ZUID havingTempToken:(NSString*)tempToken failureCallback:(ZSSOKitErrorResponse)failure {
    self->User_ZUID = ZUID;
    self->CloseAccountURL = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOCloseAccount_URL,tempToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
        
    });
}

-(void)showAuthenticatedWebPageForZUID:(NSString*)ZUID havingTempToken:(NSString*)tempToken headers:(NSDictionary<NSString*, NSString*> *)headers failureCallback:(ZSSOKitErrorResponse)failure {
    self->User_ZUID = ZUID;
   
#if !SSO_APP__EXTENSION_API_ONLY
    
    [self checkRootedDevice:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            SSOWebkitControllerViewController *sfview = [[SSOWebkitControllerViewController alloc] init];
            sfview.modalPresentationStyle = UIModalPresentationOverFullScreen;
            NSString *webSessionURLString = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOWebSession_URL,tempToken];

            NSString * encryptedMDMParam = [self getEncryptedMDMQueryParam];
            if (encryptedMDMParam) {
                webSessionURLString = [webSessionURLString stringByAppendingFormat:@"&%@",encryptedMDMParam];
            }
            sfview.urlForWebView = [NSURL URLWithString:webSessionURLString];
            sfview.headers = headers;
            sfview.failure = failure;
            UIViewController *top = [self topViewController];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self->_shouldPresentInFormSheet) {
                sfview.modalPresentationStyle = UIModalPresentationFormSheet;
            }
            if(top){
                [top presentViewController:sfview animated:YES completion:nil];
            }else{
                [[self getActiveWindow].rootViewController presentViewController:sfview animated:YES completion:nil];
            }
        });
    }];
    
   
#endif
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
//
//    });
}

-(NSString*) getEncryptedMDMQueryParam {
    if ([self getMDMToken]) {
        
        NSArray *mdmTokenSplit = [[self getMDMToken] componentsSeparatedByString:@":"];
        if (mdmTokenSplit && mdmTokenSplit.count == 3) {
            NSString* realMdmToken = mdmTokenSplit[0];
            NSString* zid = mdmTokenSplit[1];
            NSString* tokenSecret = mdmTokenSplit[2];
            long long currentMillis = [[ZIAMUtil sharedUtil] getCurrentTimeMillis];
            NSString* nbf = [NSString stringWithFormat:@"%lld",currentMillis/1000-(5*60)];
            NSString* exp = [NSString stringWithFormat:@"%lld",currentMillis/1000+(5*60)];
            
            NSMutableDictionary *mdmDetails = [[NSMutableDictionary alloc] init];
            [mdmDetails setValue:nbf forKey:@"nbf"];
            [mdmDetails setValue:exp forKey:@"exp"];
            
            
            SSOEncryption *encryption = [[SSOEncryption alloc] init];
            NSString *encrypted = [encryption getGCMEncryptedDataFor:mdmDetails keyString:tokenSecret];
            
            
            NSString *mdmParamValue = [NSString stringWithFormat:@"mdmtoken-%@:%@:%@", realMdmToken, zid, encrypted ];
            NSString *mdmParam = [NSString stringWithFormat:@"token=%@", [[ZIAMUtil sharedUtil] getEncodedStringForString:mdmParamValue]];
            return mdmParam;
        }
        return nil;
    } else {
        return nil;
    }
}
- (void) getTrustedDomainsRegex:(NSString*)ZUID completion:(void (^)(NSString* regex, NSError *error))completion {
    [self getTokenForZUID:ZUID WithSuccess:^(NSString *token) {
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
       
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        [headers setValue: ClientID forKey:@"X-Client-Id"];

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@/account/v1/currentdcdomains",[self getAccountsURLFromKeychainForZUID:ZUID]];
        [self showLoadingIndicator];
        [[SSONetworkManager sharedManager] sendGETRequestForURL:urlString parameters:paramsAndHeaders successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            NSLog(@"%@", jsonDict);
        } failureBlock:^(SSOInternalError errorType, NSError *errorInfo) {
            NSLog(@"%@", errorInfo);

        }];
    } andFailure:^(NSError *error) {
        NSLog(@"%@", error);

    }];
    
}

-(void)showAuthenticatedReLoginPageForZUID:(NSString*)ZUID havingTempToken:(NSString*)tempToken failureCallback:(ZSSOKitErrorResponse)failure {
    self->User_ZUID = ZUID;
    self->reloginURL = [NSString stringWithFormat:@"%@%@?temp_token=%@",[self getAccountsURLFromKeychainForZUID:ZUID],kSSOReAuth_URL,tempToken];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
        
    });
}
-(void)showAuthenticatedVerifyEmailPageForZUID:(NSString*)ZUID havingTempToken:(NSString*)tempToken failureCallback:(ZSSOKitErrorResponse)failure {
    self->User_ZUID = ZUID;
    ZSSOUser *user = [self getZSSOUserHavingZUID:ZUID];
    self->verifyEmailURL = [NSString stringWithFormat:@"%@%@?temp_token=%@&email=%@&action=verify_email",user.accountsUrl,kSSOVerifyEmail_URL,tempToken,[self  getEncodedStringForString:user.profile.email]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:failure];
        
    });
}
#endif

-(void)postDeviceIDtoServer:(requestLogoutSuccessBlock)success
andFailure:(requestLogoutFailureBlock)failure{
    // <accountsUrl>/oauth/sso/userSignOut?clientId=<childClientId>&deviceId=<deviceId>
    //kDeviceVerify_Signout_URL

     NSString *zuid = [self getCurrentUserZUIDFromKeychain];
    self->ButtonClick = NO;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        if([[ZIAMUtil sharedUtil] isOneAuthApp]){
            if([self getDeviceIDFromKeychain]){
                NSString *urlString = [NSString stringWithFormat:@"%@%@?clientId=%@&deviceId=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerify_Signout_URL,[NSString stringWithFormat:@"%@",self->ClientID],[self getDeviceIDFromKeychain]];


                //Add Parameters
                NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];

                //Add Headers
                NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];

                //[headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
                if ([self getDeviceIDFromKeychain]){
                    [headers setValue:[self getDeviceIDFromKeychain] forKey:@"X-Device-Id"];
                }else{
                    [headers setValue:@"NOT_CONFIGURED" forKey:@"X-Device-Id"];
                }
                [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
                
                [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
                [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                  parameters: paramsAndHeaders
                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                    //Request success
                    [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
                    DLog(@"deviceID delete Done for App:%@",AppName);

                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                    //Request failed
                    [self handleRevokeError:errorType error:error failureBlock:failure];
                    return;
                }];
            }else{
                [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
            }
        }else{
            [self removeAllScopesForZUID:[self getCurrentUserZUIDFromKeychain] success:success failure:failure];
        }



    } andFailure:^(NSError *error) {
        failure(error);
        return;
    }];

    // Request....





}

-(void)removeAllScopesForZUID:(NSString *)zuid success:(requestLogoutSuccessBlock)successBlock failure:(requestLogoutFailureBlock)failureBlock {

    if ([self checkifSSOAccountsMatchForZUID:zuid]) {
        
        // app logged in using account chooser
        //check if the OneAuth app is still using the same ZUID
        // clear app data for ZUID mapped with sso account
       NSError* logoutError = [self clearAppSSOAccountForUserHavingZUID:zuid];
        if (logoutError) {
            failureBlock(logoutError);
        } else {
            successBlock();
        }
    } else {
        
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSORevoke_URL];

        //Add Parameters
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:zuid forKey:@"mzuid"];
        [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",[self getRefreshTokenFromKeychainForZUID:zuid]] forKey:@"token"];

        //Add Headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

        // Request....
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        [self clearDataForLogoutHavingZUID:zuid];
                                                        DLog(@"Logout Done for App:%@",AppName);
                                                        successBlock();
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        //Request failed
                                                        [self handleRevokeError:errorType error:error failureBlock:failureBlock];
                                                        return;
                                                    }];
    }


}

-(NSError*)clearAppSSOAccountForUserHavingZUID:(NSString*)ZUID {
    
    // get SSO account ZUID
    [self clearDataForLogoutHavingZUID:ZUID];
    DLog(@"Logout Done for App:%@",AppName);
    [self clearDataForSSOLogoutHavingZUID:ZUID];
    return nil;
    
}

-(void)updatePhotoOfUserHavingZUID:(NSString*)zuid
                             image:(UIImage*)image WithSuccess:(responseSuccessBlock)success failure:(requestFailureBlock)failure {
   
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        NSString* transformedURL = [self getTransformedURLStringForURL:self->profileBaseUrl forZuid:zuid];
//        NSString *accountsURL = [self getAccountsURLFromKeychainForZUID:zuid];
//        NSString *profileBaseURL = [accountsURL stringByReplacingOccurrencesOfString:@"accounts" withString:@"profile"];
        NSString *urlString = [NSString stringWithFormat:@"%@/api/v1/user/self/photo",transformedURL];
       NSData *postImageData = UIImageJPEGRepresentation(image, 1);
       NSData *postData = [postImageData base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
       
       NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
       //Add headers
       NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
       [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
       [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
       
        [[SSONetworkManager sharedManager] sendPUTRequestForURL:urlString
                                                       httpbody:postData
                                                     parameters:paramsAndHeaders
                                                   successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 201){
                //TODO: Save photo data to keychain
                [self storeUserImageDataInKeychain:postImageData forZUID:zuid];
                success();
            }else{
                //failure handling...
                DLog(@"Status: Failure Response");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Update Photo Server Error Occured" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUpdatePhotoServerError userInfo:userInfo];
                failure(returnError);
            }
         
        } failureBlock:^(SSOInternalError errorType, NSError *error) {
            //Request failed
            [self handleUpdatePhotoError:errorType info:error failureBlock:failure];
            return;
        }];
    } andFailure:^(NSError *error) {
        DLog(@"UpdatePhoto failureBlock %@", error.description);
        failure(error);
    }];
}
-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url{
    return [self getTransformedURLStringForURL:url];
}
-(NSDictionary *)ziamgetDCLInfoForCurrentUser{
    return [self getDCLInfoForCurrentUser];
}

-(NSString *)ziamgetTransformedURLStringForURL:(NSString *)url havingZUID:(NSString *)zuid{
    return [self getTransformedURLStringForURL:url forZuid:zuid];
}
-(NSDictionary *)ziamgetDCLInfoForZuid:(NSString *)zuid{
    return [self getDCLInfoForZuid:zuid];
}

-(ZSSOUser*)getSSOUserFor:(NSString*)SSO_Zuid {
    NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[self getSSOUserDetailsDataFromSharedKeychain]];
    NSArray *userdetailsArray = [SSOUserDetailsDictionary objectForKey:SSO_Zuid];
    ZSSOProfileData *profileData = [[ZSSOProfileData alloc]init];
    if(userdetailsArray.count <4){
        [profileData initWithEmailid:[userdetailsArray objectAtIndex:1]
                                name:[userdetailsArray objectAtIndex:0]
                         displayName:[userdetailsArray objectAtIndex:0]
                            hasImage:YES
                    profileImageData:[userdetailsArray objectAtIndex:2]];
    }else{
        [profileData initWithEmailid:[userdetailsArray objectAtIndex:1]
                                name:[userdetailsArray objectAtIndex:3]
                         displayName:[userdetailsArray objectAtIndex:0]
                            hasImage:YES
                    profileImageData:[userdetailsArray objectAtIndex:2]];
    }


    ZSSOUser *ZOneAuthUser = [[ZSSOUser alloc]init];

    NSArray *scopesArray;
    scopesArray = [Scopes componentsSeparatedByString:@","];

    [ZOneAuthUser initWithZUID:SSO_Zuid
                       Profile:profileData accessibleScopes:scopesArray
                   accountsUrl:[self getSSOAccountsURLFromKeychainForZUID:SSO_Zuid]
                      location:SSO_Zuid];
    return ZOneAuthUser;
}

- (NSArray<ZSSOUser*> *)getUsersForApp {
    
    NSMutableArray<ZSSOUser*> *appUsers = [[NSMutableArray<ZSSOUser*> alloc] init];

    if([self isHavingSSOAccount]) {
        
        NSData* SSO_ZuidsData = [[ZIAMUtil sharedUtil] getSSOZUIDListFromSharedKeychain];
        if(SSO_ZuidsData){
            // OneAuth ZUID list available
            NSMutableArray* SSO_ZuidsArray = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:SSO_ZuidsData];
            
            for (NSString *SSOZUID in SSO_ZuidsArray) {
                
                NSData* access_token_data = [ [ZIAMUtil sharedUtil] getAppSSOAccessTokenDataFromSharedKeychainForZUID:SSOZUID];
                // check if access token store in app's keychain
                if (access_token_data) {
                    // access token available for this app using this zuid
                    ZSSOUser *usr = [self getSSOUserFor:SSOZUID];
                    [appUsers addObject:usr];
                }
                
            }
            
        } else {
            // check if OneAuth V1 user available
            NSString *SSO_Zuid = [self getSSOZUIDFromSharedKeychain];
            if (SSO_Zuid) {
                NSData* access_token_data = [ [ZIAMUtil sharedUtil] getAppSSOAccessTokenDataFromSharedKeychainForZUID:SSO_Zuid];
                // check if access token store in app's keychain
                if (access_token_data) {
                    // access token available for this app using this zuid
                    ZSSOUser *usr = [self getSSOUserFor:SSO_Zuid];
                    [appUsers addObject:usr];
                }
                
            }
            
        }
        
    }

    int count = [self getUsersCount];

    for(int i = 1; i <= count ; i++){

        NSString *Zuid = [self getZUIDFromKeyChainForIndex:i];
        ZSSOUser *zUser = [self getZSSOUserHavingZUID:Zuid];
        if(zUser){
            [appUsers addObject:zUser];
        }
    }
    
    return appUsers;
    
}

-(ZSSOProfileData*)getProfileData:(NSArray*)userDetails {
    ZSSOProfileData *profileData = [[ZSSOProfileData alloc]init];
    //Temp fix for App Store OneAuth UserDetails...
    NSData *returnProfilePhotoData;
    NSData *profileImageData = [userDetails objectAtIndex:2];
    BOOL hasImage;
    if(![profileImageData isEqual:[NSNull null]] && [[userDetails objectAtIndex:2] isKindOfClass:[NSData class]]){
        returnProfilePhotoData = profileImageData;
         hasImage = YES;
    }else if([[userDetails objectAtIndex:2] isKindOfClass:[UIImage class]]){
        UIImage *profileImage = [userDetails objectAtIndex:2];
        returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
        hasImage = YES;
    }else{
        UIImage *profileImage;
        #if !TARGET_OS_WATCH
        profileImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        #endif
        returnProfilePhotoData = UIImagePNGRepresentation(profileImage);
        hasImage = NO;
    }
    if(userDetails.count <4){
        [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                name:[userDetails objectAtIndex:0]
                         displayName:[userDetails objectAtIndex:0]
                            hasImage:hasImage
                    profileImageData:returnProfilePhotoData];
    }else{
        [profileData initWithEmailid:[userDetails objectAtIndex:1]
                                name:[userDetails objectAtIndex:3]
                         displayName:[userDetails objectAtIndex:0]
                            hasImage:hasImage
                    profileImageData:returnProfilePhotoData];
    }
    
    return profileData;
}
-(ZSSOUser *)getZSSOUserHavingZUID:(NSString *)zuid{

    if ([self checkifSSOAccountsMatchForZUID: zuid]){
        NSArray *userDetails = [self getUserDetailsForZUID:zuid forSSOAccount:YES];
        if(userDetails){

            ZSSOProfileData *profileData = [self getProfileData:userDetails];

            ZSSOUser *ZUser = [[ZSSOUser alloc]init];

            NSArray *scopesArray;
            scopesArray = [Scopes componentsSeparatedByString:@","];

            NSString *location = [self getSSODCLLocationFromSharedKeychainForZUID:zuid];

            [ZUser initWithZUID:zuid Profile:profileData accessibleScopes:scopesArray accountsUrl:[self getSSOAccountsURLFromKeychainForZUID:zuid] location:location];
            return ZUser;

        }
        return nil;

    } else {
        NSArray *userDetails = [self getUserDetailsForZUID:zuid forSSOAccount:NO];
        if(userDetails){

            ZSSOProfileData *profileData = [self getProfileData:userDetails];

            ZSSOUser *ZUser = [[ZSSOUser alloc]init];

            NSArray *scopesArray;
            scopesArray = [Scopes componentsSeparatedByString:@","];

            NSString *location = [self getDCLLocationFromKeychainForZUID:zuid];

            [ZUser initWithZUID:zuid Profile:profileData accessibleScopes:scopesArray accountsUrl:[self getAccountsURLFromKeychainForZUID:zuid] location:location];
            return ZUser;

        }
        return nil;

    }

}
// Add Secondary Email - WIP
#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY
-(void)addSecondaryEmailIDForZUID:(NSString * )zuid WithCallback:(ZSSOKitAddEmailIDHandler)failure{
    finalAddEmailIDBlock = failure;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addLoadingViewInView:[self topViewController].view];
        });
        NSMutableDictionary* paramsAndHeaders = [[NSMutableDictionary alloc] init];
        NSMutableDictionary* redirectURL = [[NSMutableDictionary alloc] init];
        [redirectURL setValue:self->UrlScheme forKey:@"redirect_uri"];
        [redirectURL setValue:@"secondary_email" forKey:@"action"];

        [paramsAndHeaders setValue:redirectURL forKey:@"token"];
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        

        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        //URL
        NSString *urlString;
        urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOTemporarySessionToken_URL];
        [self showLoadingIndicator];
        // Request....
        [[SSONetworkManager sharedManager] sendJSONPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                        //Request success
                                                        [self hideLoadingIndicator];
            int status_code = [[jsonDict objectForKey:@"status_code"]intValue];
                                                        if(status_code == 201 ){
                                                            DLog(@"Success Response ");
                                                            self->AddSecondaryEmailURL = [NSString stringWithFormat:@"%@%@?temp_token=%@&action=secondary_email",[self getAccountsURLFromKeychainForZUID:zuid],kSSOAddSecondaryEmail_URL,[jsonDict objectForKey:@"message"]];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 [self presentSSOSFSafariViewControllerWithSuccess:nil andFailure:self->finalAddEmailIDBlock];
                                                                 
                                                             });
                                                        }else{
                                                            //failure handling...
                                                            DLog(@"Status: Failure Response");
                                                            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                            [userInfo setValue:@"Add secondary email Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONativeSignInServerError userInfo:userInfo];
                                                            self->finalAddEmailIDBlock(returnError);
                                                        }
                                                    } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                        [self hideLoadingIndicator];
                                                        DLog(@"Failure Response");
                                                        [self handleSecondaryEmailError:errorType error:error failureBlock:self->finalAddEmailIDBlock];
                                                    }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}
#endif

-(void)sendOTPTo:(NSString*)mobileNumber
      countryCode:(NSString*)code
         forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitOTPCodeResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
            [paramDict setValue:[code uppercaseString] forKey:@"country_code"];
            [paramDict setValue:mobileNumber forKey:@"mobile"];
       
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];

            NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
            [finalDict setValue:paramDict forKey:@"mobile"];
            
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
            [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];


            [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];

            NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile];
        [[SSONetworkManager sharedManager]sendJSONPOSTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){

                NSString *mobileID = [jsonDict valueForKeyPath:@"mobile.mobile"];

                response(mobileID,nil);

            } else {

                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];

                if (!errorMessage) {
                    errorMessage = @"An error occurred while sending OTP your mobile number. Please try again.";
                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                response(nil,returnError);

            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            DLog(@"Failure Response");
            NSLog(@"register mobile %@", errorInfo);

                if (errorType == SSO_ERR_CONNECTION_FAILED) {
                    NSError* returnError = (NSError*)errorInfo ;
                    response(nil,returnError);

                }else if (errorType == SSO_ERR_SERVER_ERROR) {
                    NSString* errormessage = (NSString*) errorInfo;
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                    response(nil,returnError);

                } else {
                    NSString* errormessage = @"An error occurred while sending OTP your mobile number. Please try again.";
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberSendOTPError userInfo:userInfo];
                    response(nil, returnError);
                }
        }];
                                                         
    } andFailure:^(NSError *error) {
        response(nil, error);
    }];
    
}


-(void)resendOTPForMobilID:(NSString*)mobileID
         forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitErrorResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
       
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"is_resend"];
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];
            NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
            [finalDict setValue:paramDict forKey:@"mobile"];
            
            NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
            [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];


            [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];

            NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@/%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile, mobileID];
        
        [[SSONetworkManager sharedManager]sendJSONPUTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){

                response(nil);

            } else {

                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];

                if (!errorMessage) {
                    errorMessage = @"An error occurred while resending OTP your mobile number. Please try again.";
                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                response(returnError);

            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            DLog(@"Failure Response");
            NSLog(@"register mobile %@", errorInfo);

                if (errorType == SSO_ERR_CONNECTION_FAILED) {
                    NSError* returnError = (NSError*)errorInfo ;
                    response(returnError);

                }else if (errorType == SSO_ERR_SERVER_ERROR) {
                    NSString* errormessage = (NSString*) errorInfo;
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                    response(returnError);

                } else {
                    NSString* errormessage = @"An error occurred while resending OTP your mobile number. Please try again.";
                    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberResendOTPError userInfo:userInfo];
                    response(returnError);
                }
        }];
                                                         
    } andFailure:^(NSError *error) {
        response( error);
    }];
    
}

-(void)verifyMobileD:(NSString*)mobileID
         WithOTPCode:(NSString *)otp
             forZUID:(NSString*)userZUID
            response:(ZSSOKitErrorResponse)response {
    
    [self getTokenForZUID:userZUID WithSuccess:^(NSString *token) {
        NSMutableDictionary *paramDict = [[NSMutableDictionary alloc]init];
        
        [paramDict setValue:otp forKey:@"code"];
        [paramDict setValue:[NSNumber numberWithBool:NO] forKey:@"is_resend"];
        [paramDict setValue:[NSNumber numberWithBool:YES] forKey:@"screen_name"];
        
        NSMutableDictionary *headerDict = [[NSMutableDictionary alloc]init];
        [headerDict setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        NSMutableDictionary *finalDict = [[NSMutableDictionary alloc]init];
        [finalDict setValue:paramDict forKey:@"mobile"];
        [finalDict setValue:headerDict forKey:SSO_HTTPHeaders];
        
        NSString *nativeSigninURL = [NSString stringWithFormat:@"%@%@/%@", [self getAccountsURLFromKeychainForZUID:userZUID],kSSOSendOTPMobile,mobileID];
        
        [[SSONetworkManager sharedManager]sendJSONPUTRequestForURL:nativeSigninURL parameters:finalDict successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            if([[jsonDict valueForKey:@"status_code"] intValue] == 200 || [[jsonDict valueForKey:@"status_code"] intValue] == 201){
                NSLog(@"%@", jsonDict);
                response(nil);
                
            } else {
                NSString* errorMessage = [jsonDict valueForKey:@"localized_message"];
                
                if (!errorMessage) {
                    errorMessage = @"Verification failed. Please try again by resending the code.";

                }
                
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response( returnError);
                
            }
        } failureBlock:^(SSOInternalError errorType, id errorInfo) {
            if (errorType == SSO_ERR_CONNECTION_FAILED) {
                NSError* returnError = (NSError*)errorInfo ;
                response(returnError);

            }else if (errorType == SSO_ERR_SERVER_ERROR) {
                NSString* errormessage = (NSString*) errorInfo;
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response(returnError);

            } else {
                NSString* errormessage = @"Verification failed. Please try again by resending the code.";
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOMobileNumberVerifyError userInfo:userInfo];
                response(returnError);
            }
        }];
    } andFailure:^(NSError *error) {
        response(error);
    }];
    
}

//Scope Enhancement
-(void)enhanceScopeWithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                    andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{
    [self enhanceScopeForZuid:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
}
-(void)enhanceScopeForZuid:(NSString *)zuid WithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{

    finalScopeEnhancementSuccessBlock = success;
    finalScopeEnhancementFailureBlock = failure;
    User_ZUID = zuid;
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        if(self->isSSOAccessToken){
            success(token);
        }else{
            NSString* client_secret = [self getClientSecretFromKeychainForZUID:zuid];

            NSString *encoded_gt_sec=[self getEncodedStringForString:client_secret];

            //Add Parameters
            NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
            [paramsAndHeaders setValue:@"enhancement_scope" forKey:@"grant_type"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->ClientID] forKey:@"client_id"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->Scopes] forKey:@"scope"];
            }

            //Add headers
            NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
            [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
            

            [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

            #if !TARGET_OS_WATCH
            if (@available(iOS 11.0, *)) {
                DCDevice *device = [DCDevice currentDevice];
                if(device.isSupported){
                    [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                        if(error == nil && token!=nil){
                            NSString *dcToken;
                            NSCharacterSet *urlChars = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
                            dcToken = [token base64EncodedStringWithOptions:0];
                            dcToken = [dcToken stringByAddingPercentEncodingWithAllowedCharacters:[urlChars invertedSet]];
                            [paramsAndHeaders setValue:dcToken forKey:@"device_verify_token"];
                            if([self->Service isEqualToString:kMDM_BundleID]){
                                [paramsAndHeaders setValue:@"mdm" forKey:@"appid"];
                            }else{
                                [paramsAndHeaders setValue:@"prd" forKey:@"appid"];
                            }

                            [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                        }else{
                            //DCToken Error Fallback
                            [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                        }
                    }];
                }else{
                    //DCToken Device not Supported fallback
                    [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
                }
            }else{
                // iOS 11 below fallback
                [self makeScopeEnhancementPostToServerHavingParams:paramsAndHeaders forZuid:zuid WithSuccess:success andFailure:failure];
            }
            #endif
        }
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

-(void)makeScopeEnhancementPostToServerHavingParams:(NSMutableDictionary *)paramsAndHeaders forZuid:(NSString *)zuid WithSuccess:(ZSSOKitScopeEnhancementSuccessHandler)success
                                         andFailure:(ZSSOKitScopeEnhancementFailureHandler)failure{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOScopeEnhancement_URL];
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:
     ^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
        //Request success
        if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
            DLog(@"Success Response ");
            NSString *scopeEnhancementAccessToken = [jsonDict objectForKey:@"scope_token"];
            
            NSString* enhancementPageURL = [NSString stringWithFormat:@"%@%@?client_id=%@&redirect_uri=%@&state=Test&response_type=code&access_type=offline&scope_token=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOAddScope_URL,self->ClientID,self->UrlScheme,scopeEnhancementAccessToken];
            
            // exclude scopes for default scoped client
            if(![ZIAMUtil sharedUtil].donotSendScopesParam){
                enhancementPageURL = [enhancementPageURL stringByAppendingFormat:@"&scope=%@",self->Scopes];
            }
            self->ScopeEnhancementUrl = enhancementPageURL;
            //present SFSafari to show scope enhancement
            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
        }else{
            //failure handling...
            if([[jsonDict objectForKey:@"reason"] isEqualToString:@"scope_enhanced"]){
                //Scope Enhancement Success...
                [self getForceFetchOAuthTokenForZUID:self->User_ZUID success:self->finalScopeEnhancementSuccessBlock andFailure:self->finalScopeEnhancementFailureBlock];
                return;
            }else if([[jsonDict objectForKey:@"reason"] isEqualToString:@"scope_already_enhanced"]){
                //Scope Already Enhanceed error
                DLog(@"Scope Already Enhanceed");
                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                [userInfo setValue:@"Scope Already Enhanceed" forKey:NSLocalizedDescriptionKey];
                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementAlreadyDone userInfo:userInfo];
                failure(returnError);
                return;
            }
            DLog(@"Status: Failure Response");
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Get Extra Scope Server Error Occured" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOScopeEnhancementServerError userInfo:userInfo];
            failure(returnError);
            return;
        }
    } failureBlock:^(SSOInternalError errorType, NSError* error) {
        DLog(@"Failure Response");
        [self handleScopeEnhancementError:errorType error:error failureBlock:failure];
    }];
}


//AuthToOAuth
-(void)getOAuth2TokenUsingAuthToken:(NSString *)authtoken forApp:(NSString *)appName havingAccountsURL:(NSString *)accountsBaseURL havingSuccess:(requestSuccessBlock)success
                         andFailure:(requestFailureBlock)failure
{
    //enc_token Signature - clientidvalue__i__devicename__i_timestamp__i__authtoken__i__Test_App
    // Do any additional setup after loading the view.
    ZSSORSAUtil *keygen = [[ZSSORSAUtil alloc]initWithPublicTag:kSSO_public_key_tag privateTag:kSSO_private_key_tag serverPublicTag:kSSO_server_public_key_tag];
    [keygen generateKeyPair];
    
    //PublicKey to be Stored in IAM Server!
    NSString *oauthpub = [keygen getPublicKeyForServer];
    oauthpub = [self getEncodedStringForString:oauthpub];



    /// NSLog(@"%@ %@ %ld",uaString,appName,millis);
    NSString *stringToBeEncrypted;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
    double timePassed_ms = ([[NSDate date] timeIntervalSince1970] * 1000);
    stringToBeEncrypted = [NSString stringWithFormat:@"%@__i__%@__i__%.0f__i__%@__i__%@__i__%@__i__%@",[self deviceName],AppName,timePassed_ms,[[UIDevice currentDevice] name],ClientID,appName,authtoken];
#endif
#endif
    NSData *data = [stringToBeEncrypted dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encryptedDataString = [data aesEncryptWithKey:kSSOSHARED_SECRET ivData:NULL];
    encryptedDataString = [self getEncodedStringForString:encryptedDataString];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsBaseURL,kSSOAuthToOAuth_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
    [paramsAndHeaders setValue:encryptedDataString forKey:@"enc_token"];
    [paramsAndHeaders setValue:ClientID forKey:@"client_id"];
    [paramsAndHeaders setValue:oauthpub forKey:@"ss_id"];
    
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                  parameters: paramsAndHeaders
                                                successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {

                                                    //Header for DCL Handling
                                                    if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                                                        NSDictionary *dictionary = [httpResponse allHeaderFields];
                                                        if([dictionary objectForKey:@"X-Location-Meta"]){
                                                            NSString *base64EncodedString = [dictionary objectForKey:@"X-Location-Meta"];
                                                            NSData *bas64DCL_Meta_Data = [Base64Converter base64DecodeWithString:base64EncodedString];
                                                            self->setBas64DCL_Meta_Data=bas64DCL_Meta_Data;
                                                        }
                                                    }

                                                    //Request success
                                                    if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                        self->setAccountsServerURL = accountsBaseURL;
                                                        self->setAccessToken = [jsonDict objectForKey:@"access_token"];
                                                        self->setExpiresIn = [jsonDict objectForKey:@"expires_in"];
                                                        self->setLocation = [jsonDict objectForKey:@"location"];
                                                        self->setRefreshToken = [jsonDict objectForKey:@"rt_token"];

                                                        //Get the KeyPair!
                                                        ZSSORSAUtil *keygen = [[ZSSORSAUtil alloc]initWithPublicTag:kSSO_public_key_tag privateTag:kSSO_private_key_tag serverPublicTag:kSSO_server_public_key_tag];

                                                        NSString*  encrypted_gt_sec   =   [jsonDict objectForKey:@"gt_sec"];



                                                        NSData *granttokenData = [Base64Converter base64DecodeWithString: encrypted_gt_sec];

                                                        //Decrypt using private key
                                                        self->setClientSecret = [keygen rsaDecryptWith: granttokenData];

                                                        [self fetchUserInfoWithBlock:^(NSError *error) {
                                                            if(error == nil){
                                                                //Success
                                                                DLog(@"Got profile info and stored items in keychain success");
                                                                success(self->setAccessToken);
                                                            }else{
                                                                //Error Occured...
                                                                failure(error);
                                                            }
                                                        }];


                                                    }else{
                                                        //failure handling...
                                                        DLog(@"Status: Failure Response");
                                                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                        [userInfo setValue:@"Get OAuth from AuthToken Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAuthToOAuthServerError userInfo:userInfo];
                                                        failure(returnError);
                                                    }
                                                } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                    //Request failed

                                                    DLog(@"Failure Response");
                                                    [self handleAuthToOAuthError:errorType error:error failureBlock:failure];
                                                }];

}

-(void)checkAndLogout:(requestFailureBlock)logoutBlock{
    [self checkAndLogoutForZUID:[self getCurrentUserZUIDFromKeychain] handler:logoutBlock];
}
-(void)checkAndLogoutForZUID:(NSString *)zuid handler:(requestFailureBlock)logoutBlock{

    [self getForceFetchOAuthTokenForZUID:zuid success:^(NSString *token) {
        logoutBlock(nil);
    } andFailure:^(NSError *error) {
        if (([error code]== k_SSOTokenFetchError || [error code]== k_SSOOneAuthTokenFetchError) && [[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
            [self clearDataForLogoutHavingZUID:zuid];
        }
        logoutBlock(error);
    }];
}

-(BOOL)getIsSignedInUsingSSOAccount{
    return [self checkifSSOAccountsMatchForZUID:[self getCurrentUserZUIDFromKeychain]];
}

-(BOOL)getIsSignedInUsingSSOAccountForZUID:(NSString *)zuid{
    return [self checkifSSOAccountsMatchForZUID:zuid];
}

//End of ZSSOKit Helpers
-(void)processgetTokenForZuid:(NSString *)zuid WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure
{
    //Case1: OneAuth not installed but already Signed in--- Get token from this App's Keychain
    DLog(@"Checking for Case1: OneAuth not installed but already Signed in--- Get token from this App's Keychain");

    NSString* refresh_token = [self getRefreshTokenFromKeychainForZUID:zuid];

    if(refresh_token){
        // app has refresh token i.e., app Signed in
        if(ButtonClick){
            //Should not come here....
            int errorCode = k_SSOOldAccessTokenNotDeleted;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"Old Access Token Not Deleted" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorCode userInfo:userInfo];
            failure(returnError);
            return;
        }
        [self->lock lock];
        NSData *access_token_data = [self getAccessTokenDataFromKeychainForZUID:zuid];
        //Get the CurrentTime!
        long long millis = [self getCurrentTimeMillis];
        NSMutableDictionary* accessTokenDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:access_token_data];
        NSArray* tokenArray = [accessTokenDictionary objectForKey:Scopes];
        DLog(@"Keychain Dictionary objects test Token Final: %@",tokenArray[0]);
        NSString* timeStampString = tokenArray[1];

        long long timeStamp = [timeStampString longLongValue];
        if(wmsCallBack){
            expiresinMillis = timeStamp - millis;
            millis = millis + wmsTimeCheckMargin;
        }else{
            expiresinMillis = timeStamp - millis;
            millis = millis + timecheckbuffer;
        }

        DLog(@"Current Time:%ld TimeStamp:%ld",millis,timeStamp);
        dispatch_async(dispatch_get_main_queue(), ^{
            self->isSSOAccessToken = NO;
        });
        if(millis < timeStamp){
            DLog(@"Time Check Success!!!");
            [self->lock unlock];
            NSString* token = tokenArray[0];
            //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
            [[ZIAMUtil sharedUtil] removeisAppUsingSSOAccount];
            success(token);
        }else{
            DLog(@"Time Check Failed!!!");
            [self processTokenFetchForZUID:zuid isSSOAccount:NO WithSuccess:success andFailure:failure];
        }
    }else{
        //Case1: OneAuth Already there and signed in----- Get token from shared keychain
        DLog(@"Checking for Case1");
        if ([self isHavingSSOAccount]) {
            // oneauth app exists
            if (zuid == nil && ButtonClick) {
                // app not logged in
                [self showAccountChooserWithSuccess:success andFailure:failure];
            } else {
                // check if refresh tokens available for given ZUID and proceed
                [self checkSSORefreshTokenAndProceed:zuid WithSuccess:success andFailure:failure];
            }
        } else {
            // oneauth app not exists
            if ([self isAppUsingSSOAccount] || [self isAppUsingMyZohoSSOAccount]) {
                // but app was logged in already using SSO
                DLog(@"Account Mismatch");
                [self clearAndGetAccountMismatchError];
                return ;
            } else {
                [self signInToGetToken:success andFailure:failure];
            }
        }
    }
}


-(NSError*)clearAndGetAccountMismatchError {
    
    if([self isAppUsingSSOAccount]){
        [self removeisAppUsingSSOAccount];
    }

    if([self isAppUsingMyZohoSSOAccount]){
        [self removeisAppUsingMyZohoSSOAccount];
    }
    //Remove CurrentUser if this ZUID is the currentApp user...
    [self removeCurrentUserZUIDFromKeychain];
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:@"OneAuth SSO Account Mismatch" forKey:NSLocalizedDescriptionKey];
    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOOneAuthAccountMismatch userInfo:userInfo];
    return returnError;
}

- (void)showAccountChooserWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure {
#if !SSO_APP__EXTENSION_API_ONLY

    if([self checkIfUnauthorisedManagedMDMSSOAccount]){
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
        return;
    }
    
    [self isOneAuthInstalled:^(BOOL isValid) {
        if (isValid) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                ssoKit = [[ZSSOUIKit alloc] init];
                ssoKit.presentationContextProviderSSOKit = self.presentationContextProviderSSOKit;
                ssoKit.shouldPresentInFormSheet = self.shouldPresentInFormSheet;
                ssoKit.MainWindow = [self getActiveWindow];
                [ssoKit presentAccountChooserWithSuccess:success andFailure:failure havingSwitchSuccess:nil];
            });
        } else {
            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
        }
    }];
#endif

}

-(void)checkSSORefreshTokenAndProceed:(NSString*)SSO_ZUID WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure {
    
    NSString* sso_refresh_token = [self getSSORefreshTokenFromSharedKeychainForZUID:SSO_ZUID];

    if (sso_refresh_token) {
        if (ButtonClick) {
#if !SSO_APP__EXTENSION_API_ONLY

            if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                return;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{

                    ssoKit = [[ZSSOUIKit alloc] init];
                    ssoKit.presentationContextProviderSSOKit = self.presentationContextProviderSSOKit;
                    ssoKit.shouldPresentInFormSheet = self.shouldPresentInFormSheet;
                    ssoKit.MainWindow = [self getActiveWindow];
                    [ssoKit presentAccountChooserWithSuccess:success andFailure:failure havingSwitchSuccess:nil];
                });
            }
            
            
            return;
#endif
            
        } else {

            [self->lock lock];
            NSData* access_token_data;
            //changes related to moving individual accesstokens to individual apps.
            if([self getAppSSOAccessTokenDataFromSharedKeychainForZUID:SSO_ZUID]){
                access_token_data = [self getAppSSOAccessTokenDataFromSharedKeychainForZUID:SSO_ZUID];
            }else if ([self checkifSSOAccountsMatchForZUID: SSO_ZUID]) {
                access_token_data = [self getSSOAccessTokenDataFromSharedKeychainForZUID:SSO_ZUID];
            }

            //Get the CurrentTime!
            long long millis = [self getCurrentTimeMillis];
            NSMutableDictionary* accessTokenDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:access_token_data];
            NSString* overAllScopeKey;
            BOOL scopeFound = false;

            for (id key in accessTokenDictionary) {
                DLog(@"Dictionary Keys: %@",key);
                NSArray *overAllScopesArray = [key componentsSeparatedByString:@","];
                NSArray *appScopesArray = [Scopes componentsSeparatedByString:@","];

                NSSet *overAllSet = [NSSet setWithArray:overAllScopesArray];
                NSSet *scopeset = [NSSet setWithArray:appScopesArray];
                __block NSInteger count = 0;
                [overAllSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([scopeset containsObject:obj]){
                        count++;
                    }
                    if (count == [appScopesArray count]){
                        *stop = YES;

                    }
                }];

                if(count == [appScopesArray count])
                {
                    DLog(@"ScopeFound: %@ OverAllScope: %@",Scopes,key);
                    overAllScopeKey = key;
                    scopeFound = true;
                    break;
                }
            }
            //Fix : Storing this variable when any scope is missing(Enhance scope case)
            dispatch_async(dispatch_get_main_queue(), ^{
                self->isSSOAccessToken = YES;
            });

            if(scopeFound){
                NSArray* tokenArray = [accessTokenDictionary objectForKey:Scopes];
                DLog(@"One Auth Shared Keychain Dictionary objects test Token Final: %@",tokenArray[0]);
                NSString* timeStampString = tokenArray[1];
                long long timeStamp = [timeStampString longLongValue];
                DLog(@"One Auth Current Time:%ld TimeStamp:%ld",millis,timeStamp);
                if(wmsCallBack){
                    expiresinMillis = timeStamp - millis;
                    millis = millis + wmsTimeCheckMargin;
                }else{
                    expiresinMillis = timeStamp - millis;
                    millis = millis + timecheckbuffer;
                }
                if(millis < timeStamp){
                    [self->lock unlock];
                    DLog(@"One Auth Time Check Success!!!");
                    NSString* token = tokenArray[0];
                    //Backward Compatability to set the is_using_ssoaccount boolean in keychain for respective app.
                    if(![self isAppUsingSSOAccount] && [self isOneAuthApp]){
                        [self setisAppUsingSSOAccount];
                    }
                    if ([self checkIfUnauthorisedManagedMDMSSOAccount]) {
                        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                        [userInfo setValue:@"UnAuthorised Managed MDM Account" forKey:NSLocalizedDescriptionKey];
                        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOUnAuthorisedManagedMDMAccount userInfo:userInfo];
                        failure(returnError);
                    } else {
                        success(token);
                    }
                }else{
                    DLog(@"One Auth Time Check Failed!!!");
                    self->isSSOAccessToken = YES;
                    [self processTokenFetchForZUID:SSO_ZUID isSSOAccount:YES WithSuccess:success andFailure:failure];
                }
            }else{
                DLog(@"Scope Not Found");
                self->isSSOAccessToken = YES;
                [self processTokenFetchForZUID:SSO_ZUID isSSOAccount:YES WithSuccess:success andFailure:failure];
            }
        }
    } else {
        
        if (([self getAppSSOAccessTokenDataFromSharedKeychainForZUID:SSO_ZUID])) {
            // session terminated from oneauth
            DLog(@"session terminated from oneauth / account mismatch");
            // accounts mistmatch
            NSError *returnError = [self clearAndGetAccountMismatchError];
            failure(returnError);
        } else {
            [self signInToGetToken:success andFailure:failure];
        }
        // sso refresh token missing
        
    }
}

- (void)signInToGetToken:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure {

    if (ButtonClick) {
        
        /// For OneAuth App we have
        if ([self->AppName isEqual:Service]) {
            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
            return;
        }

        [self isOneAuthInstalled:^(BOOL isValid) {
            if(isValid){
                if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                    [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                    return;
                }
                //Case2: OneAuth there and and not signed in---- Open OneAuth in URL Scheme and reopen the source app. Source App should then call getToken.
                DLog(@"Checking for Case2");
                self->setFailureBlock = failure;
                self->setSuccessBlock = success;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *oneauthscheme = self->IAMURLScheme;
                    NSString* urlString = [NSString stringWithFormat:@"%@?scheme=%@&appname=%@",oneauthscheme,self->UrlScheme,self->AppName];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                });
#endif
#endif
            } else {
                // check MYZOHO installed or not
                [self isMyZohoInstalled:^(BOOL isValid) {
                    if(isValid){
                        if([self checkIfUnauthorisedManagedMDMSSOAccount]){
                            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                            return;
                        }
                        //Case2: OneAuth there and and not signed in---- Open OneAuth in URL Scheme and reopen the source app. Source App should then call getToken.
                        DLog(@"Checking for Case2.1");
                        NSString *myzohoscheme;
                        if([self->Service isEqualToString:kDevelopment_BundleID] || [self->Service isEqualToString:kDevelopment_MyZoho_BundleID]){
                            myzohoscheme  = kMyZohoURLScheme;
                        }else{
                            myzohoscheme  = kMyZohoMDMURLScheme;
                        }
                        if(myzohoscheme)
                            DLog(@"MyZoho URLScheme:%@",myzohoscheme);
                        self->setFailureBlock = failure;
                        self->setSuccessBlock = success;
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString* urlString = [NSString stringWithFormat:@"%@?scheme=%@&appname=%@",myzohoscheme,self->UrlScheme,self->AppName];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                        });
#endif
#endif

                    }else{
                        //Case4: MYZOHO not there and not Signed in--- Open LoginWebViewController and then send the response token after successful login.
                        DLog(@"Checking for Case4");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure];
                        });
                    }
                }];
            }
        }];
    } else {
        
        //No need to removeisAppUsingSSOAccount during the blocked state, should handle that...
       
        if([self isAppUsingSSOAccount]){
            [self removeisAppUsingSSOAccount];
        }

        if([self isAppUsingMyZohoSSOAccount]){
            [self removeisAppUsingMyZohoSSOAccount];
        }
        
        [self removeCurrentUserZUIDFromKeychain];
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"There is no Access Token" forKey:NSLocalizedDescriptionKey];
        NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSONoAccessToken userInfo:userInfo];
        failure(returnError);
        return ;
    }
}


-(void)verifySSOPasswordForZUID:(NSString*)zuid
                        success:(requestSuccessBlock)successBlock
                        failure:(requestFailureBlock)failureBlock {
    
    NSString *inc_token = self->inc_token;
    self->OneAuthTokenActivationURL = [NSString stringWithFormat:@"%@%@?redirect_uri=%@&inc_token=%@",[self getSSOAccountsURLFromKeychainForZUID:zuid],kSSOInactiveRefreshToken_URL,self->UrlScheme,inc_token];
    self->User_ZUID = zuid;
    [self presentSSOSFSafariViewControllerWithSuccess:successBlock andFailure:failureBlock];
}


-(void)getForceFetchOAuthToken:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    [self getForceFetchOAuthTokenForZUID:[self getCurrentUserZUIDFromKeychain] success:success andFailure:failure];
}

-(void)getForceFetchOAuthTokenForZUID:(NSString *)zuid success:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    if([self getIsSignedInUsingSSOAccountForZUID:zuid]){
        [self getSSOForceFetchOAuthTokenForSSOZUID:zuid WithSuccess:success andFailure:failure];
    }else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self processTokenFetchForZUID:zuid isSSOAccount:NO WithSuccess:success andFailure:failure];
        });
    }
}

-(void)getSSOForceFetchOAuthTokenForSSOZUID:(NSString*)ZUID WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self->isSSOLogin = YES;
        [self processTokenFetchForZUID:ZUID isSSOAccount:YES WithSuccess:success andFailure:failure];
    });
}

-(void)getClientPortalUserTokenWithSuccess:(requestSuccessBlock)success
                                andFailure:(requestFailureBlock)failure{
    [self getClientPortalUserTokenForZUID:[self getCurrentUserZUIDFromKeychain] WithSuccess:success andFailure:failure];
}
-(void)getClientPortalUserTokenForZUID:(NSString *)zuid WithSuccess:(requestSuccessBlock)success
                                andFailure:(requestFailureBlock)failure{
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        BOOL isSignedUsingSSO = [self getIsSignedInUsingSSOAccountForZUID:zuid];

            //URL

            NSString *client_id;
            NSString* client_secret;
            NSString *accountsUrl;

            if(isSignedUsingSSO ){
                accountsUrl = [self getSSOAccountsURLFromKeychainForZUID:zuid];
                client_id = [self getClientIDFromSharedKeychain];
                client_secret = [self getSSOClientSecretFromSharedKeychainForZUID:zuid];
            }else{
                accountsUrl = [self getAccountsURLFromKeychain];
                client_id = self->ClientID;
                client_secret = [self getClientSecretFromKeychainForZUID:zuid];
            }
            NSString *urlString = [NSString stringWithFormat:@"%@%@",accountsUrl,kSSOClientPortalRemoteLogin_URL];
            NSString *encoded_gt_sec= [self getEncodedStringForString:client_secret];
            //Add Parameters
            NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
            [paramsAndHeaders setValue:@"enhancement_scope" forKey:@"grant_type"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",encoded_gt_sec] forKey:@"client_secret"];
            [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",client_id] forKey:@"client_id"];
            if(isSignedUsingSSO)
                [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",self->ClientID] forKey:@"remote_app_name"];

            //Add headers
            NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
            [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
            if(isSignedUsingSSO)
                [headers setValue: self->ClientID forKey:@"X-Client-Id"];
            

            [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

            // Request....
            [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                          parameters: paramsAndHeaders
                                                        successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                            //Request success
                                                            if([[jsonDict objectForKey:@"status"] isEqualToString:@"success"]){
                                                                DLog(@"Success Response ");
                                                                NSString *loginAccessToken = [jsonDict objectForKey:@"login_token"];
                                                                success(loginAccessToken);
                                                            }else{
                                                                //failure handling...
                                                                DLog(@"Status: Failure Response");
                                                                NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
                                                                [userInfo setValue:@"Get Remote LoginKey Server Error Occured" forKey:NSLocalizedDescriptionKey];
                                                                NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSORemoteLoginServerError userInfo:userInfo];
                                                                failure(returnError);
                                                            }

                                                        } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                            //Request failed

                                                            DLog(@"Failure Response");
                                                            [self handleRemoteLoginError:errorType error:error failureBlock:failure];


                                                        }];
        } andFailure:^(NSError *error) {
            failure(error);
        }];
}

-(void)generateHandshakeIDHavingClientZID:(NSString *)clientZID
                               havingZUID:(NSString *)zuid
                               forService:(NSString*)serviceName WithSuccess:(requestSuccessBlock)success
                               andFailure:(requestFailureBlock)failure {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:clientZID forKey:@"client_zid"];
        if (serviceName) {
            [paramsAndHeaders setValue:serviceName forKey:@"notify_service"];
        }
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];

        

        BOOL isSSOLogin =[self getIsSignedInUsingSSOAccountForZUID:zuid];

        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        //Make API
        // Request....
        //URL
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOGenerateHandshakeID_URL];
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response ");
            NSString *handshakeid = [jsonDict objectForKey:@"handShakeId"];
            success(handshakeid);
            
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            //Request failed
            
            DLog(@"Failure Response");
            failure(error);
            
            
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

- (void)getDeviceVerifyToken: (void (^)(NSString*))completionBlock {
    
#if !TARGET_OS_WATCH
    if (@available(iOS 11.0, *)) {
        DCDevice *device = [DCDevice currentDevice];
        if(device.isSupported){
            [device generateTokenWithCompletionHandler:^(NSData * _Nullable token, NSError * _Nullable error) {
                if(error == nil && token!=nil){
                    NSString *dcToken = [token base64EncodedStringWithOptions:0];
                    NSCharacterSet *urlChars = [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "];
                    dcToken = [dcToken stringByAddingPercentEncodingWithAllowedCharacters:[urlChars invertedSet]];
                    completionBlock(dcToken);
                } else {
                    completionBlock(nil);
                }
            }];
        } else {
            completionBlock(nil);
        }
    } else {
        completionBlock(nil);
    }
#else
    completionBlock(nil);
#endif

}


-(void)activateRefreshTokenUsing:(NSString*)handshakeID
                      havingZUID:(NSString *)zuid
             ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                     WithSuccess:(requestSuccessBlock)success
                      andFailure:(requestFailureBlock)failure {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        //Add Parameters
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        [paramsAndHeaders setValue:@"true" forKey:@"new_verify"];

        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        

        BOOL isSSOLogin =[self getIsSignedInUsingSSOAccountForZUID:zuid];

        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
 
        //Make API
        NSString *urlString = [NSString stringWithFormat:@"%@%@?handshakeId=%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSOInternalTokenActivation_URL, handshakeID] ;
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response %@", jsonDict);
            
            if ([jsonDict objectForKey:@"activate_token"]) {
                BOOL activationSuccess = [[jsonDict objectForKey:@"activate_token"] boolValue];
                if (activationSuccess) {
                    success(token);
                } else {
                    // throw static error
        
                }
            }
            
            
            
        } failureBlock:^(SSOInternalError errorType, NSError* activateError) {
            //Request failed
            
            DLog(@"Failure Response");
                        
            if (activateError) {
                NSDictionary *userInfo = [activateError userInfo];
                if ([[userInfo valueForKey:@"error"] isEqualToString:@"unverified_device"]) {
                    
                    [self getDeviceVerifyToken:^(NSString *deviceToken) {
                        if (ignorePasswordVerification && deviceToken == nil ) {
                            //device token is nil. Device verification API will fail
                            failure(activateError);
                            return;
                        } else {
                            // Call device verify even though the devicetoken is nil. inc_token will be received in device verify api only.
                            [self verifyDeviceFor:zuid
                                      deviceToken:deviceToken
                             ignorePasswordVerification:ignorePasswordVerification
                                       completion:^(NSError *deviceVerifyError) {
                                if (deviceVerifyError) {
                                    failure(deviceVerifyError);
                                } else {
                                    //device verification success. Activate refresh token
                                    [self activateRefreshTokenUsing:handshakeID
                                                         havingZUID:zuid
                                               ignorePasswordPrompt:ignorePasswordVerification
                                                        WithSuccess:success
                                                         andFailure:failure];
                                }
                            }];
                        }
                        
                    }];
                    
                } else {
                    //throw error
                    failure(activateError);
                }
            } else {
                //throw error
                failure(activateError);
            }
            
            
        }];
    } andFailure:^(NSError *error) {
        failure(error);
    }];
}

-(void)verifyDeviceFor:(NSString*)zuid
           deviceToken:(NSString*)dcToken
ignorePasswordVerification:(BOOL)ignorePasswordVerification
            completion:(requestFailureBlock)completionBlock {
    [self getTokenForZUID:zuid WithSuccess:^(NSString *token) {
        
        NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
        
        if([self->Service isEqualToString:kMDM_BundleID]){
            [paramsAndHeaders setValue:@"mdm" forKey:@"appid"];
        }else{
            [paramsAndHeaders setValue:@"prd" forKey:@"appid"];
        }
        
        if (dcToken) {
            [paramsAndHeaders setValue:dcToken forKey:@"device_verify_token"];
        }
        
        //Add Parameters
        [paramsAndHeaders setValue:@"0" forKey:@"deviceType"];
        [paramsAndHeaders setValue:self->UrlScheme forKey:@"redirect_uri"];
        
        //Add headers
        NSMutableDictionary *headers = [[NSMutableDictionary alloc]init];
        [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",token] forKey:@"Authorization"];
        
        BOOL isSSOLogin =[self getIsSignedInUsingSSOAccountForZUID:zuid];

        if (isSSOLogin) {
            [headers setValue: self->ClientID forKey:@"X-Client-Id"];
        }
        
        [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
        
        //Make API
        NSString *urlString = [NSString stringWithFormat:@"%@%@",[self getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerify_URL];
        [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                                      parameters: paramsAndHeaders
                                                    successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
            //Request success
            
            DLog(@"Success Response %@", jsonDict);
            
            NSString *activationStatus = [jsonDict objectForKey:@"status"];
            
            if ([activationStatus isEqualToString:@"success"]) {
                completionBlock(nil);
            } else {
                // get temp token and present safari
                
            }
            
            
        } failureBlock:^(SSOInternalError errorType, NSError* error) {
            //Request failed
            
            DLog(@"Failure Response");
            if (error) {
                NSDictionary *userInfo = [error userInfo];
                if ([[userInfo valueForKey:@"error"] isEqualToString:@"unverified_device"]) {
                
                    if (ignorePasswordVerification) {
                        completionBlock(error);
                    } else {
                        NSString *inc_token = [userInfo objectForKey:@"inc_token"];
                        [self promptDeviceVerificationFor:zuid having:inc_token completion:^(NSError *deviceCheckerror) {
                            if (deviceCheckerror == nil) {
                                completionBlock(nil);
                            } else {
                                completionBlock(deviceCheckerror);
                            }
                        }];
                    }
                    
                } else {
                    //throw static error
                    completionBlock(error);
                }
            } else {
                //throw static error
                completionBlock(error);
            }
        }];
    } andFailure:^(NSError *error) {
        completionBlock(error);
    }];
}


- (void)promptDeviceVerificationFor:(NSString*)zuid
                             having:(NSString*)tempToken
                            completion:(ZSSOKitErrorResponse)activationHandler {
    [ZIAMUtil sharedUtil]->finalDeviceVerificationBlock = activationHandler;
    [ZIAMUtil sharedUtil]->deviceVerificationURL = [NSString stringWithFormat:@"%@%@?inc_token=%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSODeviceVerifyWebPage_URL,tempToken];
    //present SFSafari to show scope enhancement
    [[ZIAMUtil sharedUtil] presentSSOSFSafariViewControllerWithSuccess:nil  andFailure:nil];
}

-(void)fetchUserInfoWithBlock:(requestFailureBlock)errorBlock {
    if(self.donotfetchphoto){
        [self fetchUserInfoHavingProfileURL:nil WithBlock:errorBlock];
    }else{
        [self fetchUserInfoHavingProfileURL:profileBaseUrl WithBlock:errorBlock];
    }
}
-(void)fetchUserInfoHavingProfileURL:(NSString *)profileURL WithBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",setAccountsServerURL,kSSOFetchUserInfo_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init ];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",setAccessToken]
               forKey:@"Authorization"];

    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                               successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                                   //Request success
                                                   self->setProfileInfoDict = jsonDict;
                                                   long long ZUID_long = [[self->setProfileInfoDict objectForKey:@"ZUID"] longLongValue];
                                                   NSString *ZUID =[NSString stringWithFormat: @"%lld", ZUID_long];
                                                   self->setMultiAccountZUID = ZUID;
                                                   NSString *transformedContactsURL;
                                                   if(self->setLocation){
                                                       [self setDCLLocation:self->setLocation inKeychainForZUID:ZUID];
                                                   }
                                                   if(self->setBas64DCL_Meta_Data && ([self->setBas64DCL_Meta_Data length]>0)){
                                                       [self setDCLMeta:self->setBas64DCL_Meta_Data inKeychainForZUID:ZUID];
                                                   }
                                                   if(profileURL){
                                                       transformedContactsURL = [self transformURL:profileURL ZUID:ZUID Location:self->setLocation];
                                                       [self fetchProfilePhotoHavingProfileURL:transformedContactsURL withBlock:errorBlock];
                                                   }else{
                                                       self->setProfileImageData = nil;
                                                       [self storeItemsInKeyChainOnSuccess];
                                                       errorBlock(nil);
                                                   }
                                               } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                                   //Request failed
                                                   errorBlock(error);
                                               }];

}
-(void)fetchProfilePhoto:(requestFailureBlock)errorBlock {
    [self fetchProfilePhotoHavingProfileURL:profileBaseUrl withBlock:errorBlock];
}
-(void)fetchProfilePhotoHavingProfileURL:(NSString *)profileURL withBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",profileURL,kProfilePhotoFetch_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers =[[NSMutableDictionary alloc] init];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",setAccessToken] forKey:@"Authorization"];
    
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                       successBlockWithData:^(NSData *data, NSHTTPURLResponse *httpResponse) {
                                           //Request success

                                           self->setProfileImageData = data;
                                           [self storeItemsInKeyChainOnSuccess];
                                           errorBlock(nil);


                                       } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                           //Request failed
                                           self->setProfileImageData = nil;
                                           [self storeItemsInKeyChainOnSuccess];
                                           errorBlock(nil);
                                       }];
}
-(void)forceFetchProfilePhotoForCurrentUserhavingAccessToken:(NSString *)accessToken withSuccessBlock:(photoSuccessBlock)successBlock withErrorBlock:(requestFailureBlock)errorBlock{
    [self fetchProfilePhotoHavingProfileURL:profileBaseUrl havingAccessToken:accessToken withSuccessBlock:successBlock withErrorBlock:errorBlock];
}
-(void)fetchProfilePhotoHavingProfileURL:(NSString *)profileURL havingAccessToken:(NSString *)accessToken withSuccessBlock:(photoSuccessBlock)successBlock withErrorBlock:(requestFailureBlock)errorBlock{
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",profileURL,kProfilePhotoFetch_URL];

    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];

    //Add headers
    NSMutableDictionary *headers =[[NSMutableDictionary alloc] init];
    [headers setValue:[NSString stringWithFormat:@"Zoho-oauthtoken %@",accessToken] forKey:@"Authorization"];
    
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];

    // Request....
    [[SSONetworkManager sharedManager] sendGETRequestForURL: urlString
                                                 parameters: paramsAndHeaders
                                       successBlockWithData:^(NSData *data, NSHTTPURLResponse *httpResponse) {
                                           //Request success
                                           successBlock(data);
                                       } failureBlock:^(SSOInternalError errorType, NSError* error) {
                                           //Request failed
                                           errorBlock(error);
                                       }];
}

-(void)presentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure{
    [self checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:success andFailure:failure switchSuccess:nil];
}

- (void)checkRootedDevice:(void (^)(void))completion {
    #if !SSO_APP__EXTENSION_API_ONLY
    [self isJailbroken:^(BOOL isValid) {
            if(isValid){
                NSString *continueTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.continue" Comment:@"Continue"];

                NSString *cancelTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.cancel" Comment:@"Cancel"];
                NSString *alertTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.rooted.alert" Comment:@"Your device is rooted. Proceed at your own risk since using a rooted device will make the app vulnerable to malicious attacks."];
                UIAlertController *alertController;
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
                }else{
                    alertController = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                }
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDestructive handler:nil];
                UIAlertAction *continueAction = [UIAlertAction actionWithTitle:continueTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    completion();
                }];
                [alertController addAction:continueAction];
                [alertController addAction:cancel];

                [[alertController popoverPresentationController] setSourceView:[self getActiveWindow].rootViewController.view];
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *top = [self topViewController];
                    if(top){
                        [top presentViewController:alertController animated:YES completion:nil];
                    }else{
                        [[self getActiveWindow].rootViewController presentViewController:alertController animated:YES completion:nil];
                    }
                });
            }else{
                completion();
            }
    }];
    
#endif
}
-(void)checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure switchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
    
    [self checkRootedDevice:^{
        [self presentSSOSFSafariViewControllerWithSuccess:success andFailure:failure switchSuccess:switchSuccess];
    }];
    
#endif

}
-(void)presentSSOSFSafariViewControllerWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure switchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
    dispatch_async(dispatch_get_main_queue(), ^{
        SSOSFSafariViewController *sfview = [[SSOSFSafariViewController alloc] init];
        sfview.modalPresentationStyle = UIModalPresentationOverFullScreen;
        sfview.SSLPinningDelegate = [self SSLPinningDelegate];
        if(success)
            sfview.success = success;
        if(switchSuccess)
            sfview.switchSuccess = switchSuccess;
        sfview.failure = failure;
        
        UIViewController *top = [self topViewController];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self->_shouldPresentInFormSheet) {
            sfview.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        if(top){
            [top presentViewController:sfview animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:sfview animated:YES completion:nil];
        }
    });
#endif
}

-(BOOL)checkifSSOAccountsMatchForZUID:(NSString *)zuid {
    BOOL isAppSSOUser = NO;
    if ([AppName isEqualToString:Service]) {
        /// In New Sign-In flow access token won't be saved on shared keychain on login [Before SSO]
        if ([[ZIAMUtil sharedUtil] getSSOAccessTokenDataFromSharedKeychainForZUID:zuid]) {
            isAppSSOUser = YES;
        }
    }else {
        if ([[ZIAMUtil sharedUtil] getAppSSOAccessTokenDataFromSharedKeychainForZUID:zuid]) {
            isAppSSOUser = YES;
        }
    }
    return isAppSSOUser;
}

-(void)setRevokeFailedDueToNetworkError{
    [self setRevokeFailedDueToNetworkErrorInKeychain];
}

- (NSString*)getMDMHeaderFromMDMToken:(NSString*)mdmToken {
    NSArray *mdmTokenSplit = [mdmToken componentsSeparatedByString:@":"];
    if (mdmTokenSplit && mdmTokenSplit.count == 3) {
        NSString* realMdmToken = mdmTokenSplit[0];
        NSString* zid = mdmTokenSplit[1];
        NSString* tokenSecret = mdmTokenSplit[2];
        long long currentMillis = [[ZIAMUtil sharedUtil] getCurrentTimeMillis];
        NSString* nbf = [NSString stringWithFormat:@"%lld",currentMillis/1000-(5*60)];
        NSString* exp = [NSString stringWithFormat:@"%lld",currentMillis/1000+(5*60)];
        
        NSMutableDictionary *mdmDetails = [[NSMutableDictionary alloc] init];
        [mdmDetails setValue:nbf forKey:@"nbf"];
        [mdmDetails setValue:exp forKey:@"exp"];
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mdmDetails options:NSJSONWritingPrettyPrinted error:&error];
        NSString *encryptedDataString = [jsonData aesCBCEncryptWithKey:tokenSecret];
        encryptedDataString = [encryptedDataString stringByReplacingOccurrencesOfString:@"=" withString:@""];;
        NSString *mdmParam = [NSString stringWithFormat:@"%@:%@:%@", realMdmToken, zid, encryptedDataString ];
        return mdmParam;
    }
    return nil;
}



@end

