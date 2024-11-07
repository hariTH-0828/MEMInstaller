//
//  CloudFunction.swift
//  Catalyst
//
//  Created by Giridhar on 20/05/19.
//

import Foundation

protocol ZCatalystResponse
{
    var output: [String: Any] { get }
    
    init(output: [String: Any])
}

struct ZCatalystFunctionResult:ZCatalystResponse
{
    public internal( set ) var output : [ String : Any ]
    init(output: [String: Any])
    {
        self.output = output
    }
}

//TODO: Selecting Runner method, findout what are connectors and type. 
public struct ZCatalystFunction : ZCatalystEntity
{
    public internal( set ) var identifier : String
    
    init( identifier : String )
    {
        self.identifier = identifier
    }
    
    public func executeGet( parameters params : [ String : Any ]? = nil, completion : @escaping( Result< String, ZCatalystError > ) -> Void )
    {
        APIHandler().executeFunction( name : identifier, parameters : params, body : nil, requestMethod : .get, completion : completion )
    }
    
    public func executePost( parameters params : [ String : Any ]? = nil, body : [ String : Any ]? = nil, completion : @escaping( Result< String, ZCatalystError > ) -> Void )
    {
        APIHandler().executeFunction( name : identifier, parameters : params, body : body, requestMethod : .post, completion : completion )
    }
    
    public func executePut( parameters params : [ String : Any ]? = nil, body : [ String : Any ]? = nil, completion : @escaping( Result< String, ZCatalystError > ) -> Void )
    {
        APIHandler().executeFunction( name : identifier, parameters : params, body : body, requestMethod : .put, completion : completion )
    }
    
    public func executePatch( parameters params : [ String : Any ]? = nil, body : [ String : Any ]? = nil, completion: @escaping( Result< String,ZCatalystError > ) -> Void )
    {
        APIHandler().executeFunction( name : identifier, parameters : params, body : body, requestMethod : .patch, completion : completion )
    }
    
    public func executeDelete( parameters params : [ String : Any ]? = nil, completion : @escaping( Result< String, ZCatalystError > ) -> Void )
    {
        APIHandler().executeFunction( name : identifier, parameters : params, body : nil, requestMethod : .delete, completion : completion )
    }
}
