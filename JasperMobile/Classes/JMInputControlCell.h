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
//  JMInputControlCell.h
//  Jaspersoft Corporation
//

#import <UIKit/UIKit.h>
#import <jaspersoft-sdk/JaspersoftSDK.h>
#import "JMReportOptionsTableViewController.h"

/**
 @author Vlad Zavadskii vzavadskii@jaspersoft.com
 @since 1.6
 */
@interface JMInputControlCell : UITableViewCell {
@protected
    CGFloat baseHeight;
}

@property (nonatomic, strong) JSInputControlWrapper *inputControlWrapper;
@property (nonatomic, strong) JSInputControlDescriptor *inputControlDescriptor;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, readonly) BOOL isMandatory;
@property (nonatomic, weak) UITableViewController <JMInputControlsHolder> *delegate;

/**
 Contains value for the Input Control. Can be NSString, NSDictionary or 
 NSArray (plus mutable) type
 */
@property (nonatomic, strong) id value;

- (UILabel *)label;
- (void)clearData;
- (CGFloat)height;
- (BOOL)dismissError;
- (void)disableCell;

@end
