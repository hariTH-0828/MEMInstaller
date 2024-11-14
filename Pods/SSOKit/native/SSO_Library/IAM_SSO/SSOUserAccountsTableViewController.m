//
//  SSOUserAccountsTableViewController.m
//  IAM_SSO
//
//  Created by Kumareshwaran on 5/10/16.
//  Copyright © 2016 Zoho. All rights reserved.
//
#if !TARGET_OS_WATCH
#if !SSO_APP__EXTENSION_API_ONLY

#import "SSOUserAccountsTableViewController.h"
#import "SSOUserAccountsNavigationController.h"
#include "ZIAMUtil.h"
#include "ZIAMUtilConstants.h"
#include "SSONetworkManager.h"
#include "SSOSFSafariViewController.h"
#include "ZIAMKeyChainUtil.h"
#include "ZIAMHelpers.h"
#import "ZSSOAddAccountView.h"
#import "ZSSOAccountsTableViewCell.h"
#import "ZSSOAddAccountTableCell.h"
#import "UIView+ZIAMView.h"


#if __has_include("SSOKit-Swift.h")
    #import "SSOKit-Swift.h"
#else
    #import "SSOKit/SSOKit-Swift.h"
#endif

@interface SSOUserAccountsTableViewController ()<UITableViewDelegate, UITableViewDataSource, SSOAccountsUIManager>
{
    UIBarButtonItem *managebarButtonItem;
    ZSSOAddAccountView* addAccView;

    UITableView *tableAccounts;

   // UITableViewCell *CurrentUserCell;
    NSMutableArray<NSDictionary*>* arrayUsers;
    UILabel *loadingText;
    UILabel *labelNote;
    UIView *loadingviewFrame;
    UIView *blockingView;
    UIActivityIndicatorView *loadingActivityView;
}
@end

@implementation SSOUserAccountsTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
//    if (@available(iOS 11.0, *)) {
//        [self.view setBackgroundColor:[UIColor colorNamed:@"System Background Color"]];
//    }
    [ZIAMUtil sharedUtil]->ButtonClick = NO;

    
    [self setupUI];
    
    [self getAllUsers];
    
    tableAccounts.scrollEnabled = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void) tappedAddAccount {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[ZIAMUtil sharedUtil] checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:self->_success andFailure:self->_failure switchSuccess:self->_switchSuccess];
                    }];
                });
}
-(void)setupUI {
    
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            self.view.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
        } else {
            self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
        }
    } else {
        // Fallback on earlier versions
        self.view.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    }

    if (@available(iOS 13.0, *)) {
        self.navigationController.navigationBar.tintColor = [UIColor labelColor];
    } else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.tintColor = [UIColor darkTextColor];

    }
    
    [self addTableViewAndAddAccountView];
    [self addBlockingView];
    [self addLoadingView];
}
-(void)addTableViewAndAddAccountView {
    
    
    tableAccounts = [[UITableView alloc] init];
    [tableAccounts setEstimatedRowHeight:100.0];
    [tableAccounts setRowHeight:UITableViewAutomaticDimension];
    
        if (@available(iOS 15.0, *)) {

        [tableAccounts setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 0)];
        self->tableAccounts.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    }
    
    [self.view addSubview:tableAccounts];
    [tableAccounts setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableAccounts setBackgroundColor:[UIColor clearColor]];
    
    [tableAccounts pinTrailingToSuperView:0];
    [tableAccounts pinLeadingToSuperView:0];
    [tableAccounts pinTopToSuperView:0];

    tableAccounts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [tableAccounts registerClass:[ZSSOAccountsTableViewCell class] forCellReuseIdentifier:@"ZSSOAccountsTableViewCell"];
    [tableAccounts registerClass:[ZSSOAddAccountTableCell class] forCellReuseIdentifier:@"ZSSOAddAccountTableCell"];
    [tableAccounts setDelegate:self];
    [tableAccounts setDataSource:self];
   
    if (self.isManageAccount) {
        [tableAccounts pinBottomToSuperView:0];

    } else {
        
        labelNote = [[UILabel alloc] init];
        labelNote.numberOfLines = 0;
        labelNote.textAlignment = NSTextAlignmentCenter;
        labelNote.textColor = [UIColor colorWithRed:53.0/255.0 green:107.0/255.0 blue:211.0/255.0 alpha:1];
        [labelNote setFont:[UIFont fontWithName:@"Helvetica" size:13.0]];

        labelNote.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.account.lock.note" Comment:@"You must verify your identity using the device lock to complete the sign in process."];
        [self.view addSubview:labelNote];
        [labelNote setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [labelNote pinTrailingToSuperView:-24];
        [labelNote pinLeadingToSuperView:24];
        [labelNote pinTopTo:tableAccounts constant:20];
        [labelNote pinBottomToSuperViewSafeArea:-8];
        
    }

}


