# ZSSOKit
--

![SSOKit logo](https://git.csez.zohocorpin.com/iam-team/zaccounts-utilities/raw/master/product_package/ios-sso.png)

The SSOKit Framework  is primarily used for single sign on across all Zoho iOS apps. This framework has been enhanced to facilitate easier integration with every zoho app. We handle Single Sign-On using OneAuth, Sign-In using SFSafariViewController, Authentication, Storing OAuth Tokens, DCL handling, basic profile information and all other related work securely and efficiently. You can now afford undivided concentration on your App's business logic.


## Installation
* You can use cocoapods to install SSOKit in your project.
* Your Podfile will look something like this

```
source 'https://git.csez.zohocorpin.com/zoho/zohopodspecs.git'
target '[TARGET NAME]' do
pod 'SSOKit'
end
```
* If you are having Extensions for your app please add the key "SSOKIT\_MAIN\_APP\_BUNDLE\_ID" having the value of your app's Bundle id in your Extension Target's info.plist, and your podfile should be something like this


```
source 'https://git.csez.zohocorpin.com/zoho/zohopodspecs.git'
target '[TARGET NAME]' do
pod 'SSOKit'
end
target '[Extension TARGET NAME]' do
pod 'SSOKit/AppExtension'
end
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name.include? 'SSOKit-AppExtension'
            target.build_configurations.each do |config|                
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = "$(inherited) SSO_APP__EXTENSION_API_ONLY"
            end
        end
    end
end
```

* Run pod install and make sure you are connected to the Zoho-corp lan or wifi to access the Git repo.

## Prerequisites

* *Get Client ID* : Join [**IAM Support group**](https://connect.zoho.com/portal/intranet/group/iam-support) and use [this link](https://connect.zoho.com/portal/intranet/groups/iam-support/customapps/customapp/oauth-mobile-apps-1226815000034817011) to request for a client ID.

* In your App Capabilities turn on KeychainSharing and AppGroups.
* If you are having your Team as Zoho Corporation then you will see one of the two AppGroups:
    * group.zoho.iamtest
    * group.zoho.inhouse.iam (for MDM Apps)

* Checkout **ZSSOKit.h** file to know about all the methods/features that are available in SSOKit and also **SSOConstants.h** file for Error codes and Error handlings.

## **Getting Started:** 
### Initializing
Initialise the kit before making any token/signin calls to the kit.
```
ZSSOKit.initWithClientID(YOUR_CLIENT_ID,
                        scope: SCOPES_ARRAY,
                        urlScheme: YOUR_URL_SCHEME,
                        mainWindow: YOUR_APP_WINDOW,
                        buildType: SSOBuildType )
```
### Login

Use the below method to invoke signin.
* If the user is already signed in OneAuth, the account chooser screen is displayed.
* If sign in is not yet done, then the user is redirected to the sign in page using the SFSarfariViewController.

```
ZSSOKit.presentInitialViewController { (accessToken, error) in
    if let err = error {
        print(err)
        //Handle login errors with proper alerts and redirection
    } else {
        print(accessToken)
        // Continue from herr using the accessToken

    }
}
```

Use the method *presentInitialViewControllerWithCustomParams* for including params to the signin URL. *Refer custom params below.*

### Handling safari redirection

Upon successful login, your application URL scheme will be called. Call SSOKit's handleURL method in openURL methods of UIApplicationDelegate in your AppDelegate. 
```
func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return ZSSOKit.handle(url,
                        sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                        annotation: options[UIApplicationOpenURLOptionsKey.annotation])
}

func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return ZSSOKit.handle(url,
                          sourceApplication: sourceApplication,
                          annotation: annotation)
}
```
For apps using SceneDelegate, use the below UIWindowSceneDelegate method

```
func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    ZSSOKit.handle(URLContexts.first?.url,
                          sourceApplication: URLContexts.first?.options.sourceApplication,
                          annotation:  URLContexts.first?.options.annotation)
}
```

### Flush keychain during first launch

If the app gets launched the first time, the **clearSSODetailsForFirstLaunch** method can be called to easily remove keychain items. When the logout option is called, the access token is automatically revoked.

```
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    if !UserDefaults.standard.bool(forKey: "MY_APP_LAUNCHED") {
        UserDefaults.standard.set(true, forKey: "MY_APP_LAUNCHED")
        UserDefaults.standard.synchronize()
        ZSSOKit.clearSSODetailsForFirstLaunch()
    }
    
    //Initilise SSOKit here..
    
    return true
}

```

### Sign Up

```
ZSSOKit.presentSignUpViewController { (accessToken, error) in
    if let err = error {
        print(err)
        ZOAdminUtil.shared.handleTokenError(error:err, viewController: self)
    } else {
        print(accessToken!)
        self.completeSignInWith()        
    }
}
```
Use the method *presentSignUpViewControllerWithCustomParams* for including params to the signup URL *(Refer custom params below.)*, and

*presentSignUpViewControllerHavingURL* when your app requires a custom signup page. 

### Custom params

#### Most used

* To disable SignUp option, **hide_signup=true**.
* To hide Apple SignIn option, **hideapple=true**.
* To enable dark mode, **darkmode=true**


#### Others

> *service_language,  signupurl ,  dcc ,  partner_domain ,  hide_secure ,  hide_fp ,  hide_title ,  hide_logo ,  hide_remember ,  appinfo ,  appname ,  hidegooglesignin ,  hideyahoosignin ,  hidefbconnect ,  hidelinkedin ,  hidetwitter ,  hideweibo ,  hidebaidu ,  hidedouban ,  hideqq ,  hideazure ,  portal_id ,  portal_name ,  portal_domain ,  hide_fs ,  m_redirect , loadchosen ,  hide_smartbanner ,  hidewechat* 


## **Features**:

### SIWA (Sign-in With Apple)

Refer [this manual](https://intranet.wiki.zoho.com/accounts/Sign---In---with---Apple---SSOKit.html) to register your app for SIWA. 
And then use the below method to present apple sign-in.

```
ZSSOKit.presentNativeSignIn { (token, error) in
            if error != nil {
                print("SIWA failed with error \(error?.localizedDescription)")
            } else {
                print(token)
            }
        }
```


### AuthToken to OAuthToken Migration:

If your app is already there on the AppStore working with AuthTokens, you can use this migration to keep your existing users signed in.
First join as a member in this [Connect Group](https://connect.zoho.com/portal/intranet/group/iam-support) and then access this [Creator Form](https://app.zohocreator.com/ZS_9000500/migrate-authtoken-to-oauthtoken/form-embed/App_Details) and provide your respective details and IAM team will get back to you with the AppName param value once the required changes are mapped on our server side.

### Google Sign-in using SFSafariViewController:
Now that Google is 
removing the support for showing the Google's Sign-in page in a webview, 
we are providing a special method to take care of this.

### Fetch Profile info:
Once sign-in is complete, the SSO kit framework fetches all required user profile information  for display in your app, including username and profile picture.

*Note*: By default these scopes will be added by the framework. (aaaserver.profile.READ, zohocontacts.userphoto.READ). These need not be added individually.

### Authorization:
Easily obtain Oauth Access tokens.  You need not worry about the expiry. Everytime the **getOAuth2Token** Method is called, an alive access token is provided.


### Multi-DC Handling:
Whether the customer location is US or EU, we've got you covered! You just have to use the transformed URL provided to handle Multi=DC support. 

*Note*: For CN support transform URL will not work at the moment. Based on the locale if it is going to be CN, then upon Button Click action from your tour screen you can show an action sheet in your app asking the user to select from "Zoho" or "Zoho CN" server. So if the user is selecting Zoho CN then before calling presentInitialViewController method call **pointToChinaSetup** method and thereby CN login page would be loaded. So you will know that the user is a CN user here and you will have to persist this CN user state and handle the Base URL's of CN accordingly without using transformURL method.

### Scope Enhancement:
If you are going to update your app introducing additional new scopes, then you can use **enhanceScopes** method during app launch and wait untill you get a callback handler from here. 

*Recommended practices:*

```
if ZSSOKit.isUserSignedIn() {

    // Get stored value from UserDefaults or CoreData or whichever that is suitable for your app.
    let scopesEnhanced = UserDefaults.standard.bool(forKey: "v2_scope_enhanced") 
    
    // Check if scopes enhanced already for the new version
    if !scopesEnhanced {
        // Enhance scopes
        ZSSOKit.enhanceScopes(forZUID: zuid) { (token, error) in
            if let err = error {

                // Handle error here

            } else {

                // Scopes enhanced successfully!

                UserDefaults.standard.set(true, forKey: "v2_scope_enhanced")
                
                // Note: Setting the same v2_scope_enhanced as true after new user sign in is recommended.

            }
        }
    }

}

```


*Note*: 

If the user has signed in with SSO using OneAuth, scope enhancements would be done silently. If the user has signed from SFSafari in your app, user will have to enter their password again to do the scope enhancement.
For a new user, scope enhancements should not be called. 


## **Other Special Handlings:**

### Revoke Access Token Error Handling (invalid\_mobile\_code):
Your apps respective OAuth session can be revoked from web in Device Logins section of Sessions from <https://accounts.zoho.com/u/h#sessions/userconnectedmobileapps>. So if someone revokes from web, you will have to take the user out of your app to your initial tour screen.

*Note*:
No need to call the revoke method during this invalid_mobile_code case. We will delete the keychain items when we get this error. So if you get this error you can directly take that user to your initial onboarding screen! 
Also, if the user is revoking the refresh token from the web, if the access token in your app has expired, we will try to fetch a new access token and at this point we will get this error invalid_mobile_code from server. 
But there might be cases in which the user is having an access token is valid and alive in the app and then deletes the refresh token from the web, in these cases if you are asking for the OAuth token, since it is valid and alive, we will return you the token directly. However, if you use this OAuth token to make your api calls, you will get an Invalid_OAuthToken error from your server side. In those cases, you can call a new method of the SSOKit checkAndLogout which will return you a boolean in the Logout handler. If it is Yes/true, you will have to take the user to the initial onboarding tour screen. If it is No/false, it is caused due to some other error and you can show an alert or handle this error appropriately.

### WatchKit Handling
If your app is having WatchKit support, you can get a sample demo project from us which has the WatchKit support.

## **Contact**
* [Kumareshwaran Sreedharan](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000011177417), [Abinaya Ravichandran](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000044703219), [Sreecharan N](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000050285969) for any help regarding the iOS Framework.
* [Dhanasekar Kadirvel](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000000659894) for anything web related.
* We also have an Android framework, you can contact [Mani K](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000049470983) or [Maheswaran Sivakumar](https://people.zoho.com/hr#home/dashboard/profile-userId:2803000002098087)
* We have a channel on Cliq [**#Mobile SSO Developers**](https://cliq.zoho.com/channels/mobilessodevelopers) for handling your Queries regarding SSOKit/ Mobile OAuth Adoption.
* If you are the DRI or the person responsible for integrating SSOKit with your app, please join [**#Mobile SSO Co-Ordinators**](https://cliq.zoho.com/channels/mobilessoexpertscommunity) on Cliq for all the Important Announcements/Updates regarding SSOKit.

## **Issues and Feedback**

Please consider contributing by submitting issues at [here](https://git.csez.zohocorpin.com/iam-team/accounts_ios_ssoframework/issues). You can also file suggestions and enhancements to the framework here.
