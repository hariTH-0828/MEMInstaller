//
//  ZCatalystFolder.swift
//  Catalyst
//
//  Created by Umashri R on 31/07/20.
//

public final class ZCatalystFolder : ZCatalystEntity
{
    public internal( set ) var id : Int64 = 0
    public internal( set ) var name : String = String()
    public internal( set ) var createdTime : String = String()
    public internal( set ) var createdBy : ZCatalystUserDelegate = ZCatalystUserDelegate()
    public internal( set ) var modifiedTime : String = String()
    public internal( set ) var modifiedBy : ZCatalystUserDelegate = ZCatalystUserDelegate()
    
    init( id : Int64 )
    {
        self.id = id
    }
    
    enum CodingKeys : String, CodingKey
    {
        case id = "id"
        case name = "folder_name"
        case createdTime = "created_time"
        case createdBy = "created_by"
        case modifiedTime = "modified_time"
        case modifiedBy = "modified_by"
        case files = "file_details"
    }
    
    required public init( from decoder : Decoder ) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        self.id = try container.decode( Int64.self, forKey : .id )
        self.name = try container.decode( String.self, forKey : .name )
        self.createdTime = try container.decode( String.self, forKey : .createdTime )
        self.createdBy = try container.decode( ZCatalystUserDelegate.self, forKey : .createdBy )
        self.modifiedTime = try container.decode( String.self, forKey : .modifiedTime )
        self.modifiedBy = try container.decode( ZCatalystUserDelegate.self, forKey : .modifiedBy )
    }
    
    public func getFiles( completion : @escaping ( Result< [ ZCatalystFile ], ZCatalystError > ) -> Void )
    {
        APIHandler().getFiles( folderId : self.id, completion : completion )
    }

    public func getFile( fileId : Int64, completion : @escaping ( Result< ZCatalystFile, ZCatalystError > ) -> Void )
    {
        APIHandler().getFile( folderId : self.id, fileId : fileId, completion : completion )
    }
    
    public func upload( fileRefId : String, filePath : URL, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        APIHandler().upload( fileRefId : fileRefId, filePath : filePath, folder : self.id, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func upload( fileRefId : String, fileName : String, fileData : Data, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        APIHandler().upload( fileRefId : fileRefId, fileName : fileName, fileData : fileData, folder : self.id, fileUploadDelegate : fileUploadDelegate )
    }
    
    public func upload( filePath : URL, completion : @escaping ( Result< ZCatalystFile, ZCatalystError > ) -> Void )
    {
        APIHandler().upload( filePath : filePath, folder : self.id, completion : completion )
    }
    
    public func upload( fileName : String, fileData : Data, completion: @escaping (Result<ZCatalystFile, ZCatalystError>) -> Void )
    {
        APIHandler().upload( fileName : fileName, fileData : fileData, folder : self.id, completion : completion )
    }
    
    public func delete( fileId : Int64, completion: @escaping( ZCatalystError? ) -> Void )
    {
        APIHandler().delete(folderId: self.id, fileId: fileId, completion: completion)
    }
}