-(void)addBlockingView {
    
    //blocking view
    blockingView = [[UIView alloc] initWithFrame:self.view.bounds];
    blockingView.userInteractionEnabled = NO;
    if (@available(iOS 11.0, *)) {
        blockingView.backgroundColor = [UIColor colorNamed:@"System Background Color"];
    }
    blockingView.hidden = YES;
    
    [self.view addSubview:blockingView];
    [blockingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [blockingView pinToSuperView:0];
}


- (void)addLoadingView {
    
    loadingviewFrame = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 90)];
    loadingviewFrame.center = CGPointMake(self.view.center.x,self.view.center.y);
    loadingviewFrame.layer.cornerRadius = 10;
    loadingviewFrame.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    loadingviewFrame.hidden = YES;
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    NSLayoutConstraint* height = [NSLayoutConstraint constraintWithItem:loadingviewFrame attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:90];
    
    
    
    [self.view addSubview:loadingviewFrame];
    loadingviewFrame.translatesAutoresizingMaskIntoConstraints = false;
    
    
    [self.view addConstraint:centerX];
    [self.view addConstraint:centerY];
    [loadingviewFrame addConstraint:width];
    [loadingviewFrame addConstraint:height];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    loadingActivityView = [[UIActivityIndicatorView alloc]
                           initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingActivityView.frame = loadingviewFrame.bounds;
    loadingActivityView.hidden = NO;
    [loadingviewFrame addSubview:loadingActivityView];
    loadingText= [[UILabel alloc]initWithFrame:loadingviewFrame.frame];
    loadingText.hidden = NO;
    loadingText.text =  [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.loading" Comment:@"Loading..."];
    loadingText.textColor = [UIColor whiteColor];
    loadingText.backgroundColor = [UIColor clearColor];
    loadingText.textAlignment = NSTextAlignmentCenter;
    loadingText.font = [UIFont fontWithName:@"Helvetica" size:16];
    loadingText.center = CGPointMake(loadingviewFrame.frame.size.width/2, (loadingviewFrame.frame.size.height/2)+30);
    [loadingviewFrame addSubview:loadingText];
    [self.view addSubview:loadingviewFrame];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSIndexPath *indexPath = tableAccounts.indexPathForSelectedRow;
    if (indexPath) {
        [tableAccounts deselectRowAtIndexPath:indexPath animated:animated];
    }
}

-(void)showLoading{
    if ([ZIAMUtil sharedUtil]->showProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->showProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self->blockingView.hidden = NO;
            self.navigationController.navigationBarHidden = YES;
            self->tableAccounts.hidden = YES;
            self->labelNote.hidden = YES;
            [self->loadingActivityView startAnimating];
            self->loadingviewFrame.hidden = NO;
        });
    }
}

-(void)hideLoading{
    if ([ZIAMUtil sharedUtil]->endProgressBlock != nil) {
        [ZIAMUtil sharedUtil]->endProgressBlock();
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            self->blockingView.hidden = YES;
            self.navigationController.navigationBarHidden = NO;
            self->tableAccounts.hidden = NO;
            self->labelNote.hidden = NO;
            [self->loadingActivityView stopAnimating];
            self->loadingviewFrame.hidden = YES;
        });
    }
}

-(void)toggleClose{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self dismissViewControllerAnimated:YES completion:^{
        NSError *returnError;
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
        [userInfo setValue:@"Account Chooser Dismissed" forKey:NSLocalizedDescriptionKey];
        returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:k_SSOAccountChooserDismissedError userInfo:userInfo];
        self->_failure(returnError);
        return;
    }];
    });
}

-(void)toggleManage{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        SSOUserAccountsTableViewController* manageAccounts = [[SSOUserAccountsTableViewController alloc] init];
        manageAccounts.isManageAccount = YES;
        manageAccounts.delegate = self;
        manageAccounts.failure = self.failure;
        [self.navigationController pushViewController:manageAccounts animated:YES];

    });
}

