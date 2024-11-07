//
//  Common.swift
//  Catalyst
//
//  Created by Giridhar on 17/05/19.
//

import Foundation


class DateFormat
{
    static let `default` = DateFormat()
    private let dFormatter: DateFormatter
    private init()
    {
        self.dFormatter = DateFormatter()
        self.dFormatter.dateFormat = "yyyy-mm-dd hh:mm:ss:"
    }
    
    func date(string: String) -> Date
    {
        return self.dFormatter.date(from: string) ?? Date()
    }
    
}

public enum Function
{
    case min
    case max
    case count
    case sum
    case avg
    case distinct
}

public enum Comparator : String
{
    case equalTo = "="
    case `is` = "IS"
    case isNull = "IS NULL"
    case isNot = "IS NOT"
    case isNotNull = "IS NOT NULL"
    case notEqualTo = "NOT EQUAL TO"
    case like = "LIKE"
    case notLike = "NOT LIKE"
    case `in` = "IN"
    case notIn = "NOT IN"
    case greaterThan = ">"
    case greaterThanOrEqualTo = ">="
    case lessThan = "<"
    case lessThanOrEqualTo = "<="
}

public enum SortOrder
{
    case asc
    case desc
}

public enum LogLevels : Int
{
    case notice = 0
    case info = 1
    case debug = 2
    case error = 3
    case fault = 4
    
    init?( logLevel : String )
    {
        switch logLevel
        {
        case "default" :
            self.init( rawValue : 0 )
        case "info" :
            self.init( rawValue : 1 )
        case "debug" :
            self.init( rawValue : 2 )
        case "error" :
            self.init( rawValue : 3 )
        case "fault" :
            self.init( rawValue : 4 )
        default :
            self.init( rawValue : 3 )
        }
    }
}

public enum ZCatalystError : Error
{
    case unAuthenticatedError( code : String, message : String, details : Dictionary< String, Any >? )
    case inValidError( code : String, message : String, details : Dictionary< String, Any >? )
    case processingError( code : String, message : String, details : Dictionary< String, Any >? )
    case sdkError( code : String, message : String, details : Dictionary< String, Any >? )
    case networkError( code : String, message : String, details : Dictionary< String, Any >? )
}

public struct ErrorCode
{
    public static var invalidData = "INVALID_DATA"
    public static var internalError = "INTERNAL_ERROR"
    public static var responseNil = "RESPONSE_NIL"
    public static var valueNil = "VALUE_NIL"
    public static var oauthTokenNil = "OAUTHTOKEN_NIL"
    public static var oauthFetchError = "OAUTH_FETCH_ERROR"
    public static var unableToConstructURL = "UNABLE_TO_CONSTRUCT_URL"
    public static var invalidFileType = "INVALID_FILE_TYPE"
    public static var processingError = "PROCESSING_ERROR"
    public static var invalidOperation = "INVALID_OPERATION"
    public static var notSupported = "NOT_SUPPORTED"
    public static var noPermission = "NO_PERMISSION"
    public static var typeCastError = "TYPECAST_ERROR"
    public static var noInternetConnection = "NO_INTERNET_CONNECTION"
    public static var requestTimeOut = "REQUEST_TIMEOUT"
    public static var insufficientData = "INSUFFICIENT_DATA"
    public static var networkConnectionLost = "NETWORK_CONNECTION_LOST"
    public static let unhandled = "UNHANDLED"
    public static let initializationError = "INITIALIZATION_ERROR"
    public static let functionExecutionError = "FUNCTION_EXECUTION_ERROR"
    public static let jsonException = "JSON_EXCEPTION"
    public static let customLoginDisabled = "CUSTOM_LOGIN_DISABLED"
    public static let invalidConfiguration = "INVALID_CONFIGURATION"
}

