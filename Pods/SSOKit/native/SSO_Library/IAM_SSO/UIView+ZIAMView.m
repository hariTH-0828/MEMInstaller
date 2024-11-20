//
//  UIView+ZIAMView.m
//  IAM_SSO
//
//  Created by Abinaya Ravichandran on 05/07/22.
//  Copyright © 2022 Dhanasekar K. All rights reserved.
//

#import "UIView+ZIAMView.h"
#if !TARGET_OS_WATCH
@implementation UIView (ZIAMView)

- (void)pinToSuperView:(CGFloat)constant {
    
    [self pinTopToSuperView:constant];
    [self pinTrailingToSuperView:constant];
    [self pinLeadingToSuperView:constant];
    [self pinBottomToSuperView:constant];

}

- (void)setWidthConstraint:(CGFloat)constant  {
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:constant];
    [[self superview] addConstraints:@[width]];
}
- (void)pinTopTo:(UIView*)nextView constant:(CGFloat)constant  {
    NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nextView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:constant];
    [[self superview] addConstraints:@[top]];
}

- (void)pinTopToSuperView:(CGFloat)constant  {
    NSLayoutConstraint* top = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:[self superview]
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:constant];
    [[self superview] addConstraints:@[top]];
}

- (void)pinTopToSuperViewSafeArea:(CGFloat)constant  {

    if (@available(iOS 11.0, *)) {
        NSLayoutConstraint *top = [[self topAnchor] constraintEqualToAnchor:[self superview].safeAreaLayoutGuide.topAnchor constant:constant];
        
        [[self superview] addConstraints:@[top]];
    } else {
        // Fallback on earlier versions
        [self pinTopToSuperView:constant];
    }
   
}


- (void)pinTrailingToSuperView:(CGFloat)constant  {
    NSLayoutConstraint* trailing = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:[self superview]
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:constant];
    [[self superview] addConstraints:@[trailing]];
}


- (void)pinLeadingToSuperView:(CGFloat)constant {
    NSLayoutConstraint* leading = [NSLayoutConstraint constraintWithItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:[self superview]
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:constant];
    [[self superview] addConstraints:@[leading]];
}

- (void)pinBottomToSuperView:(CGFloat)constant  {
    NSLayoutConstraint* bottom = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:[self superview]
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:constant];
    [[self superview] addConstraints:@[bottom]];
}

- (void)pinBottomToSuperViewSafeArea:(CGFloat)constant  {

    if (@available(iOS 11.0, *)) {
        NSLayoutConstraint *top = [[self bottomAnchor] constraintEqualToAnchor:[self superview].safeAreaLayoutGuide.bottomAnchor constant:constant];
        
        [[self superview] addConstraints:@[top]];
    } else {
        // Fallback on earlier versions
        [self pinBottomToSuperView:constant];
    }
   
}

-(void)pinCenterToSuperView {
    
    NSLayoutConstraint* centerX = [NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeCenterX
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.superview
                                   attribute:NSLayoutAttributeCenterX
                                   multiplier:1
                                   constant:0];
    NSLayoutConstraint* centerY = [NSLayoutConstraint
                                   constraintWithItem:self
                                   attribute:NSLayoutAttributeCenterY
                                   relatedBy:NSLayoutRelationEqual
                                   toItem:self.superview
                                   attribute:NSLayoutAttributeCenterY
                                   multiplier:1
                                   constant:0];
    [self.superview addConstraints:@[centerX, centerY]];
}
- (void)setHeightConstraint:(CGFloat)constant {
    NSLayoutConstraint* width = [NSLayoutConstraint constraintWithItem:self
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:constant];
    [[self superview] addConstraints:@[width]];
}
@end
#endif