-(void)ssoAccountsListReload {
    [self getAllUsers];
}

-(void)toggleManageDismiss{
    

    [self.navigationController popViewControllerAnimated:YES];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    
    if (self.isManageAccount) {
        return arrayUsers.count;

    } else {
        return arrayUsers.count+1;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewAutomaticDimension;
}

- (NSMutableDictionary*)getUserDetails:(NSString*)SSOZUID  fromArray:(NSArray*)userdetailsArray {
    NSMutableDictionary *userDict  = [NSMutableDictionary new];


    if (userdetailsArray) {
        [userDict setValue:SSOZUID forKey:@"zuid"];
        [userDict setValue:[userdetailsArray objectAtIndex:0] forKey:@"name"];
        [userDict setValue:[userdetailsArray objectAtIndex:1] forKey:@"email"];
        NSData *profileImageData = [userdetailsArray objectAtIndex:2];
        if(![profileImageData isEqual:[NSNull null]] && [[userdetailsArray objectAtIndex:2] isKindOfClass:[NSData class]]){
            
            [userDict setValue:[UIImage imageWithData:profileImageData] forKey:@"image"];

        }else if([[userdetailsArray objectAtIndex:2] isKindOfClass:[UIImage class]]){
            
            [userDict setValue:[userdetailsArray objectAtIndex:2] forKey:@"image"];
        }
    }
    return userDict;
}
- (void)getAllUsers {
    
    arrayUsers = [NSMutableArray new];
    
    
    NSString* currentUserZUID = [[ZIAMUtil sharedUtil] getCurrentUserZUIDFromKeychain];
    NSData* SSO_ZuidsData = [[ZIAMUtil sharedUtil] getSSOZUIDListFromSharedKeychain];
    NSMutableDictionary *SSOUserDetailsDictionary  = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:[[ZIAMUtil sharedUtil] getSSOUserDetailsDataFromSharedKeychain]];
    
    if(SSO_ZuidsData){
        NSMutableArray* SSO_ZuidsArray = (NSMutableArray *) [NSKeyedUnarchiver unarchiveObjectWithData:SSO_ZuidsData];
        for (NSString *SSOZUID in SSO_ZuidsArray) {
            
            NSDictionary* userDict = [self getUserDictFrom:SSOUserDetailsDictionary havingZUID:SSOZUID andHavingCurrentUser:currentUserZUID];
            if (userDict) {
                [arrayUsers addObject:userDict];
            }
            
        }
    } else {
        NSString *SSO_V1_ZUID =[[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
        NSDictionary* userDict = [self getUserDictFrom:SSOUserDetailsDictionary havingZUID:SSO_V1_ZUID andHavingCurrentUser:currentUserZUID];
        if (userDict) {
            [arrayUsers addObject:userDict];
        }
        
    }
    
    NSData* user_details_data = [[ZIAMUtil sharedUtil] getUserDetailsDataFromKeychain];
    NSMutableDictionary*  userDetailsDictionary;
    if(user_details_data){
        userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        for (NSString *ZUIDKey in userDetailsDictionary) {
            NSArray *userdetailsArray = [userDetailsDictionary valueForKey:ZUIDKey];
            
            NSMutableDictionary* userDict = [self getUserDetails:ZUIDKey fromArray:userdetailsArray];
            BOOL isCurrentUser = [ZUIDKey isEqualToString:currentUserZUID];
            if (isCurrentUser) {
                [userDict setValue:@"true" forKey:@"isCurrentUser"];
            }
            [self->arrayUsers addObject:userDict];
            
        }
    }
    
    
    
    [tableAccounts reloadData];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    if (self.isManageAccount) {
        
        if(tableAccounts.editing){
            [self toggleManageDismiss];
        }
        
        [tableAccounts setEditing:!tableAccounts.editing animated:YES];
        
    }
    
    [self configureNavigationBarButtons];
}
  

- (NSDictionary*) getUserDictFrom:(NSDictionary*)allUsersDict havingZUID:(NSString*)ZUID andHavingCurrentUser:(NSString*) currentUserZUID {
    
    BOOL canIncludeUser = true;
    if (self.switchSuccess) {
        if (![[ZIAMUtil sharedUtil] getAppSSOAccessTokenDataFromSharedKeychainForZUID:ZUID]){
            canIncludeUser = false;
        }
    }
    if (canIncludeUser) {
        NSArray *userdetailsArray = [allUsersDict objectForKey:ZUID];
        NSString* refreshToken = [[ZIAMUtil sharedUtil] getSSORefreshTokenFromSharedKeychainForZUID:ZUID];
        if (userdetailsArray && refreshToken) {
            NSMutableDictionary* userDict = [self getUserDetails:ZUID fromArray:userdetailsArray];
            BOOL isCurrentUser = [ZUID isEqualToString:currentUserZUID];
            if (isCurrentUser) {
                [userDict setValue:@"true" forKey:@"isCurrentUser"];
            }
            [userDict setValue:@"true" forKey:@"sso"];
            return userDict;
        }
    }

    return nil;;
}

- (void) configureNavigationBarButtons {
    
    if (self.isManageAccount) {
        self.navigationItem.titleView = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.leftBarButtonItem = nil;

    } else {
        
        if (arrayUsers.count > 0) {
            managebarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.manage" Comment:@"Manage"] style:UIBarButtonItemStyleDone target:self action:@selector(toggleManage)];
            self.navigationItem.rightBarButtonItem = managebarButtonItem;
            
        }
        
        if (@available(iOS 11.0, *)) {
            [self.navigationItem setBackButtonTitle:@""];
        } else {
            // Fallback on earlier versions
        }
        
#if TARGET_OS_UIKITFORMAC
        [self setCloseButton];
#endif
        
        if (@available(iOS 15.0, *)) {
            
        } else {
            
            [self setCloseButton];
        }
    }
    
    
}
    
-(void) setCloseButton {
    UIImage *closeImage = [UIImage imageNamed:@"ssokit_close" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
    UIBarButtonItem *closeBarButton = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleClose)];
    
    self.navigationItem.leftBarButtonItem = closeBarButton;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < arrayUsers.count){
        DLog(@"User Account: %ld",(long)indexPath.row);
        ZSSOAccountsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZSSOAccountsTableViewCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ZSSOAccountsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZSSOAccountsTableViewCell"];
        }
        NSDictionary *userdetailsDict = [arrayUsers objectAtIndex:indexPath.row];
        NSString* SSO_Zuid = [userdetailsDict objectForKey:@"zuid"];

        UIImage *userImage = [userdetailsDict objectForKey:@"image"];
        UIImage *avatarImage = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        [cell loadUser:[userdetailsDict objectForKey:@"name"] email:[userdetailsDict objectForKey:@"email"]
                 image: (userImage != nil) ? userImage : avatarImage
          encircle:[userdetailsDict valueForKey:@"sso"]];
        
        if([userdetailsDict valueForKey:@"isCurrentUser"]){
           // selectedImageView.hidden = NO;
          //  self->CurrentUserCell = cell;
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else{
           // selectedImageView.hidden = YES;
            [cell setAccessoryType:UITableViewCellAccessoryNone];

        }
        
       return cell;
    } else {
        ZSSOAddAccountTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZSSOAddAccountTableCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ZSSOAddAccountTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ZSSOAddAccountTableCell"];
        }
        
        return cell;
    }


}

