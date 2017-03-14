/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMSaveResourcePagesCell.h"

@interface JMSaveResourcePagesCell()
@property (nonatomic, weak) IBOutlet UISwitch *pagesTypeSwitch;
@end

@implementation JMSaveResourcePagesCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.font = [[JMThemesManager sharedManager] tableViewCellTitleFont];
    self.titleLabel.textColor = [[JMThemesManager sharedManager] tableViewCellTitleTextColor];
    self.titleLabel.text = JMLocalizedString(@"resource_viewer_save_pages_all");
    self.pagesTypeSwitch.onTintColor = [[JMThemesManager sharedManager] saveReportSaveReportButtonBackgroundColor];
}

#pragma mark - Private API
-(void)setPagesType:(JMSaveResourcePagesType)pagesType{
    _pagesType = pagesType;
    self.pagesTypeSwitch.on = (pagesType == JMSaveResourcePagesType_All);
}

#pragma mark - Actions
- (IBAction)switchValueChanged:(id)sender
{
    self.pagesType = self.pagesTypeSwitch.on ? JMSaveResourcePagesType_All : JMSaveResourcePagesType_Range;
    [self.cellDelegate pagesCell:self didChangedPagesType:self.pagesType];
}
@end
