//
//  ZSSOAddAccountTableCell.m
//  SSOKit
//
//  Created by Abinaya Ravichandran on 19/01/22.
//
#if !SSO_APP__EXTENSION_API_ONLY && !TARGET_OS_WATCH

#import "ZSSOAddAccountTableCell.h"
#import "ZSSOAddAccountView.h"
#import "UIView+ZIAMView.h"
@implementation ZSSOAddAccountTableCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        ZSSOAddAccountView *addLabelsView = [[ZSSOAddAccountView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:addLabelsView];
        
        [addLabelsView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [addLabelsView pinToSuperView:0];
    }
    return  self;
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