-(void)dismissWithSuccessHavingAccessToken:(NSString *)token{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_success(token);
        }];
    });
}

-(void)dismissWithSuccessHavingAccessToken:(NSString *)token andSwitch:(BOOL)switched{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_switchSuccess(token,switched,[[ZIAMUtil sharedUtil]getCurrentUser]);
        }];
    });
}

-(void)dismissWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self->_failure(error);
        }];
    });
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isManageAccount) {
        if(indexPath.row < arrayUsers.count){
            
            
            NSString* isSSO = [[arrayUsers objectAtIndex:indexPath.row] valueForKey:@"sso"];
            NSDictionary *userdetailsDict = [arrayUsers objectAtIndex:indexPath.row];
            NSString* selectedZUID = [userdetailsDict objectForKey:@"zuid"];
            NSString* isCurrentUser = [userdetailsDict objectForKey:@"isCurrentUser"];

            if (isCurrentUser) {
                // dont do anything. User already logged in
                // may be app called presentmanageaccounts
                return;;
            }
            if (isSSO) {
                BOOL isBiometricEnabled = [[ZIAMUtil sharedUtil] getIsBiometricEnabledForUser:selectedZUID];
                
                if (!isBiometricEnabled) {
                    if (![self canAllowSSOForUser:selectedZUID]) {
                        NSString * email = [userdetailsDict objectForKey:@"email"];
                        [ZIAMUtil sharedUtil]->loginID = email;
                        [self showLoginScreen];
                        return;
                    }
                }
                
                [SSOLocalAuthentication showBiometricConfirmationOn:self shouldAllowFallback: !isBiometricEnabled completion:^(SSOLocalAuthenticationStatus error) {
                    if (error == SSOLocalAuthenticationStatusAllow) {
                        [self showLoading];
                        [self shouldBlockDismissingSheet:YES];
                        [[ZIAMUtil sharedUtil]getSSOForceFetchOAuthTokenForSSOZUID:selectedZUID WithSuccess:^(NSString *token) {
                            [self hideLoading];
                            [self shouldBlockDismissingSheet:NO];
                            [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:selectedZUID];
                            if(self->_success){
                                [self dismissWithSuccessHavingAccessToken:token];
                            }else if(self->_switchSuccess){
                                [self dismissWithSuccessHavingAccessToken:token andSwitch:YES];
                            }
                        } andFailure:^(NSError *error) {
                            [self hideLoading];
                            [self shouldBlockDismissingSheet:NO];
                            if (error.code == k_SSOOneAuthAccountBlockedState) {
                                //OneAuth password changed
                                [[ZIAMUtil sharedUtil] verifySSOPasswordForZUID:selectedZUID success:^(NSString *token) {
                                    [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:selectedZUID];
                                    if(self->_success){
                                        [self dismissWithSuccessHavingAccessToken:token];
                                    }else if(self->_switchSuccess){
                                        [self dismissWithSuccessHavingAccessToken:token andSwitch:YES];
                                    }
                                } failure:^(NSError *verifyPasswordError) {
                                    [self dismissWithError:verifyPasswordError];
                                }];
                            } else if ([[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
                                //OneAuth session terminated from browser/change password
                                [self showSessionTerminatedAlert];
                            } else {
                                [self dismissWithError:error];
                            }
                        }];
                    } else if (error == SSOLocalAuthenticationStatusFallback){
                        NSString * email = [userdetailsDict objectForKey:@"email"];
                        [ZIAMUtil sharedUtil]->loginID = email;
                        [self showLoginScreen];
                    }
                    
                }];
                
            } else {
                [self showLoading];
                [self shouldBlockDismissingSheet:YES];
                [[ZIAMUtil sharedUtil]getForceFetchOAuthTokenForZUID:selectedZUID success:^(NSString *token) {
                    [self hideLoading];
                    [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:selectedZUID];
                    if(self->_success){
                        [self dismissWithSuccessHavingAccessToken:token];
                    }else if(self->_switchSuccess){
                        [self dismissWithSuccessHavingAccessToken:token andSwitch:YES];
                    }
                } andFailure:^(NSError *error) {
                    [self hideLoading];
                    [self shouldBlockDismissingSheet:NO];
                    if ([[error localizedDescription] isEqualToString:@"invalid_mobile_code"]) {
                        [self showSessionTerminatedAlert];
                    } else {
                        [self dismissWithError:error];
                    }
                }];
            }
            
        } else {
            [self tappedAddAccount];
        }
        
    }
    

}

-(BOOL)canAllowSSOForUser:(NSString *)zuid {
    BOOL isApplockEnabled = [[ZIAMUtil sharedUtil] getOneAuthApplockStatus];
//    BOOL isMFASetupCompleted = [[ZIAMUtil sharedUtil] getIsMFASetupCompletedForUser:zuid];
    
//    return (isMFASetupCompleted && isApplockEnabled);
    return isApplockEnabled;
}

-(void)shouldBlockDismissingSheet:(BOOL)shouldBlock {
    if (@available(iOS 13.0, *)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.modalInPresentation = shouldBlock;
        });
    }
}

