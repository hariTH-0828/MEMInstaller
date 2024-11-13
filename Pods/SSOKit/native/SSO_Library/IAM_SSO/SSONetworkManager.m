//
//  SSONetworkManager.m
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 07/02/17.
//  Copyright © 2017 Zoho. All rights reserved.
//


#import "SSONetworkManager.h"
#import <UIKit/UIKit.h>
#include "ZIAMHelpers.h"
#import "ZIAMUtilConstants.h"

@interface SSONetworkManager() <NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *urlSession;

@end

@implementation SSONetworkManager
+(SSONetworkManager*)sharedManager {
    static SSONetworkManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

-(NSURLSession*)urlSession {
    if (_urlSession) {
        return _urlSession;
    }
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _urlSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    return _urlSession;
}

-(void)sendPOSTRequestForURL:(NSString*)urlString
                  parameters:(NSDictionary*)params
                successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed {
    
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:nil params:params isJson:NO];
    [request setHTTPMethod:@"POST"];
    [self processRequest:request successBlock:success failureBlock:failed];
}

-(void)sendPUTRequestForURL:(NSString*)urlString
                   httpbody:(NSData *)bodydata
                  parameters:(NSDictionary*)params
                successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed {
    
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:bodydata params:params isJson:NO];
    [request setHTTPMethod:@"PUT"];
    [self processRequest:request successBlock:success failureBlock:failed];
}

-(void)sendJSONPOSTRequestForURL:(NSString*)urlString
  parameters:(NSDictionary*)params
successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                    failureBlock:(void (^)(SSOInternalError errorType, NSError* errorInfo))failed{
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:nil params:params isJson:YES];
    [request setHTTPMethod:@"POST"];
    [self processRequest:request successBlock:success failureBlock:failed];
}
-(void)sendJSONPUTRequestForURL:(NSString*)urlString
  parameters:(NSDictionary*)params
successBlock:(void (^)(NSDictionary* jsonDict, NSHTTPURLResponse *httpResponse))success
                   failureBlock:(void (^)(SSOInternalError errorType, id errorInfo))failed {
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:nil params:params isJson:YES];
       [request setHTTPMethod:@"PUT"];
       [self processRequest:request successBlock:success failureBlock:failed];
}

-(void)sendGETRequestForURL:(NSString *)urlString
                 parameters:(NSDictionary *)params
               successBlock:(void (^)(NSDictionary *, NSHTTPURLResponse *))success
               failureBlock:(void (^)(SSOInternalError, NSError* ))failed {
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:nil params:params isJson:NO];
    [request setHTTPMethod:@"GET"];
    [self processRequest:request successBlock:success failureBlock:failed];
}

-(void)sendGETRequestForURL:(NSString*)urlString
                 parameters:(NSDictionary*)params
       successBlockWithData:(void (^)(NSData* data, NSHTTPURLResponse *httpResponse))success
               failureBlock:(void (^)(SSOInternalError errorType, NSError*  errorInfo))failed {
    NSMutableURLRequest * request = [self requestWithURL:urlString httpbody:nil params:params isJson:NO];
    [request setHTTPMethod:@"GET"];
    
    [[ZIAMUtil sharedUtil] showNetworkActivityIndicator];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
        [[ZIAMUtil sharedUtil] hideNetworkActivityIndicator];
        if ([data length] > 0 && error == nil && [httpResponse statusCode] == 200) {
            success(data,httpResponse);
        } else if (error != nil) {
            //connection error received
            failed(SSO_ERR_CONNECTION_FAILED,error);
        }else if ([data length] == 0 && error == nil) {
            //Nothing was received
            failed(SSO_ERR_SERVER_ERROR, error);
        } else {
            // When all the above cases fails..
            NSDictionary *userInfo      =   @{ NSLocalizedDescriptionKey : @"Generic error: SSO network call failed with unknown error!" };
            
            NSError *genericError = [NSError errorWithDomain:request.URL.host code:k_SSOGenericError userInfo:userInfo];
            failed(SSO_ERR_CONNECTION_FAILED,genericError);
        }
    }];
    [task resume];
}

