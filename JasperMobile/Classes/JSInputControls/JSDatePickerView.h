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
//  JSDatePickerView.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>

@protocol JSDatePickerViewControllerDelegate
@optional
- (void)dateChanged:(NSDate *)date tag:(NSInteger) tag;

@required
- (UITableView *)tableView;
- (UIView *)view;
@end

@interface JSDatePickerView : UIView {
@private
	id<JSDatePickerViewControllerDelegate> delegate;
	UIView *datePickerView;
	UIDatePicker *datePicker;
	UIToolbar *pickerToolbar;
	NSInteger parentOldOffset;
	NSDate *date;
}

@property (nonatomic) id<JSDatePickerViewControllerDelegate> delegate;
@property (nonatomic, retain) UIView *datePickerView;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic) UIDatePickerMode pickerMode;
@property (nonatomic) NSInteger tag;

- (void)slideDownDidStop;
- (void)showDatePicker:(BOOL)show atLocation:(CGFloat)loc;
- (void)showDatePicker:(BOOL)show atLocation:(CGFloat)loc withDate:(NSDate *)dt;


@end
