//
//  SSOSFSafariViewController.h
//  IAM_SSO
//
//  Created by Kumareshwaran on 16/03/17.
//
//

#import <UIKit/UIKit.h>
#include "SSORequestBlocks+Internal.h"
#if !TARGET_OS_WATCH
#import <WebKit/WebKit.h>
#import "ZSSOProtocols.h"

@interface SSOSFSafariViewController : UIViewController

@property requestSuccessBlock success;
@property requestFailureBlock failure;
@property ZSSOKitManageAccountsSuccessHandler switchSuccess;
@property (nonatomic,strong) WKWebView *webkitview;
@property (nonatomic,weak) id<ZSSOSSLChallengeDelegate> SSLPinningDelegate;

@end

#endif
