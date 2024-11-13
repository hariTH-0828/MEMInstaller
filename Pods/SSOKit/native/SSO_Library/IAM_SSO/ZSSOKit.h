//
//  ZSSOKit.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 22/03/17.
//
//

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH 
#import <UIKit/UIKit.h>

#if !TARGET_OS_UIKITFORMAC
#import <SafariServices/SafariServices.h>
#endif

#endif
#import "SSOConstants.h"
#import "SSOEnums.h"
#import "ZSSOProtocols.h"
#import "SSORequestBlocks.h"
#import "ZSSOProfileData.h"
#import "ZIAMToken.h"


/**
 The SSOKit Framework  is primarily used for single sign on across all Zoho apps. This framework has been enhanced to facilitate easier integration with every zoho app. We handle Single Sign-On using OneAuth, Sign-In and Sign-Up using SFSafariViewController, Authentication, Storing OAuth Tokens, DCL handling, basic profile information and all other related work securely and efficiently. You can now afford undivided concentration on your App's business logic.
 Refer documentation here: https://learn.zoho.com/portal/zohocorp/team/iam-mobile/manual/iam-mobile-sdks/article/documentation
 
 */
@interface ZSSOKit : NSObject

#if !TARGET_OS_WATCH
/**
 This method helps you to initialize the parameters which are required by the SSOKit.
 Call this method during App Launch.

 @param clientID The client ID of your app will be given by the IAM Team.(Note: Use different Client ID's for Local Zoho and IDC.)
 @param scopeArray The API scopes requested by the app, represented in an array of |NSString|s. The default value is |@[aaaserver.profile.READ,zohocontacts.userphoto.READ]|.(Get the list of scopes required for your app from the respective service teams. Each Scope String should follow the proper syntax. -> 'servicename'.'scopename'.'operation type' Example: aaaserver.profile.READ.
 @param urlScheme Your App's URL Scheme.(!Please WhiteList the URL Scheme "ZOA"!)
 @param mainWindow UIWindow instance is required for presenting SFSafariViewController/AccountChooserViewController.
 @param buildType This is the Enum of your build type. (LocalZoho, Live etc...)
 */

+ (void) initWithClientID: (NSString*)clientID
                         Scope:(NSArray*)scopeArray
                     URLScheme:(NSString*)urlScheme
                    MainWindow:(UIWindow*)mainWindow
                     BuildType:(SSOBuildType)buildType NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void)setMultiWindowInstance:(UIWindow*)mainWindow;
    #endif

/**
 This method helps you to initialize the parameters which are required by the SSOKit.
 Call this method during App Launch in Extensions and iWatch.
 (Note: Add your main app's bundle id in your extensions info.plist for "SSOKIT_MAIN_APP_BUNDLE_ID" key)

 @param clientID The client ID of your app will be given by the IAM Team.(Note: Use different Client ID's for Local Zoho and IDC.)
 @param scopeArray The API scopes requested by the app, represented in an array of |NSString|s. The default value is |@[aaaserver.profile.READ,zohocontacts.userphoto.READ]|.(Get the list of scopes required for your app from the respective service teams. Each Scope String should follow the proper syntax. -> 'servicename'.'scopename'.'operation type' Example: aaaserver.profile.READ.
 @param urlScheme Your App's URL Scheme.(!Please WhiteList the URL Scheme "ZOA"!)
 @param buildType This is the Enum of your build type. (LocalZoho, Live etc...)
 */
+ (void) initWithClientID: (NSString*)clientID
                                  Scope:(NSArray*)scopeArray
                              URLScheme:(NSString*)urlScheme
                              BuildType:(SSOBuildType)buildType;


/**
 Method for letting us know that your app has an App Extension, so that we will place the respective data in the keychain within the specified app group. Call this method in App Delegate launch after the above initializeWithClientID method. This should be called before you call clearSSODetailsForFirstLaunch method.

 @param appGroup appgroup string in which you want the keychain data to be available.
 */
+ (void)setHavingAppExtensionWithAppGroup:(NSString *)appGroup;