public struct ErrorMessage
{
    public static let invalidDataMsg  = "The given data seems to be invalid."
    public static let provideValidData = "Please provide valid data for"
    public static let fileSizeExceeded = "File size is more than the allowed size of"
    public static let fileUnavailable = "File seems to be unavailable."
    public static let responseParseError = "Error while parsing response."
    public static let initializationError = "Zoho Catalyst SDK must be initialized for this operation."
    public static let noInternetConnectionMsg = "The Internet connection appears to be offline."
    public static let oauthTokenNilMsg = "The oauth token is nil."
    public static let oauthFetchErrorMsg = "There was an error in fetching oauth Token."
    public static let unableToConstructURLMsg = "There was a problem constructing the URL."
    public static let customLoginDisabled = "The parameters required for Custom Login could not be found, make sure you have enabled Custom Login for the project and re-download the property file."
    public static let invalidConfigurationForDefaultLogin = "The SDK has not been initialized with the configuration required for the default login. Reinitialize the SDK with the appropriate configuration for the default login."
    public static let invalidConfigurationForCustomLogin = "The SDK has not been initialized with the configuration required for the custom login. Reinitialize the SDK with the appropriate configuration for the custom login."
}

public enum CatalystRequestMethod : String
{
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

public struct CatalystConstants
{
    static let failure = "failure"
    static let success = "success"
    static let status = "status"
    static let NotAvailable = "NA"
}

public extension Error
{
    var code : Int
    {
        return ( self as NSError ).code
    }

    var description : String
    {
        return ( self as NSError ).description
    }

    var ZCatalystErrordetails : ( code : String, description : String, details : Dictionary< String, Any>? )?
    {
        guard let error = self as? ZCatalystError else {
            return nil
        }
        switch error
        {
            case .unAuthenticatedError( let code, let desc, let details ):
                return ( code, desc, details )
            case .inValidError( let code, let desc, let details ):
                return ( code, desc, details )
            case .processingError( let code, let desc, let details ):
                return ( code, desc, details )
            case .sdkError( let code, let desc, let details ):
                return ( code, desc, details )
            case .networkError( let code, let desc, let details ):
                return ( code, desc, details )
        }
    }
}

func typeCastToZCatalystError( _ error : Error ) -> ZCatalystError {
    if let typecastedError = error as? ZCatalystError
    {
        return typecastedError
    }
    else
    {
        if error.code == NSURLErrorNotConnectedToInternet
        {
            return ZCatalystError.networkError( code : ErrorCode.noInternetConnection, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorTimedOut
        {
            return ZCatalystError.networkError( code : ErrorCode.requestTimeOut, message : error.localizedDescription, details : nil )
        }
        else if error.code == NSURLErrorNetworkConnectionLost
        {
            return ZCatalystError.networkError( code : ErrorCode.networkConnectionLost, message : error.localizedDescription, details : nil )
        }
        return ZCatalystError.sdkError( code : ErrorCode.internalError, message : error.description, details : nil )
    }
}

extension URLRequest
{
    func toString() -> String
    {
        if let headers = self.allHTTPHeaderFields, headers[ "Authorization" ] != nil
        {
            var headers = headers
            headers[ "Authorization" ] = "## ***** ##"
            return "\( self.url?.absoluteString ?? "nil" ) \n HEADERS : \( headers.description )"
        }
        return "\( self.url?.absoluteString ?? "nil" ) \n HEADERS : \( self.allHTTPHeaderFields?.description )"
    }
}

extension String
{
    func lastPathComponent( withExtension : Bool = true ) -> String
    {
        let lpc = self.nsString.lastPathComponent
        return withExtension ? lpc : lpc.nsString.deletingPathExtension
    }
    
    var nsString : NSString
    {
        return NSString( string : self )
    }
}

protocol Parsable
{
    static func parse( data : Data ) -> Result< Self, ZCatalystError >
//    init(data: Data) throws
// static func parse(data: Data) -> Self   static func parse(data: Data) -> Self
}

protocol SelfParsable {
    
}

class OAuth: OAuthCompatible
{
    func getOAuthToken(success: @escaping ZSSOKitCompletionSuccessBlock, failure: @escaping ZSSOKitCompletionErrorBlock) {
        ZohoPortalAuth.getOauth2Token { (token, error) in

            guard let aToken = token else {
                failure(NSError.init(domain: "Generic error", code: 100, userInfo: nil))
                return
            }

            if error != nil {
                failure(NSError.init(domain: "Generic error", code: 100, userInfo: nil))
                return
            }

            success(aToken)

        }
    }
    
    func isUserLoggedin() -> (Bool) {
        return ZohoPortalAuth.isUserSignedIn()
    }
    
    func initializeSSOForActionExtension() {
        return
    }
}
