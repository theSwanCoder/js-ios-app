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

@implementation JMMenuItemTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [JMFont menuItemTitleFont];
}

#pragma mark - LifeCycle
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    // selected color
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.frame = self.bounds;
    UIColor *darkOp = [UIColor colorWithRed:22/255.f green:23/255.f blue:27/255.f alpha:1.0f];
    UIColor *lightOp = [UIColor colorWithRed:22/255.f green:23/255.f blue:27/255.f alpha:0.0f];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(id)darkOp.CGColor, (id)lightOp.CGColor];
    gradient.frame = selectedBackgroundView.frame;
    [gradient setStartPoint:CGPointMake(0.0, 0.5)];
    [gradient setEndPoint:CGPointMake(1.0, 0.5)];
    [selectedBackgroundView.layer insertSublayer:gradient atIndex:0];
    
    //selectedBackgroundView.backgroundColor = [UIColor colorWithRed:22/255.f green:23/255.f blue:27/255.f alpha:1];
    self.selectedBackgroundView = selectedBackgroundView;
}

-(void)setSelected:(BOOL)selected
{
    super.selected = selected;
    if (selected) {
        self.textLabel.textColor = [UIColor whiteColor];
        self.imageView.image = self.menuItem.selectedItemIcon;
    } else {
        self.textLabel.textColor = [UIColor grayColor];
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
