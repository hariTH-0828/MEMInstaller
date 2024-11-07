//
//  APIHandler.swift
//  Catalyst
//
//  Created by Umashri R on 13/08/20.
//

import Foundation

protocol ZCatalystEntity : Decodable
{
    
}

struct APIHandler
{
    var networkClient: NetworkRequestable = Parker()
    
    func download( file fileId : Int64, in folderId : Int64, fileRefId : String, fileDownloadDelegate : ZCatalystFileDownloadDelegate )
    {
        let api = FileStorageAPI.downloadFile( folderId : String( folderId ), fileId : String( fileId ) )
        networkClient.download( url : api, fileRefId : fileRefId, fileDownloadDelegate : fileDownloadDelegate )
    }
    
    func download( file fileId : Int64, in folderId : Int64, completion : @escaping (Result< ( Data, URL ),ZCatalystError>) -> Void )
    {
        let api = FileStorageAPI.downloadFile( folderId : String( folderId ), fileId : String( fileId ) )
        networkClient.download( url : api) { ( result ) in
            switch result
            {
            case .success( let url ) :
                do
                {
                    let data = try Data( contentsOf : url )
                    completion( .success( ( data, url ) ) )
                }
                catch{
                    completion( .error( typeCastToZCatalystError( error ) ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ) :
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getFolders( completion : @escaping ( Result< [ ZCatalystFolder ], ZCatalystError > ) -> Void )
    {
        let api = FolderAPI.fetchAll
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystFolder ], ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getFolder( folderId : Int64, completion : @escaping ( Result< ZCatalystFolder, ZCatalystError > ) -> Void )
    {
        let api = FolderAPI.fetch( folder : String( folderId ) )
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystFolder, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getFiles( folderId : Int64, completion : @escaping ( Result< [ ZCatalystFile ], ZCatalystError > ) -> Void )
    {
        let api = FileStorageAPI.fetchAll( folderId : folderId )
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystFile ], ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getFile( folderId : Int64, fileId : Int64, completion : @escaping ( Result< ZCatalystFile, ZCatalystError > ) -> Void )
    {
        let api = FileStorageAPI.fetch( folderId : String( folderId ), fileId : String( fileId ) )
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystFile, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func upload( filePath : URL, folder : Int64, completion: @escaping (Result<ZCatalystFile, ZCatalystError>) -> Void )
    {
        let api = FileStorageAPI.uploadFile(folderId: String("\(folder)"))
        networkClient.upload( filePath : filePath, fileName : nil, fileData : nil, url : api) { (result) in
            switch result
            {
            case .success(let data):
                let jsonResult : Result< ZCatalystFile, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error(let routerError):
                completion( .error( typeCastToZCatalystError( routerError ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( routerError )" )
            }
        }
    }
    
    func upload( fileName : String, fileData : Data, folder : Int64, completion: @escaping (Result<ZCatalystFile, ZCatalystError>) -> Void )
    {
        let api = FileStorageAPI.uploadFile(folderId: String("\(folder)"))
        networkClient.upload( filePath : nil, fileName : fileName, fileData : fileData, url : api) { (result) in
            switch result
            {
            case .success(let data):
                let jsonResult : Result< ZCatalystFile, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error(let routerError):
                completion( .error( typeCastToZCatalystError( routerError ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( routerError )" )
            }
        }
    }
    
    func upload( fileRefId : String, filePath : URL, folder : Int64, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        let api = FileStorageAPI.uploadFile(folderId: String("\(folder)"))
        networkClient.upload( fileRefId : fileRefId, filePath : filePath, fileName : nil, fileData : nil, url : api, fileUploadDelegate : fileUploadDelegate)
    }
    
    func upload( fileRefId : String, fileName : String, fileData : Data, folder : Int64, fileUploadDelegate : ZCatalystFileUploadDelegate )
    {
        let api = FileStorageAPI.uploadFile(folderId: String("\(folder)"))
        networkClient.upload( fileRefId : fileRefId, filePath : nil, fileName : fileName, fileData : fileData, url : api, fileUploadDelegate : fileUploadDelegate )
    }
    
    func delete( folderId: Int64, fileId: Int64, completion: @escaping( ZCatalystError? ) -> Void )
    {
        let api = FileStorageAPI.deleteFile(folderId: String(folderId) , fileId: String(fileId))
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystFile, ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( _ ) :
                    completion( nil )
                case .error( let error ) :
                    completion( error )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( typeCastToZCatalystError( error ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func executeFunction( name : String, parameters params : [ String : Any ]?, body : [ String : Any ]?, requestMethod : HTTPMethod, completion : @escaping( Result< String, ZCatalystError > ) -> Void )
    {
        let api = FunctionsAPI.execute( id : name, requestMethod : requestMethod, parameters : params, body : body )
        networkClient.request(api, session: URLSession.shared) { (result) in
            switch result
            {
            case .success(let data):
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
                    guard let jsonValue = json else
                    {
                        completion( .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) ) )
                        return
                    }
                    if jsonValue[ CatalystConstants.status ] as? String == CatalystConstants.failure
                    {
                        let result : Result< ZCatalystFunctionResult, ZCatalystError > = Serializer.parse( data : data )
                        switch result {
                        case .success( let funcResult ) :
                            guard let output = funcResult.output[ APIHandlerConstants.output ] as? String else
                            {
                                ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                                completion( .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) ) )
                                return
                            }
                            completion( .success( output ) )
                        case .error( let error ) :
                            completion( .error( error ) )
                            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                        }
                    }
                    else
                    {
                        guard let output = jsonValue[ APIHandlerConstants.output ] as? String else
                        {
                            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                            completion( .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) ) )
                            return
                        }
                        completion( .success( output ) )
                    }
                }
                catch
                {
                    completion( .error( typeCastToZCatalystError( error ) ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error(let error):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getCurrentUser( completion : @escaping ( Result< ZCatalystUser,ZCatalystError > ) -> Void )
    {
        let api = UserAPI.getCurrentUser
        networkClient.request(api, session : URLSession.shared ) { (result) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystUser, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func signUp(user: ZCatalystUser, completion: @escaping (Result<( ZCatalystUser, Int64 ), ZCatalystError >) -> Void)
    {
        let api = AuthAPI.signup(user: user)
        networkClient.request(api, session : URLSession.shared) { (result) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystUser, ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( let user ) :
                    completion( .success( ( user, user.zaaId ) ) )
                case .error( let error ) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func createRow(_ row : ZCatalystRow, tableId : String, completion : @escaping( Result< ZCatalystRow, ZCatalystError > ) -> Void )
    {
        guard let payload = row.payloadData else {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.invalidData ) : \( ErrorMessage.invalidDataMsg ), Details : -" )
            completion( .error( .processingError( code : ErrorCode.invalidData, message : ErrorMessage.invalidDataMsg, details : nil ) ) )
            return
        }
        let api = RowAPI.insert( json : payload, table : tableId )
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystRow ], ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( let rows ) :
                    rows[ 0 ].tableIdentifier = tableId
                    completion( .success( rows[ 0 ] ) )
                case .error( let error ) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func updateRow(_ row : ZCatalystRow, tableId : String, completion: @escaping(Result<ZCatalystRow, ZCatalystError>) -> Void)
    {
        guard let payload = row.payloadData else {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.invalidData ) : \( ErrorMessage.invalidDataMsg ), Details : -" )
            completion( .error( .processingError( code : ErrorCode.invalidData, message : ErrorMessage.invalidDataMsg, details : nil ) ) )
            return
        }
        let api = RowAPI.update( json : payload, table : tableId )
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystRow ], ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( let rows ) :
                    rows[ 0 ].tableIdentifier = tableId
                    completion( .success( rows[ 0 ] ) )
                case .error( let error ) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func deleteRow( id : Int64, tableId : String, completion: @escaping( ZCatalystError? ) -> Void)
    {
        let api = RowAPI.delete(row: id, table: tableId)
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystRow, ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( _ ) :
                    completion( nil )
                case .error( let error ) :
                    completion( error )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( typeCastToZCatalystError( error ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func search( searchOptions : ZCatalystSearchOptions, _ completion : @escaping( Result< [ String : Any ], ZCatalystError > )-> Void )
    {
        let api = searchOptions.buildAPI()
        networkClient.request(api, session: URLSession.shared) { (result) in
            switch result
            {
            case .success(let data):
                let result: Result<ZCatalystSearchResponse, ZCatalystError> = Serializer.parse(data: data)
                switch result
                {
                case .success( let response ) :
                    completion( .success( response.output ) )
                case .error( let error ) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error(let error):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getCurrentTimeZone( completion : @escaping ( Result< TimeZone, ZCatalystError > ) -> Void )
    {
        let api = TimeZoneAPI.getTimeZone
        networkClient.request( api, session: URLSession.shared ) { result in
            switch result
            {
            case .success(let data) :
                let result: Result<ZCatalystSearchResponse, ZCatalystError> = Serializer.parse(data: data)
                switch result
                {
                case .success(let response) :
                    guard let timeZoneString = response.output[ APIHandlerConstants.timezone ] as? String, let timeZone = TimeZone(identifier: timeZoneString) else
                    {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : Failed to get the time zone details, Details : -" )
                        return completion( .error( ZCatalystError.sdkError(code: ErrorCode.jsonException, message: "Failed to get the time zone details", details: nil) ) )
                    }
                    completion( .success( timeZone ) )
                case .error(let error) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error(let error) :
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getColumns( table : String, completion : @escaping ( Result< [ ZCatalystColumn ], ZCatalystError > ) -> Void )
    {
        let api = ColumAPI.fetchAll( table : table )
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystColumn ], ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func getColumn( table : String, column : Int64, completion : @escaping ( Result< ZCatalystColumn, ZCatalystError > ) -> Void )
    {
        let api = ColumAPI.fetch( table : table, column : column )
        networkClient.request( api, session : URLSession.shared ) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystColumn, ZCatalystError > = self.parse( data : data )
                completion( jsonResult )
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func create(_ rows: [ ZCatalystRow ], tableId : String, completion: @escaping(Result<[ZCatalystRow], ZCatalystError>) -> Void)
    {
        do
        {
            let payload = try ZCatalystDataStore.bulkInsert(rows: rows)
            let api = RowAPI.insert( json : payload, table : tableId )
            networkClient.request( api, session : URLSession.shared) { ( result ) in
                switch result
                {
                case .success( let data ) :
                    let jsonResult : Result< [ ZCatalystRow ], ZCatalystError > = self.parse( data : data )
                    switch jsonResult
                    {
                    case .success( let rows ) :
                        for row in rows
                        {
                            row.tableIdentifier = tableId
                        }
                        completion( .success( rows ) )
                    case .error( let error ) :
                        completion( .error( error ) )
                        ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                    }
                case .error( let error ):
                    completion( Result.error( typeCastToZCatalystError( error ) ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            }
        }
        catch
        {
            completion(.error(typeCastToZCatalystError(error)))
        }
    }
    
    func update(_ rows: [ ZCatalystRow ], tableId : String, completion: @escaping(Result<[ZCatalystRow], ZCatalystError>) -> Void)
    {
        do
        {
            let payload = try ZCatalystDataStore.bulkInsert(rows: rows)
            let api = RowAPI.update( json : payload, table : tableId )
            networkClient.request( api, session : URLSession.shared) { ( result ) in
                switch result
                {
                case .success( let data ) :
                    let jsonResult : Result< [ ZCatalystRow ], ZCatalystError > = self.parse( data : data )
                    switch jsonResult
                    {
                    case .success( let rows ) :
                        for row in rows
                        {
                            row.tableIdentifier = tableId
                        }
                        completion( .success( rows ) )
                    case .error( let error ) :
                        completion( .error( error ) )
                        ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                    }
                case .error( let error ):
                    completion( Result.error( typeCastToZCatalystError( error ) ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            }
        }
        catch
        {
            completion(.error(typeCastToZCatalystError(error)))
        }
    }
    
    func fetchRows(table : String, maxRecord: String?, nextToken: String?, completion: @escaping (CatalystResult.DataURLResponse<[ZCatalystRow], ResponseInfo>) -> Void)
    {
        let api = RowAPI.fetchAll(table: table, nextPageToken: nextToken, perPage: maxRecord)
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< [ ZCatalystRow ], ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( let rows ) :
                    for row in rows
                    {
                        row.tableIdentifier = table
                    }
                    do
                    {
                        let info = try self.parseResponseInfo(data: data)
                        completion( .success( rows, info ) )
                    }
                    catch
                    {
                        completion( .failure( error ) )
                    }
                case .error( let error ) :
                    completion( .failure( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( .failure( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func fetchRow(table : String, row : Int64, completion: @escaping (Result<ZCatalystRow, ZCatalystError>) -> Void)
    {
        let api = RowAPI.fetch(table: table, row : row)
        networkClient.request( api, session : URLSession.shared) { ( result ) in
            switch result
            {
            case .success( let data ) :
                let jsonResult : Result< ZCatalystRow, ZCatalystError > = self.parse( data : data )
                switch jsonResult
                {
                case .success( let row ) :
                    row.tableIdentifier = table
                    completion( .success( row ) )
                case .error( let error ) :
                    completion( .error( error ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error( let error ):
                completion( Result.error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func executeZCQL(query: String, completion: @escaping (Result<[ [ String : Any ] ], ZCatalystError>) -> Void)
    {
        
        let api = QueryAPI.execute(query: query)
        networkClient.request(api, session: URLSession.shared) { (result) in
            switch result
            {
            case .success(let data):
                let result: Result<Any, ZCatalystError> = Serializer.precheckJSON(data: data)
                switch result
                {
                case .success(let obj):
                    guard let json = obj as? Array< Dictionary< String, Any > > else {
                        ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                        completion( .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) ) )
                        return
                    }
                    completion( .success( json ) )
                case .error(let error):
                    completion( .error( typeCastToZCatalystError( error ) ) )
                    ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                }
            case .error(let error):
                completion( .error( typeCastToZCatalystError( error ) ) )
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            }
        }
    }
    
    func pushNotificationPayload(token: String, testDevice isTestDevice: Bool) -> [String: Any]
    {
        let os_version = UIDevice.current.systemVersion
        let bundleID = Bundle.main.bundleIdentifier
        var payload:[String: Any] {
            var json : [ String : Any ] = [APIHandlerConstants.deviceToken:token,
                    APIHandlerConstants.osVersion:os_version,
                    APIHandlerConstants.appBundleID:bundleID ?? "",
                    APIHandlerConstants.testDevice:isTestDevice]
            if let insId = UserDefaults.standard.value(forKey: Constants.apnsInstallationKey.string)
            {
                json.updateValue( insId, forKey: APIHandlerConstants.installationID)
            }
            return json
        }
        return payload
    }
    
    func handlePushResult(_ result: Result<Data, ZCatalystError>, completion: ( ZCatalystError? ) -> ()) {
        switch result
        {
        case .success(let data):
            let jsonResult:Result<Any,ZCatalystError> = Serializer.precheckJSON(data: data)
            switch jsonResult
            {
            case .success(let json):
                guard let jsonObj = json as? [String: Any],
                      let installationId = jsonObj[APIHandlerConstants.installationID] as? String else
                {
                    completion( ZCatalystError.inValidError(code: ErrorCode.invalidData, message: "Failed to get installationId from response", details: nil ) )
                    return
                }
                
                UserDefaults.standard.set(installationId, forKey: Constants.apnsInstallationKey.string)
                completion( nil )
            case .error( let error ):
                completion( error )
            }
        case .error( let error ):
            completion( error )
        }
    }
    
    func parse< T : ZCatalystEntity >( data : Data ) -> Result< T, ZCatalystError >
    {
        let result : Result< Any, ZCatalystError > = Serializer.precheckJSON( data : data )
        switch result
        {
        case .success( let json ) :
            do
            {
                guard let json = json as? [ String : Any ] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                if T.self == ZCatalystUser.self
                {
                    if let userDetails = json[ APIHandlerConstants.userDetails ] as? [ String : Any ]
                    {
                        let jsonData = try JSONSerialization.data( withJSONObject: userDetails, options : [] )
                        let decoder = JSONDecoder()
                        let obj = try decoder.decode( T.self, from : jsonData )
                        return .success( obj )
                    }
                    let jsonData = try JSONSerialization.data( withJSONObject: json, options : [] )
                    let decoder = JSONDecoder()
                    let obj = try decoder.decode( T.self, from : jsonData )
                    return .success( obj )
                }
                let jsonData = try JSONSerialization.data( withJSONObject: json, options : [] )
                let decoder = JSONDecoder()
                let obj = try decoder.decode( T.self, from : jsonData )
                if let row = obj as? ZCatalystRow
                {
                    row.data = json
                }
                return .success( obj )
            }
            catch
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                return .error( typeCastToZCatalystError( error ) )
            }
        case .error( let error ) :
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
    }
    
    fileprivate func parse< T : ZCatalystEntity >( data : Data ) -> Result< [ T ], ZCatalystError >
    {
        let result : Result< Any, ZCatalystError > = Serializer.precheckJSON( data : data )
        switch result
        {
        case .success( let json ) :
            do
            {
                guard let jsonArr = json as? [ [ String : Any ] ] else
                {
                    ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
                    return .error( .processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil ) )
                }
                let jsonData = try JSONSerialization.data( withJSONObject: jsonArr, options : [] )
                let decoder = JSONDecoder()
                let obj = try decoder.decode( [ T ].self, from : jsonData )
                if let rows = obj as? [ ZCatalystRow ]
                {
                    for index in 0..<rows.count
                    {
                        rows[ index ].data = jsonArr[ index ]
                    }
                }
                return .success( obj )
            }
            catch
            {
                ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
                return .error( typeCastToZCatalystError( error ) )
            }
        case .error( let error ) :
            ZCatalystLogger.logError( message : "Error Occurred : \( error )" )
            return .error( typeCastToZCatalystError( error ) )
        }
    }
    
    fileprivate func parseResponseInfo(data : Data) throws -> ResponseInfo
    {
        let json = try JSONSerialization.jsonObject(with: data, options:[]) as? [String:Any]
        guard let moreRecords = json?[APIHandlerConstants.moreRecords] as? Bool else
        {
            ZCatalystLogger.logError( message : "Error Occurred : \( ErrorCode.jsonException ) : \( ErrorMessage.responseParseError ), Details : -" )
            throw  ZCatalystError.processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil )
        }
        if moreRecords
        {
            if let token = json?[APIHandlerConstants.nextToken] as? String
            {
                return ResponseInfo(hasMoreRecords: moreRecords, nextPageToken: token)
            }
            else
            {
                throw  ZCatalystError.processingError( code : ErrorCode.jsonException, message : ErrorMessage.responseParseError, details : nil )
            }
        }
        else
        {
            return ResponseInfo(hasMoreRecords: moreRecords, nextPageToken: nil)
        }
    }
}

extension FileStorageAPI: APIEndPointConvertable
{
    var path: String {
        switch self
        {
        case .fetchAll( let folderId ) :
            return "\(APIHandlerConstants.folder)/\( folderId )/\(APIHandlerConstants.file)"
        case .fetch( let folderId, let fileId ) :
            return "\(APIHandlerConstants.folder)/\( folderId )/\(APIHandlerConstants.file)/\( fileId )"
        case .uploadFile(let folderId):
            return "\(APIHandlerConstants.folder)/\(folderId)/\(APIHandlerConstants.file)"
        case .downloadFile(let folderId, let fileId):
            return "\(APIHandlerConstants.folder)/\( folderId )/\(APIHandlerConstants.file)/\(fileId)/\(APIHandlerConstants.download)"
        case .deleteFile(let folderId, let fileId):
            return "\(APIHandlerConstants.folder)/\( folderId )/\(APIHandlerConstants.file)/\(fileId)"
        }
    }
    
    var httpMethod: HTTPMethod
    {
        switch self
        {
        case .fetchAll( _ ) :
            return .get
        case .fetch( _, _ ) :
            return .get
        case .uploadFile(_):
            return .post
        case .downloadFile(_,_):
            return .get
        case .deleteFile(_,_):
            return .delete
        }
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        return nil
    }
}

extension FolderAPI : APIEndPointConvertable
{
    var path : String {
        switch self
        {
        case .fetch( let folder ) :
            return "\(APIHandlerConstants.folder)/\( folder )"
        case .fetchAll :
            return "\(APIHandlerConstants.folder)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self
        {
        case .fetch( _ ), .fetchAll :
            return HTTPMethod.get
        }
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled( helper : OAuth() )
    }
    
    var payload: Payload? {
        return nil
    }
}


extension FunctionsAPI: APIEndPointConvertable
{
    var path: String {
        switch self
        {
        case .execute( let id, _, _, _ ) :
            return "\(APIHandlerConstants.function)/\(id)/\(APIHandlerConstants.execute)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self
        {
        case .execute( _, let requestMethod, _, _ ) :
            return requestMethod
        }
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        switch self
        {
        case .execute( _ , _, let params, let body):
            return Payload(bodyParameters: body, urlParameters: params, headers: nil, bodyData: nil)
        }
    }
}

extension PushNotificationAPI: APIEndPointConvertable
{
    
    var path: String {
        switch self
        {
        case .deregister(_,let appID):
            return "/\(APIHandlerConstants.pushNotification)/\(appID)/\(APIHandlerConstants.unregister)" //TODO: Documentation says appID, not sure what it is. So have put app.name for now.
        case .register(_,let appID):
            return "/\(APIHandlerConstants.pushNotification)/\(appID)/\(APIHandlerConstants.register)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        switch self {
        case .deregister(let params,_),  .register(let params,_):
            return Payload(bodyParameters: params, urlParameters: nil, headers: nil, bodyData:  nil)
        }
    }
}

extension RowAPI: APIEndPointConvertable
{
    var path: String {
        switch self {
        case .fetchAll(let table, _ , _), .update( _ , let table), .insert(_,let table):
            return "/\(APIHandlerConstants.table)/\(table)/\(APIHandlerConstants.row)"
        case .delete(let row, let table), .fetch(let table, let row):
            return "/\(APIHandlerConstants.table)/\(table)/\(APIHandlerConstants.row)/\(row)"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self{
        case .fetchAll(_,_,_), .fetch(_, _):
            return .get
        case .update(_, _):
            return .put
        case .delete(_,_):
            return .delete
        case .insert(_,_):
            return .post
        }
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        switch self
        {
            
        case .fetch(_, _), .delete(_,_):
            return nil
        case .fetchAll(_,let nextToken, let maxRecord):
            var parameter : Parameters = Parameters()
            if let maxRecord = maxRecord
            {
                if let nextToken = nextToken
                {
                    parameter  = [APIHandlerConstants.maxRows : maxRecord, APIHandlerConstants.nextToken : nextToken]
                }
                else
                {
                    parameter = [APIHandlerConstants.maxRows : maxRecord]
                    
                }
                return Payload(bodyParameters: nil, urlParameters: parameter , headers: nil, bodyData: nil)
            }
            else
            {
                if let nextToken = nextToken
                {
                    parameter  = [APIHandlerConstants.nextToken : nextToken]
                    return Payload(bodyParameters: nil, urlParameters: parameter , headers: nil, bodyData: nil)
                }
                else
                {
                    return nil
                }
            }
        case .update(let jsonData, _), .insert(let jsonData, _):
            return Payload(bodyParameters: nil, urlParameters: nil, headers: nil, bodyData: jsonData)
        }
    }
}

extension SearchAPI: APIEndPointConvertable
{
    var path: String
    {
        return APIHandlerConstants.search
    }
    
    var httpMethod: HTTPMethod
    {
        return .post
    }
    
    var OAuthEnabled: OAuthEnabled
    {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        return PayloadFactory.generateSearch(api: self)
    }
}

extension ColumAPI : APIEndPointConvertable
{
    
    var path: String {
        switch self
        {
        case .fetch( let table, let column ) :
            return "\(APIHandlerConstants.table)/\( table )/\(APIHandlerConstants.column)/\( column )"
        case .fetchAll( let table ) :
            return "\(APIHandlerConstants.table)/\( table )/\(APIHandlerConstants.column)"
        }
    }
    
    var httpMethod: HTTPMethod {
        return HTTPMethod.get
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled( helper : OAuth() )
    }
    
    var payload: Payload? {
        return nil
    }
}

extension QueryAPI: APIEndPointConvertable
{
    var path: String {
        return "/\(APIHandlerConstants.query)"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        switch self{
        case .execute(let query):
            return Payload(bodyParameters: [APIHandlerConstants.query:query], urlParameters: nil, headers: nil, bodyData: nil)
        }
    }
}

extension AuthAPI: APIEndPointConvertable
{
    var path: String {
        return "/\(APIHandlerConstants.projectUser)/\(APIHandlerConstants.signup)"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .disabled
    }
    
    var payload: Payload? {
        switch self{
        case .signup(let user):
            return Payload(bodyParameters: user.payload, urlParameters: nil, headers: nil, bodyData: nil)
        }
    }
}

extension UserAPI : APIEndPointConvertable
{
    var path: String {
        return "/\(APIHandlerConstants.projectUser)/\(APIHandlerConstants.current)"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        return nil
    }
}

extension TimeZoneAPI : APIEndPointConvertable
{
    var path: String
    {
        return "\( APIHandlerConstants.timezone )"
    }
    
    var httpMethod: HTTPMethod
    {
        return .get
    }
    
    var OAuthEnabled: OAuthEnabled {
        return .enabled(helper: OAuth())
    }
    
    var payload: Payload? {
        return nil
    }
}

public struct APIHandlerConstants
{
    static let moreRecords = "more_records"
    static let nextToken = "next_token"
    static let query = "query"
    static let maxRows = "max_rows"
    static let projectUser = "project-user"
    static let current = "current"
    static let signup = "signup"
    static let pushNotification = "push-notification"
    static let unregister = "unregister"
    static let register = "register"
    static let installationID = "installation_id"
    static let userDetails = "user_details"
    static let output = "output"
    static let deviceToken = "device_token"
    static let osVersion = "os_version"
    static let appBundleID = "app_bundle_id"
    static let testDevice = "test_device"
    static let folder = "folder"
    static let file = "file"
    static let download = "download"
    static let function = "function"
    static let execute = "execute"
    static let table = "table"
    static let row = "row"
    static let column = "column"
    static let search  = "search"
    static let timezone = "timezone"
}