/**
 Method for sharing existing user data with newly added app extensions. Call this method, for a signed-in user, when you introduce any app extension in your new app version. So that user details will be available to the app extensions.
 */
+ (BOOL)migrateDetailsToAppGroup;


/**
 Gets the access token. In case the access token has expired or is about to expire, this method get a new token.

 @param tokenBlock callback in which you will get the required access token.
 */
+ (void) getOAuth2Token:(ZSSOKitAccessTokenHandler)tokenBlock;

/**
 For MULTI-ACCOUNT
 Gets the access token. In case the access token has expired or is about to expire, this method get a new token.
 
 @param zuid ZUID of respective user.
 @param tokenBlock callback in which you will get the required access token.
 */
+ (void) getOAuth2TokenForZUID:(NSString *)zuid tokenHandler:(ZSSOKitAccessTokenHandler)tokenBlock;

/**
 Gets the access token along with its expiry time for WMS Special case handling of web sockets. In case the access token has expired or is about to expire(Reduced from 60mins to 53mins), this method get a new token.
 
 @param tokenBlock callback in which you will get the required access token.
 */
+ (void) getOAuth2TokenForWMS:(ZSSOKitWMSAccessTokenHandler)tokenBlock;

/**
 For MULTI-ACCOUNT
 Gets the access token along with its expiry time for WMS Special case handling of web sockets. In case the access token has expired or is about to expire(Reduced from 60mins to 53mins), this method get a new token.
 
 @param zuid ZUID of respective user.
 @param tokenBlock callback in which you will get the required access token.
 */
+ (void) getOAuth2TokenForWMSHavingZUID:(NSString *)zuid tokenHandler:(ZSSOKitWMSAccessTokenHandler)tokenBlock;


/**
 Gets the access token along with its expiry time for WMS Special case handling of web sockets synchronously using semaphores and thereby may be blocking the UI. In case the access token has expired or is about to expire(Reduced from 60mins to 53mins), this method get a new token.

 @return ZIAMToken object containing the accessToken,expiryMillis and error objects.
 */
+(ZIAMToken *)getSyncOAuth2TokenForWMS;


/**
 Method to get the OAuth details which will be required by the Watch App to refresh the expired access token.

 @return dictionary containing all the details which is required to fetch a new access token.
 */
+ (NSDictionary *)getOAuthDetailsForWatchApp;

/**
 For MULTI-ACCOUNT
 Method to get the OAuth details which will be required by the Watch App to refresh the expired access token.
 
 @param zuid ZUID of respective user.
 @return dictionary containing all the details which is required to fetch a new access token.
 */
+ (NSDictionary *)getOAuthDetailsForWatchAppHavingZUID:(NSString *)zuid;


/**
 Method to set the OAuth details obtained from iPhone to the keychain of watch app.

 @param oauthDetails dictionary containing the details required to fetch new access token.
 */
+(void)setOAuthDetailsInKeychainForWatchApp:(NSDictionary *)oauthDetails;

/**
 For MULTI-ACCOUNT
 Method to set the OAuth details obtained from iPhone to the keychain of watch app.
 
 @param zuid ZUID of respective user.
 @param oauthDetails dictionary containing the details required to fetch new access token.
 */
+(void)setOAuthDetailsInKeychainForWatchAppHavingZUID:(NSString *)zuid details:(NSDictionary *)oauthDetails;


/**
 Presents the initial viewcontroller - (SFSafariViewController for Sign in/ SSOUserAccountsTableViewController for SSO Account Chooser).

 @param signinBlock handler block.
 */
+ (void) presentInitialViewController:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 Presents the initial viewcontroller with custom params for Sign in page - (SFSafariViewController for Sign in/ SSOUserAccountsTableViewController for SSO Account Chooser).

 @param urlParams custom urlparams to be passed to the sign-in page.
 @param signinBlock handler block.
 */
+ (void) presentInitialViewControllerWithCustomParams:(NSString *)urlParams
                                              signinHandler:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 Presents the Google Sign-in page directly in the SFSafariViewController.
 Note: Google Sign in Will not work in CN setup

 @param signinBlock handler block.
 */
