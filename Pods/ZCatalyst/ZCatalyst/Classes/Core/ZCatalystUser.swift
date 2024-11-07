//
//  User.swift
//  Catalyst
//
//  Created by Umashri R on 21/07/20.
//

public class ZCatalystUser : ZCatalystUserDelegate
{
    public internal( set ) var zaaId : Int64 = 0
    public internal( set ) var status : String = String()
    public internal( set ) var createdTime : String = String()
    public internal( set ) var modifiedTime : String = String()
    public internal( set ) var invitedTime : String = String()
    public internal( set ) var role : ZCatalystUserRole = ZCatalystUserRole()
    
    override internal init() {
        super.init()
    }
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        guard let zaaId = try? Int64( container.decode( String.self, forKey : .zaaId ) ) ?? container.decodeIfPresent( Int64.self, forKey: .zaaId ) else
        {
            ZCatalystLogger.logError(message: "Failed to get zaaid from the JSON")
            throw ZCatalystError.processingError(code: ErrorCode.insufficientData, message: "Failed to get zaaid from the JSON", details: nil)
        }
        self.zaaId = zaaId
        self.status = try container.decode( String.self, forKey : .status )
        self.createdTime = try container.decode( String.self, forKey : .createdTime )
        self.modifiedTime = try container.decode( String.self, forKey : .modifiedTime )
        self.invitedTime = try container.decode( String.self, forKey : .invitedTime )
        self.role = try container.decode( ZCatalystUserRole.self, forKey : .role )
        try super.init( from : decoder )
    }
    
    var payload: Parameters{
        let userdict = [ZCatalystUserConstants.lastName:self.lastName ?? "",
                        ZCatalystUserConstants.emailId:self.email, ZCatalystUserConstants.firstName:self.firstName]
        
        return [ZCatalystUserConstants.platformType:ZCatalystUserConstants.ios,
                ZCatalystUserConstants.redirectURL: ZCatalystApp.shared.appConfig.redirectURLScheme,
                ZCatalystUserConstants.zaid:ZCatalystApp.shared.appConfig.portalId,
                ZCatalystUserConstants.userDetails:userdict]
    }
    
    enum CodingKeys : String, CodingKey
    {
        case zaaId = "zaaid"
        case status = "status"
        case createdTime = "created_time"
        case modifiedTime = "modified_time"
        case invitedTime = "invited_time"
        case role = "role_details"
    }
}

public struct ZCatalystUserRole : Decodable
{
    public internal( set ) var id : Int64 = 0
    public internal( set ) var name : String = String()
    
    public enum CodingKeys : String, CodingKey
    {
        case id = "role_id"
        case name = "role_name"
    }
    
    internal init() {}
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        guard let roleId = try Int64( container.decode( String.self, forKey : .id ) ) else
        {
            ZCatalystLogger.logError(message: "Failed to get role id from the JSON")
            throw ZCatalystError.processingError(code: ErrorCode.insufficientData, message: "Failed to get role id from the JSON", details: nil)
        }
        self.id = roleId
        self.name = try container.decode( String.self, forKey : .name )
    }
}

public struct ZCatalystUserConstants
{
    static let lastName = "last_name"
    static let emailId = "email_id"
    static let firstName = "first_name"
    static let platformType = "platform_type"
    static let redirectURL = "redirect_url"
    static let zaid = "zaid"
    static let userDetails = "user_details"
    static let ios = "ios"
}
