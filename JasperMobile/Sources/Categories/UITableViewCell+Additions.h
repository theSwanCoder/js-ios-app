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
//  UITableViewCell+Additions.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>

/**
 Provides methods for setting top and bottom separators for table view cell
 
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface UITableViewCell (Additions)

- (void)setTopSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style;
- (void)setBottomSeparatorWithHeight:(CGFloat)height color:(UIColor *)color tableViewStyle:(UITableViewStyle)style;


- (UIToolbar *)toolbarForInputAccessoryView;

- (NSArray *)inputAccessoryViewToolbarItems;

- (NSArray *)rightInputAccessoryViewToolbarItems;

- (NSArray *)leftInputAccessoryViewToolbarItems;

- (void)doneButtonTapped:(id)sender;
@end
