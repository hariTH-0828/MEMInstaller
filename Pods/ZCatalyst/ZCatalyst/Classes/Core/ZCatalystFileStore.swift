//
//  FileStorage.swift
//  Catalyst
//
//  Created by Giridhar on 20/05/19.
//

public struct ZCatalystFileStore
{
    init()
    {}
    
    public func getFolderInstance( id : Int64 ) -> ZCatalystFolder
    {
        return ZCatalystFolder( id : id )
    }
    
    public func getFolders( completion : @escaping ( Result< [ ZCatalystFolder ], ZCatalystError > ) -> Void )
    {
        APIHandler().getFolders( completion : completion )
    }
    
    public func getFolder( id : Int64, completion : @escaping ( Result< ZCatalystFolder, ZCatalystError > ) -> Void )
    {
        APIHandler().getFolder( folderId : id, completion : completion )
    }
}
