/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */

#import "JMScheduleBoolenCell.h"
#import "JMThemesManager.h"

@implementation JMScheduleBoolenCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.uiSwitch.onTintColor = [[JMThemesManager sharedManager] saveReportSaveReportButtonBackgroundColor];
}

- (IBAction)switchChangedValue:(UISwitch *)sender
{
    if ([self.delegate respondsToSelector:@selector(scheduleBoolenCell:didChangeValue:)]) {
        [self.delegate scheduleBoolenCell:self didChangeValue:self.uiSwitch.isOn];
    }
}

@end
