//
//  ZCColumn.swift
//  Catalyst
//
//  Created by Umashri R on 14/07/20.
//
import Foundation

public struct ZCatalystColumn : ZCatalystEntity
{
    public internal( set ) var id : Int64 = 0
    public internal( set ) var name : String = String()
    public internal( set ) var dataType : DataType = .varchar
    public internal( set ) var isMandatory : Bool = false
    public internal( set ) var isUnique : Bool = false
    public internal( set ) var isSearchIndexEnabled : Bool = false
    public internal( set ) var defaultValue : String?
    public internal( set ) var maxLength : Int?
    public internal( set ) var decimalDigits : Int?
    public internal( set ) var parentTableName : Int64?
    public internal( set ) var sequence : Int = 0
    public internal( set ) var category : Int = 0
    public internal( set ) var constraintType : String?
    
    init()
    {}
    
    enum CodingKeys : String, CodingKey
    {
        case id = "column_id"
        case name = "column_name"
        case isMandatory = "is_mandatory"
        case isUnique = "is_unique"
        case isSearchIndexEnabled = "search_index_enabled"
        case defaultValue = "default_value"
        case dataType = "data_type"
        case maxLength = "max_length"
        case decimalDigits = "decimal_digits"
        case parentTable = "parent_table"
        case constraintType = "constraint_type"
        case category = "category"
        case sequence = "column_sequence"
    }
    
    public init( from decoder : Decoder ) throws
    {
        let container = try decoder.container( keyedBy : CodingKeys.self )
        self.id = try container.decode( Int64.self, forKey : .id )
        self.name = try container.decode( String.self, forKey : .name )
        guard let dataType = DataType( rawValue : try container.decode( String.self, forKey : .dataType ) ) else
        {
            throw ZCatalystError.processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil )
        }
        self.dataType = dataType
        self.isMandatory = try container.decode( Bool.self, forKey : .isMandatory )
        self.isUnique = try container.decode( Bool.self, forKey : .isUnique )
        self.isSearchIndexEnabled = try container.decode( Bool.self, forKey : .isSearchIndexEnabled )
        self.defaultValue = try container.decodeIfPresent( String.self, forKey : .defaultValue )
        self.maxLength = try container.decodeIfPresent( Int.self, forKey : .maxLength )
        self.sequence = try container.decode( Int.self, forKey : .sequence )
        self.category = try container.decode( Int.self, forKey : .category )
        self.decimalDigits = try container.decodeIfPresent( Int.self, forKey : .decimalDigits )
        self.parentTableName = try container.decodeIfPresent( Int64.self, forKey : .parentTable )
        self.constraintType = try container.decodeIfPresent( String.self, forKey : .constraintType )
    }
    
    public enum DataType : String
    {
        case text
        case varchar
        case date
        case datetime
        case int
        case double
        case boolean
        case bigint
        case foreignKey = "foreign key"
    }
}
