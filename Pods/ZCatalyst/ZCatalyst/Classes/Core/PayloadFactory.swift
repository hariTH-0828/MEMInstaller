//
//  PayloadFactory.swift
//  Catalyst
//
//  Created by Giridhar on 23/05/19.
//

import Foundation


struct PayloadFactory
{ 
    static func generateSearch(api: SearchAPI) -> Payload
    {
        switch api
        {
        case .search(let text, let coloumn, let select,let order, let start, let end):
            print("")
            var bodyJSON : [ String : Any ] = [ PayloadConstants.search :text,
                                                PayloadConstants.searchTableColumns : coloumn,
                                                PayloadConstants.start : start,
                                                PayloadConstants.end : end ]
            if let s = select
            {
                bodyJSON[PayloadConstants.selectTableColumns] = s
            }
            if let o = order
            {
                bodyJSON[PayloadConstants.orderBy] = o
            }
            
            return Payload(bodyParameters: bodyJSON, urlParameters: nil, headers: nil, bodyData: nil)
        }
    }
}

public struct PayloadConstants
{
    static let orderBy = "order_by"
    static let selectTableColumns = "select_table_columns"
    static let search = "search"
    static let searchTableColumns = "search_table_columns"
    static let start = "start"
    static let end = "end"
}
