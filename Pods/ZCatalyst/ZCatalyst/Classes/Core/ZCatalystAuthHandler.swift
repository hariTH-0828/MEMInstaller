//
//  AuthHandler.swift
//  Catalyst
//
//  Created by Giridhar on 16/05/19.
//

import Foundation
import UIKit

struct ZCatalystAuthHandler
{
//    var app: CatalystApp
    
//    #if TARGET_OS_IOS
// ZohoPortalAuth seems to be a singleton -> This means only one instance will be present at any point which inturn means that if we support multi app support, ZohoPortalAuth should seperately handle both auth and return their respective objects instead of having it in a singleton class function.
    
    static func initIAMLogin( with window : UIWindow, config : ZCatalystAppConfiguration ) throws
    {
        if ZCatalystApp.shared.appConfig.isCustomLogin
        {
            guard config.jwtClientId != CatalystConstants.NotAvailable && config.jwtClientSecret != CatalystConstants.NotAvailable else
            {
                ZCatalystLogger.logError(message: "\( ErrorCode.customLoginDisabled ) - \( ErrorMessage.customLoginDisabled )")
                throw ZCatalystError.inValidError(code: ErrorCode.customLoginDisabled, message: ErrorMessage.customLoginDisabled, details: nil)
            }
            guard !config.jwtClientId.isEmpty && !config.jwtClientSecret.isEmpty else
            {
                ZCatalystLogger.logError(message: "\( ErrorCode.invalidOperation ) - JWTClient Id and JWTClient Secret must not be empty for custom login ")
                throw ZCatalystError.inValidError(code: ErrorCode.invalidOperation, message: "JWTClient Id and JWTClient Secret must not be empty for custom login", details: nil)
            }
            ZohoPortalAuth.initWithClientID( config.jwtClientId, clientSecret: config.jwtClientSecret, portalID: config.portalId, scope: config.oAuthScopes, urlScheme: config.redirectURLScheme, mainWindow: window, accountsPortalURL: config.accountsURL )
        }
        else
        {
            guard !config.clientId.isEmpty && !config.clientSecret.isEmpty else
            {
                ZCatalystLogger.logError(message: "\( ErrorCode.invalidOperation ) - Client Id and Client Secret must not be empty for default login ")
                throw ZCatalystError.inValidError(code: ErrorCode.invalidOperation, message: "Client Id and Client Secret must not be empty for default login", details: nil)
            }
            ZohoPortalAuth.initWithClientID(config.clientId, clientSecret: config.clientSecret, portalID: config.portalId, scope: config.oAuthScopes, urlScheme: config.redirectURLScheme, mainWindow: window, accountsPortalURL: config.accountsURL)
        }
    }

    static func handleRedirectURL(_ url: URL, sourceApplication: String?, annotation: Any)
    {
        ZohoPortalAuth.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    static func presentLogin(completion: @escaping ( Error? ) -> Void)
    {
        ZohoPortalAuth.presentZohoPortalSign { ( success, error ) in
            if let error = error
            {
                switch( error.code )
                {
                // SFSafari Dismissed
                case 205 :
                    ZCatalystLogger.logError( message : "Error Occurred : \( error.description ), code : \( error.code )" )
                    completion( error )
                    break

                // access_denied
                case 905 :
                    ZCatalystLogger.logError( message : "Error Occurred : \( error.description ), code : \( error.code )" )
                    completion( error )
                    break

                default :
                    completion( error )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            }
            else
            {
                completion( nil )
            }
        }
    }
    
    static func getOAuthToken( completion : @escaping( Result< String, Error > ) -> () )
    {
        ZohoPortalAuth.getOauth2Token { ( token, error ) in
            if let error = error
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                completion( .error( error ) )
            }
            if let token = token
            {
                completion( .success( token ) )
            }
        }
    }
    
    static func isUserSignedIn() -> Bool
    {
        return ZohoPortalAuth.isUserSignedIn()
    }
    
    static func logout(completion: @escaping ( Error? ) -> Void)
    {
        ZohoPortalAuth.revokeAccessToken(
            { ( error ) in
                if let error = error
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                    completion( error )
                }
                else
                {
                    ZCatalystApp.shared.appConfig.requestHeaders?.removeAll()
                    URLCache.shared.removeAllCachedResponses()
                    if let cookies = HTTPCookieStorage.shared.cookies {
                        for cookie in cookies {
                            HTTPCookieStorage.shared.deleteCookie(cookie)
                        }
                    }
                    completion( nil )
                    ZCatalystLogger.logInfo( message : "Logout Successful" )
                }
        })
    }
}
