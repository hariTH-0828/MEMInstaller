//
//  ZSSOProtocols.h
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 05/04/23.
//  Copyright © 2023 Dhanasekar K. All rights reserved.
//

#ifndef ZSSOProtocols_h
#define ZSSOProtocols_h

@protocol ZSSOSSLChallengeDelegate <NSObject>
- (void)verifyChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler;
@end

#endif /* ZSSOProtocols_h */
