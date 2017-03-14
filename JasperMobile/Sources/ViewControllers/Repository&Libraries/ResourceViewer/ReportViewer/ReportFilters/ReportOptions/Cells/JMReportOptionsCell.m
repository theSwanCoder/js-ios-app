/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMReportOptionsCell.h"
#import "JMThemesManager.h"

@implementation JMReportOptionsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Make sure the contentView does a layout pass here so that its subviews have their frames set, which we
    // need to use to set the preferredMaxLayoutWidth below.
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    // Set the preferredMaxLayoutWidth of the mutli-line bodyLabel based on the evaluated width of the label's frame,
    // as this will allow the text to wrap correctly, and as a result allow the label to take on the correct height.
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

@end
