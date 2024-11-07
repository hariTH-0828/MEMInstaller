//
//  Serializer.swift
//  Catalyst
//
//  Created by Giridhar on 23/05/19.
//

import Foundation

struct Serializer
{
    static func parse<T:Codable>(data: Data) -> Result<T,ZCatalystError>
    {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
            
            guard let status = json?[CatalystConstants.status] as? String else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
            }
            if status == CatalystConstants.success
            {
                guard let body = json?[SerializerConstants.data] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                
                let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
                
                guard let jData = jsonData else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                
                //--------------------------Code repeat - Use function below till here
                
                let decoder = JSONDecoder()
                do
                {
                    let object = try decoder.decode(T.self, from: jData)
                    return Result.success(object)
                }
                catch
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                    return .error( typeCastToZCatalystError( error ) )
                }
            }
        }
        catch {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
        
        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
        return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
    }
    
    static func precheckJSON(data: Data) -> Result<Data,ZCatalystError>
    {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
            
            guard let status = json?[CatalystConstants.status] as? String else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
            }
            if status == CatalystConstants.success
            {
                guard let body = json?[SerializerConstants.data] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                
                let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])
                
                guard let jData = jsonData else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                return Result.success(jData)
        
            }
        }
        catch {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
        return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
    }
    
    
    static func precheckJSON(data: Data) -> Result<Any,ZCatalystError>
    {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
            
            guard let status = json?[CatalystConstants.status] as? String else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
            }
            if status == CatalystConstants.success
            {
                guard let body = json?[SerializerConstants.data] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                
            
                return Result.success(body)
            }
            else
            {
                if status == CatalystConstants.failure
                {
                    guard let error = json?[SerializerConstants.data] as? [ String : Any ], let code = error[ SerializerConstants.errorCode ] as? String, let message = error[ SerializerConstants.message ] as? String else
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                        return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                    }
                    
                    ZCatalystLogger.logError( message : "Error Occurred : \( code ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : code, message : message, details : nil ) )
                }
            }
        }
        catch {
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
        return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
    }
    
    static func parse<T:ZCatalystResponse>(data: Data) -> Result<T,ZCatalystError>
    {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
            
            guard let status = json?[CatalystConstants.status] as? String else
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
            }
            if status == CatalystConstants.success
            {
                guard let body = json?[SerializerConstants.data] as? [String: Any] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
            //--------------------------Code repeat - Use function above till here
                
                let response = T.init(output: body)
                
                return Result.success(response)
            }
            else
            {
                if status == CatalystConstants.failure
                {
                    guard let error = json?[SerializerConstants.data] as? [ String : Any ], let code = error[SerializerConstants.errorCode] as? String, let message = error[ SerializerConstants.message ] as? String else {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                        return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                    }
                    
                    ZCatalystLogger.logError( message : "Error Occurred : \( code ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : code, message : message, details : nil ) )
                }
            }
        }
        catch{
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
           return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
    }
}

public struct SerializerConstants
{
    static let data = "data"
    static let message = "message"
    static let errorCode = "error_code"
}
