//
//  ZSSOUIKit.h
//  SSOKit
//
//  Created by Abinaya Ravichandran on 07/10/21.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include "SSORequestBlocks.h"
#include "SSORequestBlocks+Internal.h"
#import "ZSSOKitPresentationContextProviding.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZSSOUIKit : NSObject
- (void)presentAccountChooserWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure havingSwitchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess;
@property BOOL shouldPresentInFormSheet;
@property (nonatomic, weak) UIWindow *MainWindow;
@property (nonatomic, weak) id <ZSSOKitPresentationContextProviding> presentationContextProviderSSOKit;

@end

NS_ASSUME_NONNULL_END
#endif
