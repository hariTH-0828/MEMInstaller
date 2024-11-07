//
//  File.swift
//  Catalyst
//
//  Created by Giridhar on 03/06/19.
//

import Foundation

//typealias CatalystData = [String:ZCatalystRecordType]


/// Refers to a Record or a Row in a table in the Catalyst Database.
/// The columns of a row/record can be accessed in a familiar dictionary like format
/**
 let age = row["age"].intValue
 */
/// CLRecord also support's Swift 5's `dymamicMemberLookup` which means you can refer columns like
/**
 let age = row.age.intValue
 */
///
///
/// It is needed to specify the type of value you wish to retrive from the row - this provides typesafety and also optionally provides non-null/crash-free return values in case you want it.

public final class ZCatalystRow : ZCatalystEntity
{
    public var id: Int64 = 0
    /// Refers to the Created time of the particular row
    public var createdTime: String = String()
    /// Refers to the modified time of the particular row
    public var modifiedTime: String = String()
    /// row creator's ID
    public var creatorId: Int64 = 0
    var tableIdentifier : String = String()
    var data : [ String : Any? ] = [ String : Any? ]()
    var upsertJSON : [ String : Any? ] = [ String : Any? ]()
    
    //MARK: Initializers
    init( tableIdentifier : String )
    {
        self.tableIdentifier = tableIdentifier
    }
    
    init()
    {
    }
    
    enum CodingKeys : String, CodingKey, CaseIterable
    {
        case id = "ROWID"
        case createdTime = "CREATEDTIME"
        case modifiedTime = "MODIFIEDTIME"
        case creatorId = "CREATORID"
    }
    
    public init( from decoder : Decoder ) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        if let idStr = try? container.decodeIfPresent( String.self, forKey : .id ), let id = Int64( idStr )
        {
            self.id = id
        }
        else
        {
            self.id = try container.decode( Int64.self, forKey : .id )
        }
        self.createdTime = try container.decode( String.self, forKey : .createdTime )
        self.modifiedTime = try container.decode( String.self, forKey : .modifiedTime )
        if let id = Int64( try container.decode( String.self, forKey : .creatorId ) )
        {
            self.creatorId = id
        }
    }
    
    public func setColumnValue( columnName : String, value : Any? )
    {
        self.upsertJSON.updateValue( value, forKey : columnName )
    }
    
    public func getData() -> [ String : Any? ]
    {
        var data : [ String : Any? ] = [ String : Any? ]()
        data = self.data
        for ( key, value ) in self.upsertJSON
        {
            data.updateValue( value, forKey : key )
        }
        return data
    }

    public func create(completion: @escaping(Result<ZCatalystRow, ZCatalystError>) -> Void)
    {
        APIHandler().createRow( self, tableId : self.tableIdentifier, completion : completion )
    }
    
    public func update( completion: @escaping(Result<ZCatalystRow, ZCatalystError>) -> Void)
    {
        APIHandler().updateRow( self, tableId : tableIdentifier, completion : completion )
    }
    
    /// Deletes a particular record from Catalyst Database
    /// - Parameter record: The record that has to be deleted.
    /// - Parameter completion: Returns a the record that was delete or a database error depending on whether the operation was successful
    public func delete(completion: @escaping( ZCatalystError? ) -> Void)
    {
        APIHandler().deleteRow( id : self.id, tableId : self.tableIdentifier, completion : completion )
    }
}

extension ZCatalystRow
{
    var payloadData: Data? {
        
        if id != 0
        {
            upsertJSON[ CodingKeys.id.rawValue ] = id
        }
        guard let data = try? JSONSerialization.data(withJSONObject: [upsertJSON], options: []) else {return nil}
        return data
    }
}

//MARK: Subscript Accessors
extension ZCatalystRow
{
    // let number : Int? = row.getValue(forKey: "hello")
    public func getValue<T:ZCatalystDataType>(forKey key: String) -> T?
    {
        return data[key] as? T
    }
    
    
    // let number : Int = try row.getValue(forKey: "hello")
    public func getValue(forKey key: String) throws -> ZCatalystDataType
    {
        let d = data[key]
        
        guard let dd = d as? ZCatalystDataType else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.typeCastError ) : Cannot typecast to the experted type, Details : -" )
            throw ZCatalystError.processingError( code : ErrorCode.typeCastError, message : "Cannot typecast to the experted type", details : nil )
        }
        
        return dd
    }
    
    // let number : Int? = row[ "hello" ]
    public subscript<T:ZCatalystDataType>(key: String) -> T?
    {
        get {
            return getValue(forKey: key)
        }
        
        set {
            data[key] = newValue
        }
    }
}

public struct ResponseInfo : ZCatalystEntity
{
   public internal(set) var hasMoreRecords : Bool = false
   public internal(set) var nextPageToken : String?
    
}
