//
//  SSOConstants.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 24/03/17.
//
//

#ifndef SSOConstants_h
#define SSOConstants_h



typedef NSString * SSOWebSessionHeaderKeys;
extern SSOWebSessionHeaderKeys SSOWebSessionUserAgent;


//MARK:- SSO (Oneauth) Token fetch photo errors

/**
 * Unable to fetch token using OneAuth.
 */
static const int k_SSOOneAuthTokenFetchError = 101;
/**
 * Access token fetch using OneAuth:Response is nil.
 */
static const int k_SSOOneAuthTokenFetchNil = 102;

/**
 * Unable to fetch token using OneAuth app. GeneralError..
 */
static const int k_SSOOneAuthTokenFetchGeneralError = 105;


//MARK:- Token fetch photo errors
/**
 * Unable to fetch token from server.
 */
static const int k_SSOTokenFetchError = 201;
/**
 * Access token fetch:Response is nil.
 */
static const int k_SSOTokenFetchNil = 202;

/**
 * Unable to fetch token. GeneralError.
 */
static const int k_SSOTokenFetchGeneralError = 205;
/*** Old Access Token has not been deleted.
 */
static const int k_SSOOldAccessTokenNotDeleted = 301;
/**
 * There is no access token.
 */
static const int k_SSONoAccessToken = 302;
/**
 * OneAuth SSO Account mismatch.If user is signed in as account 'A' from OneAuth and then uses the Account Chooser and selects Account 'A' and signs into your app as 'A' using SSO. Now if the user 'A' signs out from OneAuth app and then Signs in again with another account 'B'. If you ask for OAuth token from your app now which is signed as 'A', you will get this error and thereby you have to handle this error and take user 'A' out of your app.
 */
static const int k_SSOOneAuthAccountMismatch = 303;
/**
 * SSO Account is in blocked state, call CheckAndLogout method once when you get this error...
 */
static const int k_SSOOneAuthAccountBlockedState = 304;
/**
 *  No Users found.
 */
static const int k_SSONoUsersFound = 500;
/**
 *  Unable to fetch user's profile info.
 */


//MARK:- User Info errors

static const int k_SSOUserInfoFetchError = 601;
/**
 * User's profile info fetch:Response is nil.
 */
static const int k_SSOUserInfoFetchNil = 602;



//MARK:- User photo errors

/**
 * Unable to fetch user's profile photo. Some error occured.
 */
static const int k_SSOUserPhotoFetchError = 701;




//MARK:- Revoke token errors

/**
 * Unable to revoke token.
 */
static const int k_SSORevokeTokenError = 801;
/**
 * Revoke token fetch:Response is nil.
 */
static const int k_SSORevokeTokenResultNil = 802;





//MARK:- Generic errors
/**
 * Network call failed with unknown error.
 */
static const int k_SSOGenericError = 899;

//MARK:- Login errors
/**
 * Cannot get the initial login webview. Failback to the getTokenMethod which will present the AccountChooser
 */
static const int k_SSOGetInitialViewFailedCase = 900;
/**
 * Unable to fetch Refresh token from server.
 */
static const int k_SSORefreshTokenFetchError = 901;
/**
 * Refresh token fetch:Response is nil.
 */
static const int k_SSORefreshTokenFetchNil = 902;

/**
 * OAuth Server Error Occured during redirection
 */
static const int k_SSOOAuthServerError = 905;

/**
 * Sign in redirection dismissed from OneAuth.
 */
static const int k_SSOOneAuthSignInDismiss = 906;
/**
 * Sign out completed from OneAuth.
 */
static const int k_SSOOneAuthSignOut = 907;
/**
 * Done button tapped on SFSafari page
 */
static const int k_SSOSFSafariDismissedError = 908;
/**
 * SSO Account Chooser Dismissed
 */
static const int k_SSOAccountChooserDismissedError = 908;
/**
 * DC Chooser Select Your region cancelled
 */
static const int k_SSODCChooserCancelledError = 909;
/**
 * DC locations meta not received in refresh token call response
 */

static const int k_SSODCLResponseError = 910;



//MARK:- Scope enhancements errors

/**
 * Unable to Enhance Scope from server.
 */
static const int k_SSOScopeEnhancementFetchError = 1001;
/**
 * Scope Enhancement:Response is nil.
 */
static const int k_SSOScopeEnhancementFetchNil = 1002;

/**
 * Reauth needed for scope enhancement.
 */

static const int k_SSOScopeEnhancementReauthNeeded = 1003;

/**
 * OAuth Scope Enhancement Server Error Occured during redirection
 */
static const int k_SSOScopeEnhancementServerError = 1004;
/**
 * OAuth Scope Enhancement Done button tapped on SFSafari page
 */
static const int k_SSOScopeEnhancementDismissedError = 1005;
/**
 * OAuth Scope Enhancement is already done and not required
 */
static const int k_SSOScopeEnhancementAlreadyDone = 1006;


//MARK:- Auth to OAuth errors

/**
 * Unable to get OAuth token using AuthToken from server.
 */
static const int k_SSOAuthToOAuthFetchError = 2001;
/**
 * Auth to OAuth:Response is nil.
 */
static const int k_SSOAuthToOAuthFetchNil = 2002;

/**
 * OAuth to Auth Server Error Occured during redirection
 */
static const int k_SSOAuthToOAuthServerError = 2004;


//MARK:- Remote login errors
/**
 * Remote login failed
 */