-(void) showLoginScreen {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            [[ZIAMUtil sharedUtil] checkRootedDeviceAndPresentSSOSFSafariViewControllerWithSuccess:self->_success andFailure:self->_failure switchSuccess:self->_switchSuccess];
        }];
    });
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    if (self.isManageAccount) {
        if(indexPath.row < arrayUsers.count){
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* isSSO = [[arrayUsers objectAtIndex:indexPath.row] valueForKey:@"sso"];
    if (isSSO) {
        if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthMDMURLScheme]) {
            return [NSString stringWithFormat:@"%@ OneAuth",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }else if ([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoMDMURLScheme] ){
            return [NSString stringWithFormat:@"%@ MyZoho",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }else{
            return [NSString stringWithFormat:@"%@ App",[[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.open" Comment:@"Open"]];
        }
        
    }else{
        return [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.remove" Comment:@"Remove"];
    }
    
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString* isSSO = [[arrayUsers objectAtIndex:indexPath.row] valueForKey:@"sso"];

        if(isSSO){
            //Open OneAuth
            if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kOneAuthMDMURLScheme] ){
                [[ZIAMUtil sharedUtil] isOneAuthInstalled:^(BOOL isValid) {
                    if(isValid){
                        [ZIAMUtil sharedUtil]->setFailureBlock = self->_failure;
                        [ZIAMUtil sharedUtil]->setSuccessBlock = self->_success;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString * urlString = [NSString stringWithFormat:@"%@?purpose=signout&scheme=%@&appname=%@",[ZIAMUtil sharedUtil]->IAMURLScheme,[ZIAMUtil sharedUtil]->UrlScheme,[ZIAMUtil sharedUtil]->AppName];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:NULL];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString * urlString = @"https://itunes.apple.com/us/app/zoho-oneauth/id1142928979?mt=8";
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:NULL];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }
                }];
            }else if([[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoURLScheme] || [[ZIAMUtil sharedUtil]->IAMURLScheme isEqualToString:kMyZohoMDMURLScheme] ){
                [[ZIAMUtil sharedUtil] isMyZohoInstalled:^(BOOL isValid) {
                    if(isValid){
                        [ZIAMUtil sharedUtil]->setFailureBlock = self->_failure;
                        [ZIAMUtil sharedUtil]->setSuccessBlock = self->_success;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString * urlString = [NSString stringWithFormat:@"%@?purpose=signout&scheme=%@&appname=%@",[ZIAMUtil sharedUtil]->IAMURLScheme,[ZIAMUtil sharedUtil]->UrlScheme,[ZIAMUtil sharedUtil]->AppName];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:NULL];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //To Do: Add MyZoho AppStore URL
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""] options:@{} completionHandler:NULL];
                        });
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:NO completion:nil];
                        });
                    }
                }];
            }
           
            
        }else{
            //add code here for when you hit delete
            NSString *ZUID = [[arrayUsers objectAtIndex:indexPath.row] valueForKey:@"zuid"];
            [self revokeRefreshToken:[[ZIAMUtil sharedUtil] getRefreshTokenFromKeychainForZUID:ZUID] forZUID:ZUID forRowAtIndexPath:indexPath];
        }
    }
}

