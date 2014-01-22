/*
 * JasperMobile for iOS
 * Copyright (C) 2011 - 2013 Jaspersoft Corporation. All rights reserved.
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
//  UITableViewController+CellRelativeHeight.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface UITableViewController (CellRelativeHeight)

/**
 Calculates height for table view cell according to amount of text inside cell.
 Works only for cell with UITableViewCellStyleValue2, UITableViewCellStyleSubtitle or
 UITableViewCellStyleDefault style
 
 @param cell A table view cell
 @param text A text for "textLabel"
 @param detailText A text for "detailTextLabel"
 @param cellStyle The style of table view cell
 
 @return cell calculated height
 */
- (CGFloat)relativeHeightForTableViewCell:(UITableViewCell *)cell text:(NSString *)text detailText:(NSString *)detailText cellStyle:(UITableViewCellStyle)cellStyle;

/**
 Calculates default height for table view cell
 
 @return cell calculated height
 */
- (CGFloat)defaultHeightForTableViewCell;

@end
