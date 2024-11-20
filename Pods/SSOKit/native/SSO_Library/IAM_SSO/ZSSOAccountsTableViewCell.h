//
//  ZSSOAccountsTableViewCell.h
//  SSOKit
//
//  Created by Abinaya Ravichandran on 22/03/21.
//
#if !TARGET_OS_WATCH


#import <UIKit/UIKit.h>
@interface ZSSOAccountsTableViewCell : UITableViewCell
-(void)loadUser:(NSString*)userName email:(NSString*)email image:(UIImage*)image encircle:(BOOL)encircle ;
@end
#endif