static const int k_SSORemoteLoginFetchError = 3001;
/**
 * Remote login failed:Response is nil.
 */
static const int k_SSORemoteLoginFetchNil = 3002;

/**
 * Remote login failed. Server Error Occured
 */
static const int k_SSORemoteLoginServerError = 3004;

static const int k_SSORemoteLoginJWTServerError = 3014;

//MARK:- Email confirmation errors
/**
 * OAuth User Email Confirmation Server Error Occured
 */
static const int k_SSOUserConfirmationServerError = 3005;
/**
 * OAuth User Email Confirmation Done button tapped on SFSafari page
 */
static const int k_SSOUserConfirmationDismissedError = 3007;




//MARK:- Internal refresh token activation errors
/**
 * OAuth User Email Confirmation Server Error Occured
 */
static const int k_SSOInactiveRefreshTokenActivationServerError = 3006;



//MARK:- Device check errors
/**
 * OAuth device verification: Done button tapped on SFSafari page
 */
static const int k_DeviceVerificationDismissedError = 3008;




//MARK:- MDM Errors
/**
 * UnAuthorised Managed MDM Account
 */
static const int k_SSOUnAuthorisedManagedMDMAccount = 4001;
/**
 * Write a feedback option tapped from SFSafari Sign in page
 */
static const int k_SSOSFSafariFeedbackTapped = 5001;


//MARK:- SSO token reauth Errors
/**
 * Token Activation error
 */
static const int k_SSOTokenActivationServerError = 6001;
/**
 * OAuth TokenActivation Done button tapped on SFSafari page
 */
static const int k_SSOTokenActivationDismissedError = 6002;
/**
 * Native SIWA Error Authorization request failed for unknown reason
 */


//MARK:- SIWA Errors
static const int k_SSONativeSIWAASAuthorizationErrorUnknown = 7001;
/**
 * Native SIWA Error User canceled authorization request
 */
static const int k_SSONativeSIWAASAuthorizationErrorCanceled = 7002;
/**
 * Native SIWA Error Authorization request response is invalid
 */
static const int k_SSONativeSIWAASAuthorizationErrorInvalidResponse = 7003;
/**
 * Native SIWA Error Failed to process authorization request
 */
static const int k_SSONativeSIWAASAuthorizationErrorNotHandled = 7004;
/**
 * Native SIWA Error Authorization request failed
 */
static const int k_SSONativeSIWAASAuthorizationErrorFailed = 7005;
/**
 * Native SIWA Error
 */
static const int k_SSONativeSIWAError = 7006;
/**
 * Native SIWA Server Error
 */
static const int k_SSONativeSignInServerError = 7007;
/**
 * Native Sign in :Response is nil.
 */
static const int k_SSONativeSignInFetchNil = 7008;

/**
 * OAuth Native Sign in Server Error Occured during fetch
 */
static const int k_SSONativeSignInFetchError = 7010;
/**
 * Native SIWA unavailable for this os version  Error
 */
static const int k_SSONativeSIWAUnavailableForOSError = 7011;
/**
 * Native SIWA AuthState Change No Apple UserID Found in Keychain
 */
static const int k_SSONativeSIWAAuthStateNoUserID = 7012;
/**
 * Native SIWA AuthState AppleID Credential Transferred
 */
static const int k_SSONativeSIWAAuthStateCredentialTransferred = 7013;
/**
 * Native SIWA AuthState AppleID Credential Not Found
 */
static const int k_SSONativeSIWAAuthStateCredentialNotFound= 7014;
/**
 * Native SIWA AuthState AppleID Credential Revoked
 */
static const int k_SSONativeSIWAAuthStateCredentialRevoked= 7015;


//MARK:- Add Secondary Email Errors

/**
 * AddSecondaryEmail error
 */
static const int k_SSOAddSecondaryEmailServerError = 8001;
/**
 * OAuth AddSecondaryEmail Done button tapped on SFSafari page
 */
static const int k_SSOAddSecondaryEmailDismissedError = 8002;
/**
 * Close Account :Response is nil.
 */
static const int k_SSOAddSecondaryEmailResponseNil = 8003;



//MARK:- Add mobile number as screenname Errors

/**
* OAuth AddMobileNumber returned an error
*/
static const int k_SSOMobileNumberSendOTPError = 8010;

/**
* OAuth Resend OTP returned an error
*/
static const int k_SSOMobileNumberResendOTPError = 8011;


/**
* OAuth verify mobile number returned an error
*/
static const int k_SSOMobileNumberVerifyError = 8012;


//MARK:- Close Account Errors

/**
 * Close Account error
 */
static const int k_SSOCloseAccountServerError = 8030;
/**
 * Done button tapped on SFSafari Close account page's
 */
static const int k_SSOCloseAccountDismissedError = 8031;
/**
 * Close Account :Response is nil.
 */
static const int k_SSOCloseAccountResponseNil = 8032;


static const int k_SSOAuthenticatedWebsessionDismissed = 8041;

static const int k_SSOAuthenticatedWebsessionRedirected = 8042;

/**
 * Update photo error :No Response No error.
 */
static const int k_SSOUpdatePhotoServerError = 8060;
static const int k_SSOUpdatePhotoError = 8061;

static const int k_SSOReloginServerError = 8070;
static const int k_SSOReloginAccountDismissedError = 8071;
static const int k_SSOVerifyEmailDismissedError = 8081;
static const int k_SSOVerifyEmailServerError = 8080;

#endif /* SSOConstants_h */

