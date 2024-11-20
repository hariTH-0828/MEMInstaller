//
//  SSOWebkitControllerViewController.h
//  SSOKit-iOS
//
//  Created by Abinaya Ravichandran on 16/04/23.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import <UIKit/UIKit.h>
#import "SSORequestBlocks+Internal.h"
#import "SSOConstants.h"
NS_ASSUME_NONNULL_BEGIN

@interface SSOWebkitControllerViewController : UIViewController
@property (nonatomic, retain) NSURL * urlForWebView;
@property (nonatomic, retain) NSDictionary<NSString*, NSString*> * headers;
@property (nonatomic, copy) requestFailureBlock failure;

@end

NS_ASSUME_NONNULL_END
#endif
