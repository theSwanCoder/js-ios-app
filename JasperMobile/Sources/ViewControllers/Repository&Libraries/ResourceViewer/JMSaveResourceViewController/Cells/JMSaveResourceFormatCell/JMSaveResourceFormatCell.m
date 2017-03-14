/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSaveResourceFormatCell.h"

@implementation JMSaveResourceFormatCell
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
}
@end
