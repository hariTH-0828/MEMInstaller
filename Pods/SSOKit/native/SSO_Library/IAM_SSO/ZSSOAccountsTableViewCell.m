//
//  ZSSOAccountsTableViewCell.m
//  SSOKit
//
//  Created by Abinaya Ravichandran on 22/03/21.
//
#if !TARGET_OS_WATCH

#import "ZSSOAccountsTableViewCell.h"


@implementation ZSSOAccountsTableViewCell {
    UILabel *labelUserName, *labelUserEmail;
    UIImageView *imageUser, *logoImage;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        labelUserName = [[UILabel alloc] init];
        labelUserEmail = [[UILabel alloc] init];
        imageUser = [[UIImageView alloc] init];
        logoImage = [[UIImageView alloc] init];
        labelUserName.numberOfLines = 0;
        labelUserEmail.numberOfLines = 0;
        labelUserName.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
        labelUserEmail.textColor = [UIColor grayColor];
        labelUserEmail.font = [UIFont fontWithName:@"Helvetica" size:14];


        [self.contentView addSubview:labelUserName];
        [self.contentView addSubview:labelUserEmail];
        [self.contentView addSubview:imageUser];
        [self.contentView addSubview:logoImage];

        [imageUser setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelUserName setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelUserEmail setTranslatesAutoresizingMaskIntoConstraints:NO];
        [logoImage setTranslatesAutoresizingMaskIntoConstraints:NO];

        
        NSLayoutConstraint* imageTop = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:16];
        imageTop.identifier = @"imageTop";

//        NSLayoutConstraint* imageBottom = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
//        imageBottom.identifier = @"imageBottom";

        NSLayoutConstraint* imageWidth = [NSLayoutConstraint constraintWithItem:imageUser
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:44];
        NSLayoutConstraint* imageHeight = [NSLayoutConstraint constraintWithItem:imageUser
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                               constant:44];
        imageHeight.identifier = @"imageHeight";

        imageWidth.identifier = @"imageWidth";
//
//        NSLayoutConstraint* imageRatio = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
//        imageRatio.identifier = @"imageRatio";

        NSLayoutConstraint* imageLeading = [NSLayoutConstraint constraintWithItem:imageUser attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1 constant:16];
        imageLeading.identifier = @"imageLeading";
        
        NSLayoutConstraint* labelLeading = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeTrailing multiplier:1 constant:16];
        labelLeading.identifier = @"labelLeading";
        
        NSLayoutConstraint* labelTrailing = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        labelTrailing.identifier = @"labelTrailing";

        NSLayoutConstraint* labelTop = [NSLayoutConstraint constraintWithItem:labelUserName attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        labelTop.identifier = @"labelTop";
        
        NSLayoutConstraint* labelEmailTop = [NSLayoutConstraint constraintWithItem:labelUserEmail attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labelUserName attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        labelEmailTop.identifier = @"labelEmailTop";
        
        NSLayoutConstraint* labelEmailBottom = [NSLayoutConstraint constraintWithItem:labelUserEmail attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:-16];
        labelEmailBottom.identifier = @"labelEmailBottom";

        NSLayoutConstraint* labelEmailLeading = [NSLayoutConstraint constraintWithItem:labelUserEmail
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:labelUserName
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1
                                                                              constant:0];
        labelEmailLeading.identifier = @"labelEmailLeading";

        NSLayoutConstraint* labelEmailTrailing = [NSLayoutConstraint constraintWithItem:labelUserEmail attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:labelUserName attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        labelEmailTrailing.identifier = @"labelEmailTrailing";




     
        
        
        imageUser.image = [UIImage imageNamed:@"ssokit_avatar" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        
        UIImage *oneAuthLogo = [UIImage imageNamed:@"ssokit_oneauth" inBundle:[NSBundle bundleWithURL:[[[NSBundle bundleForClass:self.classForCoder] resourceURL] URLByAppendingPathComponent:@"SSOKitBundle.bundle"]] compatibleWithTraitCollection:nil];
        logoImage.image = oneAuthLogo;
        
        NSLayoutConstraint* logoTrailing = [NSLayoutConstraint constraintWithItem:logoImage attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
        NSLayoutConstraint* logoBottom = [NSLayoutConstraint constraintWithItem:logoImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:imageUser attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

        NSLayoutConstraint* logoWidth = [NSLayoutConstraint constraintWithItem:logoImage
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:16];
        NSLayoutConstraint* logoHeight = [NSLayoutConstraint constraintWithItem:logoImage
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:16];

        [NSLayoutConstraint activateConstraints:@[imageTop,
                                                  imageWidth,
                                                  imageHeight,
                                                  imageLeading,
                                                  
                                                  logoBottom,
                                                  logoTrailing,
                                                  logoHeight,
                                                  logoWidth,
                                                  
                                                  labelTop,
                                                  labelLeading,
                                                  labelTrailing,
                                                  
                                                  labelEmailTop,
                                                  labelEmailBottom,
                                                  labelEmailLeading,
                                                  labelEmailTrailing]];
        
    }
    return self;
}

-(void)loadUser:(NSString*)userName email:(NSString*)email image:(UIImage*)image encircle:(BOOL)encircle {
    labelUserName.text = userName;
    labelUserEmail.text = email;
    imageUser.image = image;
    
    [imageUser setNeedsLayout];
    [imageUser layoutIfNeeded];
    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;
    
    if (encircle) {
        [logoImage setNeedsLayout];
        [logoImage layoutIfNeeded];
        logoImage.layer.cornerRadius = logoImage.frame.size.width/2;
        [logoImage setHidden:NO];
        logoImage.layer.masksToBounds = YES;
        imageUser.layer.borderWidth = 2;
        imageUser.layer.borderColor = [UIColor colorWithRed:61.0/255.0 green:143.0/255.0 blue:213.0/255.0 alpha:1].CGColor;
    } else {
        [logoImage setHidden:YES];
    }
   

    
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end

#endif
