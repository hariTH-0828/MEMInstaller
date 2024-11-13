//
//  SSOTokenFetch.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 11/06/18.
//

#import <Foundation/Foundation.h>
#include "ZIAMUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZIAMUtil(SSOTokenFetch)
- (void)initTokenFetch;
-(void)processTokenFetchForZUID:(NSString *)zuid isSSOAccount:(BOOL)isSSO WithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure;
@end

NS_ASSUME_NONNULL_END
