//
//  ZCatalystSelectQuery.swift
//  Catalyst
//
//  Created by Umashri R on 29/09/20.
//

import Foundation

public struct Column
{
    var name : String?
    var function : Function?
    var names : Set< String >?
    
    init( name : String )
    {
        self.name = name
    }
    
    init( function : Function, name : String )
    {
        self.function = function
        self.name = name
    }
    
    init( function : Function, names : Set< String > )
    {
        self.function = function
        self.names = names
    }
}

extension Column : Hashable
{
    
}

public struct ZCatalystSelectQuery
{
    var query : String
    
    init( builder : Builder )
    {
        self.query = builder.query
    }
    
    public struct Builder
    {
        var query : String = String()
        
        public init()
        {}
        
        public mutating func select( columns : Set< Column > ) -> Builder
        {
            self.query += "SELECT \( getColumnsAsString( columns : columns ) ) "
            return self
        }
        
        public mutating func selectAll() -> Builder
        {
            self.query += "SELECT * "
            return self
        }
        
        public mutating func from( tableName : String ) -> Builder
        {
            self.query += "FROM \( tableName ) "
            return self
        }
        
        public mutating func alias( tableName : String ) -> Builder
        {
            self.query += "AS \( tableName ) "
            return self
        }
        
        public mutating func `where`( column : String, comparator : Comparator, value : String ) -> Builder
        {
            self.query += "WHERE \( column ) \( comparator ) \( value ) "
            return self
        }
        
        public mutating func and( column : String, comparator : Comparator, value : String ) -> Builder
        {
            self.query += "AND \( column ) \( comparator ) \( value ) "
            return self
        }
        
        public mutating func or( column : String, comparator : Comparator, value : String ) -> Builder
        {
            self.query += "OR \( column ) \( comparator ) \( value ) "
            return self
        }
        
        public mutating func groupBy( columns : Set< Column > ) -> Builder
        {
            self.query += "GROUP BY \( getColumnsAsString( columns : columns ) ) "
            return self
        }
        
        public mutating func orderBy( columns : Set< Column >, sortOrder : SortOrder ) -> Builder
        {
            self.query += "ORDER BY \( getColumnsAsString( columns : columns ) ) \( sortOrder ) "
            return self
        }
        
        public mutating func innerJoin( tableName : String ) -> Builder
        {
            self.query += "INNER JOIN \( tableName ) "
            return self
        }
        
        public mutating func leftJoin( tableName : String ) -> Builder
        {
            self.query += "LEFT JOIN \( tableName ) "
            return self
        }
        
        public mutating func on( joinColumn1 : String, comparator : Comparator, joinColumn2 : String ) -> Builder
        {
            self.query += "ON \( joinColumn1 ) \( comparator ) \( joinColumn2 ) "
            return self
        }
        
        public mutating func limit( offset : Int, value : Int? = nil ) -> Builder
        {
            self.query += "LIMIT \( offset ) "
            if let value = value
            {
                self.query += " ,\( value ) "
            }
            return self
        }
        
        public func build() -> ZCatalystSelectQuery
        {
            return ZCatalystSelectQuery( builder : self )
        }
        
        private func getColumnsAsString( columns : Set< Column > ) -> String
        {
            var columnsAsString = String()
            var count = 0
            for column in columns
            {
                if let function = column.function
                {
                    if let names = column.names
                    {
                        let namesStr = names.joined( separator : ", " )
                        columnsAsString += "\( function ) \( namesStr )"
                    }
                    if let name = column.name
                    {
                        columnsAsString += "\( function ) \( name )"
                    }
                }
                else
                {
                    if let name = column.name
                    {
                        columnsAsString += "\( name )"
                    }
                }
                if count < columns.count
                {
                    columnsAsString += ", "
                }
                count += 1
            }
            return columnsAsString
        }
    }
}
