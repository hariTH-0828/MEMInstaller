//
//  SSOUserAccountsTableViewController.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 5/10/16.
//  Copyright © 2016 Zoho. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "SSORequestBlocks+Internal.h"
#if !TARGET_OS_WATCH


@protocol SSOAccountsUIManager <NSObject>

-(void)ssoAccountsListReload;

@end

@interface SSOUserAccountsTableViewController : UIViewController

@property requestSuccessBlock success;
@property requestFailureBlock failure;
@property ZSSOKitManageAccountsSuccessHandler switchSuccess;
@property (weak, nonatomic) id<SSOAccountsUIManager> delegate;
@property BOOL isHavingSSOAccount;
@property BOOL isManageAccount;

@end


#endif