- (void)deleteUserInKeychain:(NSDictionary*)userDetails {
    
    NSString *zuid = [userDetails valueForKey:@"zuid"];
    NSData* user_details_data = [[ZIAMUtil sharedUtil] getUserDetailsDataFromKeychain];
    NSMutableDictionary*  userDetailsDictionary;
    if(user_details_data){
        userDetailsDictionary = (NSMutableDictionary *) [NSKeyedUnarchiver unarchiveObjectWithData:user_details_data];
        [userDetailsDictionary removeObjectForKey:zuid];
        NSData *userDetailsdictionaryRep = [NSKeyedArchiver archivedDataWithRootObject:userDetailsDictionary];
        [[ZIAMUtil sharedUtil] setUserDetailsDataInKeychain:userDetailsdictionaryRep];

    }
    
    if([userDetails valueForKey:@"isCurrentUser"]){
        
        [[ZIAMUtil sharedUtil] removeCurrentUserZUIDFromKeychain];
        //TODO: why setting oneauth user as current user ?
//        NSString *U0_ZUID;
//        if(!self->_isHavingSSOAccount){
//            U0_ZUID = [[ZIAMUtil sharedUtil] getZUIDFromKeyChainForIndex:1];
//        }else{
//            U0_ZUID = [[ZIAMUtil sharedUtil] getSSOZUIDFromSharedKeychain];
//        }
//        
//        if(U0_ZUID!= nil){
//            [[ZIAMUtil sharedUtil] setCurrentUserZUIDInKeychain:U0_ZUID];
//        }else{
            int errorCode = k_SSONoUsersFound;
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setValue:@"No Users Found" forKey:NSLocalizedDescriptionKey];
            NSError *returnError = [NSError errorWithDomain:kSSOKitErrorDomain code:errorCode userInfo:userInfo];
            [self dismissViewControllerAnimated:YES completion:^{
                self.failure(returnError);
            }];
            return;
        //}
        
    }
}

