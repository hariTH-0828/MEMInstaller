//
//  Search.swift
//  Catalyst
//
//  Created by Giridhar on 29/05/19.
//

import Foundation

struct ZCatalystSearchResponse : ZCatalystResponse
{
    var output: [String : Any]
    
    init( output : [ String : Any ] )
    {
        self.output = output
    }
}

public struct ZCatalystSearchOptions
{
    public enum SearchPattern{
        case startsWith, endsWith, equals
        
        public func searchString( _ text : String ) -> String{
            switch self{
            case .startsWith :
                return  "*" + text
            case .endsWith :
                return text + "*"
            case .equals :
                return text
            }
        }
    }
    
    public var text : String
    public var searchPattern : SearchPattern = .equals
    public var startIndex : Int?
    public var endIndex : Int?
    public internal( set ) var searchColumns = [ String : [ String ] ]()
    public internal( set ) var displayColumns = [ String : [ String ] ]()
    public internal( set ) var sortColumns = [ String : String ]()
    
    public init( searchText : String, searchColumns : [ TableColumns ] )
    {
        self.text = searchText
        for searchColumn in searchColumns
        {
            self.add( searchColumns : searchColumn )
        }
    }
    
    public mutating func add( searchColumns : TableColumns )
    {
        self.searchColumns.updateValue( searchColumns.columns, forKey : searchColumns.table )
    }
    
    public mutating func add( displayColumns : TableColumns )
    {
        self.displayColumns.updateValue( displayColumns.columns, forKey : displayColumns.table )
    }
    
    public mutating func add( sortColumn : String, in table : String )
    {
        self.sortColumns.updateValue( sortColumn, forKey : table )
    }
    
    func buildAPI() -> SearchAPI
    {
        let api = SearchAPI.search( text : searchPattern.searchString( text ),
                                   searchColoumn : searchColumns,
                                   selectTableColoumn : displayColumns,
                                   order : sortColumns, startIndex : startIndex,
                                   endIndex : endIndex )
        return api
    }
    
    public struct TableColumns
    {
        public let table : String
        public var columns : [ String ] = [ String ]()
        
        public init( tableName : String )
        {
            self.table = tableName
        }
        
        mutating public func add( column : String )
        {
            self.columns.append( column )
        }
    }
}
