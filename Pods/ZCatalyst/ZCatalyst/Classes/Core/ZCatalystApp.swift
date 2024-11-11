//
//  CatalystApp.swift
//  Catalyst
//
//  Created by Giridhar on 17/05/19.
//

import Foundation
//import ZAnalytics


internal enum Constants: String
{
    case defaultName = "__CatalystDefaultApp"
    case appConfigName = "AppConfiguration"
    case environmentName = "DefaultDevelopmentEnv"
    case apnsTokenKey = "__catalyst__pushnotification__key"
    case apnsInstallationKey = "__catalyst__installation__key"
    
    var string: String {
        return self.rawValue
    }
}

public enum ZCatalystEnvironment
{
    case production
    case development
}

/// The Catalyst class lets you initialize an application/project
public class ZCatalystApp
{
    public internal( set ) var appConfig : ZCatalystAppConfiguration = ZCatalystAppConfiguration()
    internal var userAgent : String = "ZC_iOS_unknown_app"
    static var sessionCompletionHandlers : [ String : () -> () ] = [ String : () -> () ]()
    public static var fileUploadURLSessionConfiguration : URLSessionConfiguration = .default
    public static var fileDownloadURLSessionConfiguration : URLSessionConfiguration = .default
    public static var sessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
    static var session : URLSession = URLSession( configuration : sessionConfiguration )
    public static let shared = ZCatalystApp()
    
    private init()
    {
    }
    
    public func initSDK( window : UIWindow, appConfiguration : ZCatalystAppConfiguration ) throws
    {
        if let packageName = Bundle.main.infoDictionary?[ kCFBundleNameKey as String ] as? String, let appVersion = Bundle.main.infoDictionary?[ "CFBundleShortVersionString" ] as? String
        {
            self.userAgent = "\( packageName )/\( appVersion )(iPhone) ZCiOSSDK"
        }
        ZCatalystApp.shared.appConfig = appConfiguration
        try ZCatalystAuthHandler.initIAMLogin( with : window, config : appConfiguration )
    }
    
