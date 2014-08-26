/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2014 Jaspersoft Corporation. All rights reserved.
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
//  UITableViewCell+SetSeparators.h
//  Jaspersoft Corporation
//

#import "UITableViewCell+SetSeparators.h"
#import "JMUtils.h"

@implementation UITableViewCell (SetSeparators)

- (void)setTopSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style
{
    if (![self isSeparatorNeeded:style]) return;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, height)];
    separator.backgroundColor = color;
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:separator];
}

- (void)setBottomSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style
{
    if (![self isSeparatorNeeded:style]) return;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - height, self.frame.size.width, height)];
    separator.backgroundColor = color;
    separator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:separator];
}

#pragma mark - Private

- (BOOL)isSeparatorNeeded:(UITableViewStyle)style
{
    return style != UITableViewStyleGrouped;
}

@end
