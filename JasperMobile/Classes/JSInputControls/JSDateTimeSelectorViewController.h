/*
 * JasperMobile for iOS
 * Copyright (C) 2005 - 2012 Jaspersoft Corporation. All rights reserved.
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
//  JSDateTimeSelectorViewController.h
//  Jaspersoft Corporation
//

#import <Foundation/Foundation.h>
#import "JSDatePickerView.h"

@interface JSDateTimeSelectorViewController : UITableViewController<JSDatePickerViewControllerDelegate>  {
	NSDate *selectedValue;
	NSArray *predefinedDates;
	NSArray *predefinedDateLabels;
	JSDatePickerView* datePickerView;
}

@property(nonatomic, assign) BOOL dateOnly;
@property(nonatomic, assign) BOOL mandatory;
@property(nonatomic, retain) id selectionDelegate;
@property(nonatomic, retain) NSDate *selectedValue;

// Date picker view functions
- (void)dateChanged:(NSDate *)newDate tag:(NSInteger)tag;
- (BOOL)isDateEqual:(NSDate *)dt1 to:(NSDate *)dt2;

@end
