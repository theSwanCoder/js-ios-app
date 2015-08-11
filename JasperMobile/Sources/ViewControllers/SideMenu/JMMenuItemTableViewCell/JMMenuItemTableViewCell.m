/*
 * TIBCO JasperMobile for iOS
 * Copyright © 2005-2014 TIBCO Software, Inc. All rights reserved.
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
//  JMMenuItemTableViewCell.h
//  TIBCO JasperMobile
//

#import "JMMenuItemTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+RGBComponent.h"
@implementation JMMenuItemTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [[JMThemesManager sharedManager] menuItemTitleFont];
}

#pragma mark - LifeCycle
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // selected color
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.frame = self.bounds;
    UIColor *selectedMenuColor = [UIColor сolorFromColor:[[JMThemesManager sharedManager] menuViewBackgroundColor] differents:0.25 increase:YES];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)[selectedMenuColor colorWithAlphaComponent:1.0f].CGColor, (id)[selectedMenuColor colorWithAlphaComponent:0.0f].CGColor];
    gradient.frame = selectedBackgroundView.frame;
    [gradient setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient setEndPoint:CGPointMake(1.0, 0.5)];
    [selectedBackgroundView.layer insertSublayer:gradient atIndex:0];
    
    self.selectedBackgroundView = selectedBackgroundView;
}

-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    if (selected) {
        self.textLabel.textColor = [[JMThemesManager sharedManager] menuViewSelectedTextColor];
        self.imageView.image = self.menuItem.selectedItemIcon;
    } else {
        self.textLabel.textColor = [[JMThemesManager sharedManager] menuViewTextColor];
        self.imageView.image = self.menuItem.itemIcon;
    }
}

#pragma mark - Setters
- (void)setMenuItem:(JMMenuItem *)menuItem
{
    _menuItem = menuItem;
    self.textLabel.text = menuItem.itemTitle;
    self.imageView.image = menuItem.itemIcon;
}

@end
