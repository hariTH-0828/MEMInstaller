//
//  SSONetworkManager.h
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 07/02/17.
//  Copyright © 2017 Zoho. All rights reserved.
//

#define SSO_HTTPHeaders @"SSO_HTTPHeaders"
#import <Foundation/Foundation.h>
#import "ZSSOProtocols.h"
/*!
 @typedef SSOInternalError
 @brief Types of error handled in every API calls.
 */
typedef NS_ENUM(NSInteger, SSOInternalError) {
    SSO_ERR_JSONPARSE_FAILED,
    SSO_ERR_JSON_NIL,
    SSO_ERR_SERVER_ERROR,
    SSO_ERR_CONNECTION_FAILED,

};

@interface SSONetworkManager : NSObject

+(SSONetworkManager*)sharedManager;
@property (weak, nonatomic) id<ZSSOSSLChallengeDelegate> SSLPinningDelegate;
-(void)sendPOSTRequestForURL:(NSString*)urlString
                  parameters:(NSDictionary*)params
                successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;

-(void)sendGETRequestForURL:(NSString*)urlString
                 parameters:(NSDictionary*)params
               successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;

-(void)sendGETRequestForURL:(NSString*)urlString
                 parameters:(NSDictionary*)params
       successBlockWithData:(void (^)(NSData* data, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed;
-(void)sendJSONPOSTRequestForURL:(NSString*)urlString
  parameters:(NSDictionary*)params
successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                    failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed;


-(void)sendJSONPUTRequestForURL:(NSString*)urlString
                     parameters:(NSDictionary*)params
                   successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                   failureBlock:(void (^)(SSOInternalError errorType, id errorInfo))failed;
-(void)sendPUTRequestForURL:(NSString*)urlString
                   httpbody:(NSData *)bodydata
                  parameters:(NSDictionary*)params
                successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed ;
@end
