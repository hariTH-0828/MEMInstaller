//
//  FileManager.swift
//  Catalyst
//
//  Created by Giridhar on 21/06/19.
//

public struct ZCatalystFile : ZCatalystEntity
{
    public internal( set ) var id : Int64 = 0
    public internal( set ) var name : String = String()
    internal var folderId : Int64 = 0
    public internal( set ) var size : Int64 = 0
    public internal( set ) var createdTime : String = String()
    public internal( set ) var createdBy : ZCatalystUserDelegate = ZCatalystUserDelegate()
    public internal( set ) var modifiedTime : String = String()
    public internal( set ) var modifiedBy : ZCatalystUserDelegate = ZCatalystUserDelegate()
    
    init()
    {
    }
    
    enum CodingKeys : String, CodingKey
    {
        case id = "id"
        case folderId = "folder_details"
        case name = "file_name"
        case size = "file_size"
        case createdTime = "created_time"
        case createdBy = "created_by"
        case modifiedTime = "modified_time"
        case modifiedBy = "modified_by"
    }
    
    public init( from decoder : Decoder ) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        self.id = try container.decode( Int64.self, forKey : .id )
        self.folderId = try container.decode( Int64.self, forKey : .folderId)
        self.name = try container.decode( String.self, forKey : .name )
        self.size = try container.decode( Int64.self, forKey : .size )
        self.createdTime = try container.decode( String.self, forKey : .createdTime )
        self.createdBy = try container.decode( ZCatalystUserDelegate.self, forKey : .createdBy )
        self.modifiedTime = try container.decode( String.self, forKey : .modifiedTime )
        self.modifiedBy = try container.decode( ZCatalystUserDelegate.self, forKey : .modifiedBy )
    }
    
    public func download( fileDownloadDelegate : ZCatalystFileDownloadDelegate )
    {
        APIHandler().download( file : self.id, in : self.folderId, fileRefId : String( self.id ), fileDownloadDelegate : fileDownloadDelegate )
    }
    
    public func download( completion : @escaping ( Result< ( Data, URL ), ZCatalystError > ) -> Void )
    {
        APIHandler().download( file : self.id, in : self.folderId, completion : completion )
    }
}
