//
//  ZSSOUIKit.m
//  SSOKit
//
//  Created by Abinaya Ravichandran on 07/10/21.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import "ZSSOUIKit.h"
#import "SSOUserAccountsTableViewController.h"
#import "SSOUserAccountsNavigationController.h"
#import "SSOConstants.h"
#import "ZIAMUtilConstants.h"

@interface ZSSOUIKit()< UISheetPresentationControllerDelegate> {
    
    
    SSOUserAccountsNavigationController *accountsNavigationController;
    requestFailureBlock failureBlock;
    requestSuccessBlock successBlock;

}
@end

@implementation ZSSOUIKit

- (void)dealloc {
    NSLog(@"dealloc");
}


- (void)presentAccountChooserWithSuccess:(requestSuccessBlock)success andFailure:(requestFailureBlock)failure havingSwitchSuccess:(ZSSOKitManageAccountsSuccessHandler)switchSuccess{
#if !SSO_APP__EXTENSION_API_ONLY
#if !TARGET_OS_WATCH

    dispatch_async(dispatch_get_main_queue(), ^{

//        
        
        self->failureBlock = failure;
        self->successBlock = success;
        
        SSOUserAccountsTableViewController *accountListTableViewController = [[SSOUserAccountsTableViewController alloc] init];
        accountListTableViewController.success = success;
        accountListTableViewController.failure = failure;
        accountListTableViewController.switchSuccess = switchSuccess;
        
        
        self->accountsNavigationController = [[SSOUserAccountsNavigationController alloc] initWithRootViewController:accountListTableViewController];
        
        
        UIViewController *top = [self topViewController];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && self->_shouldPresentInFormSheet) {
            self->accountsNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        } else {
            if (@available(iOS 15.0, *)) {
                
                UISheetPresentationController* sheet = self->accountsNavigationController.sheetPresentationController;
                sheet.delegate = self;
                sheet.prefersGrabberVisible = YES;
                sheet.detents = @[ [UISheetPresentationControllerDetent mediumDetent], [UISheetPresentationControllerDetent largeDetent]];
                sheet.preferredCornerRadius = 24.0;
                sheet.prefersScrollingExpandsWhenScrolledToEdge = NO;
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = YES;
                sheet.prefersEdgeAttachedInCompactHeight = YES;
            } else {
                //  Fallback on earlier versions
                self->accountsNavigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;

            }
        }
        if(top){
            [top presentViewController:self->accountsNavigationController animated:YES completion:nil];
        }else{
            [[self getActiveWindow].rootViewController presentViewController:self->accountsNavigationController animated:YES completion:nil];
        }
    });

#endif
#endif

}

- (void)presentationControllerDidDismiss:(UIPresentationController *)presentationController {
    
    NSString* errormessage = @"account chooser closed";
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:errormessage forKey:NSLocalizedDescriptionKey];
    NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAccountChooserDismissedError userInfo:userInfo];
    failureBlock(returnError);
}
-(UIWindow *)getActiveWindow{
    if(self.presentationContextProviderSSOKit){
        return [self.presentationContextProviderSSOKit presentationAnchorForSSOKit];
    }else{
        return self.MainWindow;
    }
}

- (UIViewController*)topViewController {
    
    return [self topViewControllerWithRootViewController:[self getActiveWindow].rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}


@end
#endif
