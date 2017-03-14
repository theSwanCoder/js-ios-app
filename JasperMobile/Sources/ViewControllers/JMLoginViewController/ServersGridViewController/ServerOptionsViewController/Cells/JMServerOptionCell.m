/*
 * Copyright ©  2014 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMServerOptionCell.h"
#import "JMThemesManager.h"

@interface JMServerOptionCell ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *errorLabel;
@end

@implementation JMServerOptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    
    self.errorLabel.font = [[JMThemesManager sharedManager] tableViewCellErrorFont];
    self.errorLabel.textColor = [[JMThemesManager sharedManager] tableViewCellErrorColor];
}

- (void)setServerOption:(JMServerOption *)serverOption
{
    _serverOption = serverOption;
    
    self.titleLabel.text = serverOption.titleString;
    [self updateDisplayingOfErrorMessage];
}

- (void) updateDisplayingOfErrorMessage
{
    self.errorLabel.text = self.serverOption.errorString;
    [UIView beginAnimations:nil context:nil];
    self.errorLabel.alpha = (self.serverOption.errorString.length == 0) ? 0 : 1;
    [UIView commitAnimations];
    [self.delegate reloadTableViewCell:self];
}


@end
