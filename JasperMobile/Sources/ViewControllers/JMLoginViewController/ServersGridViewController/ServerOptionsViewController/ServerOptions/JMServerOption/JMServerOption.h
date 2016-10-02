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
//  JMServerOption.h
//  TIBCO JasperMobile
//

/**
 @author Alexey Gubarev ogubarie@tibco.com
 @since 1.9
 */

@import UIKit;

@interface JMServerOption : NSObject

@property (nonatomic, strong, readonly) NSString *titleString;
@property (nonatomic, strong) NSString *errorString;
@property (nonatomic, strong, readonly) NSString *elementAccessibilityID;
@property (nonatomic, strong) id        optionValue;
@property (nonatomic, strong, readonly) NSString *cellIdentifier;
@property (nonatomic, assign, readonly) BOOL      editable;       // By default YES
@property (nonatomic, assign, readonly) BOOL      mandatory;      // By default YES

- (instancetype)initWithTitle:(NSString *)title
                  optionValue:(id)optionValue
               cellIdentifier:(NSString *)cellIdentifier
                     editable:(BOOL)editable
       elementAccessibilityID:(NSString *)elementAccessibilityID
                    mandatory:(BOOL)mandatory;

+ (instancetype)optionWithTitle:(NSString *)title
                    optionValue:(id)optionValue
                 cellIdentifier:(NSString *)cellIdentifier
                       editable:(BOOL)editable
         elementAccessibilityID:(NSString *)elementAccessibilityID
                      mandatory:(BOOL)mandatory;
@end