    public func initSDK( window : UIWindow, environment : ZCatalystEnvironment ) throws
    {
        var plistName = "AppConfiguration"
        if environment == .production
        {
            plistName += "Production"
        }
        else
        {
            plistName += "Development"
        }
        guard let appConfigPlist = Bundle.main.path( forResource : plistName, ofType : "plist" ), let appConfig = NSDictionary( contentsOfFile : appConfigPlist ) as? [String : Any] else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.initializationError ) : \(plistName).plist is not found, Details : -" )
            throw ZCatalystError.sdkError(code: ErrorCode.initializationError, message: "\(plistName).plist is not found.", details: nil)
        }
        let configData = try JSONSerialization.data( withJSONObject: appConfig, options : [] )
        let decoder = JSONDecoder()
        let appConfiguration = try decoder.decode( ZCatalystAppConfiguration.self, from : configData )
        if let packageName = Bundle.main.infoDictionary?[ kCFBundleNameKey as String ] as? String, let appVersion = Bundle.main.infoDictionary?[ "CFBundleShortVersionString" ] as? String
        {
            self.userAgent = "\( packageName )/\( appVersion )(iPhone) ZCiOSSDK"
        }
        ZCatalystApp.shared.appConfig = appConfiguration
        ZCatalystApp.shared.appConfig.environment = environment
        try ZCatalystAuthHandler.initIAMLogin( with : window, config : appConfiguration )
    }
    
    public func getCurrentUser( completion: @escaping ( Result< ZCatalystUser,ZCatalystError > ) -> Void )
    {
        APIHandler().getCurrentUser( completion : completion )
    }
    
    public func signUp(user: ZCatalystUser, completion: @escaping (Result<( ZCatalystUser, Int64 ), ZCatalystError >) -> Void)
    {
        APIHandler().signUp( user : user, completion : completion )
    }
    
    public func handleLoginRedirection( _ url : URL, sourceApplication : String?, annotation : Any )
    {
        ZCatalystAuthHandler.handleRedirectURL( url, sourceApplication : sourceApplication, annotation : annotation )
    }
    
    public func showLogin( completion : @escaping ( Error? ) -> Void )
    {
        if ZCatalystApp.shared.isUserSignedIn()
        {
            return completion( nil )
        }
        if ZCatalystApp.shared.appConfig.isCustomLogin
        {
            ZCatalystLogger.logError(message: "\( ErrorCode.invalidConfiguration ) - \( ErrorMessage.invalidConfigurationForDefaultLogin )")
            return completion( ZCatalystError.inValidError(code: ErrorCode.invalidConfiguration, message: ErrorMessage.invalidConfigurationForDefaultLogin, details: nil) )
        }
        else
        {
            ZCatalystAuthHandler.presentLogin( completion : completion )
        }
    }
    
    public func getOAuthToken(completion: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        if ZCatalystApp.shared.isUserSignedIn() {
            ZCatalystAuthHandler.getOAuthToken { result in
                switch result {
                case .success(let token):
                    completion(token)
                case .error(let error):
                    failure(error)
                }
            }
        }else {
            failure(ZCatalystError.unAuthenticatedError(code: ErrorCode.noPermission, message: ErrorMessage.invalidConfigurationForDefaultLogin, details: nil))
        }
    }
    
    public func handleCustomLogin( withJWT token : String, completion : @escaping ( Error? ) -> Void )
    {
        if ZCatalystApp.shared.isUserSignedIn()
        {
            return completion( nil )
        }
        if !ZCatalystApp.shared.appConfig.isCustomLogin
        {
            ZCatalystLogger.logError(message: "\( ErrorCode.invalidConfiguration ) - \( ErrorMessage.invalidConfigurationForCustomLogin )")
            return completion( ZCatalystError.inValidError(code: ErrorCode.invalidConfiguration, message: ErrorMessage.invalidConfigurationForCustomLogin, details: nil) )
        }
        ZohoPortalAuth.getOAuthToken(forRemoteUser: token, tokenType: ZohoPortalAuthRemoteLoginTypeJWT, baseURL: nil) { accessToken, error in
            if let error = error
            {
                return completion( error )
            }
            if let _ = accessToken
            {
                completion( nil )
            }
        }
    }
    
    public func logout( completion : @escaping ( Error? ) -> Void )
    {
        ZCatalystAuthHandler.logout( completion : completion )
    }
    
    public func isUserSignedIn() -> Bool
    {
        return ZCatalystAuthHandler.isUserSignedIn()
    }
    
    public func getFileStoreInstance() -> ZCatalystFileStore
    {
        return ZCatalystFileStore()
    }
    
    public func getFunctionInstance( id : Int64 ) -> ZCatalystFunction
    {
        return ZCatalystFunction( identifier : String( id ) )
    }
    
    public func getFunctionInstance( name : String ) -> ZCatalystFunction
    {
        return ZCatalystFunction( identifier : name )
    }
    
    public func getDataStoreInstance(tableIdentifier : String) -> ZCatalystDataStore
    {
        return ZCatalystDataStore(tableIdentifier: tableIdentifier)
    }
    public func execute( query : ZCatalystSelectQuery, completion: @escaping (Result<[ [ String : Any ] ], ZCatalystError>) -> Void)
    {
        APIHandler().executeZCQL( query : query.query, completion : completion )
    }
    
    public func newUser( firstName : String, email : String ) -> ZCatalystUser
    {
        let user = ZCatalystUser()
        user.firstName = firstName
        user.email = email
        return user
    }
    
    public func search( searchOptions : ZCatalystSearchOptions, completion : @escaping( Result< [ String : Any ], ZCatalystError > ) -> Void )
    {
        APIHandler().search( searchOptions : searchOptions, completion )
    }
    
    public func getCurrentTimeZone( completion : @escaping ( Result< TimeZone, ZCatalystError > ) -> Void )
    {
        APIHandler().getCurrentTimeZone(completion: completion)
    }
    
    /**
     To resume the URLSession delegate method calls when the app transition from background to foreground
     
     NSURLSession delegate methods won't get invoked in some devices when app resumes from background. We have to resume atleast one task in that URLSession to resume the delgate method calls.
     */
    public func notifyApplicationEnterForeground()
    {
        Router.fileUploadURLSessionWithDelegates.getTasksWithCompletionHandler() { _, uploadTasks, _ in
            uploadTasks.first?.resume()
        }
        Router.fileDownloadURLSessionWithDelegates.getTasksWithCompletionHandler() { _, _, downloadTasks in
            downloadTasks.first?.resume()
        }
    }
    
    public func notifyBackgroundSessionEvent(_ identifier : String, _ completionHandler : @escaping () -> Void)
    {
        ZCatalystApp.sessionCompletionHandlers.updateValue( completionHandler, forKey: identifier)
    }
    
    public static func makeURLRequest(url : URL, requestTimeout : TimeInterval, requestMethod : CatalystRequestMethod, cachePolicy : URLRequest.CachePolicy = .returnCacheDataElseLoad, headers : [ String : String ]?, requestBody : [ String : Any ]?, completion : @escaping( CatalystResult.DataURLResponse< [ String : Any ]?, URLResponse > ) -> () )
    {

        var urlRequest = URLRequest( url : url )
        urlRequest.httpMethod = requestMethod.rawValue
        urlRequest.cachePolicy = cachePolicy
        urlRequest.allHTTPHeaderFields = headers
        if let requestBody = requestBody, !requestBody.isEmpty
        {
            let reqBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
            urlRequest.httpBody = reqBody
        }
        sessionConfiguration.timeoutIntervalForRequest = requestTimeout
        session.dataTask( with : urlRequest) { ( data, response, error ) in
            if let error = error
            {
                completion( .failure( typeCastToZCatalystError( error ) ) )
                return
            }
            if let response = response, let data = data
            {
                if let responseJSON = try? JSONSerialization.jsonObject( with : data, options : [] ) as? [ String : Any ]
                {
                    completion( .success( responseJSON, response ) )
                }
                else
                {
                    completion( .success( nil, response ) )
                }
            }
        }.resume()
    }
    
    public func registerNotification( token : String, appID : String, testDevice : Bool, completion : @escaping ( ZCatalystError? ) -> () )
    {
        guard UserDefaults.standard.value(forKey: Constants.apnsInstallationKey.string) == nil else
        {
            return ZCatalystLogger.logError( message : "Error Occurred : Device already registered for Push notifications" )
        }
        let apiHandler = APIHandler()
        let payload = apiHandler.pushNotificationPayload(token: token, testDevice: testDevice)
        let api = PushNotificationAPI.register(paramets: payload, appID: appID)
        apiHandler.networkClient.request(api, session: URLSession.shared) { (result) in
            apiHandler.handlePushResult(result) { error in
                if error != nil
                {
                    UserDefaults.standard.set(token, forKey: Constants.apnsTokenKey.string)
                }
                completion( error )
            }
        }
    }
    
    public func deregisterNotification( token : String, appID : String, testDevice : Bool, completion : @escaping ( ZCatalystError? ) -> () )
    {
        guard UserDefaults.standard.value(forKey: Constants.apnsInstallationKey.string) != nil else
        {
            ZCatalystLogger.logError( message : "Error Occurred : Device not registered for Push notifications" )
            return completion( ZCatalystError.inValidError(code: ErrorCode.invalidOperation, message: "Device not registered for Push notifications", details: nil) )
        }
        let apiHandler = APIHandler()
        let payload = apiHandler.pushNotificationPayload(token: token,testDevice: testDevice)
        let api = PushNotificationAPI.deregister(parameters: payload, appID: appID)
        apiHandler.networkClient.request(api, session: URLSession.shared) { (result) in
            apiHandler.handlePushResult(result) { error in
                if error == nil
                {
                    UserDefaults.standard.removeObject(forKey: Constants.apnsTokenKey.string)
                    UserDefaults.standard.removeObject(forKey: Constants.apnsInstallationKey.string)
                }
                completion( error )
            }
        }
    }
}