+ (void) presentGoogleSigninSFSafariViewController:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the Google Sign-in page directly in the SFSafariViewController.
 Using this method will not consider OneAuth App flow.
 Note: Google Sign in Will not work in CN setup
 
 @param signinBlock handler block.
 */
+ (void) presentGoogleSigninSFSafariViewControllerWithOutOneAuth:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the Native Sign-in with Apple screen.
 Using this method will not consider OneAuth App flow.
 
 @param signinBlock handler block.
 */
+ (void) presentNativeSignInWithApple:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/// Presents the Native Sign-in for WeChat. Using this method will not consider OneAuth App flow.
/// @param weChatAppID App ID for your app registered on WeChat
/// @param weChatAppSecret App Secret for your app registered on WeChat
/// @param universalLink Universal Link for your app registered on WeChat
/// @param signinBlock handler block.
+ (void) presentWeChatSignInHavingWeChatID:(NSString *)weChatAppID weChatAppSecret:(NSString *)weChatAppSecret universalLink:(NSString *)universalLink signinHandler:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari. Normal Accounts Signup page will be shown.
 
 @param signinBlock handler block.
 */
+ (void) presentSignUpViewController:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari. Normal Accounts Signup page will be shown with custom params for Sign up page

 @param urlParams custom urlparams to be passed to the sign-up page. Query param should start with @"?" and multiple params can be passed in url query param format with "&" seperator. Example: @"?servicename=YOUR_SERVICENAME&ANYOTHERPARAM_KEY=VALUE" service name custom param is mandatory...
 @param signinBlock handler block.
 */
+ (void) presentignUpViewControllerWithCustomParams:(NSString *)urlParams
                                              signinHandler:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari having a custom signup flow. Your respective service team should be contacting IAM for service url param and will have to set the same on their signup page's register.js.
 
 @param signupUrl custom signup url.
 @param signinBlock handler block.
 */
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl
                                        signinHandler:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari having a custom signup flow. Your respective service team should be contacting IAM for service url param and will have to set the same on their signup page's register.js. And also do a special case handling to return the teamparams required to continue signup proccess from native app.
 
 @param signupUrl custom signup url.
 @param signupBlock handler block.
 */
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl
                                signupHandler:(ZSSOKitSignupHandler)signupBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari having a custom signup flow. Your respective service team should be contacting IAM for service url param and will have to set the same on their signup page's register.js. And also do a special case handling to return the teamparams required to continue signup proccess from native app.
 
 @param signupUrl custom signup url.
 @param cnSignUpURL custom signup url for cn setup.
 @param signupBlock handler block.
 */
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL
                                signupHandler:(ZSSOKitSignupHandler)signupBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Presents the SignUpViewController instance of SFSafari having a custom signup flow. Your respective service team should be contacting IAM for service url param and will have to set the same on their signup page's register.js.
 
 @param signupUrl custom signup url.
 @param cnSignUpURL custom signup url for cn setup.
 @param signinBlock handler block.
 */