-(void)processRequest:(NSURLRequest*)request successBlock:(void (^)(NSDictionary *, NSHTTPURLResponse *))success
         failureBlock:(void (^)(SSOInternalError, NSError*))failed {
    
    [[ZIAMUtil sharedUtil] showNetworkActivityIndicator];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse*)response;
        [[ZIAMUtil sharedUtil] hideNetworkActivityIndicator];
        
        if (error) {
            failed(SSO_ERR_CONNECTION_FAILED,error);

        } else {
            
            if ([data length] > 0) {
                [[ZIAMUtil sharedUtil] hideNetworkActivityIndicator];
                NSError *jsonError;
                NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                
                if (jsonError) {
                    failed(SSO_ERR_JSONPARSE_FAILED,jsonError);

                } else {
                    if (responseDictionary == nil) {
                        //fetch nil
                        failed(SSO_ERR_JSON_NIL,jsonError);
                    } else if ([responseDictionary valueForKey:@"error"] || [responseDictionary valueForKey:@"errors"]) {
                        //fetch error received
                        NSMutableDictionary *errorResponseDict = [[NSMutableDictionary alloc] initWithDictionary:responseDictionary];
                        
                        NSString *iCrestErrorMessage = [responseDictionary valueForKey:@"message"];
                        if (iCrestErrorMessage) {
                            //ASM iCrest errors
                            [errorResponseDict setObject:iCrestErrorMessage forKey:NSLocalizedDescriptionKey];
                            NSError *err = [NSError errorWithDomain:kSSOKitErrorDomain code:0 userInfo:errorResponseDict];
                            failed(SSO_ERR_SERVER_ERROR, err);
                        } else {
                            NSString *oauthErrorMessage = [responseDictionary valueForKey:@"error"];
                            if (oauthErrorMessage) {
                                [errorResponseDict setObject:oauthErrorMessage forKey:NSLocalizedDescriptionKey];
                                NSError *err = [NSError errorWithDomain:kSSOKitErrorDomain code:0 userInfo:errorResponseDict];
                                failed(SSO_ERR_SERVER_ERROR, err);
                            } else {
                                [errorResponseDict setObject:@"Error occured" forKey:NSLocalizedDescriptionKey];
                                NSError *err = [NSError errorWithDomain:kSSOKitErrorDomain code:0 userInfo:errorResponseDict];
                                failed(SSO_ERR_SERVER_ERROR, err);
                            }
                        }
                       
                    } else {
                        //fetch success
                        success(responseDictionary,httpResponse);
                    }
                }
                
            } else {
                //Nothing was received
                NSMutableDictionary *errorResponseDict = [[NSMutableDictionary alloc] init];
                [errorResponseDict setObject:@"No data received" forKey:NSLocalizedDescriptionKey];
                NSError *err = [NSError errorWithDomain:kSSOKitErrorDomain code:0 userInfo:errorResponseDict];
                failed(SSO_ERR_SERVER_ERROR, err);
            }
        }
        
    }];
    [task resume];
    
}

//Helpers

-(NSMutableURLRequest*)requestWithURL:(NSString*)urlString
                             httpbody:(NSData *)bodydata
                               params:(NSDictionary*)parameters
                               isJson:(BOOL)isJson {
    NSURL *url = [NSURL URLWithString:urlString];
    NSData *postData;
    
    if(bodydata){
        postData = bodydata;
    } else {
        if(isJson){
            postData= [self getJSONData:parameters];
        }else{
            postData= [self getData:parameters];
        }
    }
    
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    //Create request with the given url and params
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPBody:postData];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    //Set HTTP Headers.....
    NSDictionary* dictHeaders = [parameters valueForKey:SSO_HTTPHeaders];
    for (NSString* HTTPHeaderField in dictHeaders) {
        NSString* header = [dictHeaders valueForKey:HTTPHeaderField];
        [request setValue:header forHTTPHeaderField:HTTPHeaderField];
    }
    
    NSString *mdmToken = [[ZIAMUtil sharedUtil] getMDMToken];
    if(mdmToken){

        NSString *mdmHeader = [[ZIAMUtil sharedUtil] getMDMHeaderFromMDMToken:mdmToken];
        [request setValue:mdmHeader forHTTPHeaderField:@"X-MDM-Token"];
    }
    
    [request setValue:[[ZIAMUtil sharedUtil] getUserAgentString] forHTTPHeaderField:@"User-Agent"];
    return request;
}
-(NSData*)getData:(NSDictionary*)paramDict {
    NSString *paramThread;
    for (id key in paramDict) {
        if (![key isEqualToString:SSO_HTTPHeaders]) {
            if (paramThread) {
                paramThread = [paramThread stringByAppendingString:[NSString stringWithFormat:@"&%@=",key]];
            }else{
                paramThread = [NSString stringWithFormat:@"%@=",key];
            }
            if([[paramDict valueForKey:key] isKindOfClass:[NSString class]]){
                paramThread = [paramThread stringByAppendingString:[paramDict valueForKey:key]];
            }else{
                NSError *err;
                NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:[paramDict valueForKey:key] options:0 error:&err];
                NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
                paramThread = [paramThread stringByAppendingString:myString];
            }


            }
        }
    NSData *postData = [paramThread dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    return postData;
}

-(NSData*)getJSONData:(NSDictionary*)paramDict {
    NSString *paramThread;
    NSError * err;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict addEntriesFromDictionary:paramDict];
    if (dict.count > 0) {

        if ([dict valueForKey:SSO_HTTPHeaders]) {
            [dict removeObjectForKey:SSO_HTTPHeaders];
        }
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict
                                                             options:0
                                                               error:&err];

//        NSString *myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
//        DLog(@"jsonform %@",myString);
//        DLog(@"paramThread %@",paramThread);
        return  jsonData;

    }
    NSData *postData = [paramThread dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    return postData;
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    
    if([self SSLPinningDelegate]) {
        [[self SSLPinningDelegate] verifyChallenge:challenge completionHandler:completionHandler];
    } else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling,nil);
    }
    
}
@end

