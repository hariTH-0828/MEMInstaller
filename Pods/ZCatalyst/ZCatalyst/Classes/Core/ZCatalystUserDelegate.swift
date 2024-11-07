//
//  UserDelegate.swift
//  Catalyst
//
//  Created by Umashri R on 21/07/20.
//

public class ZCatalystUserDelegate : ZCatalystEntity
{
    public internal( set ) var id : Int64 = 0
    public var email : String = String()
    public var firstName : String = String()
    public var lastName : String?
    public internal( set ) var zuId : Int64 = 0
    public internal( set ) var isConfirmed : Bool = false
    
    init() {
    }
    
    public required init( from decoder : Decoder ) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        if let userId = try? container.decodeIfPresent( Int64.self, forKey: .id )
        {
            self.id = userId
        }
        else if let userId = try Int64( container.decode( String.self, forKey : .id ) )
        {
            self.id = userId
        }
        else
        {
            ZCatalystLogger.logError(message: "Failed to get user id from the JSON")
            throw ZCatalystError.processingError(code: ErrorCode.insufficientData, message: "Failed to get user id from the JSON", details: nil)
        }
        self.email = try container.decode( String.self, forKey : .email )
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent( String.self, forKey : .lastName )
        if let zuId = try? container.decodeIfPresent( Int64.self, forKey: .zuId)
        {
            self.zuId = zuId
        }
        else if let zuId = try Int64( container.decode( String.self, forKey : .zuId ) )
        {
            self.zuId = zuId
        }
        else
        {
            ZCatalystLogger.logError(message: "Failed to get zuid from the JSON")
            throw ZCatalystError.processingError(code: ErrorCode.insufficientData, message: "Failed to get zuid from the JSON", details: nil)
        }
        self.isConfirmed = try container.decode( Bool.self, forKey : .isConfirmed )
    }
    
    enum CodingKeys : String, CodingKey
    {
        case id = "user_id"
        case email = "email_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case zuId = "zuid"
        case isConfirmed = "is_confirmed"
    }
}
