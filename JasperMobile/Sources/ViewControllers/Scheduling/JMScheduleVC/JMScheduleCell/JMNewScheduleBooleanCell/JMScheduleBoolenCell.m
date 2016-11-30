/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2016 TIBCO Software, Inc. All rights reserved.
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
//  JMScheduleBoolenCell.m
//  TIBCO JasperMobile
//
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