/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2015 TIBCO Software, Inc. All rights reserved.
 * http://community.jaspersoft.com/project/jaspermobile-ios
 *
 * Unless you have purchased a commercial license agreement from Jaspersoft,
 * the following license terms apply:
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/lgpl>.
 */


//
//  JMExternalWindowDashboardControlsTableViewCell.m
//  TIBCO JasperMobile
//

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
            [sender setTitle:JMCustomLocalizedString(@"min_value_title", nil) 
                    forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsTableViewCellDidMaximize:)]) {
                [self.delegate externalWindowDashboardControlsTableViewCellDidMaximize:self];
            }
            break;
        }
        case MaximazedButtonStateMinimized: {
            self.maximazedButtonState = MaximazedButtonStateMaximazed;
            [sender setTitle:JMCustomLocalizedString(@"max_value_title", nil) 
                    forState:UIControlStateNormal];
            if ([self.delegate respondsToSelector:@selector(externalWindowDashboardControlsTableViewCellDidMinimize:)]) {
                [self.delegate externalWindowDashboardControlsTableViewCellDidMinimize:self];
            }
            break;
        }
    }
}


@end