+ (void) presentSignUpViewControllerHavingURL:(NSString *)signupUrl andCNSignUpURL:(NSString *)cnSignUpURL
                                signinHandler:(ZSSOKitSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 For MULTI-ACCOUNT
 Presents the SignViewController instance of SFSafari. Normal Accounts Sign page will be shown.
 
 @param signinBlock handler block.
 */
+ (void) presentMultiAccountSignin:(ZSSOKitMultiAccountSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 For MULTI-ACCOUNT
 Presents the SignViewController instance of SFSafari. Normal Accounts Sign page will be shown.
 
 @param urlParams custom urlparams to be passed to the sign-in page.
 @param signinBlock handler block.
 */
+ (void) presentMultiAccountSigninWithCustomParams:(NSString *)urlParams
                                     signinHandler:(ZSSOKitMultiAccountSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 For MULTI-ACCOUNT
 Presents the SignViewController instance of SFSafari. Normal Accounts Sign page will be shown.
 
 @param urlParams custom urlparams to be passed to the sign-in page.
 @param signinBlock handler block.
 */
+ (void) presentSignInUsingAnotherAccountWithCustomParams:(NSString *)urlParams
                                     signinHandler:(ZSSOKitMultiAccountSigninHandler)signinBlock NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 For MULTI-ACCOUNT
 Method to present the Manage Multiple Accounts viewcontroller. Call this method only if your app is having multi account support.
 
 @param manageHandler handler block.
 */
+ (void) presentManageAccountsViewController:(ZSSOKitManageAccountsHandler)manageHandler NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 Method to clear the keychain items stored by SSOKit which would be persistant even after uninstalling the app. (Call this method if it is going to be your apps firt time launch. Keychain items are persistently stored even if the app is Uninstalled!)
 */
+ (void) clearSSODetailsForFirstLaunch;


/**
 Method to get the Signed-in status of user in your app.

 @return YES if there is already a user signed-in to your app or NO if there is no user signed in to your app.
 */
+ (BOOL) isUserSignedIn;

/**
 Method to Check if the current user is signed in to the app using Sign in With Apple

 @return YES if there is already a user signed-in to your app or NO if there is no user signed in to your app.
 */
+ (BOOL) isCurrentUserSignedInUsingSIWA;

/**
 Method to Check if the particular ZUID user is signed in to the app using Sign in With Apple

 @param ZUID zuid of the user
 @return YES if there is already a user signed-in to your app or NO if there is no user signed in to your app.
 */
+ (BOOL) isUserSignedInUsingSIWAForZUID:(NSString *)ZUID;


/**
 Method to handle OAuth redirection via URL Scheme.
 This method should be called from your |UIApplicationDelegate|'s
 |application:openURL:sourceApplication:annotation|.  Returns |YES| if |SSOKit handled this URL.


 @param url url opened.
 @param sourceApplication The application which opened this app.
 @param annotation annotation object.
 @return YES if SSOKit handled this URL.
 */
+ (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
       annotation:(id)annotation NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 Method to get the Current User object of your App.

 @return ZSSOUser object of the current user.
 */
+(ZSSOUser *)getCurrentUser;



/**
 For MULTI-ACCOUNT
 Method to get the array containg objects of all ZUser objects of Signed in users. Call this method only if your app is having multi account support.
 
 @return Array of ZUser objects.
 */
+(NSArray<ZSSOUser*> *) getUsersForApp;


/**
 For MULTI-ACCOUNT
 Method to get the ZUser object of particular ZUID. Call this method only if your app is having multi account support.
 
 @return ZSSOUser object of the respecrtive zuid user.
 */
+(ZSSOUser *) getZSSOUserHavingZUID:(NSString *)zuid;


/**
 Method to be called during Logout. This will revoke the access token from the server and clears the keychain items stored by SSOKit.

 @param revoke handler block.
 */
+(void)revokeAccessToken:(ZSSOKitRevokeAccessTokenHandler)revoke;


/**
 For MULTI-ACCOUNT
 Method to be called during Logout. This will revoke the access token from the server and clears the keychain items stored by SSOKit.
 
 @param zuid ZUID of respective user.
 @param revoke handler block.
 */
+(void)revokeAccessTokenForZUID:(NSString *)zuid revokeHandler:(ZSSOKitRevokeAccessTokenHandler)revoke;


/**
 Method to get the transformed URL which does the DCL handling. (Call this method once and persist the transformed URL)

 @param url Input URL which needs to be transformed.
 @return Output transformed URL based upon the users DCL data.
 */
+(NSString *)getTransformedURLStringForURL:(NSString *)url;



/**
 For MULTI-ACCOUNT
 Method to get the transformed URL which does the DCL handling. (Call this method once and persist the transformed URL)

 @param url url Input URL which needs to be transformed.
 @param zuid ZUID of respective user.
 @return Output transformed URL based upon the users DCL data.
 */
+(NSString *)getTransformedURLStringForURL:(NSString *)url havingZUID:(NSString *)zuid;


/**
 Method to get the DCL Related Data if required for any special handling in your app.
 
 @return dcl information.
 */
+(NSDictionary *)getDCLInfoForCurrentUser;


/**
 For MULTI-ACCOUNT
 Method to get the DCL Related Data if required for any special handling in your app.

 @param zuid ZUID of respective user.
 @return dcl information.
 */
+(NSDictionary *)getDCLInfoForZuid:(NSString *)zuid;


/**
 Call this method to skip fetching the profile photo during sign in. This might improve the performace by reducing the time taken for completing the Sign in.
 */
+(void) donotFetchProfilePhotoDuringSignin;


/**
 Method used for Scope Enhancements. Call this method once if you are introducing new scopes in your app update.
 
 @param enhanceHandler handler block.
 */
+(void)enhanceScopes:(ZSSOKitScopeEnhancementHandler)enhanceHandler NS_EXTENSION_UNAVAILABLE_IOS("");


/**
 For MULTI-ACCOUNT
 Method used for Scope Enhancements. Call this method once if you are introducing new scopes in your app update.
 
 @param zuid ZUID of respective user.
 @param enhanceHandler handler block.
 */
+(void)enhanceScopesForZUID:(NSString *)zuid handler:(ZSSOKitScopeEnhancementHandler)enhanceHandler NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Method used to migrate the existing AuthToken users to OAuth.
 
 @param authToken existing user's AuthToken
 @param appName Contact IAM Team and get the value for AppName.
 @param accountsBaseURL accounts base URL for the respective user.
 @param authToOAuthBlock handler block.
 */
+(void)getOAuth2TokenUsingAuthToken:(NSString *)authToken
                             forApp:(NSString *)appName
                  havingAccountsURL:(NSString *)accountsBaseURL
                      authToOAuthHandler:(ZSSOKitAuthToOAuthHandler)authToOAuthBlock NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Calling this method will point to China setup thereby showing the China Sign in page.
 */
+(void) pointToChinaSetup __deprecated_msg("use setAppSupportsChinaSetup instead.");


/**
 Call this method everytime when your server gives you the invalid OAuth token error to check if it is a valid error case and to determine if you should logout the user and take them to your onboarding screen.

 @param logoutHandler handler block.
 */
+(void)checkAndLogoutUserDuringInvalidOAuth:(ZSSOKitErrorResponse)logoutHandler;

/**
 For MULTI-ACCOUNT
 Call this method everytime when your server gives you the invalid OAuth token error to check if it is a valid error case and to determine if you should logout the  respective user and take them to your onboarding screen or remove that user in case of Multi Account.
 
 @param zuid ZUID of respective user.
 @param logoutHandler handler block.
 */
+(void)checkAndLogoutUserDuringInvalidOAuthForZUID:(NSString *)zuid handler:(ZSSOKitErrorResponse)logoutHandler;


/**
 You can hide the SSOKit console debug logs using this method.

 @param shouldLog preferred bool value
 */
+(void)shouldShowSSOKitLogs:(BOOL)shouldLog;

#if !TARGET_OS_WATCH && !SSO_APP__EXTENSION_API_ONLY

/**
 WKWebview will be used to present sign in page specifically added for Managed MDM case.
 
 @param shouldUseWKWebview preferred bool value.
 */
+(void)setShouldUseWKWebview:(BOOL)shouldUseWKWebview API_AVAILABLE(ios(11.0));

/**
 ASWebAuthenticationSession will be used to present sign in page. This will allow your app to share cookie with Safari browser by asking for a user prompt.
 
 @param shouldUseASWebAuth preferred bool value.
 */
+(void)shoulduseASWebAuthenticationSession:(BOOL)shouldUseASWebAuth API_AVAILABLE(ios(12.0));


#if !TARGET_OS_UIKITFORMAC
/**
 SFSafari Customisation support for setting the SFSafari Bar Tint Color.

 @param preferredBarTintColor preferred UIColor
 */
+(void)setPreferredBarTintColorForSFSafari:(UIColor *)preferredBarTintColor;

/**
 SFSafari Customisation support for setting the SFSafari Controller Tint Color.
 
 @param preferredControlTintColor preferred UIColor
 */
+(void)setPreferredControlTintColorForSFSafari:(UIColor *)preferredControlTintColor;

/**
 SFSafari Customisation support for editing the dismiss button style.
 
 @param dismissButtonStyle preferred value
 */
+(void)setSFSafariViewControllerDismissButtonStyle:(SFSafariViewControllerDismissButtonStyle)dismissButtonStyle API_AVAILABLE(ios(11.0));

/**
 SFAuthenticationSession will be used to present sign in page. This will allow your app to share cookie with Safari browser by asking for a user prompt.
 
 @param shouldUseSFAuth preferred bool value.
 */
+(void)setShouldUseSFAuthenticationSession:(BOOL)shouldUseSFAuth API_AVAILABLE(ios(11.0));

/// Method to set the source view for DC Chooser Action sheet for iPad to select Zoho China or Zoho DC
/// @param dcChooserActionSheetSourceView source view for Action sheet for iPad
+(void)setDCChooserActionSheetSourceView:(UIView *)dcChooserActionSheetSourceView NS_EXTENSION_UNAVAILABLE_IOS("");
#endif
#endif

/**
 Method to know if the current signed in user of the App, Used OneAuth SSO Account to login. If this is true, then Scope Enhancements for this user will not require password confirmation and would be done silently.
 
 @return YES if the user signed in with SSO Account Chooser
 */
+(BOOL)getIsSignedInUsingSSOAccount;


/**
 For MULTI-ACCOUNT
 Method to know if this ZUID user of the App, Used OneAuth SSO Account to login. If this is true, then Scope Enhancements for this user will not require password confirmation and would be done silently.
 
 @param zuid ZUID of respective user.
 @return YES if the user signed in with SSO Account Chooser
 */
+(BOOL)getIsSignedInUsingSSOAccountForZUID:(NSString *)zuid;


/**
 Call this method before calling present method, to get the feedback option on Sign in page displayed on SFSafari. On tapping the feedback button, error would be returned to sign in callback.
 
 @param showFeedback preferred bool value.
 */
+(void)setShouldShowFeedBackOptionOnSFSafari:(BOOL)showFeedback;


/**
 If your app supports CN Setup, call this method before the present method. If this is called, we will read the locale or country code and if it is CN, China login page would be shown and the login page on SFSafari would have an DC switcher button to go to US DC and vice versa.
 
 @param isAppSupportsCN preferred bool value.
 */
+(void)setAppSupportsChinaSetup:(BOOL)isAppSupportsCN;


/**
 If this method is called before calling the present methods, we will not send the scopes paramater during Sign in and Sign up cases.
 If this is called during app launch along with init, we will not send the scopes param during OAuth token fetch and Scope enhancements as well!
 */
+(void)donotSendScopesParam;


/**
 If this method is called, then all the presentations by SSOKit on iPads will have FormSheet presentation style.
 
 @param shouldPresentInFormSheet preferred bool value.
 */
+(void)setShouldPresentIniPadFormSheetPresentationStyle:(BOOL)shouldPresentInFormSheet;


/**
 Method to show custom loading indicator during Sign in/Sign up process...

 @param callbackBlock handler block
 */
+(void) startProgress:(void (^)(void)) callbackBlock;


/**
Method to stop custom loading indicator during Sign in/Sign up process...

 @param callbackBlock handler block
 */
+(void) endProgress:(void (^)(void)) callbackBlock;


/**
 Method to call the account account confirmation process for unconfirmed accounts. Confirmation process would be presented on SFSafari.

 @param tokenBlock handler block
 */
+(void)confirmUnconfirmedUserAndGetOAuth2Token:(ZSSOKitAccessTokenHandler)tokenBlock;


/**
 If you used "donotFetchProfilePhotoDuringSignin" and later if you need to fetch profile photo from server or if you want the current updated profile photo of a user, you can use this method.

 @param token valid accessToken obtained from getOAuth2Token Method
 @param photoBlock handler block
 */
+(void)forceFetchProfilePhotoFromServerHavingAccessToken:(NSString *)token photoHandler:(ZSSOKitPhotoFetchHandler)photoBlock;

/**
 For generating handshake ID to create internal refresh token.

 @param clientZID ZID of the client mapped in the server
 @param service This is optional. If your app's client ID is created for XXXX service, but if the internal refresh token is to be created for YYYY service, you will need to send YYYY to this param. Setting nil will consider that the service is same for whiich this mobile app's client ID is configured.
 */
+(void)generateHandshakeIDHavingClientZID:(NSString * _Nonnull)clientZID
                               forService:(NSString * _Nullable)service
                                  handler:(ZSSOKitHandShakeIDHandler _Nonnull)handshakeIDHandler;
/**
 For generating handshake ID to create internal refresh token.

 @param clientZID ZID of the client mapped in the server
 @param zuid ZUID of the user
 @param service This is optional. If your app's client ID is created for XXXX service, but if the internal refresh token is to be created and activated for YYYY service, you will need to send YYYY to this param. Setting nil will consider that the service is same for whiich this mobile app's client ID is created.
 */
+(void)generateHandshakeIDHavingClientZID:(NSString * _Nonnull)clientZID havingZUID:(NSString * _Nonnull)zuid forService:(NSString * _Nullable)service handler:(ZSSOKitHandShakeIDHandler _Nonnull )handshakeIDHandler;

+(void)activateTokenForHandshakeID:(NSString *)handshakeID
               ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                           handler:(ZSSOKitTokenActivationHandler)activationHandler;

+(void)activateTokenForHandshakeID:(NSString *)handshakeID
               ignorePasswordPrompt:(BOOL)ignorePasswordVerification
                           forZUID:(NSString *)zuid handler:(ZSSOKitTokenActivationHandler)activationHandler;

/// If the current user is signed in to your app using SIWA, call this method during every app launch and based upon the error received, call revoke method of SSOKit showing appropriate error to user to logout the user out of the app.
/// @param SIWAAuthStateHandler handler block returning error if any.
+ (void)observeSIWAAuthticationStateHavingCallback:(ZSSOKitSignInWithAppleAuthStateChangeHandler)SIWAAuthStateHandler;

/// For MULTI-ACCOUNT
/// If the current user is signed in to your app using SIWA, call this method during every app launch and based upon the error received, call revoke method of SSOKit showing appropriate error to user to logout the user out of the app.
/// @param SIWAAuthStateHandler handler block returning error if any.
+ (void)observeSIWAAuthticationStateWithZUIDHavingCallback:(ZSSOKitSignInWithAppleAuthStateChangeWithZUIDHandler)SIWAAuthStateHandler;


/// Method to get MDM Token from Managed MDM Configuration to set "X-MDM-Token" header value required for all API calls specifically added for Managed MDM case.
+(NSString *)getMangedMDMToken;
/// For Mobile verification
/**
Method to send OTP to mobile number for adding as user ID

 @param response

 This method gives you response of two values
 mobileID - This ID has to be persisted and sent back when attempting to resend/verify OTP to the same mobile number.
 error - if there is no error in sending OTP , it throws error with code k_SSOMobileNumberSendOTPError else it will be nil

 @param mobileNumber mobile number of the user
 @param countryCode country code selected by the user
 @param forZUID ZUID of the user
 */
+ (void)sendOTPTo:(NSString*)mobileNumber
 countryCode:(NSString*)code
    forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitOTPCodeResponse)response ;
/**
Method to Resend OTP to mobile number for adding as user ID

 @param response

 Callback with error
 error - if there is no error in resending OTP , it throws error with code k_SSOMobileNumberSendOTPError else it will be nil
 
 @param mobileID Use mobileID received in the previous call of this same method.
 @param forZUID ZUID of the user
 */
+ (void)resendOTPTo:(NSString*)mobileID
            forZUID:(NSString*)userZUID
     WithResponse:(ZSSOKitErrorResponse)response ;
/**
Method to send OTP to mobile number for adding as user ID
 @param response

 error - if there is any error in verifying OTP ,  it throws error with code k_SSOMobileNumberVerifyError, else it will be nil

 @param mobileID the mobileID received in the l 'sendOTPTo'
 @param OTP OTP code received by the user
 @param forZUID ZUID of the user
 */
+(void)verifyMobileD:(NSString*)mobileID
         WithOTPCode:(NSString *)OTP
             forZUID:(NSString*)userZUID
            response:(ZSSOKitErrorResponse)response ;
/**

 For handling k_SSOOneAuthAccountBlockedState
 If the current user is signed in to your app using SSO(OneAuth's user), and changed the password, the SSO token will become inactive. Call this method to activate the same.
 @param zuid zuid of the sso user
 @param callback handler block returning error if any.
 */

+ (void) activateSSOTokenForZUID:(NSString*)zuid
                  HavingCallback:(ZSSOKitTokenActivationHandler)callback;
/**
 Method to be called during close account. This will show an authenticated accounts deletion page(user doesnt have to login) on the safari view controller . 

 @param revoke handler block. This gets called when user finishes/cancels the close account process
 */
+(void)presentCloseAccountViewControllerWithoutSignInPage:(ZSSOKitErrorResponse)response NS_EXTENSION_UNAVAILABLE_IOS("");
/**
 Method to be called during close account. This will show an authenticated accounts deletion page(user doesnt have to login) on the safari view controller .

 @param revoke handler block. This gets called when user finishes/cancels the close account process
 @param ZUID ZUID of the user

 */
+(void)presentCloseAccountViewControllerWithoutSignInPageForUserHavingZUID:(NSString*)ZUID completionHandler:(ZSSOKitErrorResponse)response NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void) presentWebkitViewForZUID:(NSString*)zuid
                      url:(NSURL*)url
                           headers:(NSDictionary<NSString*, NSString*> *)headers
                       WithFailure:(ZSSOKitErrorResponse)failure;

#if !TARGET_OS_WATCH
+ (void) getViewForLoadingWebcontentForZUID:(NSString*)zuid
                                        url:(NSURL*)url
                                     headers:(NSDictionary<NSString*, NSString*> *)headers
                      withCompletionHandler:(ZSSOKitContentViewHandler)handler;
#endif
/**
 Call this method to update your profile photo.
 
 @param image UIImage object.
 @param uploadBlock handler block.
 */
#if !TARGET_OS_WATCH

+(void)updatePhoto:(UIImage*)image uploadHandler:(ZSSOKitErrorResponse)uploadBlock NS_EXTENSION_UNAVAILABLE_IOS("");
#endif

/**
 Call this method to set use custom base domain url other than the supported SSOBuildType
 
 @param urlString string representation of the base url to which this SDK will append the other endpoints as necessary.
 */
+ (void)setBaseURL:(NSString*)urlString;
/**
  To support SSL pinning and validations.
 
 @param delegate Inhertit this protocol and implements its method to validate the challenge in the API calls and webview navigations from the SDK
 */
+ (void)setDelegateForSSLPinning:(id <ZSSOSSLChallengeDelegate>) delegate;

/** There may be cases in your app where you will need to authenticate the user for doing an operation. This method opens user password/MFA verification page and marks the user/session as authentic for while (defined by the server based on their criteria.
 @param ZUID ZUID of the user

 */
+ (void) presentReauthenticationPageForUser:(NSString*_Nonnull)zuid
                WithFailure:(ZSSOKitErrorResponse _Nullable )failure;

/** Verifies the email of the user if it is not verified . Please call this method if you know that the user's email is unverified.
 @param ZUID ZUID of the user

 */
+ (void) presentVerifyEmailForUser:(NSString* _Nonnull)zuid
                       WithFailure:(ZSSOKitErrorResponse _Nullable)failure;

+ (void) getJWTForUser:(NSString*)ZUID portalID:(NSString*)portalID completion:(ZSSOKitAccessTokenHandler)completion;


+ (void)addSecondaryEmailIDForZUID:(NSString *)zuid WithCallback:(ZSSOKitAddEmailIDHandler)failure;

+ (void)addSecondaryEmailIDWithCallback:(ZSSOKitAddEmailIDHandler)failure;
@end
