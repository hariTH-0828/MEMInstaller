//
//  ZSSOAddAccountView.m
//  SSOKit
//
//  Created by Abinaya Ravichandran on 06/10/21.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import "ZSSOAddAccountView.h"
#import "ZIAMHelpers.h"

@implementation ZSSOAddAccountView {
    UILabel *labelUserName;
    UIImageView *imageUser;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        labelUserName = [[UILabel alloc] init];
        imageUser = [[UIImageView alloc] init];
        labelUserName.numberOfLines = 0;
        labelUserName.font = [UIFont fontWithName:@"Helvetica" size:18];

        [self addSubview:labelUserName];
        [self addSubview:imageUser];
        [imageUser setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelUserName setTranslatesAutoresizingMaskIntoConstraints:NO];

        labelUserName.text = [[ZIAMUtil sharedUtil] GetLocalizedString:@"zohoSSO.addaccount" Comment:@"Add Account"];
        
        if (@available(iOS 12.0, *)) {
            if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                imageUser.image = [UIImage imageNamed:@"ssokit_add_account_dark" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
            } else {
                imageUser.image = [UIImage imageNamed:@"ssokit_add_account" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
                
            }
        } else {
            // Fallback on earlier versions
            
            imageUser.image = [UIImage imageNamed:@"ssokit_add_account" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];

        }
        
        
            NSLayoutConstraint* imageWidth = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:48];
            NSLayoutConstraint* imageRatio = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeHeight multiplier:1.2 constant:0];
            NSLayoutConstraint* imageLeading = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:16];
//           NSLayoutConstraint* imageCenterY = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
        NSLayoutConstraint* imageTop = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:16];

        NSLayoutConstraint* imageBottom = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-16];

        
            NSLayoutConstraint* labelLeading = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeTrailing multiplier:1 constant:16];
            NSLayoutConstraint* labelTrailing = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:15];
            NSLayoutConstraint* labelCenterY = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        
            
            
            imageLeading.identifier = @"imageLeading";
            labelCenterY.identifier = @"labelCenterY";
//            imageCenterY.identifier = @"imageCenterY";
            labelLeading.identifier = @"labelLeading";
            labelTrailing.identifier = @"labelTrailing";
            imageRatio.identifier = @"imageRatio";
            
            [NSLayoutConstraint activateConstraints:@[imageTop, imageBottom, imageLeading, imageWidth, imageRatio, labelCenterY, labelLeading,labelTrailing]];

        
    }
    return self;
}
@end
#endif
