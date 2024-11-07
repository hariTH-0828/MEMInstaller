//
//  Database.swift
//  Catalyst
//
//  Created by Giridhar on 29/05/19.
//

import Foundation



/// The Database type allows you to access the Zoho Catalyst Database
public struct ZCatalystDataStore
{
    internal var tableIdentifier : String = String()
    
    init(tableIdentifier : String)
    {
        self.tableIdentifier = tableIdentifier
    }
    init()
    {
    }
    
    static func bulkInsert(rows : [ZCatalystRow]) throws -> Data
    {
        var allData = [ [ String : Any? ] ]()
        for row in rows
        {
            row.upsertJSON.updateValue( row.id, forKey : ZCatalystRow.CodingKeys.id.rawValue )
            allData.append( row.upsertJSON )
        }
        if let data = try? JSONSerialization.data(withJSONObject: allData, options: [])
        {
            return data
        }
        else {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.invalidData ) : \( ErrorMessage.invalidDataMsg ), Details : -" )
            throw ZCatalystError.processingError( code : ErrorCode.invalidData, message : ErrorMessage.invalidDataMsg, details : nil )
            
        }
    }
    
    public func newRow() -> ZCatalystRow
    {
        return ZCatalystRow( tableIdentifier : self.tableIdentifier )
    }
    
    public func getColumns( completion : @escaping ( Result< [ ZCatalystColumn ], ZCatalystError > ) -> Void )
    {
        APIHandler().getColumns( table : self.tableIdentifier, completion : completion )
    }
    
    public func getColumn( id : Int64, completion : @escaping ( Result< ZCatalystColumn, ZCatalystError > ) -> Void )
    {
        APIHandler().getColumn( table : self.tableIdentifier, column : id, completion : completion )
    }
    
    public func create(_ rows: [ ZCatalystRow ], completion: @escaping(Result<[ZCatalystRow], ZCatalystError>) -> Void)
    {
        APIHandler().create( rows, tableId : self.tableIdentifier, completion : completion )
    }
    
    
    public func update(_ rows: [ ZCatalystRow ], completion: @escaping(Result<[ZCatalystRow], ZCatalystError>) -> Void)
    {
        APIHandler().update( rows, tableId : self.tableIdentifier, completion : completion )
    }
    
    
    //MARK: Public Methods to access database
    /// Fetches all rows from a specified table from the catalyst database
    /// - Parameter table: Name of the table from when rows have to be fetched
    /// - Parameter completion: Asyncronously returns the fetched rows or a Database Error
    
    
    public func getRows(nextToken : String?, maxRecord : String?, completion: @escaping (CatalystResult.DataURLResponse<[ZCatalystRow], ResponseInfo>) -> Void)
    {
        APIHandler().fetchRows( table : self.tableIdentifier, maxRecord: maxRecord, nextToken: nextToken, completion : completion )
    }
    
    public func getRow(id : Int64, completion: @escaping (Result<ZCatalystRow, ZCatalystError>) -> Void)
    {
        APIHandler().fetchRow( table : self.tableIdentifier, row : id, completion : completion )
    }
    
    public func deleteRow( id : Int64, completion : @escaping( ZCatalystError? ) -> Void )
    {
        APIHandler().deleteRow( id : id, tableId : self.tableIdentifier, completion : completion )
    }
}