-(void)revokeRefreshToken:(NSString *)refreshToken forZUID:(NSString *)zuid forRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableAccounts reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    UITableViewCell *cell = [tableAccounts cellForRowAtIndexPath:indexPath];
    UIView *cellblockingView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    // background view that blocks the taps from the user when network is not available
    cellblockingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    cellblockingView.hidden = YES;
    
    UIActivityIndicatorView *cellactivityView = [[UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    cellactivityView.color = [UIColor whiteColor];
    
    
    //cellactivityView.center = CGPointMake(cell.contentView.frame.size.width+20,cell.contentView.center.y);
    cellactivityView.center = CGPointMake(cell.contentView.center.x,cell.contentView.center.y);
    [cellblockingView addSubview:cellactivityView];
    
    UILabel *errormsgLabel = [[UILabel alloc]initWithFrame:cell.contentView.frame];
    errormsgLabel.textAlignment = NSTextAlignmentCenter;
    errormsgLabel.textColor = [UIColor whiteColor];
    errormsgLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    
    
    
    
    
    [cellblockingView addSubview:errormsgLabel];
    [cell.contentView addSubview:cellblockingView];
    
    //URL
    NSString *urlString = [NSString stringWithFormat:@"%@%@",[[ZIAMUtil sharedUtil] getAccountsURLFromKeychainForZUID:zuid],kSSORevoke_URL];
    
    //Add Parameters
    NSMutableDictionary *paramsAndHeaders = [[NSMutableDictionary alloc] init];
    [paramsAndHeaders setValue:[NSString stringWithFormat:@"%@",refreshToken] forKey:@"token"];
    
    //Add headers
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
   
    [paramsAndHeaders setValue:headers forKey:SSO_HTTPHeaders];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cellactivityView startAnimating];
    cellblockingView.hidden = NO;
    });
    
    // Request....
    [[SSONetworkManager sharedManager] sendPOSTRequestForURL: urlString
                                         parameters: paramsAndHeaders
                                       successBlock:^(NSDictionary *jsonDict, NSHTTPURLResponse *httpResponse) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                    [cellactivityView stopAnimating];
                                               cellblockingView.hidden = YES;
                                               [self deleteUserInKeychain:[arrayUsers objectAtIndex:indexPath.row]];
                                               [self->arrayUsers removeObjectAtIndex:indexPath.row];
                                               [self->tableAccounts deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                                               [tableAccounts reloadData];
                                               if(self.isManageAccount){
                                                   [self.delegate ssoAccountsListReload];
                                                   [self toggleManageDismiss ];
                                               }
                                               
                                            });
                                        

                                       } failureBlock:^(SSOInternalError errorType, id errorInfo) {
                                           //Request failed
                                           cellblockingView.hidden = NO;
                                           if(errorType == SSO_ERR_CONNECTION_FAILED){
                                               NSError *error = (NSError *)errorInfo;
                                               errormsgLabel.text = error.localizedDescription ;
                                           }else{
                                               errormsgLabel.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.somethingwentwrong" Comment:@"Something went wrong"];
                                           }
                                           
                                           double delayInSeconds = 5.0;
                                           dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                           dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                [cellactivityView stopAnimating];
                                               cellblockingView.hidden = YES;
                                           });
                                           DLog(@"Revoke refresh token error:%ld",(long)errorType);
                                       }];
    
}

-(void)showSessionTerminatedAlert {
    NSString *cancelTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.Cancel" Comment:@"Cancel"];
    NSString *zohoTitle = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.account.session.expired" Comment:@"Session expired"];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:zohoTitle preferredStyle:UIAlertControllerStyleAlert];
    
    // cancel
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction* _Nonnull action) {
        [self showLoginScreen];
        return;
    }];
    [alertVC addAction:actionCancel];
    
    //[[alertVC popoverPresentationController] setSourceView:MainWindow.rootViewController.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertVC animated:YES completion:nil];
    });
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (id<UIViewControllerTransitioningDelegate>)transitionManager {
    return self.transitionManager;
}

- (void)setTransitionManager:(id<UIViewControllerTransitioningDelegate>)transitionManager {
    DLog(@"dsdsd");
}

- (UIScrollView *)dismissalHandlingScrollView {
    return  tableAccounts;
}

@end
#endif
#endif
