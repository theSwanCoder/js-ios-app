/*
 * Copyright ©  2015 - 2017. TIBCO Software Inc. All Rights Reserved. Confidential & Proprietary.
 */


#import "JMExternalWindowDashboardControlsTableViewCell.h"
#import "JMLocalization.h"

typedef NS_ENUM(NSInteger, MaximazedButtonState) {
    MaximazedButtonStateMaximazed,
    MaximazedButtonStateMinimized,
};

@interface JMExternalWindowDashboardControlsTableViewCell()
@property (nonatomic, assign) MaximazedButtonState maximazedButtonState;
@end

@implementation JMExternalWindowDashboardControlsTableViewCell

#pragma mark - Actions
- (IBAction)maximizeAction:(UIButton *)sender
{
    switch (self.maximazedButtonState) {
        case MaximazedButtonStateMaximazed: {
            self.maximazedButtonState = MaximazedButtonStateMinimized;
            [sender setTitle:JMLocalizedString(@"min_value_title")
                    forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsTableViewCellDidMaximize:)]) {
                [self.delegate externalWindowDashboardControlsTableViewCellDidMaximize:self];
            }
            break;
        }
        case MaximazedButtonStateMinimized: {
            self.maximazedButtonState = MaximazedButtonStateMaximazed;
            [sender setTitle:JMLocalizedString(@"max_value_title") 
                    forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsTableViewCellDidMinimize:)]) {
                [self.delegate externalWindowDashboardControlsTableViewCellDidMinimize:self];
            }
            break;
        }
    }
}


@end
